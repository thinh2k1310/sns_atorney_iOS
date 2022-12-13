//
//  SearchViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import RxCocoa
import RxSwift
import UIKit

class SearchViewController: UIViewController {
    // MARK: - Section 1 - IBOutlet
    @IBOutlet private weak var navigationBarView: UIView!
    @IBOutlet private weak var heightNavigationLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundTabView: UIView!
    @IBOutlet private weak var tabStackView: UIStackView!
    @IBOutlet private weak var backgroundStackView: UIStackView!
    @IBOutlet private weak var shadowTabView: UIView!
    
    // MARK: - Section 2 - Private variable
    var viewModel: SearchViewModel!
    private let disposeBag = DisposeBag()
    private(set) var searchTextField: UITextField!
    private(set) var clearButton: UIButton!
    private var lineView: UIView!
    private var pagingViewController: UIPageViewController!
    private var pages = [SearchChildViewController]()
    private let selectedTab = BehaviorRelay<SearchScreenType>(value: .searchAll)
    private var listTabButton = [UIButton]()
    private var isAnimating = false

    private var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }

    // MARK: - Section 3 - Lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSearchBar()
        self.setupTabButton()
        self.configurePaging()
        self.bindingSearchTextField()
        self.showKeyBoard()
        self.bindingViewModel()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func bindingViewModel() {
        viewModel.allDataEmptyEvent.subscribe(onNext: { [weak self] isEmpty in
            self?.disableSwipePageView(isEmpty)
        }).disposed(by: disposeBag)
        
        viewModel.goToPostDetailEvent.subscribe(onNext: { [weak self] postId in
            self?.goToPostDetail(postId: postId)
        }).disposed(by: disposeBag)
        
        viewModel.goToProfileEvent.subscribe(onNext: { [weak self] profileId in
            self?.goToProfile(userId: profileId)
        }).disposed(by: disposeBag)
    }

    private func bindingSearchTextField() {
        self.searchTextField
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.textChangeEvent)
            .disposed(by: disposeBag)

        self.searchTextField
            .rx.text
            .orEmpty
            .changed
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] textChanged in
                log.debug("==>textChanged:\(textChanged)")
                self?.searchTextFieldAttributedStringDefault()
                guard !textChanged.isEmpty else {
                    self?.clearSearch()
                    return
                }
                self?.handleClearSearchButton(currentText: textChanged)
                self?.moveToTab(.searchAll, animated: false)
            }).disposed(by: disposeBag)

        self.searchTextField
            .rx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.searchTextField.text, !text.isEmpty else {
                    self?.searchTextFieldAttributedStringDefault()
                    return
                }
                self?.searchTextFieldAttributedString()
                self?.handleClearSearchButton(currentText: text)
            }).disposed(by: disposeBag)

        self.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .debounce(DispatchTimeInterval.milliseconds(600), scheduler: MainScheduler.instance)
            .bind(to: viewModel.editingDidEndOnExitEvent)
            .disposed(by: disposeBag)
    }

    private func searchTextFieldAttributedString() {
        searchTextField.font = UIFont.appSemiBoldFont(size: 14.0)
        searchTextField.textColor = Color.textColor
    }

    @objc private func clearSearch() {
        self.disableSwipePageView(true)
        self.moveToTab(.searchAll, animated: false)
        self.triggerSearchTextField()
        self.handleClearSearchButton(currentText: nil)
    }

    @IBAction private func onTapBackButton(_ sender: Any) {
        self.hiddenKeyBoard()
        self.navigationController?.popViewController(animated: true)
    }

    private func handleClearSearchButton(currentText: String?) {
        if let currentText = currentText, !currentText.isEmpty {
            self.searchTextField.rightViewMode = .always
        } else {
            self.searchTextField.rightViewMode = .never
        }
    }

    private func setUpSearchBar() {
        if hasTopNotch {
            self.heightNavigationLayoutConstraint.constant = 100
        } else {
            self.heightNavigationLayoutConstraint.constant = 80
        }
        /*Right item*/
        var iconDelete = UIImage(named: "icon-close-grey")!
        iconDelete = iconDelete.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        clearButton.setImage(iconDelete, for: .normal)
        clearButton.contentMode = .center
        clearButton.rx.tap.bind { [weak self] in self?.clearSearch() }.disposed(by: disposeBag)

        // Search Icon
        let searchIconImageView = UIImageView(frame: CGRect(x: 8, y: 4, width: 24, height: 24))
        searchIconImageView.image = UIImage(named: "discoverImageSearchText")

        // Search TextField
        let iconContainerView: UIView = UIView(frame: CGRect(x: 8, y: 0, width: 32, height: 32))
        iconContainerView.addSubview(searchIconImageView)
        let iconDeleteView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        iconDeleteView.addSubview(clearButton)
        UITextField.appearance().tintColor = Color.textColor
        self.searchTextField = UITextField(frame: CGRect(x: 52,
            y: (8 + heightNavigationLayoutConstraint.constant) - 56,
            width: view.frame.width - 68.0,
            height: 40))
        self.searchTextFieldAttributedStringDefault()
        self.searchTextField.borderStyle = .none
        self.searchTextField.adjustsFontSizeToFitWidth = true
        self.searchTextField.minimumFontSize = 10.0
        self.searchTextField.backgroundColor = .white
        self.searchTextField.leftView = iconContainerView
        self.searchTextField.leftViewMode = .always
        self.searchTextField.rightView = clearButton
        self.searchTextField.contentMode = .center
        self.searchTextField.borderColor = R.color.dfe3E9()
        self.searchTextField.borderWidth = 1.0
        self.searchTextField.layer.cornerRadius = 20.0
        self.navigationBarView.addSubview(searchTextField)
    }

    private func searchTextFieldAttributedStringDefault() {
        let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.appFont(size: 14),
                .foregroundColor: Color.colorPaymentSubText
        ]
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search users or posts",
            attributes: attributes)
    }

    private func setupTabButton() {
        self.shadowTabView.addShadow(offset: CGSize(width: 0, height: 7),
                                     color: UIColor.black,
                                     opacity: 0.04,
                                     radius: 6)

        for tab in SearchScreenType.allCases {
            let tabButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: tabStackView.bounds.height))
            tabButton.setTitle(tab.title, for: .normal)
            tabButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: Configs.paddingTitleButton, bottom: 0, right: Configs.paddingTitleButton)
            tabButton.titleLabel?.font = R.font.proximaNovaSemibold(size: 14)
            tabButton.setTitleColor(Color.colorPaymentSubText, for: .normal)
            tabButton.sizeToFit()
            listTabButton.append(tabButton)
            tabStackView.addArrangedSubview(tabButton)

            if tab == .searchAll {
                self.setupUISelectedTab(for: tabButton)
            }

            tabButton.rx.tap.bind { [weak self] in
                guard let self = self else { return }
                self.moveToTab(tab, animated: false)
                self.hiddenKeyBoard()
            }.disposed(by: disposeBag)
        }
    }

    private func setupUISelectedTab(for tabButton: UIButton?) {
        guard let tabButton = tabButton else { return }
        for button in self.listTabButton {
            button.setTitleColor(Color.colorPaymentSubText, for: .normal)
        }
        tabButton.setTitleColor(Color.textColor, for: .normal)

        let lineViewFrame = CGRect(x: tabButton.originX + Configs.paddingTitleButton, y: 42, width: tabButton.width - Configs.paddingTitleButton * 2, height: 4)
        if lineView == nil {
            lineView = UIView(frame: lineViewFrame)
            lineView.backgroundColor = Color.appTintColor
            tabStackView.addSubview(lineView)
        }

        UIView.animate(withDuration: 0.3) {
            self.lineView.frame = lineViewFrame
        }
    }

    private func configurePaging() {
        pagingViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.addChild(pagingViewController)
        self.backgroundStackView.addArrangedSubview(pagingViewController.view)

        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingViewController.view.topAnchor.constraint(equalTo: self.tabStackView.bottomAnchor),
            pagingViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        pagingViewController.didMove(toParent: self)

        for tab in SearchScreenType.allCases {
            let searchChildVC = R.storyboard.searchChildViewController.searchChildViewController()!
            let childViewModel = SearchChildViewModel(provider: Application.shared.provider)
            childViewModel.searchType = tab
            self.bindingActionTo(childViewModel)
            self.bindingActionFrom(childViewModel)
            searchChildVC.viewModel = childViewModel

            pages.append(searchChildVC)
        }

        pagingViewController.setViewControllers([pages[selectedTab.value.rawValue]], direction: .forward, animated: true, completion: nil)
        self.disableSwipePageView(true)
    }


    private func bindingActionFrom(_ childViewModel: SearchChildViewModel) {
        childViewModel.didSelectKeywordsEvent.subscribe(onNext: { [weak self] keyword in
            guard let self = self else { return }
            self.searchTextFieldAttributedString()
            self.triggerSearchTextField(text: keyword)
            self.handleClearSearchButton(currentText: keyword)
        }).disposed(by: disposeBag)

        childViewModel.clickShowAllEvent.subscribe(onNext: { [weak self] screenType in
            self?.moveToTab(screenType, animated: false)
        }).disposed(by: disposeBag)

        childViewModel.selectItem.bind(to: viewModel.selectItem).disposed(by: disposeBag)
    }

    private func bindingActionTo(_ childViewModel: SearchChildViewModel) {
        selectedTab.bind(to: childViewModel.tabSelectedEvent).disposed(by: disposeBag)
        clearButton.rx.tap.filter { childViewModel.searchType == .searchAll }.bind(to: childViewModel.clearSearchButtonEvent).disposed(by: disposeBag)

        self.searchTextField
            .rx.text
            .orEmpty
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .debug("text event changed")
            .bind(to: childViewModel.textChangeEvent)
            .disposed(by: disposeBag)
        
        // Binding search all data response
        viewModel.searchAllEvent.bind(to: childViewModel.searchAllEvent).disposed(by: disposeBag)
    }

    private func moveToTab(_ tabType: SearchScreenType, animated: Bool) {
        self.setupUISelectedTab(for: listTabButton[tabType.rawValue])
        if isAnimating || tabType == selectedTab.value { return }
        isAnimating = true
        let displayingChildVC = pages[tabType.rawValue]
        let direction: UIPageViewController.NavigationDirection = tabType.rawValue > selectedTab.value.rawValue ? .forward : .reverse
        DispatchQueue.main.async {
            self.pagingViewController.setViewControllers([displayingChildVC], direction: direction, animated: animated, completion: { [weak self] _ in
                self?.isAnimating = false
            })
        }
        selectedTab.accept(tabType)
    }

    private func disableSwipePageView(_ isDisable: Bool) {
        if let scrollView = self.pagingViewController.view.subviews.first as? UIScrollView {
            scrollView.isScrollEnabled = !isDisable
        }
        self.backgroundTabView.isHidden = isDisable
        self.shadowTabView.isHidden = isDisable
    }

    private func triggerSearchTextField(text: String = "") {
        self.searchTextField.text = text
        self.searchTextField.sendActions(for: .editingChanged)
    }
}

