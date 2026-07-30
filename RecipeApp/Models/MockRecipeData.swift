import Foundation

enum MockRecipeData {
    static let folders: [CuisineFolder] = [
        CuisineFolder(
            id: "american",
            name: "American",
            symbol: "flag.fill",
            tint: .init(red: 0.23, green: 0.35, blue: 0.78),
            recipes: [
                RecipeDocument(
                    id: "pancakes",
                    title: "Buttermilk Pancakes",
                    subtitle: "12 pancakes · griddle",
                    prepTime: "15 min",
                    source: pancakesSource
                ),
                RecipeDocument(
                    id: "cornbread",
                    title: "Skillet Cornbread",
                    subtitle: "8 wedges · cast iron",
                    prepTime: "35 min",
                    source: cornbreadSource
                )
            ]
        ),
        CuisineFolder(
            id: "italian",
            name: "Italian",
            symbol: "leaf.fill",
            tint: .init(red: 0.08, green: 0.55, blue: 0.32),
            recipes: [
                RecipeDocument(
                    id: "focaccia",
                    title: "Overnight Focaccia",
                    subtitle: "12 pieces · sheet pan",
                    prepTime: "overnight",
                    source: focacciaSource
                )
            ]
        ),
        CuisineFolder(
            id: "desserts",
            name: "Desserts",
            symbol: "birthday.cake.fill",
            tint: .init(red: 0.55, green: 0.28, blue: 0.62),
            recipes: [
                RecipeDocument(
                    id: "brownies",
                    title: "Espresso Brownies",
                    subtitle: "16 squares · 8×8 pan",
                    prepTime: "45 min",
                    source: browniesSource
                )
            ]
        ),
        CuisineFolder(
            id: "basics",
            name: "Basics",
            symbol: "drop.fill",
            tint: .init(red: 0.78, green: 0.52, blue: 0.18),
            recipes: [
                RecipeDocument(
                    id: "vinaigrette",
                    title: "Everyday Vinaigrette",
                    subtitle: "3/4 cup · jar",
                    prepTime: "5 min",
                    source: vinaigretteSource
                )
            ]
        ),
        CuisineFolder(
            id: "japanese",
            name: "Japanese",
            symbol: "sun.max.fill",
            tint: .init(red: 0.82, green: 0.22, blue: 0.28),
            recipes: [
                RecipeDocument(
                    id: "miso-soup",
                    title: "Miso Soup",
                    subtitle: "4 bowls · donabe",
                    prepTime: "20 min",
                    source: misoSoupSource
                )
            ]
        ),
        CuisineFolder(
            id: "mexican",
            name: "Mexican",
            symbol: "flame.fill",
            tint: .init(red: 0.86, green: 0.42, blue: 0.12),
            recipes: [
                RecipeDocument(
                    id: "salsa-verde",
                    title: "Salsa Verde",
                    subtitle: "2 cups · molcajete",
                    prepTime: "25 min",
                    source: salsaVerdeSource
                )
            ]
        )
    ]

    // MARK: - Sources from artifact.html examples + light mock additions

    static let browniesSource = """
title: Espresso Brownies
yield: 16 brownies
pan: 8x8 in
oven: 350F | 170C
prep: Butter and flour the {pan} pan
prep: Preheat oven to {oven}
finish: Cool in the pan on a rack before cutting

bake | {oven}, 30 to 40 min, until a skewer comes out with a few damp crumbs
  fold in
    mix
      mix
        melt
          4 oz | 115 g | unsalted butter
        1 cup | 200 g | sugar
        1/4 tsp | 2.5 mL | vanilla extract
        4 Tbs | 60 mL | fresh brewed espresso or very strong coffee | 1 shot
      2 large | 100 g | eggs
    1/2 cup | 80 g | all-purpose flour
    1/3 cup | 80 g | Hershey's cocoa powder
    1/4 tsp | 1.3 g | baking soda
    1/4 tsp | 1.5 g | table salt
"""

    static let pancakesSource = """
title: Buttermilk Pancakes
yield: 12 pancakes
pan: griddle
oven: 375F | 190C
prep: Heat a griddle over medium until a drop of water skitters
finish: Serve straight off the griddle

cook | 2 to 3 min per side, until the edges set
  stir | until just combined — lumps are fine
    whisk @dry
      1 1/2 cups | 190 g | all-purpose flour
      2 Tbs | 25 g | sugar
      2 tsp | 9 g | baking powder
      1/2 tsp | 3 g | table salt
    whisk @wet
      1 1/4 cups | 300 mL | buttermilk
      2 large | 100 g | eggs
      3 Tbs | 42 g | unsalted butter | melted and cooled
"""

