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
    func goToCaseList(cases: [Case])
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
        let isNoCase = viewModel.isEmpty()
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
        contentTableView.registerHeaderFooterNib(CaseHeaderView.self)
//        tableView.register(PrivilegeListingCardSkeletonTableCell.self)
        view.backgroundColor = .white
        contentTableView.isScrollEnabled = false
    }

    func scrollToBottom(index: Int) {
        guard let viewModel = viewModel as? CaseChildViewModel else { return }
        guard !viewModel.isEmpty() else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CaseChildViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return 0 }
        if !viewModel.isLoadingCases {
            if section == 0 {
                return min(viewModel.inProgressCases.count, 3)
            } else if section == 1 {
                return min(viewModel.completedCases.count, 3)
            } else if section == 2{
                return min(viewModel.cancelledCases.count, 3)
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return UITableViewCell() }
        if !viewModel.isLoadingCases {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CaseTableViewCell
            cell.selectionStyle = .none
            if indexPath.section == 0 {
                cell.configureCell(with: viewModel.inProgressCases[indexPath.row])
            } else if indexPath.section == 1 {
                cell.configureCell(with: viewModel.completedCases[indexPath.row])
            } else if indexPath.section == 2{
                cell.configureCell(with: viewModel.cancelledCases[indexPath.row])
            }
            return cell
        }
//        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PrivilegeListingCardSkeletonTableCell
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return }
        if viewModel.isEmpty() { return }
        if indexPath.section == 0 {
            guard viewModel.inProgressCases.count > indexPath.row else { return }
            let caseDetail = viewModel.inProgressCases[indexPath.row]
            delegate?.caseChildViewController(self, caseDetail: caseDetail, indexPath: indexPath)
        } else if indexPath.section == 1 {
            guard viewModel.completedCases.count > indexPath.row else { return }
            let caseDetail = viewModel.completedCases[indexPath.row]
            delegate?.caseChildViewController(self, caseDetail: caseDetail, indexPath: indexPath)
        } else if indexPath.section == 2{
            guard viewModel.cancelledCases.count > indexPath.row else { return }
            let caseDetail = viewModel.cancelledCases[indexPath.row]
            delegate?.caseChildViewController(self, caseDetail: caseDetail, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = self.viewModel as? CaseChildViewModel else { return UIView() }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CaseHeaderView.reuseIdentifier) as? CaseHeaderView
        if section == 0 {
            headerView?.configureHeader(title: "IN-PROGRESS", cases: viewModel.inProgressCases)
        } else if section == 1 {
            headerView?.configureHeader(title: "COMPLETED", cases: viewModel.completedCases)
        } else if section == 2 {
            headerView?.configureHeader(title: "CANCELLED", cases: viewModel.cancelledCases)
        }
        headerView?.didTapViewAll = { [weak self] cases in
            self?.delegate?.goToCaseList(cases: cases)
        }
        return headerView
    }
}


