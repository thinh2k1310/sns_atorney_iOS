//
//  HomeViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift

final class HomeViewController: ViewController{
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noItemView: UIView!
    
    
    var heighOfContent: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        handler = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        handler = nil
    }
    
    override func setupData() {
        super.setupData()
        guard let viewModel = viewModel as? HomeViewModel else {
            return
        }
        viewModel.setupData()
        viewModel.getPosts()
    }
    
    override func setupUI() {
        super.setupUI()
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.barTintColor = Color.backgroundTabbar
        tabBarController?.tabBar.unselectedItemTintColor = Color.unselectedTabbar // color for unselected item on TabBar
        tabBarController?.tabBar.tintColor = Color.selectedTabBar // color for selected item on TabBar
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.isOpaque = false
    }


    // MARK: - Section 4 - Binding, subscribe

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = self.viewModel as? HomeViewModel else { return }

        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            self?.collectionView.isScrollEnabled = !isLoading
        })
        .disposed(by: disposeBag)

        viewModel.dataSources.subscribe(onNext: { [weak self] dataSources in
            if let dataSource = dataSources.first, !dataSource.items.isEmpty {
                self?.collectionView.isHidden = false
                self?.noItemView.isHidden = true
            } else {
                self?.collectionView.isHidden = true
                self?.noItemView.isHidden = false
            }
        })
        .disposed(by: disposeBag)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Post>> { [weak self] (_, collectionView, indexPath, item) -> UICollectionViewCell in
            if viewModel.isLoading.value == true && viewModel.isFirstLoad {
                if let skeletonCell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsfeedSkeletonCollectionViewCell.identifier, for: indexPath) as? NewsfeedSkeletonCollectionViewCell {
                    return skeletonCell
                }
            }

            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsFeedCollectionViewCell.identifier, for: indexPath) as? NewsFeedCollectionViewCell {
                cell.delegate = self
                cell.bindingData(with: item)
                cell.setupLayout()
                return cell
            }
            return UICollectionViewCell()
        }
        //Header
        dataSource.configureSupplementaryView = { (_, collectionView, viewType, indexPath) in
            switch viewType {
            case UICollectionView.elementKindSectionHeader:
                if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderHomeReusableView.reuseIdentifier, for: indexPath) as? HeaderHomeReusableView {
                    if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
                        header.configureHeader(with: userInfo)
                    }
                    return header
                }

            case UICollectionView.elementKindSectionFooter:
                if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadmoreIndicatorReusableView.reuseIdentifier, for: indexPath) as? LoadmoreIndicatorReusableView {
                    return footer
                }

            default:
                break
            }
            return UICollectionReusableView()
        }

        viewModel.dataSources.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

        // Set collection delegate
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        // Do reset page
        viewModel.resetPageEvent.subscribe { [weak self] _ in
            self?.collectionView.scrollToTop(animated: false)
        }
        .disposed(by: disposeBag)


    }

    // MARK: - Section 5 - IBAction

    // MARK: - Section 6 - Private function

    private func configureCollectionView() {
        collectionView.register(NewsFeedCollectionViewCell.self)
        collectionView.register(NewsfeedSkeletonCollectionViewCell.self)
        collectionView.register(UINib.init(nibName: LoadmoreIndicatorReusableView.identifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoadmoreIndicatorReusableView.identifier)
        collectionView.register(UINib.init(nibName: HeaderHomeReusableView.identifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderHomeReusableView.identifier)
    }


    private func configureNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true

    }


}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = viewModel as? HomeViewModel else { return .zero }
        let cellWidth: CGFloat = collectionView.frame.width
        if viewModel.isLoading.value == true && viewModel.isFirstLoad {
            return CGSize(width: cellWidth, height: NewsfeedSkeletonCollectionViewCell.contentHeight)
        }
        let cellSize = viewModel.cellSizeForPost(at: indexPath.item, withConstrainedCellWidth: cellWidth)
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = viewModel as? HomeViewModel else {
            return .zero
        }
        let viewWidth = self.view.frame.width
        var viewHeight = Configs.footerHeight
        if !viewModel.canLoadMore {
            viewHeight = 0
        }
        return CGSize(width: viewWidth - 5, height: viewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewWidth = self.view.frame.width
        let viewHeight = Configs.headerHeight
        return CGSize(width: viewWidth - 5, height: viewHeight)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel as? HomeViewModel else {
            return
        }

        if indexPath.row == viewModel.lastIndexItemOfPage {
            viewModel.loadMoreEvent.onNext(())
        }
    }
}


// MARK: - Navigation
private extension HomeViewController {
    func gotoDealDetailScreen(post: Post) {
//        guard let viewModel = self.viewModel as? VouchersListViewModel else { return }
//        guard let provider = Application.shared.provider else { return }
//        let dealDetailViewModel = DealDetailViewModel(provider: provider)
//        dealDetailViewModel.setDealDetail(voucher)
//        viewModel.navigationStackEvent.onNext(.push(viewModel: dealDetailViewModel,
//                                                    animated: true))
    }
}

// MARK: - NewsFeedCollectionViewCellDelegate
extension HomeViewController: NewsFeedCollectionViewCellDelegate {
    func viewDetailPost(_ post: Post?) {
        let postDetailVC = R.storyboard.detailPost.postDetailViewController()!
        guard let provider = Application.shared.provider else { return }
        let postDetailVM = PostDetailViewModel(provider: provider)
        postDetailVM.postId = post?._id
        postDetailVC.viewModel = postDetailVM
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func likePost(_ post: Post?, user: String?) {
        
    }
    
    func requestPost(_ post: Post?, user: String?) {
        
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension HomeViewController {
    struct Configs {
        static let footerHeight: CGFloat = 67.0
        static let headerHeight: CGFloat = 150.0
    }
}

extension HomeViewController: ReselectTabHandler {
    func didReselectTab() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}
