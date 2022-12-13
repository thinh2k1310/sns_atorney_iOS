//
//  SearchChildViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import RxDataSources
import RxSwift
import UIKit

final class SearchChildViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backgroundResultView: UIView!
    @IBOutlet private weak var searchDiscoverKeywords: SearchDiscoverWithKeywordsView!
    @IBOutlet private weak var notFoundView: UIView!
    var disposeBag = DisposeBag()
    var viewModel: SearchChildViewModel!

    // MARK: - Section 2 - Private variable
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SearchItemType>> { [weak self] (_, tableView, indexPath, item) -> UITableViewCell in
        guard let strongSelf = self else { return UITableViewCell() }

        switch item {
        case .userItem(let user):
            return strongSelf.createUserCell(tableView: tableView, user: user, indexPath: indexPath)

        case .postItem(let post):
            return strongSelf.createPostCell(tableView: tableView, post: post, indexPath: indexPath)

        }
    }

    // MARK: - Section 3 - Lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindViewModel()
        addKeyboardObserverNotification()
        configureSearchWithKeywordsView()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Section 4 - Binding, subscribe
    private func bindViewModel() {
        viewModel.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        tableView.rx.modelSelected(SearchItemType.self)
            .subscribe(onNext: { [weak self] model in
            self?.viewModel.selectItem.accept(model)
        }).disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] _, indexPath in
            self?.viewModel.handleLoadmore(cellIndex: indexPath.row)
        }).disposed(by: disposeBag)

        viewModel.clearSearchButtonEvent.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.displayDefaultUI()
        }).disposed(by: disposeBag)

        viewModel.emptyDataEvent.subscribe(onNext: { [weak self] isEmptyData in
            guard let self = self else { return }
            self.displayResultUI(isEmpty: isEmptyData)
        }).disposed(by: disposeBag)

        viewModel.textChangeEvent
            .skip(while: { $0.isEmpty })
            .subscribe(onNext: { [weak self] textChanged in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
                if textChanged.isEmpty && self.viewModel.searchType == .searchAll {
                    self.displayDefaultUI()
                }
            }).disposed(by: disposeBag)
    }

    // MARK: - Section 5 - IBAction

    // MARK: - Section 6 - Private function
    private func configureTableView() {
        tableView.register(PostCell.self)
        tableView.register(UserCell.self)
        tableView.registerHeaderFooterNib(CaseHeaderView.self)
        tableView.registerHeaderFooterNib(SearchFooterView.self)
        tableView.registerHeaderFooterNib(LoadMoreIndicatorFooterView.self)
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
    }


    private func configureSearchWithKeywordsView() {
        viewModel.searchWithKeywordsViewModel.searchType = viewModel.searchType
        searchDiscoverKeywords.viewModel = viewModel.searchWithKeywordsViewModel
        searchDiscoverKeywords.didSelectKeyword = { [weak self] keyword in
            self?.searchDiscoverKeywords.searchText = keyword
            self?.viewModel.didSelectKeywordsEvent.accept(keyword)
        }
        viewModel.displaySearchKeywordEvent.subscribe(onNext: { [weak self] isSearchDataEmpty in
            guard let self = self else { return }
            if self.viewModel.textChangeEvent.value.isEmpty {
                self.displayDefaultUI()
                return
            }
            self.displayResultUI(isEmpty: isSearchDataEmpty)
        }).disposed(by: disposeBag)
    }

    private func displayDefaultUI() {
        self.searchDiscoverKeywords.searchText = ""
        self.searchDiscoverKeywords.isHidden = viewModel.recentKeywords.value.isEmpty && viewModel.popularKeywords.value.isEmpty
        self.backgroundResultView.isHidden = !searchDiscoverKeywords.isHidden
        self.tableView.isHidden = true
        self.notFoundView.isHidden = true

        DispatchQueue.main.async {
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    private func displayResultUI(isEmpty: Bool) {
        if isEmpty && viewModel.searchType == .searchAll {
            self.backgroundResultView.isHidden = true
            self.tableView.isHidden = true
            self.searchDiscoverKeywords.isHidden = viewModel.isEmptyKeyword
            self.notFoundView.isHidden = !viewModel.isEmptyKeyword
        } else if isEmpty && viewModel.searchType != .searchAll {
            self.searchDiscoverKeywords.isHidden = false
            self.backgroundResultView.isHidden = true
            self.tableView.isHidden = true
            self.notFoundView.isHidden = true
        } else {
            self.searchDiscoverKeywords.isHidden = true
            self.backgroundResultView.isHidden = true
            self.tableView.isHidden = false
            self.notFoundView.isHidden = true
        }
    }
}

extension SearchChildViewController {
    func createUserCell(tableView: UITableView, user: User, indexPath: IndexPath) -> UITableViewCell {
        let cell: UserCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.configureCelll(with: user)
        return cell
    }

    func createPostCell(tableView: UITableView, post: Post, indexPath: IndexPath) -> UITableViewCell {
        let cell: PostCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.configureCell(with: post)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchChildViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.cellHeightForItem(at: indexPath, withConstrainedCellWidth: tableView.frame.width)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.getHeaderSizeForSection(at: section, withConstrainedCellWidth: tableView.frame.width).height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.getFooterSizeForSection(at: section, withConstrainedCellWidth: tableView.frame.width).height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CaseHeaderView.reuseIdentifier) as? CaseHeaderView
        headerView?.configureHeader(title: viewModel.getHeaderTitle(forSection: section)!, cases: [])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let searchType = viewModel.getSearchType()
        switch searchType {
        case .searchAll:
            if viewModel.shouldShowFooterView(atSection: section) {
                let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchFooterView.reuseIdentifier) as? SearchFooterView
                footerView?.configureTitle(title: viewModel.getFooterTitle(forSection: section))
                footerView?.viewAllButtonDidTap = { [unowned self] in
                    self.viewModel.showAllResults(at: section)
                }
                return footerView
            } else {
                return UIView(frame: .zero)
            }

        case .searchPosts, .searchUsers:
            if viewModel.canLoadMore(atSection: section) {
                let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LoadMoreIndicatorFooterView.reuseIdentifier) as? LoadMoreIndicatorFooterView
                return footerView
            } else {
                return UIView(frame: .zero)
            }
        }
    }
}

extension SearchChildViewController {
    private func addKeyboardObserverNotification() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
            self?.doShowKeyboard(notification)
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
            self?.doHideKeyboard(notification)
        }).disposed(by: disposeBag)
    }

    @objc private func doShowKeyboard(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        searchDiscoverKeywords.addContentHeightWhenShowKeyboard(isShowKeyboard: true, keyboardHeight: keyboardHeight)
    }

    @objc private func doHideKeyboard(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        searchDiscoverKeywords.addContentHeightWhenShowKeyboard(isShowKeyboard: false, keyboardHeight: keyboardHeight)
    }
}

