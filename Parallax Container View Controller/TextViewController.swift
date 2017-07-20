//
//  TextViewController.swift
//  Parallax Container View Controller
//
//  Created by Jeff Hanna on 7/19/17.
//  Copyright © 2017 Stackberry. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    // MARK: - ui elements
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - properties
    
    var text: String = "" {
        didSet {
            if let label = label {
                label.text = text
            }
        }
    }
    
    // MARK: - init
    
    convenience init(text: String) {
        
        let type = type(of: self)
        let className = String(describing: type)
        let bundle = Bundle(for: type)
        self.init(nibName: className, bundle: bundle)
        
        self.text = text
        
    }
    
    // MARK: - view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // view
        
        view.backgroundColor = .clear
        
        // label
        
        label.text = text
        
    }

}
