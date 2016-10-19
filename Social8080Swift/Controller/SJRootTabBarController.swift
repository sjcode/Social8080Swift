//
//  SJRootTabBarController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import WMPageController_Swift

class SJRootTabBarController: SJTabBarController {
    let home = SJHomeViewController()
    let message = SJMessageViewController()
    let mine = SJMineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#E8ECEE")
        
        self.tabBar.tintColor = UIColor(hexString: "#FBC700")
        
        let v = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ControlSize.TABBAR_HEIGHT))

        v.backgroundColor = UIColor(hexString: "#28384D")
        self.tabBar.addSubview(v)
        
        self.addViews(home, normalImage: "Home", selectImage: "Home_selected", title: "列表")
        self.addViews(message, normalImage: "Message", selectImage: "Message_selected", title: "消息")
        self.addViews(mine, normalImage: "Male", selectImage: "Male_selected", title: "我的")
    }
    
    func addViews(vc : UIViewController, normalImage: String, selectImage: String, title: String) {
        
        let nav = SJNavigationController(rootViewController: vc)
        //nav.navigationBarHidden = true
        let itemImage = UIImage.init(named: normalImage)?.imageWithRenderingMode(.AlwaysOriginal)
        let selectedImage = UIImage.init(named: selectImage)?.imageWithRenderingMode(.AlwaysOriginal)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = itemImage
        nav.tabBarItem.selectedImage = selectedImage
        
        self.addChildViewController(nav)
        
        
    }
    
    
}
