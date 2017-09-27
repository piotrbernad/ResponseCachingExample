//
//  PostsDataSource.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 07/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import UIKit
import RxSwift



class PostsDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier = "postTableViewCell"
    
    public let state = Variable(LoadableState<Post>.idle)
    
    private let disposeBag = DisposeBag()
    
    func reloadData() {
        self.state.value = .loading
        
        FakeAPI.allPosts().subscribe { [weak self] (event) in
            switch event {
            case .next(let posts):
                self?.state.value = .loaded(items: posts)
            case .error(let error):
                self?.state.value = .error(error: error)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.state.value.allItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let post = self.state.value.items()?[indexPath.row] else { return cell }
        
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = String(describing: post.id)
        
        return cell
    }
}