    static let vinaigretteSource = """
title: Everyday Vinaigrette
yield: 3/4 cup
pan: jar
finish: Taste — more vinegar for sharpness, more oil for softness

whisk in | slowly, until it emulsifies
  whisk
    1 Tbs | 15 mL | Dijon mustard
    2 Tbs | 30 mL | red wine vinegar
    1 tsp | 5 mL | honey
    1/4 tsp | 1.5 g | table salt
    pinch | | black pepper | freshly ground
  6 Tbs | 90 mL | extra-virgin olive oil
"""

    static let cornbreadSource = """
title: Skillet Cornbread
yield: 8 wedges
pan: 9-in round
oven: 425F | 220C
prep: Heat the skillet in the oven while it comes up to {oven}
finish: Turn it out after 5 min so the bottom crust stays crisp

bake | {oven}, 20 to 24 min, until the top springs back
  swirl in | to coat the hot skillet, then pour in the batter
    stir | until just combined, a few lumps are fine
      whisk @dry
        1 1/4 cups | 175 g | fine cornmeal
        3/4 cup | 95 g | all-purpose flour
        1 Tbs | 12 g | sugar
        2 tsp | 9 g | baking powder
        1 tsp | 6 g | table salt
      whisk @wet
        1 1/4 cups | 300 mL | buttermilk
        2 large | 100 g | eggs
        6 Tbs | 85 g | unsalted butter | melted
    > 2 Tbs | 28 g | unsalted butter
"""

    static let focacciaSource = """
title: Overnight Focaccia
yield: 12 pieces
pan: 9x13 in
oven: 450F | 230C
prep: Oil the {pan} pan generously — the bottom should shine
finish: Lift out onto a rack so the base stays crisp

bake | {oven}, 22 to 26 min, until the top is deep gold
  top with | 45 min rest, until pillowy
    work in | 20 min, then stretch to the corners
      cold ferment | overnight, 12 to 18 hours in the fridge
        mix | 3 min, until no dry flour remains
          4 cups | 500 g | bread flour
          1 1/2 tsp | 9 g | table salt
          1/2 tsp | 2 g | instant yeast
          1 3/4 cups | 415 mL | warm water
        1/4 cup | 60 mL | olive oil
"""

    static let misoSoupSource = """
title: Miso Soup
yield: 4 bowls
pan: donabe
prep: Slice scallions thin on the bias
finish: Serve immediately — do not boil after miso goes in

simmer | 5 min, until mushrooms soften
  whisk in | off heat, until smooth
    bring to a simmer
      4 cups | 950 mL | dashi
      8 oz | 225 g | silken tofu | cubed
      4 oz | 115 g | shiitake mushrooms | sliced
    3 Tbs | 45 g | white miso paste
  2 | | scallions | for garnish
"""

    static let salsaVerdeSource = """
title: Salsa Verde
yield: 2 cups
pan: molcajete
finish: Rest 10 min so the salt blooms

blend | until coarse-smooth
  char | 8 to 10 min, until blistered
    1 lb | 450 g | tomatillos | husked
    2 | | jalapeños
    3 cloves | | garlic | unpeeled
  pulse in
    1/2 cup | 12 g | cilantro
    1/2 tsp | 3 g | table salt
    2 Tbs | 30 mL | lime juice
"""

    private struct BookRecipeSeed {
        let title: String
        let prepTime: String
        let genre: RecipeGenre
    }

    static func bookRecipes(for folder: CuisineFolder) -> [RecipeDocument] {
        guard !folder.recipes.isEmpty else { return [] }

        return seeds(for: folder.id).enumerated().map { index, seed in
            let template = folder.recipes[index % folder.recipes.count]
            return RecipeDocument(
                id: "\(folder.id)-book-\(index)",
                title: seed.title,
                subtitle: template.subtitle,
                prepTime: seed.prepTime,
                genre: seed.genre,
                source: source(named: seed.title, from: template.source)
            )
        }
    }

