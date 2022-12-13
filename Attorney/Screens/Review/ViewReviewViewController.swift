//
//  ViewReviewViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/13/22.
//

import UIKit
import RxSwift

final class ViewReviewViewController: ViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Reviews"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = self.viewModel as? ViewReviewViewModel else { return }

        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.getReviewsDone
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
                self?.bindingUI()
            }).disposed(by: disposeBag)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReviewTableViewCell.self)
    }
    
    private func bindingUI() {
        guard let viewModel = self.viewModel as? ViewReviewViewModel else { return }
        totalLabel.text = "Total completed cases: \(viewModel.total)"
        ratingLabel.text = "Average rating: \(viewModel.rating)"
    }
}

extension ViewReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel as? ViewReviewViewModel else { return 0 }
        return viewModel.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel as? ViewReviewViewModel else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.reuseIdentifier, for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(with: viewModel.reviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
