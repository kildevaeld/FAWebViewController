//
//  FAWebView.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 02/08/15.
//
//

import Foundation
import NJKWebViewProgress

@IBDesignable public class FAWebView : UIView, NJKWebViewProgressDelegate {
    public var delegate: UIWebViewDelegate? {
        get {
            return self.progressProxy?.webViewProxyDelegate
        }
        set (value) {
            self.progressProxy?.webViewProxyDelegate = value
        }
    }
    
    private var progressView: NJKWebViewProgressView?
    private var progressProxy: NJKWebViewProgress?
    var webView: UIWebView?
    
    @IBInspectable var progressBarColor : UIColor? {
        get {
            return self.progressView!.backgroundColor
        }
        set (value) {
            var v = value
            if value == nil {
                v = UIColor.blueColor()
            }
            self.progressView!.backgroundColor = v
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    private func commonInit () {
        
        var progressBarHeight: CGFloat = 2.0
        
        var bound = self.bounds
        
        bound.size.height = progressBarHeight
        
        self.progressProxy = NJKWebViewProgress()
        self.progressProxy!.progressDelegate = self
        self.progressView = NJKWebViewProgressView(frame: bound)
        self.progressView!.autoresizingMask = .FlexibleWidth //| .FlexibleTopMargin
        bounds = self.bounds
        self.webView = UIWebView(frame: frame)
        self.webView?.delegate = self.progressProxy
        self.webView?.autoresizingMask = .FlexibleWidth //| .FlexibleTopMargin;
        self.addSubview(self.webView!)
    
    
        self.addSubview(self.progressView!)
    }
    
    
    public func loadRequest(request: NSURLRequest) {
        self.webView!.loadRequest(request)
    }
    
    public func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressView!.setProgress(progress, animated: true)
    }
}