//
//  PostFilterView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

enum FilterAction: String {
    case all = "All"
    case requesting = "Requesting"
    case discussing = "Discussing"
    func value() -> String {
        switch self {
        case .requesting:
            return "REQUESTING"
        case .discussing:
            return "DISCUSSING"
        default:
            return ""
        }
    }
}

final class PostFilterView: BaseCustomView {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var didTapShowResults: ((FilterAction, [Category]) -> Void)?
    
    override func setupUI() {
        super.setupUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterCollectionViewCell.self)
        collectionView.register(UINib.init(nibName: HeaderFilterView.identifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderFilterView.identifier)
    }
    let actions: [FilterAction] = [.all, .requesting, .discussing]
    let categories: [Category] = [.All, .Administrative, .Civil, .Civil_Procedure, .Constitutional, .Criminal, .Criminal_Procedure,
                                  .Economic, .Finance, .International, .Labour, .Land, .Marriage]
    
    var selectedAction : FilterAction = .all
    var selectedCategories: [Category] = [.All]
    
    @IBAction private func didTapShowResults(_ sender: Any) {
        didTapShowResults?(selectedAction, selectedCategories)
    }
    
    private func didSelectCategory(category: Category) {
        if category == .All {
            selectedCategories.removeAll()
            selectedCategories.append(.All)
        } else if selectedCategories.count > 1 && selectedCategories.contains(category) {
            selectedCategories = selectedCategories.filter { $0 != category }
        } else {
            selectedCategories = selectedCategories.filter { $0 != .All }
            selectedCategories.append(category)
        }
    }
    
}

extension PostFilterView: UICollectionViewDataSource,  UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return actions.count
        } else if section == 1 {
            return categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier, for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            let isSelected = selectedAction == actions[indexPath.row]
            cell.configureCell(title: actions[indexPath.row].rawValue, isSelected: isSelected)
        } else if indexPath.section == 1 {
            let isSelected = selectedCategories.contains(categories[indexPath.row])
            cell.configureCell(title: categories[indexPath.row].rawValue, isSelected: isSelected)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedAction = actions[indexPath.row]
        } else if indexPath.section == 1 {
            didSelectCategory(category: categories[indexPath.row])
        }
        self.collectionView.reloadData()
    }
}

extension PostFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = collectionView.frame.width
        
        if indexPath.section == 0 {
           return CGSize(width: cellWidth, height: 30)
        } else if indexPath.section == 1 {
            return CGSize(width: (cellWidth - 24) / 2, height: 30)
        }
        return CGSize.zero
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let cellWidth: CGFloat = collectionView.frame.width
        return CGSize(width: cellWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderFilterView.identifier, for: indexPath) as! HeaderFilterView
            if indexPath.section == 0 {
                sectionHeader.configureHeader(title: "ACTION")
            } else if indexPath.section == 1 {
                sectionHeader.configureHeader(title: "CATEGORY")
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
}
