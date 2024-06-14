//
//  OMJoystick.swift
//  Omicro
//
//  Created by tichise on 2020年8月9日 20/08/09.
//  Copyright © 2020 tichise. All rights reserved.
//

import SwiftUI

public struct OMJoystick: View {
    
    @ObservedObject var viewModel: OMJoystickViewModel
    
    var iconColor: Color
    var subRingColor: Color
    var bigRingNormalBackgroundColor: Color
    var bigRingDarkBackgroundColor: Color
    var bigRingStrokeColor: Color
    var leftIcon: Image?
    var rightIcon: Image?
    var upIcon: Image?
    var downIcon: Image?
    
    var isDebug = false
        
    public var completionHandler: ((_ joyStickState: JoyStickState, _ stickPosition: CGPoint, _ angle: CGFloat?, _ distanceFromOrigin: Int) -> Void)
    
    let iconPadding: CGFloat = 10
    
    var dragGesture: some Gesture {
        // minimumDistanceが1以上だとタッチイベントを一切拾わない
        DragGesture(minimumDistance: 0)
            .onChanged{ value in
                viewModel.onChanged(value: value)

                let stickPosition = viewModel.stickPosition

                // 角度を取得
                let angle = JoyStickStateCalculator.getAngle(stickPosition: stickPosition)
                
                let distanceFromOrigin = JoyStickStateCalculator.getDistanceFromOrigin(stickPosition: stickPosition)
                
                self.completionHandler(viewModel.joyStickState,  viewModel.stickPosition, angle, distanceFromOrigin)
        }
        .onEnded{ value in
            viewModel.onEnded()
            
            let angle: CGFloat? = nil
            let discanceFromOrigin = 0
            let stickPosition = viewModel.stickPosition
            
            self.completionHandler(viewModel.joyStickState,  stickPosition, angle, discanceFromOrigin)
        }
    }
    
    
    public init(isDebug: Bool = false, iconSetting: IconSetting? = nil, colorSetting: ColorSetting, smallRingRadius: CGFloat = 50, bigRingRadius: CGFloat = 140, isOctantLinesVisible: Bool = false,
        completionHandler: @escaping ((_ joyStickState: JoyStickState, _ stickPosition: CGPoint, _ angle: CGFloat?, _ distanceFromOrigin: Int) -> Void)) {
        
        self.isDebug = isDebug
        
        self.iconColor = colorSetting.iconColor
        self.subRingColor = colorSetting.subRingColor
        self.bigRingNormalBackgroundColor = colorSetting.bigRingNormalBackgroundColor
        self.bigRingDarkBackgroundColor = colorSetting.bigRingDarkBackgroundColor
        self.bigRingStrokeColor = colorSetting.bigRingStrokeColor
        
        if let iconSetting = iconSetting {
            self.leftIcon = iconSetting.leftIcon
            self.rightIcon = iconSetting.rightIcon
            self.upIcon = iconSetting.upIcon
            self.downIcon = iconSetting.downIcon
        }
        
        self.completionHandler = completionHandler
        
        // ViewModelの初期化
        self.viewModel = OMJoystickViewModel(isOctantLinesVisible: isOctantLinesVisible, smallRingRadius: smallRingRadius, bigRingRadius: bigRingRadius)
    }
    
    public var body: some View {
        
        VStack {
            upIcon?.renderingMode(.template)
                .foregroundColor(iconColor).padding(iconPadding)
            
            HStack() {
                leftIcon?.renderingMode(.template)
                    .foregroundColor(iconColor).padding(iconPadding)
                
                ZStack {
                    // 中央は直径280の場合は140:140
                    BigRing(
                        bigRingNormalBackgroundColor: bigRingNormalBackgroundColor,  bigRingDarkBackgroundColor: bigRingDarkBackgroundColor, 
                        bigRingStrokeColor: bigRingStrokeColor,
                        bigRingDiameter: viewModel.bigRingRadius*2).environmentObject(viewModel).gesture(dragGesture)
                    
                    SmallRing(smallRingDiameter: viewModel.smallRingRadius*2, subRingColor: subRingColor).offset(x: viewModel.smallRingLocationX, y: viewModel.smallRingLocationY).environmentObject(viewModel).allowsHitTesting(false)
                }
                
                rightIcon?.renderingMode(.template)
                    .foregroundColor(iconColor).padding(iconPadding)
            }
            
            downIcon?.renderingMode(.template)
                .foregroundColor(iconColor).padding(iconPadding)
            
            if isDebug {                
                VStack(spacing: 5) {
                    HStack() {
                        Text("LocationXY:").font(.body)
                        Text(viewModel.locationX.text()).font(.body)
                        Text(":").font(.body)
                        Text(viewModel.locationY.text()).font(.body)
                    }
                    HStack() {
                        Text("StickPosition:").font(.body)
                        Text(viewModel.stickPosition.x.text()).font(.body)
                        Text(":").font(.body)
                        Text(viewModel.stickPosition.y.text()).font(.body)
                    }
                    HStack {
                        Text("JoyStickState:").font(.body)
                        Text(viewModel.joyStickState.rawValue).font(.body)
                    }
                    HStack {
                        Text("DistanceFromOrigin:").font(.body)
                        Text(String(JoyStickStateCalculator.getDistanceFromOrigin(stickPosition: viewModel.stickPosition))).font(.body)
                    }
                    HStack {
                        Text("Angle:").font(.body)
                        Text(JoyStickStateCalculator.getAngle(stickPosition: viewModel.stickPosition).text()).font(.body)
                    }
                }
            }
        }.padding(40)
    }
}

struct OMJoystick_Previews1: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 5) {
                OMJoystick(isDebug: true, colorSetting: ColorSetting(subRingColor: .red, bigRingNormalBackgroundColor: .green, bigRingDarkBackgroundColor: .blue, bigRingStrokeColor: .yellow, iconColor: .red)) { (joyStickState, stickPosition, angle, distanceFromOrigin) in
                    
                }.frame(width: geometry.size.width-40, height: geometry.size.width-40)
            }
        }.padding(.top, 50)
    }
}

struct OMJoystick_Previews2: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 5) {
                OMJoystick(isDebug: true,  colorSetting: ColorSetting(iconColor: .orange), smallRingRadius: 30, bigRingRadius: 120, isOctantLinesVisible: true
                ) { (joyStickState, stickPosition, angle, distanceFromOrigin)  in

                }.frame(width: geometry.size.width-40, height: geometry.size.width-40)
            }
        }
        .padding(.top, 50.0)
    }
}
