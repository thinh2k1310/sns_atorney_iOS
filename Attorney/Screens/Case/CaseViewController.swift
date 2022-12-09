//
//  MessagesViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class CaseViewController: ViewController{
    // MARK: - Section 1 - IBOutlet
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var caseSegmentView: CaseSegmentView!
    // MARK: - Section 2 - Private variable
    private var pageViewController: UIPageViewController!
    private let yourRequestViewController = RequestChildViewController()
    private let yourCaseViewController = CaseChildViewController()
    private var viewControllers: [ViewController] = []
    private var viewControllerCurrentIndex: Int = 0 {
        didSet {
            updateUIForCaseSegmentView(index: viewControllerCurrentIndex)
            guard viewControllers.count > viewControllerCurrentIndex else { return }
            pageViewController.setViewControllers([viewControllers[viewControllerCurrentIndex]], direction: viewControllerCurrentIndex > oldValue ? .forward : .reverse, animated: true, completion: nil)
        }
    }
    
    // MARK: - Section 3 - Lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func setupUI() {
        super.setupUI()
        configureTabBar()
        caseSegmentView.delegate = self
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        guard let provider = Application.shared.provider else { return }
        let requestsViewModel = RequestChildViewModel(provider: provider)
    
        let casesViewModel = CaseChildViewModel(provider: provider)
       
        yourRequestViewController.viewModel = requestsViewModel
        yourCaseViewController.viewModel = casesViewModel
        yourCaseViewController.delegate = self
        viewControllers.removeAll()
        viewControllers.append(yourRequestViewController)
        viewControllers.append(yourCaseViewController)
        yourRequestViewController.caseType = .yourRequest
        yourCaseViewController.caseType = .yourCase
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.frame = CGRect(origin: CGPoint.zero, size: mainContentView.frame.size)
        mainContentView.addSubview(pageViewController.view)
        viewControllerCurrentIndex = 0
    }
    // MARK: - Section 4 - Binding, subscribe
    func updateUIForCaseSegmentView(index: Int) {
        caseSegmentView.setSelectIndex(index: index)
    }
    
    private func configureTabBar() {
        tabBarController?.selectedIndex = 1
        tabBarController?.tabBar.barTintColor = Color.backgroundTabbar
        tabBarController?.tabBar.unselectedItemTintColor = Color.unselectedTabbar // color for unselected item on TabBar
        tabBarController?.tabBar.tintColor = Color.selectedTabBar // color for selected item on TabBar
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.isOpaque = false
    }
}

// MARK: - CaseSegmentViewDelegate
extension CaseViewController: CaseSegmentViewDelegate {
    func caseSegmentView(_ caseSegmentView: CaseSegmentView, didSelectIndex index: Int) {
        viewControllerCurrentIndex = index
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension CaseViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllerCurrentIndex < viewControllers.count - 1 {
            return viewControllers[viewControllerCurrentIndex + 1]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewControllerCurrentIndex == 0 {
            return nil
        } else {
            return viewControllers[viewControllerCurrentIndex - 1]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // Update the current page
            if let currentViewController = pageViewController.viewControllers?.first as? CaseChildViewController,
                let viewControllerCurrentIndex = viewControllers.firstIndex(of: currentViewController){
                self.viewControllerCurrentIndex = viewControllerCurrentIndex
            } else if let currentViewController = pageViewController.viewControllers?.first as? RequestChildViewController,
                      let viewControllerCurrentIndex = viewControllers.firstIndex(of: currentViewController){
                      self.viewControllerCurrentIndex = viewControllerCurrentIndex
            } else {
                return
            }
           
        }
    }
}

// MARK: - PrivilegesViewControllerDelegate
extension CaseViewController: CaseChildViewControllerDelegate {
    func caseChildViewController(_ caseChildViewController: CaseChildViewController, caseDetail: Case, indexPath: IndexPath) {
        guard let provider = Application.shared.provider else { return }
        let caseDetailVC = R.storyboard.case.caseDetailViewController()!
        let caseDetailVM = CaseDetailViewModel(provider: provider)
        caseDetailVM.caseId = caseDetail._id
        caseDetailVC.viewModel = caseDetailVM
        self.navigationController?.pushViewController(caseDetailVC, animated: true)
    }
    
    func goToCaseList(cases: [Case]) {
        let caseListVC = R.storyboard.case.caseListViewController()!
        caseListVC.cases = cases
        self.navigationController?.pushViewController(caseListVC, animated: true)
    }
}