// MARK: - UIPageViewControllerDataSource
extension SearchViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? SearchChildViewController,
              let index = pages.firstIndex(of: viewController) else {
            return nil
        }

        if index == 0 {
            return nil
        }

        let prevIndex = index - 1
        let pageContentViewController = pages[prevIndex]

        return pageContentViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? SearchChildViewController,
              let index = pages.firstIndex(of: viewController) else {
            return nil
        }

        if index == pages.count - 1 {
            return nil
        }

        let nextIndex = index + 1
        let pageContentViewController = pages[nextIndex]

        return pageContentViewController
    }
 }

// MARK: - UIPageViewControllerDelegate
extension SearchViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            isAnimating = false
        }
        if completed {
            guard let displayedViewController = pageViewController.viewControllers?.first as? SearchChildViewController,
                  let displayedIndex = pages.firstIndex(of: displayedViewController) else { return }
            setupUISelectedTab(for: listTabButton[displayedIndex])
            selectedTab.accept(SearchScreenType(rawValue: displayedIndex) ?? .searchAll)
        }
    }
}

// MARK: - Keyboard
extension SearchViewController {
    func showKeyBoard() {
        self.searchTextField.becomeFirstResponder()
        self.searchTextField.inputAccessoryView = UIView()
        self.searchTextField.returnKeyType = .search
    }

    func hiddenKeyBoard() {
        self.searchTextField.resignFirstResponder()
    }
}

// MARK: - Configs
extension SearchViewController {
    struct Configs {
        static let paddingTitleButton: CGFloat = 12
    }
}

// MARK: - Transitions
extension SearchViewController {

    func goToPostDetail(postId: String?) {
        let postDetailVC = R.storyboard.detailPost.postDetailViewController()!
        guard let provider = Application.shared.provider else { return }
        let postDetailVM = PostDetailViewModel(provider: provider)
        postDetailVM.postId = postId
        postDetailVC.viewModel = postDetailVM
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }

    func goToProfile(userId: String?) {
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider,
        let id = userId else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
