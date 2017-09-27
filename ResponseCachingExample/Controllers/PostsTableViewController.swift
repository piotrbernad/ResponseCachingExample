//
//  PostsTableViewController.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 07/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import UIKit
import RxSwift
import DZNEmptyDataSet

class PostsTableViewController: UITableViewController {
    private let dataSource = PostsDataSource()
    private let disposeBag = DisposeBag()
    
    fileprivate var state = LoadableState<Post>.idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToDataSource()
        hideCellSeparators()
    }
    
    private func hideCellSeparators() {
        self.tableView.tableFooterView = UIView()
    }
    
    private func subscribeToDataSource() {
        
        self.tableView.dataSource = dataSource
        self.tableView.emptyDataSetSource = self
        
        dataSource.state.asObservable().subscribe(onNext: { [weak self] (state) in
            self?.state = state
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        dataSource.reloadData()
    }
}

extension PostsTableViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        switch self.state {
        case .loading:
            return NSAttributedString(string: NSLocalizedString("Loading...", comment: ""))
        case .error:
            return NSAttributedString(string: NSLocalizedString("Error", comment: ""))
        default:
            return NSAttributedString(string: "")
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        switch self.state {
        case .loading:
            return NSAttributedString(string: NSLocalizedString("Loading items from network", comment: ""))
        case .error(let error):
            return NSAttributedString(string: error.localizedDescription)
        default:
            return NSAttributedString(string: "")
        }
    }
}
