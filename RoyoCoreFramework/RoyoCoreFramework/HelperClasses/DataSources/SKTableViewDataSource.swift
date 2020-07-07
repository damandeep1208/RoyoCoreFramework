//
//  TableViewDataSource.swift
//  SafeCity
//
//  Created by Aseem 13 on 29/09/15.
//  Copyright (c) 2015 Taran. All rights reserved.
//


import UIKit

public typealias SKBlock_ConfigCellBlock       = (_ indexpath: IndexPath, _ cell: Any?, _ item: Any?) -> ()
public typealias SKBlock_DidSelectRow          = (_ indexPath: IndexPath , _ cell: Any?) -> ()
public typealias SKBlock_WillDisplayCell       = (_ indexPath: IndexPath, _ cell: Any?) -> ()
public typealias SKBlock_DidScroll             = (_ scrollView: UIScrollView) -> ()
public typealias SKBlock_CellIdentifier        = (_ indexPath: IndexPath) -> String?
public typealias SKBlock_HeightForRowAt        = (_ indexPath: IndexPath) -> (CGFloat)
public typealias SKBlock_DidDeSelectRow        = (_ indexPath: IndexPath) -> ()
public typealias SKBlock_CanEditRowAtIndexPath = (_ indexPath: IndexPath) -> (Bool)
public typealias SKBlock_CommitEditingStyle    = (_ editingStyle: UITableViewCell.EditingStyle, _ indexPath: IndexPath) -> ()
public typealias SKBlock_RefreshTableList      = () -> ()

open class SKTableViewDataSource: NSObject  {
    
    public var tableView : UITableView?
    private var refreshControl : UIRefreshControl?

    public var items: [Any]? {
        didSet {
            endRefreshing()
        }
    }

    public var cellIdentifier: String?
    public var configureCellBlock          :       SKBlock_ConfigCellBlock?
    public var aRowSelectedListener        :       SKBlock_DidSelectRow?
    public var block_DidScroll             :       SKBlock_DidScroll?
    public var block_WillDisplayCell       :       SKBlock_WillDisplayCell?
    public var scrollDidEndDraging         :       SKBlock_DidScroll?
    public var blockCellIdentifier         :       SKBlock_CellIdentifier?
    public var block_HeightForRowAt        :       SKBlock_HeightForRowAt?
    public var block_DidDeSelectRow        :       SKBlock_DidDeSelectRow?
    public var canEditRow                  :       SKBlock_CanEditRowAtIndexPath?
    public var block_CommitEditingStyle    :       SKBlock_CommitEditingStyle?
    
    //    var direction: DirectionForScroll?
    
    public var cellHeight: CGFloat = UITableView.automaticDimension
    
    public var refreshTable: SKBlock_RefreshTableList? {
        didSet {
            if refreshTable == nil {
                refreshControl = nil
                tableView?.refreshControl = nil
                return
            }
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
            tableView?.refreshControl = refreshControl
        }
    }
    
    public init (items: [Any]? = [], tableView: UITableView?, cellIdentifier: String? = nil, cellHeight:CGFloat = UITableView.automaticDimension) {
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.tableView = tableView
        self.cellHeight = cellHeight
    }
    
    override init() {
        super.init()
    }
    
    public func reloadTable(items: [Any]?) {
        self.items = items
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.reloadData()
    }
    
    @objc private func refreshTableData() {
        refreshTable?()
    }
    
    @objc public func beginRefreshing() {
        refreshControl?.beginRefreshing()
    }
    
    @objc public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

extension SKTableViewDataSource: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.items?[indexPath.row]

        var identifierCell = self.blockCellIdentifier?(indexPath)
        
        if identifierCell == nil {
            identifierCell = cellIdentifier
        }
        
        guard let identifier = identifierCell else {
            fatalError("Cell identifier not provided")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Cell not provided")
        }

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if let block = self.configureCellBlock {
            block(indexPath, cell, item)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let block = self.aRowSelectedListener,
            case let cell as Any = tableView.cellForRow(at: indexPath) {
            block(indexPath , cell)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return /self.items?.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.block_HeightForRowAt?(indexPath)) ?? cellHeight
    }   
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let block = block_WillDisplayCell {
            block(indexPath, cell)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let block = block_DidScroll {
            block(scrollView)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let block = scrollDidEndDraging {
            block(scrollView)
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let block = block_DidDeSelectRow {
            block(indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let block = canEditRow {
           return block(indexPath)
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let block = block_CommitEditingStyle {
            block(editingStyle, indexPath)
        }
    }
}

//MARK:- ======== Extension UITableView ========
extension UITableView {
    
    func registerCells(nibNames:[String]) {
        nibNames.forEach({
            [weak self] in
            let nib = UINib(nibName: $0, bundle: nil)
            self?.register(nib, forCellReuseIdentifier: $0)
        })
    }
}

//MARK:- ======== Extension UICollectionView ========
extension UICollectionView {
    
    func registerCells(nibNames:[String]) {
        nibNames.forEach({
            [weak self] in
            let nib = UINib(nibName: $0, bundle: nil)
            self?.register(nib, forCellWithReuseIdentifier: $0)
        })
    }
}
