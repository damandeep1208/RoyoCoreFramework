//
//  TableViewDataSource.swift
//  Realm
//
//  Created by Night Reaper on 29/09/15.
//  Copyright (c) 2015 Gagan. All rights reserved.
//


import UIKit
import SkeletonView

public typealias ListCellConfigureBlock = (_ cell : Any , _ item : Any?) -> ()
public typealias DidSelectedRow = (_ indexPath : IndexPath) -> ()
public typealias ViewForHeaderInSection = (_ section : Int) -> UIView?
public typealias BlockSizeForCollectionCell = (_ index : IndexPath) -> CGSize
public typealias SwipeToDelete = (_ indexPath : IndexPath) -> ()

open class TableViewDataSource: NSObject , UITableViewDelegate , UITableViewDataSource {
    
    public var data : Any?
    public var items : Array<Any>?
    public var cellIdentifier : String?
    public var skeletonCellIdentifier : String?
    public var tableView  : UITableView?
    public var tableViewRowHeight : CGFloat = 44.0
    
    public var configureCellBlock : ListCellConfigureBlock?
    public var aRowSelectedListener : DidSelectedRow?
    public var viewforHeaderInSection : ViewForHeaderInSection?
    public var headerHeight : CGFloat?
    public var swipeToDeleteBlock :  SwipeToDelete?
    
    public init (items : Array<Any>? , data : Any? = nil, height : CGFloat , tableView : UITableView? , cellIdentifier : String?  , configureCellBlock : ListCellConfigureBlock? , aRowSelectedListener : @escaping DidSelectedRow,aRowSwipeListner: SwipeToDelete? = nil, skeletonCellIdentifier: String?) {
        
        self.tableView = tableView
        self.items = items
        self.data = data
        self.cellIdentifier = cellIdentifier
        self.tableViewRowHeight = height
        self.configureCellBlock = configureCellBlock
        self.aRowSelectedListener = aRowSelectedListener
        self.swipeToDeleteBlock = aRowSwipeListner
        self.skeletonCellIdentifier = skeletonCellIdentifier

    }
    
    public override init() {
        super.init()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = cellIdentifier else{
            fatalError("Cell identifier not provided")
        }
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier , for: indexPath) as UITableViewCell
        cell.tag = indexPath.row
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if let block = self.configureCellBlock , let item: Any = self.items?[indexPath.row]{
            block(cell , item)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let block = self.aRowSelectedListener{
            block(indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    public func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (/skeletonCellIdentifier).isEmpty ? 0 : 1
    }
    
    public func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return skeletonCellIdentifier ?? ""
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewRowHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let block = viewforHeaderInSection else { return nil }
        return block(section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight ?? 0.0
    }
    
}
