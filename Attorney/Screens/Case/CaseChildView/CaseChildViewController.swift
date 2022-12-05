//
//  CaseChildViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import UIKit
import RxCocoa

protocol CaseChildViewControllerDelegate: AnyObject {
    func caseChildViewController(_ caseChildViewController: CaseChildViewController, caseDetail : Case, indexPath: IndexPath)
}


final class CaseChildViewController: ViewController {
    // MARK: - Section 2 - Private variable
    @IBOutlet private weak var contentTableView: UITableView!
    @IBOutlet private weak var noItemView: UIView!
    
    var caseType: CaseSegmentData = .yourRequest
    weak var delegate: CaseChildViewControllerDelegate?

    // MARK: - Section 3 - Lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        subscribeViewModelEvents()
        noItemView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    // MARK: - Section 4 - Binding, subscribe
    override func bindViewModel() {
        guard let viewModel = viewModel as? CaseChildViewModel else { return }
        
        // Do reset page
        viewModel.resetPageEvent.subscribe(onNext: { [weak self] _ in
            self?.contentTableView.scrollToTop(animated: false)
        })
    }

    private func subscribeViewModelEvents() {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return }

        viewModel.getRequestsSuccessEvent
            .subscribe(onNext: {[weak self] in
                guard let this = self else { return }
                this.updateUIAfterReloadData()
                this.contentTableView.reloadData()
                this.contentTableView.isScrollEnabled = true
            }).disposed(by: disposeBag)
    }

    // MARK: - Section 5 - IBAction

}

// MARK: - Section 6 - Private function
private extension CaseChildViewController {
    
    func updateUIAfterReloadData() {
        guard let viewModel = viewModel as? CaseChildViewModel else { return }
        let isNoCase = viewModel.casesToDisplay.isEmpty
        if !viewModel.isLoadingCases {
            noItemView.isHidden = !isNoCase
            contentTableView.isHidden = isNoCase
        } else {
            noItemView.isHidden = true
        }
    }

    func configTableView() {
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(CaseTableViewCell.self)
        contentTableView.contentInsetAdjustmentBehavior = .never
//        tableView.register(PrivilegeListingCardSkeletonTableCell.self)
        view.backgroundColor = .white
        contentTableView.isScrollEnabled = false
    }

    func scrollToBottom(index: Int) {
        guard let viewModel = viewModel as? CaseChildViewModel else { return }
        guard !viewModel.casesToDisplay.isEmpty else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CaseChildViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return 0 }
        return !viewModel.isLoadingCases ? viewModel.casesToDisplay.count : 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return UITableViewCell() }
        if !viewModel.isLoadingCases {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CaseTableViewCell
            cell.selectionStyle = .none
            cell.configureCell(with: viewModel.casesToDisplay[indexPath.row])
            return cell
        }
//        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PrivilegeListingCardSkeletonTableCell
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return }
        if viewModel.casesToDisplay.isEmpty { return }
        guard viewModel.casesToDisplay.count > indexPath.row else { return }
        let caseDetail = viewModel.casesToDisplay[indexPath.row]
        delegate?.caseChildViewController(self, caseDetail: caseDetail, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230.0
    }
}


