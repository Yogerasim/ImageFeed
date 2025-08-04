import XCTest
@testable import ImageFeed

final class ProfileViewModelTests: XCTestCase {

    func testFetchProfileSuccess() {
        // Given: Mocked profile and image services with expected results
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
            // Then: Profile data matches
            XCTAssertEqual(loadedProfile.name, "Test User")
            XCTAssertEqual(loadedProfile.avatarURL, avatarURL)
            profileExpectation.fulfill()
        }

        viewModel.onAvatarChanged = { url in
            // Then: Avatar URL matches
            XCTAssertEqual(url, avatarURL)
            avatarExpectation.fulfill()
        }

        // When: Fetching profile
        viewModel.fetchProfile()

        wait(for: [profileExpectation, avatarExpectation], timeout: 1.0)
    }
}
