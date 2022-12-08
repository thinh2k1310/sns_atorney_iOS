//
//  CategoryViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

final class CategoryViewController: ViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.title = "Category"
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self)
    }
}

extension CategoryViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel as? CategoryViewModel else { return 0 }
        return viewModel.categories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel as? CategoryViewModel else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: viewModel.categories[indexPath.row].rawValue)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel as? CategoryViewModel else { return }
        
        let listAttorneyVC = R.storyboard.listAttorney.listAttorneyViewController()!
        guard let provider = Application.shared.provider else { return }
        let listAttorneyVM = ListAttorneyViewModel(provider: provider)
        listAttorneyVM.category = viewModel.categories[indexPath.row].rawValue
        listAttorneyVC.viewModel = listAttorneyVM
        self.navigationController?.pushViewController(listAttorneyVC, animated: true)
    }
    
    
}
