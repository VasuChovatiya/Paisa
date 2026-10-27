//
//  Typography.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - Font + Dynamic Weights & Sizes

extension Font {
    // MARK: - Dynamic Font Generator Functions

    static func bold(_ size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .bold, design: design)
    }

    static func bold(size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .bold, design: design)
    }

    static func semibold(_ size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .semibold, design: design)
    }

    static func semibold(size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .semibold, design: design)
    }

    static func medium(_ size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .medium, design: design)
    }

    static func medium(size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .medium, design: design)
    }

    static func regular(_ size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .regular, design: design)
    }

    static func regular(size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .regular, design: design)
    }

    static func heavy(_ size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .heavy, design: design)
    }

    static func heavy(size: CGFloat, design: Font.Design = .rounded) -> Font {
        .system(size: size, weight: .heavy, design: design)
    }

    static func light(_ size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .light, design: design)
    }

    static func light(size: CGFloat, design: Font.Design = .default) -> Font {
        .system(size: size, weight: .light, design: design)
    }

    static func mono(size: CGFloat = 15, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - PaisaFont Typography Tokens & Presets

enum PaisaFont {
    // MARK: - Dynamic Functions
    static func bold(_ size: CGFloat, design: Font.Design = .rounded) -> Font { Font.bold(size, design: design) }
    static func bold(size: CGFloat, design: Font.Design = .rounded) -> Font { Font.bold(size, design: design) }

    static func semibold(_ size: CGFloat, design: Font.Design = .rounded) -> Font { Font.semibold(size, design: design) }
    static func semibold(size: CGFloat, design: Font.Design = .rounded) -> Font { Font.semibold(size, design: design) }

    static func medium(_ size: CGFloat, design: Font.Design = .default) -> Font { Font.medium(size, design: design) }
    static func medium(size: CGFloat, design: Font.Design = .default) -> Font { Font.medium(size, design: design) }

    static func regular(_ size: CGFloat, design: Font.Design = .default) -> Font { Font.regular(size, design: design) }
    static func regular(size: CGFloat, design: Font.Design = .default) -> Font { Font.regular(size, design: design) }

    static func heavy(_ size: CGFloat, design: Font.Design = .rounded) -> Font { Font.heavy(size, design: design) }
    static func heavy(size: CGFloat, design: Font.Design = .rounded) -> Font { Font.heavy(size, design: design) }

    static func light(_ size: CGFloat, design: Font.Design = .default) -> Font { Font.light(size, design: design) }
    static func light(size: CGFloat, design: Font.Design = .default) -> Font { Font.light(size, design: design) }

    static func mono(size: CGFloat = 15, weight: Font.Weight = .semibold) -> Font {
        Font.mono(size: size, weight: weight)
    }

    // MARK: - Standard Semantic Presets
    static func display()  -> Font { bold(34, design: .rounded) }
    static func title1()   -> Font { bold(28, design: .rounded) }
    static func title2()   -> Font { semibold(22, design: .rounded) }
    static func title3()   -> Font { semibold(18, design: .rounded) }
    static func headline() -> Font { semibold(16, design: .default) }
    static func body()     -> Font { regular(15, design: .default) }
    static func callout()  -> Font { medium(14, design: .default) }
    static func caption()  -> Font { regular(12, design: .default) }
    static func caption2() -> Font { medium(11, design: .default) }
}
