//
//  ReportViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/26/22.
//

import UIKit

final class ReportViewController: ViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterCollectionViewCell.self)
        collectionView.register(UINib.init(nibName: ReportHeaderView.identifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ReportHeaderView.identifier)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? ReportViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.reportSuccess
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
                viewModel.showAlertEvent.onNext(())
            }).disposed(by: disposeBag)
    }
    
    @IBAction private func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func didTapReport(_ sender: Any) {
        guard let viewModel = viewModel  as? ReportViewModel else { return }
        viewModel.report()
    }
}

extension ReportViewController: UICollectionViewDataSource,  UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel  as? ReportViewModel else { return 0 }
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel  as? ReportViewModel else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier, for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        let isSelected = viewModel.selectedCategory == viewModel.categories[indexPath.row]
        cell.configureCell(title: viewModel.categories[indexPath.row].rawValue, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel  as? ReportViewModel else { return }
        viewModel.selectedCategory = viewModel.categories[indexPath.row]
        self.collectionView.reloadData()
    }
}

extension ReportViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = collectionView.frame.width
        return CGSize(width: cellWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let cellWidth: CGFloat = collectionView.frame.width
        return CGSize(width: cellWidth, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReportHeaderView.identifier, for: indexPath) as! ReportHeaderView
            return sectionHeader
        }
        return UICollectionReusableView()
    }
}
