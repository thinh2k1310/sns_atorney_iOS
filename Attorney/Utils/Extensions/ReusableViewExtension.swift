//
//  ReusableViewExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import UIKit

public protocol ReusableView: AnyObject { }

public extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol NibLoadableView: AnyObject { }

public extension NibLoadableView where Self: UIView {
    static var nibName: String {
        // notice the new describing here
        // now only one place to refactor if describing is removed in the future
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadableView { }
extension UITableViewCell: ReusableView { }
extension UITableViewHeaderFooterView: NibLoadableView { }
extension UITableViewHeaderFooterView: ReusableView { }
extension UICollectionReusableView: NibLoadableView { }
extension UICollectionReusableView: ReusableView { }

public extension UITableView {
    func register<T: UITableViewCell>(_: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerHeaderFooterNib<T: UITableViewHeaderFooterView>(_: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue view with identifier: \(T.reuseIdentifier)")
        }

        return view
    }
}

public extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerFooterNib<T: UICollectionReusableView>(_: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
    }

    func registerHeaderNib<T: UICollectionReusableView>(_: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
    }

    func registerFooterClass<T: UICollectionReusableView>(_: T.Type, bundle: Bundle? = nil) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableFooterView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }

    func dequeueReusableHeaderView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

