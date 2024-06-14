//
//  SwiftUIView.swift
//  
//
//  Created by tichise on 2024/01/01.
//

import SwiftUI

/// 大きなリング
struct BigRing: View {
    @EnvironmentObject var omJoystickViewModel: OMJoystickViewModel

    @Environment(\.colorScheme) var colorScheme
    
    var bigRingNormalBackgroundColor: Color
    var bigRingDarkBackgroundColor: Color
    var bigRingStrokeColor: Color
    
    var bigRingDiameter: CGFloat
    
    // 円周率を直接記述する
    private let piValue: Double = 3.14159265358979
    
    var body: some View {
        ZStack {
            Circle().stroke(bigRingStrokeColor, lineWidth: 10)
                .frame(width: bigRingDiameter, height: bigRingDiameter)
            
            Circle().fill(colorScheme == .dark ? bigRingDarkBackgroundColor : bigRingNormalBackgroundColor)
                .frame(width: bigRingDiameter, height: bigRingDiameter)
            
            if omJoystickViewModel.isOctantLinesVisible {
                let radius = min(bigRingDiameter, bigRingDiameter) / 2
                let center = CGPoint(x: bigRingDiameter / 2, y: bigRingDiameter / 2)
                
                let additionalAngle = piValue / 8 // 線の開始位置を調整
             
                ForEach(0..<8) { i in
                    Path { path in
                        path.move(to: center)
                        let angle = CGFloat(i) * piValue / 4 + additionalAngle
                        let endX = center.x + radius * cos(angle)
                        let endY = center.y + radius * sin(angle)
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(bigRingStrokeColor, lineWidth: 1)
                }
            }
        }.frame(width: bigRingDiameter, height: bigRingDiameter)
    }
}

// BingRingのPreview用
struct BigRing_Previews: PreviewProvider {
    static var previews: some View {
        BigRing(bigRingNormalBackgroundColor: .white, bigRingDarkBackgroundColor: .black, bigRingStrokeColor: .primary, bigRingDiameter: 120).environmentObject(OMJoystickViewModel(isOctantLinesVisible: true, smallRingRadius: 30, bigRingRadius: 60))
        
        BigRing(bigRingNormalBackgroundColor: .white, bigRingDarkBackgroundColor: .gray, bigRingStrokeColor: .red, bigRingDiameter: 220).environmentObject(OMJoystickViewModel(isOctantLinesVisible: true, smallRingRadius: 30, bigRingRadius: 60))
        
        BigRing(bigRingNormalBackgroundColor: .white, bigRingDarkBackgroundColor: .black, bigRingStrokeColor: .primary, bigRingDiameter: 120).environmentObject(OMJoystickViewModel(isOctantLinesVisible: false, smallRingRadius: 30, bigRingRadius: 60))
    }
}
