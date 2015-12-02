//
//  FAMapViewController.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 02/08/15.
//
//

import Foundation
import UIKit
import NJKWebViewProgress


func darkerColorForColor(color: UIColor) -> UIColor {
    
    var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
    
    if color.getRed(&r, green: &g, blue: &b, alpha: &a){
        return UIColor(red: max(r - 0.2, 0.0), green: max(g - 0.2, 0.0), blue: max(b - 0.2, 0.0), alpha: a)
    }
    
    return UIColor()
}

func lighterColorForColor(color: UIColor) -> UIColor {
    
    var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
    
    if color.getRed(&r, green: &g, blue: &b, alpha: &a){
        return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha: a)
    }
    
    return UIColor()
}

enum ArrowDirection {
    case Right
    case Left
}


class ClickableView: UIView {
    var handler: ((sender: ClickableView) -> Void)?
    enum State {
        case Active, Default
    }
    var state: State = .Default
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.state = .Active
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.state = .Default
        self.setNeedsDisplay()
        
        self.handler?(sender: self)
    }
}

@IBDesignable class ArrowView : ClickableView {
    @IBInspectable var color: UIColor = UIColor.blackColor()
    @IBInspectable var strokeWidth: CGFloat = 1.0
    var direction: ArrowDirection = .Right {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    
    override func drawRect(rect: CGRect) {
        
        let frameSize = rect.size;
        let viewFrame = rect;
        let context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        
        let col = self.state == .Default ? self.color : lighterColorForColor(self.color)
        
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.backgroundColor!.CGColor)
        CGContextFillRect(context, rect)
        CGContextSetStrokeColorWithColor(context, col.CGColor);
        //Set the width of the pen mark
        //CGContextSetLineCap(context,kCGLineCapRound);
        CGContextSetLineWidth(context, self.strokeWidth);
        
        
        
        switch (self.direction) {
        case .Left:
            CGContextMoveToPoint(context, frameSize.width, 0 );
            CGContextAddLineToPoint(context, 0, frameSize.height/2);
            CGContextAddLineToPoint(context, frameSize.width, frameSize.height);
        case .Right:
            CGContextMoveToPoint(context, 0, 0 );
            CGContextAddLineToPoint(context, frameSize.width, frameSize.height/2);
            CGContextAddLineToPoint(context, 0, frameSize.height);
        }
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
}

@IBDesignable class CloseView : ClickableView {
    
    @IBInspectable var color: UIColor = UIColor.darkGrayColor()
    @IBInspectable var strokeWidth: CGFloat = 1.0
    
    
    
    
    override func drawRect(rect: CGRect) {
        
        
        let frameSize = rect.size;
        let col = self.state == .Default ? self.color : lighterColorForColor(self.color)
        
        let context = UIGraphicsGetCurrentContext();
        
        
        CGContextClearRect(context, rect);
        
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.backgroundColor!.CGColor)
        CGContextFillRect(context, rect)
        CGContextSetStrokeColorWithColor(context, col.CGColor);
        //Set the width of the pen mark
        //CGContextSetLineCap(context,kCGLineCapRound);
        CGContextSetLineWidth(context, self.strokeWidth);
        
        
        CGContextMoveToPoint(context, frameSize.width, 0 );
        CGContextAddLineToPoint(context, 0, frameSize.height);
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, frameSize.width, frameSize.height);
        

        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
}

@IBDesignable public class FAWebViewController : UIViewController, UIWebViewDelegate {
    private var _webView: FAWebView?
    private var _bar: UIToolbar?
    public var toolbar : UIToolbar? {
        return self._bar
    }
    private var _closeButton: UIBarButtonItem?
    private var _backButton: UIBarButtonItem?
    private var _forwardButton: UIBarButtonItem?
    
    public var webView: FAWebView {
        get {
            if _webView == nil {
                _webView = FAWebView(frame: self.view.bounds)
                _webView!.autoresizingMask = .FlexibleWidth //| .FlexibleTopMargin
            }
            return _webView!
        }
    }
    
    @IBInspectable public var progressBarColor : UIColor? {
        get {
            return self.webView.progressBarColor
        }
        set (value) {
            self.webView.progressBarColor = value
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        self.setupViews()
    
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let request = NSURLRequest(URL: NSURL(string: "http://google.com")!)
        
        //self.webView.loadRequest(request)
    }
    
    // MARK: - WebView Delegate
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Error \(error)")
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        self._backButton?.enabled = self.webView.webView!.canGoBack
        self._forwardButton?.enabled = self.webView.webView!.canGoForward
        
        return true
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    
    
    private func setupViews () {
        self.view.opaque = false
        var toolbarRect: CGRect
        let hasNavigation = self.navigationController != nil
        
        var offset = hasNavigation ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height
        
        if self.presentingViewController != nil {
            offset = 0
        }
        
        if hasNavigation {
            toolbarRect = self.navigationController!.navigationBar.bounds
            
        } else {
            var bounds = self.view.bounds
            toolbarRect = CGRect(x: 0.0, y: 0.0+offset, width: bounds.size.width, height: 44.0)
            self._bar = UIToolbar(frame: toolbarRect)
            _bar!.autoresizingMask = .FlexibleWidth
            self.view.addSubview(self._bar!)
            
            bounds = self.webView.frame
            
            bounds.size.height -= toolbarRect.size.height + offset
            bounds.origin.y += toolbarRect.size.height + offset
            self.webView.frame = bounds
        }
        
        
        self.view.addSubview(self.webView)
        
        var items: [UIBarButtonItem] = []
        var space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        
        if hasNavigation {
            items.append(space)
        }
        let selector = "onBarButton:"
        
        let arrowRect = CGRect(x: 0, y: 0, width: toolbarRect.height - 30, height: toolbarRect.height - 20)
        
        var arrowView = ArrowView(frame: arrowRect)
        arrowView.direction = .Left
        arrowView.tag = 200
        arrowView.handler = self.onBarButton
        arrowView.color = UIColor.whiteColor() //_bar!.tintColor
        _backButton = UIBarButtonItem(customView: arrowView)
        
        //_forwardButton = UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: Selector(selector))
    
        arrowView = ArrowView(frame: arrowRect)
        arrowView.direction = .Right
        arrowView.tag = 201
        arrowView.handler = self.onBarButton
        arrowView.color = UIColor.whiteColor()// _bar!.tintColor
        _forwardButton = UIBarButtonItem(customView: arrowView)
        
        let s = UIBarButtonItem(barButtonSystemItem:.FixedSpace, target: nil, action: nil)
        s.width = 8
        items += [_backButton!, s, _forwardButton!]
        
        if !hasNavigation {
            
            //_closeButton = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector(selector))
            let closeView = CloseView(frame: CGRect(x:0,y:0,width:toolbarRect.height - 20,height:toolbarRect.height - 20))
            _closeButton = UIBarButtonItem(customView:closeView)
            closeView.tag = 202
            closeView.handler = self.onBarButton
            closeView.color = UIColor.whiteColor() //_bar!.tintColor
            items.append(space)
            
            items.append(_closeButton!)
        }
        
        
        
        
        
        self._bar?.items = items
    }
    
    
    func onBarButton(sender: ClickableView) {
        if sender.tag == 200 && self.webView.webView!.canGoBack {
            self.webView.webView?.goBack()
        } else if sender.tag == 201 && self.webView.webView!.canGoForward {
            self.webView.webView?.goForward()
        } else if sender.tag == 202 {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}