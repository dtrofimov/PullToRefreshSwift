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
    public var backgroundColor = UIColor.clearColor()
    
    public var arrowImage: UIImage? = nil
    
    public var spinnerColor = UIColor.grayColor()
    public var spinnerLineWidth: CGFloat = 3.0
    public var spinnerSize: CGFloat = 24
    
    public var titleColor = UIColor.grayColor()
    public var titleFont = UIFont.systemFontOfSize(14)
    public var titlePulling = "Потяните вниз для обновления"
    public var titleRefreshing = "Обновление"
    public var titleTriggered = "Отпустите для обновления"
    
    public var autoStopTime: Double = 0 // 0 is not auto stop
    public var fixedSectionHeader = false  // Update the content inset for fixed section headers
}