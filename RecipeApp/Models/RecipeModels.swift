import Foundation
import SwiftUI

struct RecipeMeta: Equatable {
    var title: String = ""
    var yield: String = ""
    var pan: String = ""
    var oven: String = ""
    var source: String = ""
    var prep: [String] = []
    var finish: [String] = []
}

struct IngredientAmount: Equatable {
    var value: Double?
    var unit: String
    var literal: String

    var displayUS: String {
        if let value {
            return formatFraction(value) + (unit.isEmpty ? "" : " \(unit)")
        }
        return literal
    }

    private func formatFraction(_ n: Double) -> String {
        let whole = Int(n)
        let frac = n - Double(whole)
        if abs(frac) < 0.001 { return whole == 0 ? "0" : "\(whole)" }
        let denominators = [2, 3, 4, 8]
        for d in denominators {
            let num = Int(round(frac * Double(d)))
            if abs(frac - Double(num) / Double(d)) < 0.02, num > 0 {
                if whole > 0 { return "\(whole) \(num)/\(d)" }
                return "\(num)/\(d)"
            }
        }
        if n == floor(n) { return "\(Int(n))" }
        return String(format: "%.1f", n)
    }
}

final class RecipeNode: Identifiable {
    let id: String
    let raw: String
    let indent: Int
    let line: Int
    var children: [RecipeNode] = []
    weak var parent: RecipeNode?

    var type: NodeType = .operation
    var verb: String = ""
    var detail: String = ""
    var cname: String?
    var us = IngredientAmount(value: nil, unit: "", literal: "")
    var metric = IngredientAmount(value: nil, unit: "", literal: "")
    var name: String = ""
    var note: String = ""
    var target: RecipeNode?
    var row: Int = 0
    var col: Int = 0
    var span: Int = 1
    var first: Int = 0
    var colspan: Int = 1

    enum NodeType {
        case operation, ingredient, reference
    }

    init(id: String, raw: String, indent: Int, line: Int) {
        self.id = id
        self.raw = raw
        self.indent = indent
        self.line = line
    }
}

struct ParsedRecipe {
    var meta: RecipeMeta
    var root: RecipeNode?
    var leaves: [RecipeNode] = []
    var operations: [RecipeNode] = []
    var columnCount: Int = 1
    var error: String?
}

struct RecipeDocument: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let source: String

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: RecipeDocument, rhs: RecipeDocument) -> Bool { lhs.id == rhs.id }

    var parsed: ParsedRecipe { RecipeParser.parse(source) }
}

struct CuisineFolder: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let tint: ColorToken
    let recipes: [RecipeDocument]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CuisineFolder, rhs: CuisineFolder) -> Bool { lhs.id == rhs.id }

    struct ColorToken: Hashable {
        let red: Double
        let green: Double
        let blue: Double
    }
}

extension CuisineFolder.ColorToken {
    var color: Color { Color(red: red, green: green, blue: blue) }
    var soft: Color { color.opacity(0.18) }
}

enum RecipeViewMode: String, CaseIterable, Identifiable {
    case diagram = "Diagram"
    case recipe = "Recipe"

    var id: String { rawValue }
}

enum UnitDisplay: String, CaseIterable, Identifiable {
    case both = "Both"
    case us = "US"
    case metric = "Metric"

    var id: String { rawValue }
}

struct DiagramRow: Identifiable {
    let id = UUID()
    let leaf: RecipeNode
    let cells: [DiagramCell]
}

struct DiagramCell: Identifiable {
    let id: String
    let node: RecipeNode
    let kind: Kind

    enum Kind {
        case ingredient, operation
    }
}
