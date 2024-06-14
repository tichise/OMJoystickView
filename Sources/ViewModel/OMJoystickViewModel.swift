//
//  OMJoystickViewModel.swift
//
//
//  Created by tichise on 2024/01/01.
//

import SwiftUI

/// OMJoystickViewModel
class OMJoystickViewModel: ObservableObject {
    // 8等分のラインを表示するか制御する
    public var isOctantLinesVisible: Bool
    
    public init(isOctantLinesVisible: Bool, smallRingRadius: CGFloat, bigRingRadius: CGFloat) {
        self.isOctantLinesVisible = isOctantLinesVisible
        self.smallRingRadius = smallRingRadius
        self.bigRingRadius = bigRingRadius
        
        self.locationX = bigRingRadius
        self.locationY = bigRingRadius
        self.joyStickState = .center
    }
    
    @Published public var joyStickState: JoyStickState = .center
    
    var smallRingRadius: CGFloat
    var bigRingRadius: CGFloat
    
    @Published var locationX: CGFloat = 0
    @Published var locationY: CGFloat = 0
    
    var smallRingLocationX: CGFloat {
        return locationX - bigRingRadius
    }
    
    var smallRingLocationY: CGFloat {
        return locationY - bigRingRadius
    }
    
    var stickPosition: CGPoint {
        let stickPositionX = floor(locationX - bigRingRadius)
        
        // 上をY軸プラスにするためにマイナスをかける
        var stickPositionY = floor(locationY - bigRingRadius) * -1
        
        // stickPositionYが-0の場合は-を消す
        if (stickPositionY == -0) {
            stickPositionY = 0
        }
        
        return CGPoint(x: stickPositionX, y: stickPositionY)
    }
    
    var org: CGPoint {
        return CGPoint(x: self.bigRingRadius, y: self.bigRingRadius)
    }
    
    // DragChangeでonChangedした時に実行する処理
    func onChanged(value: DragGesture.Value) {
        let distance = self.org.getDistance(otherPoint: value.location)
        
        let smallRingLimitCenter: CGFloat = self.bigRingRadius - self.smallRingRadius
        
        if (distance <= smallRingLimitCenter) {
            // 円の範囲内
            self.locationX = value.location.x
            self.locationY = value.location.y
            
            
        } else {
            // 円の範囲外の場合は
            let radian = self.org.getRadian(pointOnCircle: value.location)
            
            let pointOnCircle = self.org.getPointOnCircle(radius: smallRingLimitCenter, radian: radian)
            
            self.locationX = pointOnCircle.x
            self.locationY = pointOnCircle.y
        }
        
        // 原点からの距離を取得
        let distanceFromOrigin = JoyStickStateCalculator.getDistanceFromOrigin(stickPosition: stickPosition)
        
        // 角度を取得
        let angle = JoyStickStateCalculator.getAngle(stickPosition: stickPosition)
        
        if isOctantLinesVisible {
            // 八等分の場合
            self.joyStickState = JoyStickStateCalculator.getJoyStickStateOctant(angle: angle,
                stength: distanceFromOrigin
            )
        } else {
            // 四等分の場合
            self.joyStickState = JoyStickStateCalculator.getJoyStickStateQuadrant(angle: angle,
                distanceFromOrigin: distanceFromOrigin
            )
        }
    }

    // DragChangeでonEndedした時に実行する処理
    func onEnded() {
        self.locationX = self.bigRingRadius
        self.locationY = self.bigRingRadius
        
        self.joyStickState = .center
    }
}
