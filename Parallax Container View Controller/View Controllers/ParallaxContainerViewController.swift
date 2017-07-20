//
//  ParallaxContainerViewController.swift
//  ParallaxContainerViewController
//
//  Created by Jeff Hanna on 7/19/17.
//  Copyright © 2017 Stackberry. All rights reserved.
//

import UIKit

public protocol ParallaxContainerViewControllerDelegate: class {
    
    func parallaxContainerViewControllerDidScroll(offset: CGPoint)
    
}

public class ParallaxContainerViewController: UIViewController {

    // MARK: - ui elements
    
    public var scrollView: UIScrollView!
    public var scrollContentView: UIView!
    
    private let backgroundImageView = UIImageView()
    
    // MARK: - constraints
    
    public var placeholderWidthConstraint: NSLayoutConstraint!
    
    // MARK: - properties
    
    public weak var delegate: ParallaxContainerViewControllerDelegate?
    
    public var viewControllers: [UIViewController] = [] {
        
        willSet {
            
            // remove previous view controllers
            
            for viewController in viewControllers {
                viewController.willMove(toParentViewController: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
            
        }
        
        didSet {
            configureViewControllers()
        }
        
    }
    
    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
            updateBackgroundImageViewFrame()
        }
    }
    
    private var backgroundScrollRatio: CGFloat {
        
        // scroll ratio is determined by image size, image is always full height
        
        let totalScrollWidth = scrollContentView.bounds.size.width
        let maximumScrollWidth = totalScrollWidth - view.bounds.size.width
        let backgroundScrollRatio = (backgroundImageView.bounds.size.width - view.bounds.size.width) / maximumScrollWidth
        
        return backgroundScrollRatio
        
    }
    
    public var currentIndex: Int {
        
        let offset = scrollView.contentOffset.x
        let currentIndex = max(0, Int(round(offset / view.bounds.size.width)))
        
        return currentIndex
        
    }
    
    public var currentViewController: UIViewController? {
        
        guard viewControllers.count > currentIndex else {
            return nil
        }
        
        return viewControllers[currentIndex]

    }

    // MARK: status bar
    
    public var childViewControllerForStatusBarStyleOverride: UIViewController?
    
    public override var childViewControllerForStatusBarStyle: UIViewController? {
        return childViewControllerForStatusBarStyleOverride ?? currentViewController
    }
    
    public var childViewControllerForStatusBarHiddenOverride: UIViewController?
    
    public override var childViewControllerForStatusBarHidden: UIViewController? {
        return childViewControllerForStatusBarHiddenOverride ?? currentViewController
    }
    
    // MARK: - init
    
    public convenience init(backgroundImage: UIImage, viewControllers: [UIViewController]) {
        self.init()
        self.viewControllers = viewControllers
        self.backgroundImage = backgroundImage
        backgroundImageView.image = backgroundImage
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    // MARK: - view lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
     
        configureScrollView()
        configureScrollContentView()
        configureBackgroundImageView()
        updateBackgroundImageViewFrame()
        configureViewControllers()
                
    }
    
    func didPressPreviousButton() {
        scrollToPreviousPage()
    }
    
    func didPressNextButton() {
        scrollToNextPage()
    }
    
