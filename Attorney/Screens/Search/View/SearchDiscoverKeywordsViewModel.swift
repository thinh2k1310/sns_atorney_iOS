//
//  SearchDiscoverKeywordsViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import AVFoundation
import RxCocoa
import RxDataSources
import RxSwift

enum SearchKeywordsCellType {
    case noResult
    case recentKeyword(String)
    case `default`
}

// swiftlint:disable type_name
class SearchDiscoverKeywordsViewModel: ViewModel {
    let dataSources = PublishSubject<[SectionModel<String, SearchKeywordsCellType>]>()

    let noSearchResultSubject = PublishSubject<Bool>()
    let recentSearchsSubject = PublishSubject<[String]>()

    var displayNoResultSection = false
    var recentSearchs = [String]()
    var searchType: SearchScreenType = .searchAll

    init() {
        super.init(provider: Application.shared.provider)
        react()
    }


    override func setupData() {
        super.setupData()
    }

    private func react() {
        recentSearchsSubject.subscribe(onNext: { [weak self] recentKeywords in
            self?.recentSearchs = recentKeywords
            self?.makeSources()
        }).disposed(by: disposeBag)

        noSearchResultSubject.subscribe(onNext: { [weak self] isNoResult in
            self?.displayNoResultSection = isNoResult
            self?.makeSources()
        }).disposed(by: disposeBag)
    }

    func makeSources() {
        // Make prefix with 6 item earliest
        let prefixRecentKeywords = recentSearchs.count > 6 ? Array(recentSearchs.prefix(upTo: 6)) : recentSearchs

        // Make datasources
        var dataSource = [SectionModel<String, SearchKeywordsCellType>]()
        dataSource.append(SectionModel(model: "", items: [SearchKeywordsCellType.noResult]))
        dataSource.append(SectionModel(model: R.string.localizable.string_recent_searches(preferredLanguages: Configurations.App.preferredLanguages), items: prefixRecentKeywords.map { SearchKeywordsCellType.recentKeyword($0) }))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dataSources.onNext(dataSource)
        }
    }
}

