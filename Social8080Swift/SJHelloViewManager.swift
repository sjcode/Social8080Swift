//
//  SJHelloViewManager.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import UIKit

// View and subview related stuffs should be written here.
class SJHelloViewManager: NSObject {

    @IBOutlet var view: UIView!

    weak var viewController: SJHelloViewController?

    override init() {
        super.init()
        NSBundle.mainBundle().loadNibNamed("SJHelloViewManager", owner: self, options: nil)
    }

    convenience init(parentViewController: SJHelloViewController) {
        self.init()
        self.viewController = parentViewController
    }

    func viewDidLoad() {
    }

    func viewDidAppear(animated: Bool) {
    }

    func viewWillDisappear(animated: Bool) {
    }

}
