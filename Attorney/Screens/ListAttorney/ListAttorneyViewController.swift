//
//  ListAttorneyViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

final class ListAttorneyViewController: ViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        guard let viewModel = viewModel as? ListAttorneyViewModel else {
            return
        }
        noDataLabel.isHidden = true
        self.navigationItem.title = viewModel.category
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? ListAttorneyViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.getListAttorneysSuccess
            .subscribe(onNext: { [weak self] attorneys in
                if attorneys.isEmpty {
                    self?.noDataLabel.isHidden = false
                }
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AttorneyCell.self)
    }
}

extension ListAttorneyViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel as? ListAttorneyViewModel else { return 0 }
        return viewModel.arttorneys.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel as? ListAttorneyViewModel else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AttorneyCell.reuseIdentifier, for: indexPath) as? AttorneyCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: viewModel.arttorneys[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel as? ListAttorneyViewModel else { return }
        
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = viewModel.arttorneys[indexPath.row]._id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
}

