import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerTests: XCTestCase {
    
    func test_defaultAppearance() {
        let viewModel = MockTrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Default", testName: "Trackers")
    }
    
    func test_defaultAppearanceDark() {
        let viewModel = MockTrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Default_Dark", testName: "Trackers")
    }
    
    func test_defaultAppearance_empty() {
        let viewModel = MockEmptyTrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Empty", testName: "Trackers")
    }
    
    func test_defaultAppearanceDark_empty() {
        let viewModel = MockEmptyTrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Empty_Dark", testName: "Trackers")
    }
}
