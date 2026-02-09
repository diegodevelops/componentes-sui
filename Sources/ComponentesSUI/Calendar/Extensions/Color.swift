//
//  Color.swift
//  ComponentesSUI
//
//  Created by Diego A. Perez Pares on 2/9/26.
//

import SwiftUI

extension Color {
    /// Returns either white or black color based on which provides better contrast
    /// with the current color (used as background)
    var contrastingTextColor: Color {
        // Convert Color to UIColor/NSColor to access RGB components
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        #elseif canImport(AppKit)
        let uiColor = NSColor(self)
        #endif
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using WCAG formula
        // https://www.w3.org/TR/WCAG20-TECHS/G17.html
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        
        // Use white text for dark backgrounds, black text for light backgrounds
        // Threshold of 0.5 works well for most cases
        return luminance > 0.5 ? .black : .white
    }
}
