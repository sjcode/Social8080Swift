//
//  SJViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        configBackButtonStyle()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func configBackButtonStyle(){
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "icon_back"), forState: .Normal)
        button.addTarget(self, action: #selector(back(_:)), forControlEvents: .TouchUpInside)
        button.sizeToFit()
        let backitem = UIBarButtonItem.init(customView: button)
        navigationItem.leftBarButtonItem = backitem
    }
    
    func back(sender : AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
}
