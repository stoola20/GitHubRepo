////
//  DetailViewModelTests.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

@testable import GitHubRepo
import RxSwift
import XCTest

final class DetailViewModelTest: XCTestCase {
    var sut: DetailViewModel!
    var disposeBag: DisposeBag!
    var interactor: MockSearchInteractor!

    override func setUp() {
        super.setUp()
        interactor = MockSearchInteractor()
        sut = DetailViewModel(interactor: interactor)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        interactor = nil
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    func testGetRepoDetail_Success() {
        // Given
        let stubDetailRepo = DetailRepo(
            owner: RepoOwner(
                login: "TheAlgorithms",
                avatarUrl: "TheAlgorithms"
            ),
            name: "Java",
            fullName: "TheAlgorithms/Java",
            language: "Java",
            stargazersCount: 56985,
            watchersCount: 56985,
            forksCount: 18605,
            openIssuesCount: 13
        )
        
        interactor.stubGetRepoResult = Observable.just(stubDetailRepo)
        sut.ownerRelay.accept("TheAlgorithms")
        sut.repoRelay.accept("Java")
        
        // When
        sut.getRepoRelay.accept(())
        
        // Then
        sut.outputs.detailRepoRelay
            .subscribe { detailRepo in
                XCTAssertEqual(detailRepo, stubDetailRepo)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetRepoDetail_Error() {
        // Given
        let errorMessage = "Server Error"
        interactor.stubGetRepoResult = Observable.error(ServerError.requestFailure(errorMessage))
        sut.ownerRelay.accept("TheAlgorithms")
        sut.repoRelay.accept("Java")
        
        // When
        sut.getRepoRelay.accept(())
        
        // Then
        sut.outputs.errorMessageRelay
            .subscribe { message in
                XCTAssertEqual(message, errorMessage)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetRepoDetail_NoOwnerName() {
        // Given
        let expectation = expectation(description: "No owner name provided.")
        expectation.isInverted = true
        sut.repoRelay.accept("Java")
        
        // When
        sut.getRepoRelay.accept(())
        
        sut.outputs.detailRepoRelay
            .subscribe { _ in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetRepoDetail_NoRepoName() {
        // Given
        let expectation = expectation(description: "No repo name provided.")
        expectation.isInverted = true
        sut.ownerRelay.accept("TheAlgorithms")
        
        // When
        sut.getRepoRelay.accept(())
        
        sut.outputs.detailRepoRelay
            .subscribe { _ in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
}
