//
//  OMJoystickViewModel.swift
//
//
//  Created by tichise on 2024/01/01.
//

import SwiftUI

/// OMJoystickViewModel
class OMJoystickViewModel: ObservableObject {
    @Published var locationX: CGFloat
    @Published var locationY: CGFloat
    @Published var joyStickState: JoyStickState
    
    // 8等分のラインを表示するか制御する
    @Published var isSplitLine: Bool = false

    // 大きなリングの中心座標
    var org: CGPoint {
        CGPoint(x: self.bigRingRadius, y: self.bigRingRadius)
    }

    // 大きなリングの半径
    let bigRingRadius: CGFloat
    
    // 小さなリングの半径
    let smallRingRadius: CGFloat
    
    // 大きなリングの直径
    var bigRingDiameter: CGFloat {
        bigRingRadius * 2
    }

    // 小さなリングの直径
    var smallRingDiameter: CGFloat {
        smallRingRadius * 2
    }

    init(bigRingRadius: CGFloat, smallRingRadius: CGFloat, isSplitLine: Bool) {
        self.bigRingRadius = bigRingRadius
        self.smallRingRadius = smallRingRadius
        self.locationX = bigRingRadius
        self.locationY = bigRingRadius
        self.joyStickState = .center
        self.isSplitLine = isSplitLine
    }

    var stickPosition: CGPoint {
        let stickPositionX = floor(locationX - bigRingRadius)
        let stickPositionY = floor((locationY - bigRingRadius) < 0 ? -1 * (locationY - bigRingRadius) : locationY - bigRingRadius)
        return CGPoint(x: stickPositionX, y: stickPositionY)
    }

    var smallRingLocationX: CGFloat {
        locationX - bigRingRadius
    }
    
    var smallRingLocationY: CGFloat {
        locationY - bigRingRadius
    }

    // ジョイスティックの状態を取得する
    func getJoyStickState() -> JoyStickState {
        var state: JoyStickState = .center
        let xValue = locationX - bigRingRadius
        let yValue = locationY - bigRingRadius
        
        if (abs(xValue) > abs(yValue)) {
            state = xValue < 0 ? .left : .right
        } else if (abs(yValue) > abs(xValue)) {
            state = yValue < 0 ? .up : .down
        }
        
        return state
    }

    // ドラッグ時のジェスチャー。
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged{ [weak self] value in
                guard let self = self else { return }
                let distance = self.org.getDistance(otherPoint: value.location)
                let smallRingLimitCenter = self.bigRingRadius - self.smallRingRadius
                
                if (distance <= smallRingLimitCenter) {
                    self.locationX = value.location.x
                    self.locationY = value.location.y
                } else {
                    let radian = self.org.getRadian(pointOnCircle: value.location)
                    let pointOnCircle = self.org.getPointOnCircle(radius: smallRingLimitCenter, radian: radian)
                    self.locationX = pointOnCircle.x
                    self.locationY = pointOnCircle.y
                }
                
                self.joyStickState = self.getJoyStickState()
                // completionHandlerの呼び出しを追加する必要がある
            }
            .onEnded{ [weak self] value in
                guard let self = self else { return }
                self.resetPosition()
                // completionHandlerの呼び出しを追加する必要がある
            }
    }

    // ジョイスティックの位置をリセットする
    func resetPosition() {
        locationX = bigRingRadius
        locationY = bigRingRadius
        joyStickState = .center
    }
}
