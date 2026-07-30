import SwiftUI

private struct DiagramSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    func readDiagramSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: DiagramSizePreferenceKey.self,
                    value: proxy.size
                )
            }
        }
        .onPreferenceChange(DiagramSizePreferenceKey.self, perform: onChange)
    }
}

struct RecipeDiagramView: View {
    let recipe: ParsedRecipe
    var units: UnitDisplay = .both
    var scale: Double = 1
    var availableWidth: CGFloat = 320
    @State private var highlightedID: String?
    @State private var diagramSize: CGSize = .zero

    private let rowHeight: CGFloat = 58

    private var fitScale: CGFloat {
        let width = max(availableWidth, 1)
        return min(1, width / max(tableMinWidth, 1))
    }

    private var columnMetrics: (ingredient: CGFloat, operation: CGFloat) {
        if availableWidth < 520 {
            return (228, 78)
        }
        return (ArtifactMetrics.ingredientColumnWidth, ArtifactMetrics.operationColumnWidth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Fig. 1 — flow diagram, ingredients left, finished dish right")
                .font(.system(size: 11))
                .foregroundColor(ArtifactColors.ink3)
                .kerning(0.4)
                .padding(.bottom, 8)

            ZStack(alignment: .topLeading) {
                diagramTable
                    .frame(width: tableMinWidth, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: true)
                    .hidden()
                    .readDiagramSize { size in
                        guard size != diagramSize else { return }
                        diagramSize = size
                    }

                diagramTable
                    .frame(width: tableMinWidth, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: true)
                    .scaleEffect(fitScale, anchor: .topLeading)
            }
            .frame(
                width: max(availableWidth, 1),
                height: layoutHeight,
                alignment: .topLeading
            )
            .clipped()
        }
        .frame(width: max(availableWidth, 1), alignment: .leading)
    }

    private var layoutHeight: CGFloat? {
        guard diagramSize.height > 0 else { return nil }
        let scaledHeight = diagramSize.height * fitScale
        guard scaledHeight.isFinite, scaledHeight > 0 else { return nil }
        return scaledHeight
    }

    private var diagramTable: some View {
        VStack(spacing: 0) {
            ForEach(Array(recipe.meta.prep.enumerated()), id: \.offset) { index, step in
                bannerRow(text: step, index: index + 1, isFinish: false)
            }

            diagramGrid

            ForEach(Array(recipe.meta.finish.enumerated()), id: \.offset) { _, step in
                bannerRow(text: step, index: nil, isFinish: true)
            }
        }
        .overlay(diagramBorder)
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

    private var diagramGrid: some View {
        ZStack(alignment: .topLeading) {
            ForEach(recipe.leaves, id: \.id) { node in
                ingredientCell(node, colspan: node.colspan)
                    .offset(y: CGFloat(node.row) * rowHeight)
            }

            ForEach(recipe.operations, id: \.id) { node in
                operationCell(node)
                    .offset(
                        x: operationX(for: node),
                        y: CGFloat(node.first) * rowHeight
                    )
            }
        }
        .frame(
            width: tableMinWidth,
            height: CGFloat(recipe.leaves.count) * rowHeight,
            alignment: .topLeading
        )
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
        .frame(
            width: ingredientWidth(for: colspan),
            height: rowHeight,
            alignment: .leading
        )
        .background {
            if isRef {
                refBackground
            } else {
                (isHighlighted ? ArtifactColors.accentSoft : ArtifactColors.card)
            }
        }
        .overlay(Rectangle().stroke(ArtifactColors.rule, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            ExilyHaptics.tap(highlightedID == node.id ? .select : .light)
            withAnimation(.easeOut(duration: 0.15)) {
                highlightedID = highlightedID == node.id ? nil : node.id
            }
        }
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
        .frame(
            width: columnMetrics.operation * CGFloat(max(node.colspan, 1)),
            height: CGFloat(node.span) * rowHeight
        )
        .background(isHighlighted ? ArtifactColors.accentSoft : ArtifactColors.band)
        .overlay(alignment: .leading) {
            if isHighlighted {
                Rectangle()
                    .fill(ArtifactColors.accent)
                    .frame(width: 3)
            }
        }
        .overlay(Rectangle().stroke(ArtifactColors.rule, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            ExilyHaptics.tap(highlightedID == node.id ? .select : .light)
            withAnimation(.easeOut(duration: 0.15)) {
                highlightedID = highlightedID == node.id ? nil : node.id
            }
        }
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
        columnMetrics.ingredient + columnMetrics.operation * CGFloat(max(recipe.columnCount - 1, 0))
    }

    private func ingredientWidth(for colspan: Int) -> CGFloat {
        columnMetrics.ingredient + columnMetrics.operation * CGFloat(max(colspan - 1, 0))
    }

    private func operationX(for node: RecipeNode) -> CGFloat {
        columnMetrics.ingredient
            + columnMetrics.operation * CGFloat(max(node.col - 1, 0))
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
