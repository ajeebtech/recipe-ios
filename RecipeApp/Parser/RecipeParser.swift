import Foundation

enum RecipeParser {
    private static let metaKeys: Set<String> = ["title", "yield", "pan", "oven", "prep", "finish", "source"]

    static func parse(_ source: String) -> ParsedRecipe {
        var meta = RecipeMeta()
        var treeLines: [(indent: Int, text: String, line: Int)] = []

        let lines = source.replacingOccurrences(of: "\t", with: "  ").components(separatedBy: "\n")
        for (index, rawLine) in lines.enumerated() {
            let trimmedEnd = rawLine.replacingOccurrences(of: #"\s+$"#, with: "", options: .regularExpression)
            guard !trimmedEnd.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            if trimmedEnd.trimmingCharacters(in: .whitespaces).hasPrefix("#") { continue }

            let indent = trimmedEnd.prefix(while: { $0 == " " }).count
            let text = trimmedEnd.trimmingCharacters(in: .whitespaces)

            if indent == 0, let metaPair = parseMetaLine(text) {
                switch metaPair.key {
                case "prep": if !metaPair.value.isEmpty { meta.prep.append(metaPair.value) }
                case "finish": if !metaPair.value.isEmpty { meta.finish.append(metaPair.value) }
                case "title": meta.title = metaPair.value
                case "yield": meta.yield = metaPair.value
                case "pan": meta.pan = metaPair.value
                case "oven": meta.oven = metaPair.value
                case "source": meta.source = metaPair.value
                default: break
                }
                continue
            }

            treeLines.append((indent, text, index + 1))
        }

        guard !treeLines.isEmpty else {
            return ParsedRecipe(meta: meta, error: "No steps yet — add a final operation, then indent things under it.")
        }

        var stack: [RecipeNode] = []
        var root: RecipeNode?
        var nodeID = 0

        for line in treeLines {
            let node = RecipeNode(id: "n\(nodeID)", raw: line.text, indent: line.indent, line: line.line)
            nodeID += 1

            while let last = stack.last, last.indent >= node.indent {
                stack.removeLast()
            }

            if let parent = stack.last {
                node.parent = parent
                parent.children.append(node)
            } else if root != nil {
                return ParsedRecipe(
                    meta: meta,
                    error: "Line \(line.line): \"\(line.text)\" starts a second recipe. Indent it under the one above."
                )
            } else {
                root = node
            }
            stack.append(node)
        }

        guard let root else {
            return ParsedRecipe(meta: meta, error: "Could not build recipe tree.")
        }

        var leaves: [RecipeNode] = []
        var operations: [RecipeNode] = []
        classify(node: root, leaves: &leaves, operations: &operations)

        let ingredients = leaves.filter { $0.type == .ingredient }
        let references = leaves.filter { $0.type == .reference }

        guard !ingredients.isEmpty else {
            return ParsedRecipe(meta: meta, root: root, error: "No ingredients found — indent at least one ingredient under a step.")
        }
        guard root.type == .operation else {
            return ParsedRecipe(meta: meta, root: root, error: "Add a step — indent your ingredients under an operation such as “mix”.")
        }

        for ref in references {
            let want = ref.name.lowercased().trimmingCharacters(in: .whitespaces)
            guard !want.isEmpty else {
                return ParsedRecipe(meta: meta, root: root, error: "Line \(ref.line): a “>” line has to name an ingredient you declared above.")
            }
            var hits = ingredients.filter { $0.name.lowercased() == want }
            if hits.isEmpty {
                hits = ingredients.filter { $0.name.lowercased().contains(want) }
            }
            guard !hits.isEmpty else {
                let available = ingredients.map(\.name).joined(separator: ", ")
                return ParsedRecipe(meta: meta, root: root, error: "Line \(ref.line): nothing called “\(ref.name)” is declared. Available: \(available).")
            }
            guard hits.count == 1 else {
                return ParsedRecipe(meta: meta, root: root, error: "Line \(ref.line): “\(ref.name)” matches multiple ingredients. Name it exactly.")
            }
            ref.target = hits[0]
        }

        measure(node: root)
        assignColspan(root: root)
        let cols = (operations.map(\.col).max() ?? 0) + 1

        return ParsedRecipe(
            meta: meta,
            root: root,
            leaves: leaves,
            operations: operations,
            columnCount: cols
        )
    }

    static func diagramRows(from recipe: ParsedRecipe) -> [DiagramRow] {
        guard recipe.error == nil else { return [] }
        return recipe.leaves.enumerated().map { index, leaf in
            var cells: [DiagramCell] = [DiagramCell(id: leaf.id, node: leaf, kind: .ingredient)]
            var ancestor = leaf.parent
            while let node = ancestor, node.first == index {
                cells.append(DiagramCell(id: node.id, node: node, kind: .operation))
                ancestor = node.parent
            }
            cells.sort { $0.node.col < $1.node.col }
            return DiagramRow(leaf: leaf, cells: cells)
        }
    }

    static func interpolate(_ text: String, meta: RecipeMeta) -> String {
        text
            .replacingOccurrences(of: "{pan}", with: meta.pan)
            .replacingOccurrences(of: "{oven}", with: meta.oven)
    }

    // MARK: - Private

    private static func parseMetaLine(_ text: String) -> (key: String, value: String)? {
        guard let colon = text.firstIndex(of: ":") else { return nil }
        let key = String(text[..<colon]).trimmingCharacters(in: .whitespaces).lowercased()
        guard metaKeys.contains(key) else { return nil }
        let value = String(text[text.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
        return (key, value)
    }

    private static func classify(node: RecipeNode, leaves: inout [RecipeNode], operations: inout [RecipeNode]) {
        if !node.children.isEmpty {
            node.type = .operation
            let parts = node.raw.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            var head = parts.first?.trimmingCharacters(in: .whitespaces) ?? ""

            if let atRange = head.range(of: #"@([A-Za-z][\w-]*)"#, options: .regularExpression) {
                let token = String(head[atRange]).dropFirst()
                node.cname = String(token)
                head.removeSubrange(atRange)
                head = head.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }

            node.verb = head
            node.detail = parts.dropFirst().joined(separator: "|").trimmingCharacters(in: .whitespaces)
            if node.detail.isEmpty {
                let tokens = node.verb.split(separator: " ").map(String.init)
                if let cutIndex = tokens.firstIndex(where: { token in
                    token.contains(where: \.isNumber) || token.contains("{")
                }), cutIndex > 0 {
                    node.detail = tokens[cutIndex...].joined(separator: " ")
                    node.verb = tokens[..<cutIndex].joined(separator: " ")
                }
            }
            operations.append(node)
            node.children.forEach { classify(node: $0, leaves: &leaves, operations: &operations) }
        } else {
            var body = node.raw
            let isRef = body.hasPrefix(">")
            if isRef {
                node.type = .reference
                body = body.replacingOccurrences(of: #"^>\s*"#, with: "", options: .regularExpression)
            } else {
                node.type = .ingredient
            }
            let fields = body.split(separator: "|", omittingEmptySubsequences: false).map {
                String($0).trimmingCharacters(in: .whitespaces)
            }
            switch fields.count {
            case 0:
                break
            case 1:
                node.name = fields[0]
            case 2:
                node.us = splitAmount(fields[0])
                node.name = fields[1]
            default:
                node.us = splitAmount(fields[0])
                node.metric = splitAmount(fields[1])
                node.name = fields[2]
                if fields.count > 3 { node.note = fields[3] }
            }
            node.row = leaves.count
            leaves.append(node)
        }
    }

    private static func splitAmount(_ raw: String) -> IngredientAmount {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return IngredientAmount(value: nil, unit: "", literal: "") }

        let pattern = #"^([\d]+(?:\s+\d+\s*\/\s*\d+)?(?:\s*\/\s*\d+)?(?:\.\d+)?)\s*(.*)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              match.numberOfRanges >= 3,
              let numRange = Range(match.range(at: 1), in: trimmed),
              let unitRange = Range(match.range(at: 2), in: trimmed) else {
            return IngredientAmount(value: nil, unit: "", literal: trimmed)
        }

        let numText = String(trimmed[numRange])
        if let value = parseQuantity(numText) {
            return IngredientAmount(value: value, unit: String(trimmed[unitRange]).trimmingCharacters(in: .whitespaces), literal: "")
        }
        return IngredientAmount(value: nil, unit: "", literal: trimmed)
    }

    private static func parseQuantity(_ text: String) -> Double? {
        let s = text.trimmingCharacters(in: .whitespaces)

        if let regex = try? NSRegularExpression(pattern: #"^(\d+)\s+(\d+)\s*/\s*(\d+)$"#),
           let match = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)),
           match.numberOfRanges == 4,
           let wholeRange = Range(match.range(at: 1), in: s),
           let numRange = Range(match.range(at: 2), in: s),
           let denRange = Range(match.range(at: 3), in: s),
           let whole = Double(s[wholeRange]),
           let num = Double(s[numRange]),
           let den = Double(s[denRange]), den != 0 {
            return whole + num / den
        }

        if let regex = try? NSRegularExpression(pattern: #"^(\d+)\s*/\s*(\d+)$"#),
           let match = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)),
           match.numberOfRanges == 3,
           let numRange = Range(match.range(at: 1), in: s),
           let denRange = Range(match.range(at: 2), in: s),
           let num = Double(s[numRange]),
           let den = Double(s[denRange]), den != 0 {
            return num / den
        }

        return Double(s)
    }

    private static func measure(node: RecipeNode) {
        if node.type == .ingredient || node.type == .reference {
            node.col = 0
            node.span = 1
            node.first = node.row
            return
        }
        var maxCol = 0
        var span = 0
        var first = Int.max
        for child in node.children {
            measure(node: child)
            maxCol = max(maxCol, child.col)
            span += child.span
            first = min(first, child.first)
        }
        node.col = maxCol + 1
        node.span = span
        node.first = first == Int.max ? 0 : first
    }

    private static func assignColspan(root: RecipeNode) {
        func walk(_ node: RecipeNode, depth: Int) {
            if node.type == .ingredient || node.type == .reference {
                node.colspan = max(1, depth - node.col + 1)
            }
            node.children.forEach { walk($0, depth: depth) }
        }
        walk(root, depth: root.col)
    }
}

extension RecipeNode {
    func amountDisplay(units: UnitDisplay, scale: Double = 1) -> String {
        switch units {
        case .us:
            return scaledAmount(us, scale: scale)
        case .metric:
            return scaledAmount(metric, scale: scale)
        case .both:
            let usText = scaledAmount(us, scale: scale)
            let metText = scaledAmount(metric, scale: scale)
            if metText.isEmpty || metText == usText { return usText }
            if usText.isEmpty { return metText }
            return "\(usText) · \(metText)"
        }
    }

    private func scaledAmount(_ amount: IngredientAmount, scale: Double) -> String {
        if let value = amount.value {
            let scaled = value * scale
            return IngredientAmount(value: scaled, unit: amount.unit, literal: "").displayUS
        }
        return amount.literal
    }

    var displayName: String {
        if type == .reference, let target { return target.name }
        return name
    }
}
