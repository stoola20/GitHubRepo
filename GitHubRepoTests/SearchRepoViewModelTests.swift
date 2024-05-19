////
//  SearchRepoViewModelTests.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

@testable import GitHubRepo
import RxSwift
import XCTest

final class SearchRepoViewModelTests: XCTestCase {
    var sut: SearchRepoViewModel!
    var interactor: MockSearchInteractor!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        interactor = MockSearchInteractor()
        sut = SearchRepoViewModel(interactor: interactor)
        disposeBag = DisposeBag()
        super.setUp()
    }
    
    override func tearDown() {
        interactor = nil
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    func testSearchRepoList_Success() {
        // Given
        let repoItems: [SearchRepoItem] = [
            SearchRepoItem(
                name: "AppleALC",
                fullName: "acidanthera/AppleALC",
                description: "Native macOS HD audio for not officially supported codecs",
                owner: RepoOwner(
                    login: "acidanthera",
                    avatarUrl: "https://avatars.githubusercontent.com/u/39672954?v=4"
                )
            ),
            SearchRepoItem(
                name: "AppleDNS",
                fullName: "gongjianhui/AppleDNS",
                description: "Apple 网络服务加速配置。[已停止更新，请慎用。]",
                owner: RepoOwner(
                    login: "gongjianhui",
                    avatarUrl: "https://avatars.githubusercontent.com/u/4310161?v=4"
                )
            )
        ]
        
        let repoList = SearchRepoList(items: repoItems)

        interactor.stubSearchRepoResult = .just(repoList)
        
        // When
        sut.searchTriggerRelay.accept(())
        
        // Then
        sut.outputs.repoListRelay
            .skip(1)
            .asObservable()
            .subscribe(onNext: { result in
                XCTAssertEqual(result[0].name, "AppleALC")
                XCTAssertEqual(result[1].description, "Apple 网络服务加速配置。[已停止更新，请慎用。]")
                XCTAssertEqual(result.count, 2)

            })
            .disposed(by: disposeBag)
    }
    
    func testSearchRepoList_Error() {
        // Given
        let errorMessage = "The data couldn't be read because it is missing."
        interactor.stubSearchRepoResult = .error(ServerError.emptyQuery)
        
        // When
        sut.searchTriggerRelay.accept(())
        
        // Then
        sut.outputs.errorRelay
            .subscribe { message in
                XCTAssertEqual(message, errorMessage)
            }
            .disposed(by: disposeBag)
    }
}
