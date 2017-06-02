//
//  YYPageFlowViewController.swift
//  YYPageFlowDemo
//
//  Created by ouyongyong on 2017/6/1.
//  Copyright © 2017年 kila. All rights reserved.
//

import Foundation
import UIKit

let cellIdentifier = "cellIdentifier"
let edgeInset:CGFloat = 0
let cardSize = CGSize(width: UIScreen.main.bounds.size.width*0.7, height: UIScreen.main.bounds.size.width*0.7*(380/524))

open class YYPageFlowViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, YYPageFlowLayoutDelegate {
    
    var originOffset:CGPoint = CGPoint.zero
    open var detailVC:UIViewController = UIViewController()
    
    lazy var flow:YYPageFLowLayout = { ()->YYPageFLowLayout in
        let flow:YYPageFLowLayout = YYPageFLowLayout()
        flow.scrollDirection = .horizontal;
        flow.itemSize = cardSize
        flow.minimumLineSpacing = edgeInset;
        flow.minimumInteritemSpacing = edgeInset;
        flow.sectionInset = UIEdgeInsets(top: 20, left: edgeInset, bottom: 20, right: edgeInset)
        
        return flow
    }()
    
    lazy var banner:UICollectionView = { () -> UICollectionView in
        var rect = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: cardSize.height + 20)
        if (self.navigationController != nil) {
            rect.size.height += (self.navigationController?.navigationBar.bounds.size.height)!
        }
        let banner:UICollectionView = UICollectionView(frame: rect, collectionViewLayout: self.flow)
        
        banner.delegate = self
        banner.dataSource = self
        banner.backgroundColor = UIColor.clear
        banner.register(UINib.init(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        banner.contentInset = UIEdgeInsets(top: 0, left: (rect.size.width - cardSize.width)/2 - edgeInset, bottom: 0, right: (rect.size.width - cardSize.width)/2-edgeInset)
        banner.decelerationRate = UIScrollViewDecelerationRateFast
//        banner.isPagingEnabled = true
        return banner
    }()
    
    var detailVCFrame:CGRect {
        get {
            let originY:CGFloat = self.banner.frame.size.height+self.banner.frame.origin.y + 35
            let height:CGFloat = self.view.frame.size.height - originY
            let width:CGFloat = self.view.frame.size.width - 34
            return CGRect(x: 34/2, y: originY, width: width, height: height)
        }
    }
    
    
    open override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.banner)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.setupGesture()
        self.setupDetailVC()
    }
    
    private func setupDetailVC() {
        
        self.detailVC.view.frame = self.detailVCFrame
        self.view.addSubview(self.detailVC.view)
    }
    
    private func setupGesture() {
        let ges = UIPanGestureRecognizer(target: self, action: #selector(handePan))
        self.view.addGestureRecognizer(ges)
    }
    
//MARK: YYPageFlowLayoutDelegate
    func layout(_ flowLayout: UICollectionViewLayout, didChangeIndex index: Int) {
        //
    }
    
//MARK: UICollectionViewDelegate, datasource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        let lbl:UILabel = cell.viewWithTag(999) as! UILabel
        lbl.text = "\(indexPath.row)"
        
        return cell
    }
    
    public func handePan(_ gesture : UIPanGestureRecognizer) {
//        print("handle pan \(gesture.translation(in: self.view))")
        
        var offset = CGPoint.zero
        
        if gesture.state == .began {
            originOffset = self.banner.contentOffset
        }
        offset = CGPoint(x: originOffset.x - (gesture.translation(in: self.view)).x, y: originOffset.y)
        
        if gesture.state == .ended {
            offset = self.flow.targetContentOffset(forProposedContentOffset: offset, withScrollingVelocity: gesture.velocity(in: self.view)) }
        
        self.banner.setContentOffset(offset, animated: (gesture.state == .ended))
        
        if gesture.state == .changed {
            UIView.beginAnimations("move", context: nil)
            let opacity:CGFloat = fabs(gesture.translation(in: self.view).x*2)/self.detailVCFrame.size.width
            self.detailVC.view.alpha = 1 - opacity
            UIView.commitAnimations()
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.6, animations: {
                self.detailVC.view.alpha = 1
            })
        }
    }
    
}



//MARK:YYPageFlowLayout
fileprivate protocol YYPageFlowLayoutDelegate {
    func layout(_ flowLayout : UICollectionViewLayout, didChangeIndex index : Int) -> Void
}

open class YYPageFLowLayout : UICollectionViewFlowLayout {
    var index = 0
    
    open override var collectionViewContentSize: CGSize {
        return super.collectionViewContentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleItemArray = super.layoutAttributesForElements(in: rect)

        for attr in visibleItemArray! {
            
            let xOffset = fabs(attr.center.x-(self.collectionView?.contentOffset.x)!-((self.collectionView?.frame.size.width)! / 2))
            var scale:CGFloat = xOffset / ((self.collectionView?.frame.size.width)!*0.7+edgeInset)
            scale = 1.0 - 0.25 * min(scale, 1.0)

            attr.transform3D = CATransform3DMakeScale(1*scale , 1*scale, 1)

        }
        
        return visibleItemArray
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        super.shouldInvalidateLayout(forBoundsChange: newBounds)
        return true
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // ProposeContentOffset是本来应该停下的位子
        var currentItemCenter:CGPoint = CGPoint.zero
        // 1. 先给一个字段存储最小的偏移量 那么默认就是无限大
        var minOffset:CGFloat = CGFloat.greatestFiniteMagnitude;
        // 2. 获取到可见区域的centerX
        let horizontalCenter:CGFloat = proposedContentOffset.x + self.collectionView!.bounds.size.width / 2;
        // 3. 拿到可见区域的rect
        let visibleRec:CGRect = CGRect(x: proposedContentOffset.x, y: 0, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        // 4. 获取到所有可见区域内的item数组
        let visibleAttributes:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: visibleRec)!
        
        // 遍历数组，找到距离中心最近偏移量是多少
        for  attr:UICollectionViewLayoutAttributes in visibleAttributes {
            // 可见区域内每个item对应的中心X坐标
            let itemCenterX:CGFloat = attr.center.x;
            // 比较是否有更小的，有的话赋值给minOffset
            if (fabs(itemCenterX - horizontalCenter) <= fabs(minOffset)) {
                minOffset = itemCenterX - horizontalCenter;
                currentItemCenter = attr.center
            }
            
        }

        var centerOffsetX:CGFloat = proposedContentOffset.x + minOffset;
  
        if (centerOffsetX > (self.collectionView?.contentSize.width)! - (self.sectionInset.left + self.sectionInset.right + self.itemSize.width)) {
            centerOffsetX = floor(centerOffsetX);
        }

        let indexPathNow:NSIndexPath? = self.collectionView?.indexPathForItem(at: currentItemCenter) as NSIndexPath?
        if indexPathNow?.row != index {
            index = (indexPathNow?.row)!
            print("index change to \(index)")
        }
        
        
        return CGPoint(x: centerOffsetX, y: proposedContentOffset.y)
    
    }
    
}
