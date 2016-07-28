//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//  Qiulang rewrites it to support pull down & push up
//
import UIKit

public class PullToRefreshView: UIView {
    enum PullToRefreshState {
        case Pulling
        case Triggered
        case Refreshing
        case Stop
        case Finish
    }
    
    // MARK: Variables
    let contentOffsetKeyPath = "contentOffset"
    let contentSizeKeyPath = "contentSize"
    var kvoContext = "PullToRefreshKVOContext"
    
    private var options: PullToRefreshOption
    private var backgroundView: UIView
    private var arrow: UIImageView
    private var spinner: SpinnerView
    private var titleLabel: UILabel
    
    private var scrollViewBounces: Bool = false
    private var scrollViewInsets: UIEdgeInsets = UIEdgeInsetsZero
    private var refreshCompletion: (Void -> Void)?
    private var pull: Bool = true
    
    private var positionY:CGFloat = 0 {
        didSet {
            if self.positionY == oldValue {
                return
            }
            var frame = self.frame
            frame.origin.y = positionY
            self.frame = frame
        }
    }
    
    var state: PullToRefreshState = PullToRefreshState.Pulling {
        didSet {
            if self.state == oldValue {
                return
            }
            switch self.state {
            case .Stop:
                stopAnimating()
            case .Finish:
                var duration = PullToRefreshConst.animationDuration
                var time = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.stopAnimating()
                }
                duration = duration * 2
                time = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.removeFromSuperview()
                }
            case .Refreshing:
                startAnimating()
                setTitle(options.titleRefreshing)
            case .Pulling: //starting point
                arrowRotationBack()
                setTitle(options.titlePulling)
            case .Triggered:
                arrowRotation()
                setTitle(options.titleTriggered)
            }
        }
    }
    
    // MARK: UIView
    public override convenience init(frame: CGRect) {
        self.init(options: PullToRefreshOption(),frame:frame, refreshCompletion:nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(options: PullToRefreshOption, frame: CGRect, refreshCompletion :(Void -> Void)?, down:Bool=true) {
        self.options = options
        self.refreshCompletion = refreshCompletion

        self.backgroundView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        self.backgroundView.backgroundColor = self.options.backgroundColor
        self.backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.arrow = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        self.arrow.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        
        self.arrow.image = UIImage(named: PullToRefreshConst.imageName, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
        
        self.spinner = SpinnerView(frame: CGRectMake(0, 0, options.spinnerSize, options.spinnerSize))
        self.spinner.lineWidth = options.spinnerLineWidth
        self.spinner.circleRadius = options.spinnerSize / 2.0
        self.spinner.color = options.spinnerColor
        self.spinner.autoresizingMask = self.arrow.autoresizingMask
        self.pull = down
        
        self.titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        self.titleLabel.text = options.titlePulling
        self.titleLabel.textColor = options.titleColor
        self.titleLabel.font = options.titleFont
        
        super.init(frame: frame)
        self.addSubview(spinner)
        self.addSubview(titleLabel)
        self.addSubview(backgroundView)
        self.addSubview(arrow)
        self.autoresizingMask = .FlexibleWidth
    }
    
    public func applyOptions(options: PullToRefreshOption) {
        self.options = options
        self.backgroundView.backgroundColor = options.backgroundColor
        self.spinner.lineWidth = options.spinnerLineWidth
        self.spinner.circleRadius = options.spinnerSize / 2.0
        self.spinner.color = options.spinnerColor
        self.spinner.frame = CGRectMake(spinner.frame.origin.x, spinner.frame.origin.y, options.spinnerSize, options.spinnerSize)
        self.titleLabel.textColor = options.titleColor
        self.titleLabel.font = options.titleFont
        self.arrow.image = options.arrowImage
    }
   
    public override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPointMake(frame.size.width / 2, frame.size.height / 2)
        self.arrow.center = center
        self.arrow.frame = CGRectMake(PullToRefreshConst.arrowLeftOffset, arrow.frame.origin.y, arrow.frame.width, arrow.frame.height)
        self.spinner.frame = arrow.frame
        self.titleLabel.center = center
        let titleX = PullToRefreshConst.arrowLeftOffset + self.spinner.frame.width + PullToRefreshConst.titleLeftOffset
        self.titleLabel.frame = CGRectMake(titleX, titleLabel.frame.origin.y, 0, 0)
        self.titleLabel.sizeToFit()
    }
    
    public override func willMoveToSuperview(superView: UIView!) {
        //superview NOT superView, DO NEED to call the following method
        //superview dealloc will call into this when my own dealloc run later!!
        self.removeRegister()
        guard let scrollView = superView as? UIScrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &kvoContext)
        if !pull {
            scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: .Initial, context: &kvoContext)
        }
    }
    
    private func setTitle(title: String) {
        self.titleLabel.text = title
        self.titleLabel.sizeToFit()
    }
    
    private func removeRegister() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
            if !pull {
                scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &kvoContext)
            }
        }
    }
    
    deinit {
        self.removeRegister()
    }
    
    // MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        guard let scrollView = object as? UIScrollView else {
            return
        }
        if keyPath == contentSizeKeyPath {
            self.positionY = scrollView.contentSize.height
            return
        }
        
        if !(context == &kvoContext && keyPath == contentOffsetKeyPath) {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        // Pulling State Check
        let offsetY = scrollView.contentOffset.y
        
        // Alpha set
        if PullToRefreshConst.alpha {
            var alpha = fabs(offsetY) / (self.frame.size.height + 40)
            if alpha > 0.8 {
                alpha = 0.8
            }
            self.arrow.alpha = alpha
        }
        
        if offsetY <= 0 {
            if !self.pull {
                return
            }
            print(offsetY)
            print(self.frame.size.height)
            if offsetY < -self.frame.size.height {
                // pulling or refreshing
                if scrollView.dragging == false && self.state != .Refreshing { //release the finger
                    self.state = .Refreshing //startAnimating
                } else if self.state != .Refreshing { //reach the threshold
                    self.state = .Triggered
                }
            } else if self.state == .Triggered {
                //starting point, start from pulling
                self.state = .Pulling
            }
            return //return for pull down
        }
        
        //push up
        let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
        if upHeight > 0 {
            // pulling or refreshing
            if self.pull {
                return
            }
            if upHeight > self.frame.size.height {
                // pulling or refreshing
                if scrollView.dragging == false && self.state != .Refreshing { //release the finger
                    self.state = .Refreshing //startAnimating
                } else if self.state != .Refreshing { //reach the threshold
                    self.state = .Triggered
                }
            } else if self.state == .Triggered  {
                //starting point, start from pulling
                self.state = .Pulling
            }
        }
    }
    
    // MARK: private
    
    private func startAnimating() {
        self.spinner.start()
        self.arrow.hidden = true
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollViewBounces = scrollView.bounces
        scrollViewInsets = scrollView.contentInset
        
        var insets = scrollView.contentInset
        if pull {
            insets.top += self.frame.size.height
        } else {
            insets.bottom += self.frame.size.height
        }
        scrollView.bounces = false
        UIView.animateWithDuration(PullToRefreshConst.animationDuration,
                                   delay: 0,
                                   options:[],
                                   animations: {
            scrollView.contentInset = insets
            },
                                   completion: { _ in
                if self.options.autoStopTime != 0 {
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(self.options.autoStopTime * Double(NSEC_PER_SEC)))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.state = .Stop
                    }
                }
                self.refreshCompletion?()
        })
    }
    
    private func stopAnimating() {
        self.spinner.stop()
        self.arrow.hidden = false
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollView.bounces = self.scrollViewBounces
        let duration = PullToRefreshConst.animationDuration
        UIView.animateWithDuration(duration,
                                   animations: {
                                    scrollView.contentInset = self.scrollViewInsets
                                    self.arrow.transform = CGAffineTransformIdentity
                                    }
        ) { _ in
            self.state = .Pulling
        }
    }
    
    private func arrowRotation() {
        UIView.animateWithDuration(0.2, delay: 0, options:[], animations: {
            // -0.0000001 for the rotation direction control
            self.arrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI-0.0000001))
        }, completion:nil)
    }
    
    private func arrowRotationBack() {
        UIView.animateWithDuration(0.2) {
            self.arrow.transform = CGAffineTransformIdentity
        }
    }
}
