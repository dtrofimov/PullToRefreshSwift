//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import UIKit

struct PullToRefreshConst {
    static let pullTag = 810
    static let pushTag = 811
    static let alpha = true
    static let height: CGFloat = 49
    static let animationDuration: Double = 0.5
    static let fixedTop = true // PullToRefreshView fixed Top
    static let arrowLeftOffset: CGFloat = 16
    static let titleLeftOffset: CGFloat = 10
    static let imageName = "pulltorefresharrow.png"
}

public struct PullToRefreshOption {
    
    public init() {
        self.backgroundColor = UIColor.clearColor()
        self.arrowImage = nil
        self.spinnerColor = UIColor.grayColor()
        self.spinnerLineWidth = 3.0
        self.spinnerSize = 24
        self.titleColor = UIColor.grayColor()
        self.titleFont = UIFont.systemFontOfSize(14)
        self.titlePulling = "Потяните вниз для обновления"
        self.titleRefreshing = "Обновление"
        self.titleTriggered = "Отпустите для обновления"
        self.autoStopTime = 0
        self.fixedSectionHeader = false
    }
    public var backgroundColor: UIColor
    public var arrowImage: UIImage?
    public var spinnerColor: UIColor
    public var spinnerLineWidth: CGFloat
    public var spinnerSize: CGFloat
    public var titleColor: UIColor
    public var titleFont: UIFont
    public var titlePulling: String
    public var titleRefreshing: String
    public var titleTriggered: String
    public var autoStopTime: Double         // 0 is not auto stop
    public var fixedSectionHeader: Bool     // Update the content inset for fixed section headers
    
}