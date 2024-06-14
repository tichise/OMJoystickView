//
//  SmallRing.swift
//
//
//  Created by tichise on 2024/01/01.
//

import SwiftUI

/// Small ring
struct SmallRing: View {
    var smallRingDiameter: CGFloat
    var subRingColor: Color
    
    var body: some View {
        Circle().fill(subRingColor)
            .frame(width: smallRingDiameter, height: smallRingDiameter)
    }
}

// SmallRingのPreview用
struct Small_Previews: PreviewProvider {
    static var previews: some View {
        SmallRing(smallRingDiameter: 100, subRingColor: .primary)
    }
}