    private static func seeds(for cuisineID: String) -> [BookRecipeSeed] {
        switch cuisineID {
        case "american":
            return makeSeeds([
                ("Breakfast", "sunrise.fill", [
                    ("Buttermilk Pancakes", "15 min"), ("Blueberry Waffles", "25 min"),
                    ("Hash Brown Skillet", "30 min"), ("Soft Scrambled Eggs", "10 min")
                ]),
                ("Mains", "fork.knife", [
                    ("Buttermilk Fried Chicken", "1 hr"), ("Classic Cheeseburger", "35 min"),
                    ("Meatloaf", "1 hr 20"), ("Pulled Pork", "6 hr")
                ]),
                ("Breads", "birthday.cake.fill", [
                    ("Skillet Cornbread", "35 min"), ("Buttermilk Biscuits", "30 min"),
                    ("Dinner Rolls", "2 hr"), ("Banana Bread", "1 hr")
                ])
            ])
        case "italian":
            return makeSeeds([
                ("Pasta", "fork.knife", [
                    ("Cacio e Pepe", "25 min"), ("Rigatoni Amatriciana", "40 min"),
                    ("Pesto Genovese", "20 min"), ("Mushroom Tagliatelle", "45 min")
                ]),
                ("Mains", "frying.pan.fill", [
                    ("Chicken Piccata", "35 min"), ("Eggplant Parmigiana", "1 hr"),
                    ("Osso Buco", "3 hr"), ("Pollo al Mattone", "50 min")
                ]),
                ("Breads", "leaf.fill", [
                    ("Overnight Focaccia", "overnight"), ("Rosemary Schiacciata", "3 hr"),
                    ("Garlic Knots", "2 hr"), ("Ciabatta", "overnight")
                ]),
                ("Desserts", "birthday.cake.fill", [
                    ("Tiramisu", "6 hr"), ("Panna Cotta", "4 hr"),
                    ("Olive Oil Cake", "1 hr"), ("Affogato", "5 min")
                ])
            ])
        case "desserts":
            return makeSeeds([
                ("Chocolate", "birthday.cake.fill", [
                    ("Espresso Brownies", "45 min"), ("Flourless Chocolate Cake", "1 hr"),
                    ("Chocolate Pots", "3 hr"), ("Dark Chocolate Tart", "2 hr")
                ]),
                ("Fruit", "apple.logo", [
                    ("Apple Galette", "1 hr"), ("Lemon Bars", "50 min"),
                    ("Berry Cobbler", "45 min"), ("Pear Crumble", "55 min")
                ]),
                ("Frozen", "snowflake", [
                    ("Vanilla Bean Gelato", "6 hr"), ("Strawberry Semifreddo", "5 hr"),
                    ("Chocolate Sorbet", "4 hr"), ("Lemon Granita", "3 hr")
                ])
            ])
        case "basics":
            return makeSeeds([
                ("Sauces", "drop.fill", [
                    ("Everyday Vinaigrette", "5 min"), ("Classic Mayonnaise", "10 min"),
                    ("Green Goddess", "10 min"), ("Tomato Sauce", "45 min")
                ]),
                ("Stocks", "takeoutbag.and.cup.and.straw.fill", [
                    ("Chicken Stock", "4 hr"), ("Vegetable Stock", "1 hr"),
                    ("Quick Dashi", "20 min"), ("Mushroom Broth", "1 hr")
                ]),
                ("Doughs", "circle.grid.cross.fill", [
                    ("Pizza Dough", "overnight"), ("Shortcrust Pastry", "1 hr"),
                    ("Fresh Pasta", "45 min"), ("Pie Dough", "2 hr")
                ])
            ])
        case "japanese":
            return makeSeeds([
                ("Soups", "takeoutbag.and.cup.and.straw.fill", [
                    ("Miso Soup", "20 min"), ("Shoyu Ramen", "4 hr"),
                    ("Tonjiru", "1 hr"), ("Clear Clam Soup", "25 min")
                ]),
                ("Rice", "circle.grid.cross.fill", [
                    ("Chicken Donburi", "35 min"), ("Onigiri", "30 min"),
                    ("Ochazuke", "10 min"), ("Mushroom Takikomi Gohan", "50 min")
                ]),
                ("Mains", "fish.fill", [
                    ("Teriyaki Salmon", "30 min"), ("Chicken Katsu", "40 min"),
                    ("Agedashi Tofu", "30 min"), ("Saba Shioyaki", "25 min")
                ]),
                ("Sides", "leaf.fill", [
                    ("Goma-ae Spinach", "15 min"), ("Sunomono", "20 min"),
                    ("Tamagoyaki", "15 min"), ("Edamame", "10 min")
                ])
            ])
        default:
            return makeSeeds([
                ("Salsas", "flame.fill", [
                    ("Salsa Verde", "25 min"), ("Roasted Tomato Salsa", "30 min"),
                    ("Pico de Gallo", "15 min"), ("Chile de Árbol Salsa", "20 min")
                ]),
                ("Mains", "fork.knife", [
                    ("Chicken Tinga", "1 hr"), ("Carnitas", "4 hr"),
                    ("Chiles Rellenos", "1 hr"), ("Carne Asada", "45 min")
                ]),
                ("Antojitos", "takeoutbag.and.cup.and.straw.fill", [
                    ("Elote", "25 min"), ("Quesadillas", "20 min"),
                    ("Sopes", "1 hr"), ("Tostadas", "40 min")
                ])
            ])
        }
    }

    private static func makeSeeds(
        _ groups: [(String, String, [(String, String)])]
    ) -> [BookRecipeSeed] {
        groups.flatMap { name, symbol, recipes in
            let genre = RecipeGenre(name, symbol: symbol)
            return recipes.map {
                BookRecipeSeed(title: $0.0, prepTime: $0.1, genre: genre)
            }
        }
    }

    private static func source(named title: String, from source: String) -> String {
        source.replacingOccurrences(
            of: #"(?m)^title:.*$"#,
            with: "title: \(title)",
            options: .regularExpression
        )
    }
}
