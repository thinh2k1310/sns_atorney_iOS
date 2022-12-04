//
//  ProfileViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 04/12/2022.
//

import UIKit
import RxSwift
import RxDataSources

final class ProfileViewController: ViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var heighOfContent: CGFloat = 0.0
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureRefreshControl()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        handler = nil
    }
    
    override func setupData() {
        super.setupData()
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }
        viewModel.setupData()
        viewModel.getPosts()
    }
    
    override func setupUI() {
        super.setupUI()
    }


    // MARK: - Section 4 - Binding, subscribe

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = self.viewModel as? ProfileViewModel else { return }

        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            self?.collectionView.isScrollEnabled = !isLoading
        })
        .disposed(by: disposeBag)

        viewModel.dataSources.subscribe(onNext: { [weak self] dataSources in
            self?.refreshControl.endRefreshing()
            if let dataSource = dataSources.first, !dataSource.items.isEmpty {
                self?.collectionView.isHidden = false
//                self?.noItemView.isHidden = true
            } else {
//                self?.noItemView.isHidden = false
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
                if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderReusableView.reuseIdentifier, for: indexPath) as? ProfileHeaderReusableView {
                    if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
//                        header.configureHeader(with: userInfo)
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
        collectionView.register(UINib.init(nibName: ProfileHeaderReusableView.identifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeaderReusableView.identifier)
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }

    private func configureNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Profile"

    }

    @objc func refresh(_ sender: AnyObject) {
        guard let viewModel = viewModel as? ProfileViewModel else {
            refreshControl.endRefreshing()
            return
        }
        viewModel.resetPage()
        viewModel.getPosts()
    }


}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = viewModel as? ProfileViewModel else { return .zero }
        let cellWidth: CGFloat = collectionView.frame.width
        if viewModel.isLoading.value == true && viewModel.isFirstLoad {
            return CGSize(width: cellWidth, height: NewsfeedSkeletonCollectionViewCell.contentHeight)
        }
        let cellSize = viewModel.cellSizeForPost(at: indexPath.item, withConstrainedCellWidth: cellWidth)
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = viewModel as? ProfileViewModel else {
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
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }

        if indexPath.row == viewModel.lastIndexItemOfPage {
            viewModel.loadMoreEvent.onNext(())
        }
    }
}

// MARK: - NewsFeedCollectionViewCellDelegate
extension ProfileViewController: NewsFeedCollectionViewCellDelegate {
    func viewDetailPost(_ post: String?) {
        let postDetailVC = R.storyboard.detailPost.postDetailViewController()!
        guard let provider = Application.shared.provider else { return }
        let postDetailVM = PostDetailViewModel(provider: provider)
        postDetailVM.postId = post
        postDetailVC.viewModel = postDetailVM
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func likePost(_ post: String?) {
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }
        if let post = post {
            viewModel.likePost(postId: post)
        }
    }
    
    func requestPost(_ post: Post?) {
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }
        if let post = post, let postId = post._id, let customer = post.user?._id {
            viewModel.sendDefenceRequest(postId: postId, customerId: customer)
        }
    }
}

extension ProfileViewController {
    struct Configs {
        static let footerHeight: CGFloat = 67.0
        static let headerHeight: CGFloat = 620.0
    }
}


