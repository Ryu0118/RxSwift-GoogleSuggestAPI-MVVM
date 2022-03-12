//
//  ViewController.swift
//  RxSwift-GoogleSuggestAPI-Sample
//
//  Created by Ryu on 2022/03/12.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class APICell : UITableViewCell {
    
    static let identifier  = "APICell"
    
    func setInfo(title:String) {
        self.textLabel?.text = title
    }
}

class ViewController: UIViewController {
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    let viewModel:SuggestAPIViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: SuggestAPIViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        bind()
    }
    
    private func setupViews() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.placeholder = "タイトルで探す"
            searchBar.tintColor = UIColor.gray
            searchBar.keyboardType = UIKeyboardType.default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(APICell.self, forCellReuseIdentifier: APICell.identifier)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        viewModel.outputs.suggestionsObserver
            .drive(tableView.rx.items(cellIdentifier: APICell.identifier, cellType: APICell.self)) { indexPath, suggestion, cell in
                cell.setInfo(title: suggestion.suggest)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .bind(to: self.viewModel.inputs.searchObserver)
            .disposed(by: disposeBag)
        
    }

}