    // MARK: - layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackgroundImageViewFrame()
        scrollToNearestHorizontalPage()
    }
    
    // MARK: - methods
    
    private func configureScrollView() {
        
        guard scrollView == nil else {
            return
        }
        
        scrollView = UIScrollView()
        
        // appearance
        
        scrollView.backgroundColor = .clear
        
        // behavior
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        
        // layout
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: scrollView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1,
                               constant: 0)
            ])
        
        // kvo
        
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [], context: nil)
        
    }
    
    private func configureScrollContentView() {
        
        guard scrollContentView == nil else {
            return
        }
        
        scrollContentView = UIView()
        
        // appearance
        
        scrollContentView.backgroundColor = .clear
        
        // layout
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: scrollContentView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollContentView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollContentView,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: scrollContentView,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .trailing,
                               multiplier: 1,
                               constant: 0),
            ])
        
        placeholderWidthConstraint = NSLayoutConstraint(item: scrollContentView,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: view,
                                                        attribute: .width,
                                                        multiplier: 1,
                                                        constant: 0)
        
        view.addConstraints([
            placeholderWidthConstraint,
            NSLayoutConstraint(item: scrollContentView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .height,
                               multiplier: 1,
                               constant: 0)
            ])
        
    }
    
    private func configureBackgroundImageView() {
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.frame = view.bounds
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
        
    }
    
    private func configureViewControllers() {
        
        // early return if view did not load yet
        
        guard let _ = view else {
            return
        }
        
        // early return if view controllers empty
        
        guard !viewControllers.isEmpty else {
            placeholderWidthConstraint.isActive = true
            return
            
        }
        
        placeholderWidthConstraint.isActive = false
        
        for (index, viewController) in viewControllers.enumerated() {
            
            // all view controllers
            
            // add child view controller
            
            addChildViewController(viewController)
            scrollContentView.addSubview(viewController.view)
            viewController.willMove(toParentViewController: self)
            viewController.didMove(toParentViewController: self)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            // equal height and width to view
            
            view.addConstraints([
                NSLayoutConstraint(item: viewController.view,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .width,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: viewController.view,
                                   attribute: .height,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .height,
                                   multiplier: 1,
                                   constant: 0)
                ])
            
            // pin top and bottom to scroll content view
            
            scrollContentView.addConstraints([
                NSLayoutConstraint(item: viewController.view,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: scrollContentView,
                                   attribute: .top,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: viewController.view,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: scrollContentView,
                                   attribute: .bottom,
                                   multiplier: 1,
                                   constant: 0)
                ])
            
            if viewController == viewControllers.first {
                
                // first view controller
                
                // pin leading to scroll content view
                
                scrollContentView.addConstraint(NSLayoutConstraint(item: viewController.view,
                                                                   attribute: .leading,
                                                                   relatedBy: .equal,
                                                                   toItem: scrollContentView,
                                                                   attribute: .leading,
                                                                   multiplier: 1,
                                                                   constant: 0)
                )
                
            } else {
                
                // all view controllers but first
                
                // pin leading to previous view controllers trailing
                
                let previousViewController = viewControllers[index-1]
                
                scrollContentView.addConstraint(NSLayoutConstraint(item: viewController.view,
                                                                   attribute: .leading,
                                                                   relatedBy: .equal,
                                                                   toItem: previousViewController.view,
                                                                   attribute: .trailing,
                                                                   multiplier: 1,
                                                                   constant: 0)
                )
                
                if viewController == viewControllers.last {
                    
                    // last view controller
                    
                    // pin trailing to scroll content view
                    
                    scrollContentView.addConstraint(NSLayoutConstraint(item: viewController.view,
                                                                       attribute: .trailing,
                                                                       relatedBy: .equal,
                                                                       toItem: scrollContentView,
                                                                       attribute: .trailing,
                                                                       multiplier: 1,
                                                                       constant: 0)
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func updateBackgroundImageViewFrame() {
        
        // early return if no background image
        
        guard let backgroundImage = backgroundImage else {
            backgroundImageView.image = nil
            return
        }
        
        let aspectRatio = backgroundImage.size.width / backgroundImage.size.height
        let height = view.bounds.size.height
        let width = max(height * aspectRatio, view.bounds.size.width)
        
        // update frame
        
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // update offset based on scroll
        
        updateBackgroundImageViewOffset()
        
    }
    
    fileprivate func updateBackgroundImageViewOffset() {
        
        let minOffset = CGFloat(0)
        let maxOffset = max(0, backgroundImageView.bounds.size.width - view.bounds.size.width)
        let proportionalOffset = scrollView.contentOffset.x * backgroundScrollRatio
        
        backgroundImageView.frame.origin.x = -min(max(minOffset, proportionalOffset), maxOffset)
        
    }
    
    public func scrollToPreviousPage(animated: Bool = true) {
        
        var contentOffset = scrollView.contentOffset
        contentOffset.x = view.bounds.size.width * CGFloat(max(0, currentIndex - 1))
        scrollView.setContentOffset(contentOffset, animated: animated)
        
    }
    
    public func scrollToNearestHorizontalPage() {
        scrollView.contentOffset.x = view.bounds.size.width * CGFloat(currentIndex)
    }
    
    public func scrollToNextPage(animated: Bool = true) {
        
        var contentOffset = scrollView.contentOffset
        contentOffset.x = view.bounds.size.width * CGFloat(min(viewControllers.count-1, currentIndex + 1))
        scrollView.setContentOffset(contentOffset, animated: animated)
        
    }
    
    // MARK: - actions
    
    // MARK: - notification handlers
    
    // MARK: - kvo
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = object as? UIScrollView,
            scrollView == self.scrollView,
            keyPath == #keyPath(UIScrollView.contentOffset) else {
                return
        }
        
        // update background image
        
        updateBackgroundImageViewOffset()
        
        // forward offset to view controllers and delegate
        
        delegate?.parallaxContainerViewControllerDidScroll(offset: scrollView.contentOffset)
        
        for viewController in viewControllers {
            
            guard let viewController = viewController as? ParallaxContainerViewControllerDelegate else {
                continue
            }
            
            viewController.parallaxContainerViewControllerDidScroll(offset: scrollView.contentOffset)
            
        }
        
    }
    
}
