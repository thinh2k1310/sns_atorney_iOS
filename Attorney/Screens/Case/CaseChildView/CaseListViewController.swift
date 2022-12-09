//
//  CaseListViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

final class CaseListViewController: ViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var cases: [Case] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.title = "List cases"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Section 4 - Binding, subscribe

    // MARK: - Section 5 - IBAction

}

// MARK: - Section 6 - Private function
private extension CaseListViewController {
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CaseTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.register(PrivilegeListingCardSkeletonTableCell.self)
        view.backgroundColor = .white
    }
}

// MARK: - UITableViewDataSource
extension CaseListViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CaseTableViewCell
        cell.selectionStyle = .none
        cell.configureCell(with: cases[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let provider = Application.shared.provider else { return }
        let caseDetailVC = R.storyboard.case.caseDetailViewController()!
        let caseDetailVM = CaseDetailViewModel(provider: provider)
        caseDetailVM.caseId = cases[indexPath.row]._id
        caseDetailVC.viewModel = caseDetailVM
        self.navigationController?.pushViewController(caseDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230.0
    }
}
