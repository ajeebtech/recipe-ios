import SwiftUI

struct RecipeDiagramView: View {
    let recipe: ParsedRecipe
    var units: UnitDisplay = .both
    var scale: Double = 1
    @State private var highlightedID: String?

    private var rows: [DiagramRow] { RecipeParser.diagramRows(from: recipe) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Fig. 1 — flow diagram, ingredients left, finished dish right")
                .font(.system(size: 11))
                .foregroundColor(ArtifactColors.ink3)
                .kerning(0.4)
                .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(Array(recipe.meta.prep.enumerated()), id: \.offset) { index, step in
                        bannerRow(text: step, index: index + 1, isFinish: false)
                    }

                    ForEach(rows) { row in
                        diagramDataRow(row)
                    }

                    ForEach(Array(recipe.meta.finish.enumerated()), id: \.offset) { _, step in
                        bannerRow(text: step, index: nil, isFinish: true)
                    }
                }
                .overlay(diagramBorder)
            }
        }
    }

    private var diagramBorder: some View {
        RoundedRectangle(cornerRadius: 0)
            .stroke(ArtifactColors.rule2, lineWidth: 1)
    }

    private func bannerRow(text: String, index: Int?, isFinish: Bool) -> some View {
        HStack(spacing: 7) {
            if let index {
                Text("\(index)")
                    .font(.artifactMono(size: 10.5))
                    .foregroundColor(ArtifactColors.ink4)
            } else {
                Text("✓")
                    .font(.artifactMono(size: 10.5))
                    .foregroundColor(ArtifactColors.ink4)
            }
            Text(RecipeParser.interpolate(text, meta: recipe.meta))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(ArtifactColors.ink2)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minWidth: tableMinWidth)
        .background(ArtifactColors.band)
        .overlay(alignment: .bottom) {
            Rectangle().fill(ArtifactColors.rule).frame(height: 1)
        }
    }

    private func diagramDataRow(_ row: DiagramRow) -> some View {
        HStack(spacing: 0) {
            ForEach(row.cells) { cell in
                switch cell.kind {
                case .ingredient:
                    ingredientCell(cell.node, colspan: cell.node.colspan)
                case .operation:
                    operationCell(cell.node)
                }
            }
        }
        .frame(minWidth: tableMinWidth, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(ArtifactColors.rule).frame(height: 1)
        }
    }

    private func ingredientCell(_ node: RecipeNode, colspan: Int) -> some View {
        let isRef = node.type == .reference
        let isHighlighted = isNodeHighlighted(node)
        let amount = node.amountDisplay(units: units, scale: scale)

        return HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text(amount.isEmpty ? (isRef ? "the rest" : "—") : amount)
                        .font(.artifactMono(size: 12.2))
                        .foregroundColor(amount.isEmpty ? ArtifactColors.ink4 : ArtifactColors.ink)
                        .frame(minWidth: 84, alignment: .leading)
                        .monospacedDigit()

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        if isRef {
                            Text("↳")
                                .font(.artifactMono(size: 12))
                                .foregroundColor(ArtifactColors.accent)
                        }
                        Text(node.displayName)
                            .font(.system(size: 14))
                            .foregroundColor(ArtifactColors.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !node.note.isEmpty {
                    Text(node.note)
                        .font(.system(size: 11.5))
                        .foregroundColor(ArtifactColors.ink3)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
        .frame(width: ingredientWidth(for: colspan), alignment: .leading)
        .background {
            if isRef {
                refBackground
            } else {
                (isHighlighted ? ArtifactColors.accentSoft : ArtifactColors.card)
            }
        }
        .overlay(alignment: .trailing) {
            Rectangle().fill(ArtifactColors.rule).frame(width: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture { highlightedID = node.id }
    }

    private func operationCell(_ node: RecipeNode) -> some View {
        let isHighlighted = isNodeHighlighted(node)
        let detail = RecipeParser.interpolate(node.detail, meta: recipe.meta)

        return VStack(spacing: 4) {
            if let cname = node.cname {
                Text(cname.uppercased())
                    .font(.system(size: 9.5, weight: .bold))
                    .kerning(1.2)
                    .foregroundColor(isHighlighted ? ArtifactColors.accent2 : ArtifactColors.ink4)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(isHighlighted ? ArtifactColors.accentSoft : .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .stroke(isHighlighted ? ArtifactColors.accentLine : ArtifactColors.rule, lineWidth: 1)
                            )
                    )
            }

            Text(node.verb.uppercased())
                .font(.system(size: 11.5, weight: .bold))
                .kerning(1.1)
                .foregroundColor(isHighlighted ? ArtifactColors.ink : ArtifactColors.ink2)
                .multilineTextAlignment(.center)

            if !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(isHighlighted ? ArtifactColors.ink2 : ArtifactColors.ink3)
                    .multilineTextAlignment(.center)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .frame(width: ArtifactMetrics.operationColumnWidth * CGFloat(max(node.colspan, 1)))
        .frame(minHeight: CGFloat(node.span) * 52)
        .background(isHighlighted ? ArtifactColors.accentSoft : ArtifactColors.card)
        .overlay(alignment: .leading) {
            if isHighlighted {
                Rectangle()
                    .fill(ArtifactColors.accent)
                    .frame(width: 3)
            }
        }
        .overlay(alignment: .trailing) {
            Rectangle().fill(ArtifactColors.rule).frame(width: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture { highlightedID = node.id }
    }

    private var refBackground: some View {
        LinearGradient(
            colors: [Color.white, ArtifactColors.band],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.9)
    }

    private var tableMinWidth: CGFloat {
        ArtifactMetrics.ingredientColumnWidth + ArtifactMetrics.operationColumnWidth * CGFloat(max(recipe.columnCount - 1, 0))
    }

    private func ingredientWidth(for colspan: Int) -> CGFloat {
        ArtifactMetrics.ingredientColumnWidth + ArtifactMetrics.operationColumnWidth * CGFloat(max(colspan - 1, 0))
    }

    private func isNodeHighlighted(_ node: RecipeNode) -> Bool {
        guard let highlightedID else { return false }
        if node.id == highlightedID { return true }
        return isDescendant(of: node, targetID: highlightedID) || isAncestor(of: node, targetID: highlightedID)
    }

    private func isDescendant(of node: RecipeNode, targetID: String) -> Bool {
        node.children.contains { $0.id == targetID || isDescendant(of: $0, targetID: targetID) }
    }

    private func isAncestor(of node: RecipeNode, targetID: String) -> Bool {
        var current = node.parent
        while let parent = current {
            if parent.id == targetID { return true }
            current = parent.parent
        }
        return false
    }
}

struct RecipeProseView: View {
    let recipe: ParsedRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            section(title: "Ingredients") {
                VStack(spacing: 0) {
                    ForEach(recipe.leaves.filter { $0.type == .ingredient }, id: \.id) { leaf in
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text(leaf.amountDisplay(units: .both))
                                .font(.artifactMono(size: 12))
                                .foregroundColor(ArtifactColors.ink)
                                .frame(minWidth: 96, alignment: .leading)
                                .monospacedDigit()
                            Text(leaf.name)
                                .font(.system(size: 14.5))
                                .foregroundColor(ArtifactColors.ink)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 6)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(Color(red: 0.933, green: 0.941, blue: 0.945)).frame(height: 1)
                        }
                    }
                }
            }

            section(title: "Method") {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(recipe.meta.prep.enumerated()), id: \.offset) { index, step in
                        proseStep(index: index + 1, text: RecipeParser.interpolate(step, meta: recipe.meta), dashed: true)
                    }
                    ForEach(Array(recipe.operations.enumerated()), id: \.element.id) { index, op in
                        proseStep(index: index + 1 + recipe.meta.prep.count, text: stepText(for: op), dashed: false)
                    }
                    ForEach(Array(recipe.meta.finish.enumerated()), id: \.offset) { index, step in
                        proseStep(index: index + 1, text: RecipeParser.interpolate(step, meta: recipe.meta), dashed: true, prefix: "✓")
                    }
                }
            }
        }
        .frame(maxWidth: 560, alignment: .leading)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10.5, weight: .bold))
                .kerning(1.6)
                .foregroundColor(ArtifactColors.ink3)
                .padding(.bottom, 8)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(ArtifactColors.rule).frame(height: 1)
                }
            content()
        }
    }

    private func proseStep(index: Int, text: String, dashed: Bool, prefix: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(prefix ?? "\(index)")
                .font(.artifactMono(size: 11))
                .foregroundColor(ArtifactColors.ink2)
                .frame(width: 21, height: 21)
                .overlay(
                    Circle()
                        .stroke(ArtifactColors.rule2, style: StrokeStyle(lineWidth: 1, dash: dashed ? [3, 2] : []))
                )
            Text(text)
                .font(.system(size: 14.5))
                .foregroundColor(ArtifactColors.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func stepText(for node: RecipeNode) -> String {
        var text = node.verb
        let detail = RecipeParser.interpolate(node.detail, meta: recipe.meta)
        if !detail.isEmpty { text += " — \(detail)" }
        return text
    }
}
