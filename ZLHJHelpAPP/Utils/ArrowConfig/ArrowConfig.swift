//
//  ArrowConfig.swift
//  Example
//
//  Created by jiaxin on 2019/7/2.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation
import JXPatternLock

struct ArrowConfig: PatternLockViewConfig {
    var matrix: Matrix = Matrix(row: 3, column: 3)
    var gridSize: CGSize = CGSize(width: 70, height: 70)
    var connectLine: ConnectLine?
    var autoMediumGridsConnect: Bool = false
    var connectLineHierarchy: ConnectLineHierarchy = .bottom
    var errorDisplayDuration: TimeInterval = 1
    var initGridClosure: (Matrix) -> (PatternLockGrid)

    init() {
        let tintColor = UIColor.RGB(red: 18, green: 143, blue: 235, 1)
        initGridClosure = {(matrix) -> PatternLockGrid in
            let gridView = GridView()
            let outerStrokeLineWidthStatus = GridPropertyStatus<CGFloat>.init(normal: 1, connect: 2, error: 2)
            let outerStrokeColorStatus = GridPropertyStatus<UIColor>(normal: tintColor, connect: tintColor, error: .red)
            gridView.outerRoundConfig = RoundConfig(radius: 33, lineWidthStatus: outerStrokeLineWidthStatus, lineColorStatus: outerStrokeColorStatus, fillColorStatus: nil)
            let innerFillColorStatus = GridPropertyStatus<UIColor>(normal: nil, connect: tintColor, error: .red)
            gridView.innerRoundConfig = RoundConfig(radius: 10, lineWidthStatus: nil, lineColorStatus: nil, fillColorStatus: innerFillColorStatus)
            return gridView
        }
        let lineView = ConnectLineView()
        lineView.lineColorStatus = .init(normal: tintColor, error: .red)
        lineView.triangleColorStatus = .init(normal: tintColor, error: .red)
        lineView.isTriangleHidden = false
        lineView.lineWidth = 3
        connectLine = lineView
    }
}
