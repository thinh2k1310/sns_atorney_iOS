//
//  RequestChildViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import UIKit

protocol RequestChildViewControllerDelegate: AnyObject {
    func requestChildViewController(_ requestChildViewController: RequestChildViewController, openRequestDetail case: Case, indexPath: IndexPath)
}

final class RequestChildViewController: ViewController {
    @IBOutlet private weak var contentTableView: UITableView!
    @IBOutlet private weak var noItemView: UIView!
    
    var caseType: CaseSegmentData = .yourRequest
    weak var delegate: RequestChildViewControllerDelegate?

    // MARK: - Section 3 - Lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        subscribeViewModelEvents()
        noItemView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    // MARK: - Section 4 - Binding, subscribe
    override func bindViewModel() {
        guard let viewModel = viewModel as? RequestChildViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        // Do reset page
        viewModel.resetPageEvent.subscribe(onNext: { [weak self] _ in
            self?.contentTableView.scrollToTop(animated: false)
        }).disposed(by: disposeBag)
    }

    private func subscribeViewModelEvents() {
        guard let viewModel = self.viewModel as? RequestChildViewModel else { return }
//        viewModel.privilegesViewModelEvent
//            .subscribe(onNext: { [weak self] event in
//            guard let this = self else { return }
//            switch event {
//            case .reloadTableView(let isScroll, let index):
//                this.tableView.isScrollEnabled = !viewModel.privilegesToDisplay.isEmpty
//                this.displayLoadMoreButton()
//                this.updateUIAfterReloadData()
//                this.tableView.reloadData()
//                if isScroll {
//                    this.scrollToBottom(index: index)
//                }
//            default: break
//            }
//        })
//            .disposed(by: disposeBag)
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
private extension RequestChildViewController {
    
    func updateUIAfterReloadData() {
        guard let viewModel = viewModel as? RequestChildViewModel else { return }
        let isNoCase = viewModel.requestsToDisplay.isEmpty
        if !viewModel.isLoadingRequests {
            noItemView.isHidden = !isNoCase
            contentTableView.isHidden = isNoCase
        } else {
            noItemView.isHidden = true
        }
    }

    func configTableView() {
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(RequestTableViewCell.self)
        contentTableView.contentInsetAdjustmentBehavior = .never
//        tableView.register(PrivilegeListingCardSkeletonTableCell.self)
        view.backgroundColor = .white
        contentTableView.isScrollEnabled = false
    }

    func scrollToBottom(index: Int) {
        guard let viewModel = viewModel as? RequestChildViewModel else { return }
        guard !viewModel.requestsToDisplay.isEmpty else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension RequestChildViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel as? RequestChildViewModel else { return 0 }
        return !viewModel.isLoadingRequests ? viewModel.requestsToDisplay.count : 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel as? RequestChildViewModel else { return UITableViewCell() }
        if !viewModel.isLoadingRequests {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RequestTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureCell(with: viewModel.requestsToDisplay[indexPath.row])
            return cell
        }
//        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PrivilegeListingCardSkeletonTableCell
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel as? RequestChildViewModel else { return }
//        if viewModel.privilegesToDisplay.isEmpty { return }
//        guard viewModel.privilegesToDisplay.count > indexPath.row else { return }
//        let privilege = viewModel.privilegesToDisplay[indexPath.row]
//        delegate?.privilegesViewController(self, openPrivilegeDetail: privilege, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

// MARK: - RequestTableViewCellDelegate
extension RequestChildViewController: RequestTableViewCellDelegate {
    func acceptRequest(requestId: String?) {
        guard let viewModel = viewModel as? RequestChildViewModel else { return }
        if let requestId = requestId {
            viewModel.acceptRequest(requestId: requestId)
        }
    }
    
    func cancelRequest(requestId: String?) {
        guard let viewModel = viewModel as? RequestChildViewModel else { return }
        if let requestId = requestId {
            viewModel.cancelRequest(requestId: requestId)
        }
    }
    
    
}
