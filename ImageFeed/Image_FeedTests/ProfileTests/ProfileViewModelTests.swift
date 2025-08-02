import XCTest
@testable import ImageFeed

final class ProfileViewModelTests: XCTestCase {

    func testFetchProfileSuccess() {
        // given
        let avatarURL = URL(string: "https://example.com/avatar.jpg")!
        let profile = Profile(
            username: "test_user",
            name: "Test User",
            loginName: "test_login",
            bio: "test bio",
            avatarURL: avatarURL
        )

        let mockProfileService = ProfileServiceMock()
        mockProfileService.result = .success(profile)

        let mockImageService = ProfileImageServiceMock()
        mockImageService.result = .success(avatarURL)

        let viewModel = ProfileViewModel(
            profileService: mockProfileService,
            profileImageService: mockImageService
        )

        let profileExpectation = expectation(description: "onProfileChanged called")
        let avatarExpectation = expectation(description: "onAvatarChanged called")

        viewModel.onProfileChanged = { loadedProfile in
            XCTAssertEqual(loadedProfile.name, "Test User")
            XCTAssertEqual(loadedProfile.avatarURL, avatarURL)
            profileExpectation.fulfill()
        }

        viewModel.onAvatarChanged = { url in
            XCTAssertEqual(url, avatarURL)
            avatarExpectation.fulfill()
        }

        // when
        viewModel.fetchProfile()

        // then
        wait(for: [profileExpectation, avatarExpectation], timeout: 1.0)
    }
}
