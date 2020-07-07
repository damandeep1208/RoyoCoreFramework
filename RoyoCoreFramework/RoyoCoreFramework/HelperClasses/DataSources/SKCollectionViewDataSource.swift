//
//  CollectionViewDataSource.swift
//  SafeCity
//
//  Created by Aseem 13 on 29/10/15.
//  Copyright © 2015 Taran. All rights reserved.
//


import UIKit

public typealias SKBlock_ScrollViewDragged = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> ()
public typealias SKBlock_WillDisplay = (_ indexPath: IndexPath) -> ()
public typealias SKBlock_SizeConfigureBlock = (_ indexPath : IndexPath) -> CGSize?

public typealias SKBlock_HeightFoHeaderInSection = (_ section: Int, _ sectionObj:TableViewHeaderObjectType) -> CGFloat?
public typealias SKBlock_ViewForHeaderInSection = (_ header: Any?, _ section: Int, _ sectionObj:TableViewHeaderObjectType) -> ()

    //MARK:- ======== TableViewHeaderObjectType ========
    public struct TableViewHeaderObjectType {
        
        var header: String = ""
        var footer: String = ""
        var rows:[Any] = []
        var type: Any?
        var subHeader:String = ""
        
        init(header: String = "", footer: String = "", rows: [Any]?, type: Any? = nil,subHeader:String = "") {
            self.header = header
            self.footer = footer
            self.rows = rows ?? []
            self.type = type
            self.subHeader = subHeader
        }
    }

open class SKCollectionViewDataSource: NSObject
{
    public var collectionView              :   UICollectionView?
    public var items                       :   [Any] = []
    public var cellHeight                  :   CGFloat = 0.0
    public var cellWidth                   :   CGFloat = 0.0
    public var cellIdentifier              :   String?
    public var headerIdentifier            :   String?
    
    public var scrollViewListener          :   SKBlock_DidScroll?
    public var configureCellBlock          :   SKBlock_ConfigCellBlock?
    public var aRowSelectedListener        :   SKBlock_DidSelectRow?
    public var willDisplay                 :   SKBlock_WillDisplayCell?
    public var blockSizeConfigure          :   SKBlock_SizeConfigureBlock?
    public var blockCellIdentifier         :   SKBlock_CellIdentifier?
    public var scrollViewDidEndDeclaring   :   SKBlock_DidScroll?
    public var scrollViewWillEndDragging   :   SKBlock_ScrollViewDragged?
    
    public var blockHeightHeaderSection    :   SKBlock_HeightFoHeaderInSection?
    public var blockViewHeaderSection      :   SKBlock_ViewForHeaderInSection?
    
    public init (items: [Any] = [],
          collectionView: UICollectionView?,
          cellIdentifier: String? = nil,
          headerIdentifier: String? = nil,
          cellHeight: CGFloat = 0.0,
          cellWidth: CGFloat = 0.0) {
        
        self.collectionView = collectionView
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.headerIdentifier = headerIdentifier
        self.cellWidth  = cellWidth
        self.cellHeight = cellHeight
        
        
    }
    
    override init() {
        super.init()
    }
    
    //MARK:- ======== Functions ========
    public func reload(items: [Any]?) {
        
        self.items = items ?? []
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.reloadData()
    }
}

extension SKCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var item: Any?
        
        if let items = items as? [TableViewHeaderObjectType] {
            item = items[indexPath.section].rows[indexPath.row]
        } else {
            item = self.items[indexPath.row]
        }
        
        var identifierCell = self.blockCellIdentifier?(indexPath)
        
        if identifierCell == nil {
            identifierCell = cellIdentifier
        }
        
        guard let identifier = identifierCell else {
            fatalError("Cell identifier not provided")
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as UICollectionViewCell
        
        if let block = self.configureCellBlock {
            block(indexPath, cell, item)
        }
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if ((items as? [TableViewHeaderObjectType]) != nil) {
            return items.count
        }
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = items as? [TableViewHeaderObjectType] {
            return items[section].rows.count
        }
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //      let item = self.items[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let block = self.aRowSelectedListener {
            block(indexPath, cell)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let block = willDisplay {
            block(indexPath, cell)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let block = self.scrollViewListener {
            block(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let block = self.scrollViewDidEndDeclaring {
            block(scrollView)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let block = self.scrollViewWillEndDragging {
            block(scrollView, velocity, targetContentOffset)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let items = items as? [TableViewHeaderObjectType] {
            guard let identifier = headerIdentifier else {
                fatalError("Cell identifier not provided")
            }
            
            if kind == UICollectionView.elementKindSectionHeader {
                
                let viewHeader =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
                
                if let block = self.blockViewHeaderSection {
                    block(viewHeader, indexPath.section, items[indexPath.section])
                }
                return viewHeader
            }
            else {
                return UICollectionReusableView()
            }
        } else {
            return UICollectionReusableView()
        }
        
    }
}

extension SKCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let block = blockSizeConfigure, let size = block(indexPath) {
            return size
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
