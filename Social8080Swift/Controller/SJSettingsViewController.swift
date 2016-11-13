//
//  SJSettingsViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/11/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJSettingsViewController: SJViewController {

    private lazy var tableView : UITableView = { [unowned self] in
        let v = UITableView(frame: self.view.bounds,
                            style: .Grouped)
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJProfileTableViewCell.self, forCellReuseIdentifier: "profilecell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mm_drawerController.openDrawerGestureModeMask = .None
        
    }
}

extension SJSettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
