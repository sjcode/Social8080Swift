//
//  SJScrollTitleView.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

struct SJScrollMenuBarItem {
    var title : String?
    var type : Int?
}

protocol SJScrollTitleViewDataSource : NSObjectProtocol{
    func numberOfMenus() -> Int
    func titleAtIndex(index : Int) -> String
}

protocol SJScrollTitleViewDelegate : NSObjectProtocol {
    func didSelectedIndexOfTitle(view : SJScrollTitleView, index : Int)
}

class SJScrollTitleView: UIView {
    
    weak var delegate : SJScrollTitleViewDelegate?
    weak var datasource : SJScrollTitleViewDataSource?
    var oldIndex  = 0
    var currentIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI(){
        addSubview(scrollView)
    }
    
    func layoutLabels(){
        let count = datasource?.numberOfMenus()
        var offsetx : CGFloat = 15
        for index in 0...(count! - 1) {
            let title = datasource?.titleAtIndex(index)
            let label = SJTitleLabel()
            label.font = defaultFont(12)
            label.textColor = UIColor.darkGrayColor()
            label.text = title
            label.textAlignment = .Center
            label.sizeToFit()
            var frame = label.frame
            
            frame.size.width += 20
            frame.size.height = self.bounds.size.height
            frame.origin.x = offsetx
            label.frame = frame
            
            label.tag = index
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleLabelOnClick(_:)))
            label.addGestureRecognizer(tap)
            scrollView.addSubview(label)
            
            offsetx = CGRectGetWidth(frame) + offsetx
        }
        offsetx += 15
        scrollView.contentSize = CGSize(width: offsetx, height: bounds.size.height)
        if scrollView.subviews.count > 0{
            let label = scrollView.subviews[0] as! SJTitleLabel
            label.currentScale = 1.5
        }
    }
    
    func reloadMenus(){
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        layoutLabels()
    }
    
    func titleLabelOnClick(sender : UITapGestureRecognizer){
        guard let currentLabel = sender.view as? SJTitleLabel else{
            return
        }
        oldIndex = currentIndex
        currentIndex = currentLabel.tag
        let oldLabel = scrollView.subviews[oldIndex] as? SJTitleLabel
        oldLabel!.currentScale = 1.0
        currentLabel.currentScale = 1.5
        scrollSelectedItemToCenter(currentIndex)
        delegate?.didSelectedIndexOfTitle(self, index: currentIndex)
    }
    
    func scrollSelectedItemToCenter(selectedIndex : Int){
        let label = scrollView.subviews[selectedIndex] as! SJTitleLabel
        var offsetX = label.center.x - ScreenSize.SCREEN_WIDTH * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        
        var maxOffsetX = scrollView.contentSize.width - ScreenSize.SCREEN_WIDTH
        if maxOffsetX < 0 {
            maxOffsetX = 0
        }
        
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        scrollView.setContentOffset(CGPointMake(offsetX, 0), animated: true)
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height))
        scrollView.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.delegate = self
        return scrollView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SJScrollTitleView : UIScrollViewDelegate{
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dprint("开始拖拽.=================>")
        let parent = self.superview as? UIScrollView
        parent?.scrollEnabled = false
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dprint("结束拖拽.<=================== \(decelerate)")
        let parent = self.superview as? UIScrollView
        parent?.scrollEnabled = true
    }
}

class SJTitleLabel : UILabel{
    var currentScale : CGFloat = 1.0{
        didSet{
            UIView.animateWithDuration(0.2) { 
                self.transform = CGAffineTransformMakeScale(self.currentScale, self.currentScale)
            }
        }
    }
}