//
//  CollectionViewDataSource.swift
//  Whatashadi
//
//  Created by Night Reaper on 29/10/15.
//  Copyright © 2015 Gagan. All rights reserved.
//


import UIKit

public typealias WillBeginDragginBlock = (_ scrollView : UIScrollView) -> ()
public typealias DidEndDraggingBlock = (_ scrollView : UIScrollView) -> ()
public typealias WillDisplayCellBlock = (_ cell : UICollectionViewCell) -> ()
public typealias DidEndDeceleratingBlock = (_ scrollView : UIScrollView) -> ()

open class BaseCollectionViewDataSource: NSObject  {
    
    public var items : Array<Any>?
    public var cellIdentifier : String?
    public var headerIdentifier : String?
    public var tableView  : UICollectionView?
    public var cellHeight : CGFloat = 0.0
    public var cellWidth : CGFloat = 0.0
//    var isServiceTypeCollectionView : Bool = false
//    var isFilterProductListing : Bool?
//    var isProductListing : Bool?

    public var configureCellBlock : ListCellConfigureBlock?
    public var aRowSelectedListener : DidSelectedRow?
    public var willBeginDraggingListener : WillBeginDragginBlock?
    public var didEndDraggingListener : DidEndDraggingBlock?
    public var willDisplayCellListener : WillDisplayCellBlock?
    public var didEndDeceleratingBlock : DidEndDeceleratingBlock?
    public var scrollViewListener : DidEndDeceleratingBlock?
    public var blockSizeCell : BlockSizeForCollectionCell?

    public init (items : Array<Any>?  , tableView : UICollectionView? , cellIdentifier : String? , headerIdentifier : String? , cellHeight : CGFloat , cellWidth : CGFloat  , configureCellBlock : @escaping ListCellConfigureBlock  , aRowSelectedListener : @escaping DidSelectedRow, scrollViewListener: DidEndDeceleratingBlock? = nil)  {
        
        self.tableView = tableView
        self.items = items
        self.cellIdentifier = cellIdentifier
        
        self.headerIdentifier = headerIdentifier
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.configureCellBlock = configureCellBlock
        self.aRowSelectedListener = aRowSelectedListener
        self.scrollViewListener = scrollViewListener
        
    }
    
    override init() {
        super.init()
    }
    
}

extension BaseCollectionViewDataSource : UICollectionViewDelegate , UICollectionViewDataSource {
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let identifier = cellIdentifier else{
            fatalError("Cell identifier not provided")
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier ,
                                                      for: indexPath) as UICollectionViewCell
        if let block = self.configureCellBlock , let item: Any = self.items?[indexPath.row]{
            block(cell , item)
        }
        
        return cell
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let block = self.aRowSelectedListener{
            block(indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let block = willDisplayCellListener else { return }
        block(cell)
    }

}


extension BaseCollectionViewDataSource : UICollectionViewDelegateFlowLayout{
    
     public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let block = blockSizeCell else { return CGSize(width : cellWidth, height :cellHeight) }
        return block(indexPath)
        
//        if isServiceTypeCollectionView && indexPath.row == (items?.count ?? 0) - 1  {
//            let layout = collectionViewLayout as! UICollectionViewFlowLayout
//          // layout.scrollDirection = .horizontal
//            switch (items?.count ?? 0) % 3 {
//            case 1 :
//                return CGSize(width : (collectionView.bounds.width) - (layout.sectionInset.left + layout.sectionInset.right ) , height : cellHeight)
//            case 2 :
//                  return CGSize(width : cellWidth, height :cellHeight)
//               // return CGSize(width : (cellWidth * 2) + LowPadding , height : cellHeight)
//            default:
//                return CGSize(width : cellWidth, height : cellHeight)
//
//            }
//        }
        
        
    }
}

extension BaseCollectionViewDataSource : UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let block = willBeginDraggingListener else { return }
        block(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let block = didEndDraggingListener else { return }
        block(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let block = didEndDeceleratingBlock else { return }
        block(scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let block = scrollViewListener else { return }
        block(scrollView)
    }
}

//class CollectionViewDataSource : BaseCollectionViewDataSource {
//
//    var isServiceTypeCollectionView : Bool = false
//    var isFilterProductListing : Bool?
//    var isProductListing : Bool?
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let identifier = cellIdentifier else{
//            fatalError("Cell identifier not provided")
//        }
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier ,
//                                                      for: indexPath) as UICollectionViewCell
//        if isFilterProductListing == true{
//
//            if let block = self.configureCellBlock , let item: Any = isProductListing == false ? (self.items?[indexPath.section] as? DetailedSubCategories)?.arrProducts?[indexPath.row] : self.items?[indexPath.row] as? Product{
//                block(cell , item)
//            }
//        }
//        else{
//            if let block = self.configureCellBlock , let item: Any = self.items?[indexPath.row]{
//                block(cell , item)
//            }
//        }
//
//        return cell
//
//    }
//
//   override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        if self.isFilterProductListing == true{
//
//            if items?.count ?? 0 > 0{
//
//                if  let item: Any = isProductListing == false ? (self.items?[section] as? DetailedSubCategories)?.arrProducts : self.items{
//                    return (item as AnyObject).count
//                }
//            }
//            else{
//                 return 0
//            }
//
//        }
//
//        return self.items?.count ?? 0
//    }
//
//}
