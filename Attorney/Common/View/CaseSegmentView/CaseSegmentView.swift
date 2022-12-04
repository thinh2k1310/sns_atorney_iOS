//
//  CaseSegmentView.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import UIKit

enum CaseSegmentData: Int, CaseIterable {
    case yourRequest, yourCase
    var title: String {
        switch self {
        case .yourRequest:
            return "Your requests"
        case .yourCase:
            return "Your cases"
        }
    }
}

protocol CaseSegmentViewDelegate: AnyObject {
    func caseSegmentView(_ caseSegmentView: CaseSegmentView, didSelectIndex index: Int)
}

class CaseSegmentView: BaseCustomView {
    @IBOutlet private weak var segmentCollectionView: UICollectionView!
    
    weak var delegate: CaseSegmentViewDelegate?
    private var selectedIndex: Int = 0

    override func setupUI() {
        super.setupUI()
        segmentCollectionView.register(CaseSegmentCollectionViewCell.self)
        segmentCollectionView.delegate = self
        segmentCollectionView.dataSource = self
        selectSegmentPrivilege(index: selectedIndex)
    }

    private func selectSegmentPrivilege(index: Int) {
        let selectedIndexPath = IndexPath(item: index, section: 0)
        segmentCollectionView.selectItem(at: selectedIndexPath,
                                         animated: true, scrollPosition: .centeredVertically)
        selectedIndex = index
    }

    func setSelectIndex(index: Int) {
        if selectedIndex == index { return }
        selectSegmentPrivilege(index: index)
    }
}

extension CaseSegmentView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CaseSegmentData.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CaseSegmentCollectionViewCell
        let title = CaseSegmentData(rawValue: indexPath.row)?.title ?? ""
        cell.setupUI(menu: title)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectSegmentPrivilege(index: indexPath.row)
        delegate?.caseSegmentView(self, didSelectIndex: selectedIndex)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CaseSegmentView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 99, height: self.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24.0
    }
}
