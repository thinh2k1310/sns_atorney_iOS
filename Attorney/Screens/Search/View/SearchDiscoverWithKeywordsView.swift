//
//  SearchDiscoverWithKeywordsView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import RxDataSources
import RxSwift
import UIKit

enum KeywordsSection: Int, CaseIterable {
    case noResults
    case recentSearchs
}

@IBDesignable
class SearchDiscoverWithKeywordsView: BaseCustomView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    var viewModel: ViewModel? {
        didSet {
            setupData()
        }
    }
    
    var searchText: String? {
        didSet {
            collectionView.reloadData()
        }
    }

    var didSelectKeyword: ((String) -> Void)?
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SearchKeywordsCellType>> { [weak self] (_, collectionView, indexPath, itemSource) -> UICollectionViewCell in
        switch itemSource {
        case .noResult:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoResultCollectionViewCell.reuseIdentifier, for: indexPath) as? NoResultCollectionViewCell {
                guard let viewModel = self?.viewModel as? SearchDiscoverKeywordsViewModel else { return UICollectionViewCell() }
                cell.setupDataFor(viewModel.searchType)
                return cell
            }

        case .recentKeyword(let recentKeyword):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? RecentSearchCollectionViewCell {
                cell.configureCell(keyword: recentKeyword)
                return cell
            }

        default:
            break
        }
        return UICollectionViewCell()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setupUI() {
        super.setupUI()
        configureCollection()
    }

    override func setupData() {
        super.setupData()
        guard let viewModel = viewModel as? SearchDiscoverKeywordsViewModel else {
            return
        }
        bindingViewModel()
        viewModel.setupData()
    }

    private func configureCollection() {
        collectionView.collectionViewLayout = SearchKeywordsCollectionCustomLayout(minimumInteritemSpacing: 8.0, minimumLineSpacing: 0.0, sectionInset: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24))
        collectionView.register(RecentSearchCollectionViewCell.self)
        collectionView.register(NoResultCollectionViewCell.self)
    }

    private func bindingViewModel() {
        guard let viewModel = viewModel as? SearchDiscoverKeywordsViewModel else { return }

        viewModel.dataSources.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        Observable
            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(SearchKeywordsCellType.self))
            .subscribe(onNext: { [unowned self] itemSelected, modelSelected in
            debugPrint("itemSelected: \(itemSelected) ---- modelSelected: \(modelSelected)")
            switch modelSelected {
            case .recentKeyword(let keyword):
                self.didSelectKeyword?(keyword)

            default:
                break
            }
        }).disposed(by: disposeBag)
    }

    func isSearchText() -> Bool {
        guard let text = searchText else { return false }
        return !text.isEmpty
    }
}

extension SearchDiscoverWithKeywordsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = viewModel as? SearchDiscoverKeywordsViewModel else {
            return CGSize.zero
        }
        let section = indexPath.section
        switch section {
        case KeywordsSection.noResults.rawValue:
            if viewModel.displayNoResultSection {
                return NoResultCollectionViewCell.cellSize(searchType: viewModel.searchType)
            } else {
                return CGSize.zero
            }

        case KeywordsSection.recentSearchs.rawValue:
            return viewModel.searchType != .searchAll ? .zero : RecentSearchCollectionViewCell.cellSize()

        default:
            break
        }
        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let viewModel = viewModel as? SearchDiscoverKeywordsViewModel else { return .zero }
        switch section {
        case KeywordsSection.recentSearchs.rawValue:
            if viewModel.recentSearchs.isEmpty || viewModel.searchType != .searchAll {
                return .zero
            } else {
                return CGSize(width: collectionView.frame.width, height: 56)
            }

        default:
            break
        }
        return .zero
    }

    func addContentHeightWhenShowKeyboard(isShowKeyboard: Bool, keyboardHeight: CGFloat) {
        if isShowKeyboard {
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}


// MARK: - Configs
extension SearchDiscoverWithKeywordsView {
    struct Configs {
        static let headerHeight1line: CGFloat = 55
        static let headerHeight2line: CGFloat = 80
        static let headerHeightTooltip: CGFloat = 107
        static let referenceSizeForFooterInSectionHeight: CGFloat = 100
    }
}
