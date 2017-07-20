//
//  ViewController.swift
//  ParallaxContainerViewController
//
//  Created by Jeff Hanna on 7/19/17.
//  Copyright © 2017 Stackberry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // setup view controllers
        
        var viewControllers: [UIViewController] = []
        
        // page 1
        
        let viewController1 = TextViewController(text: "This is the Parallax Container View Controller")
        viewControllers.append(viewController1)
        
        // page 2
        
        let viewController2 = TextViewController(text: "It's a single Swift 3 file")
        viewControllers.append(viewController2)
        
        
        // page 3
        
        let viewController3 = TextViewController(text: "Just drop in your view controllers and a background image")
        viewControllers.append(viewController3)
        
        // page 4
        
        let viewController4 = TextViewController(text: "The parallax effect is determined by the images aspect ratio and the number of view controllers")
        viewControllers.append(viewController4)
        
        // page 5
        
        let viewController5 = TextViewController(text: "If the view controllers conform to the delegate, they can respond to the scroll position")
        viewControllers.append(viewController5)
        
        let parallaxContainerViewController = ParallaxContainerViewController(backgroundImage: #imageLiteral(resourceName: "background"), viewControllers: viewControllers)
        present(parallaxContainerViewController, animated: false, completion: nil)
        
    }

}

