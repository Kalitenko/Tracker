import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewController_defaultAppearance() {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Default", testName: "TrackersCommon")
    }
    
    func testTrackersViewController_withDifferentBackground() {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        vc.view.backgroundColor = .red

        XCTExpectFailure("Snapshot expected to fail because background is different") {
            assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Default", testName: "TrackersCommon")
        }
    }
    
    func testTrackersViewController_defaultAppearanceDark() {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Default_Dark", testName: "TrackersCommon")
    }
    
    func testTrackersViewController_withDifferentBackgroundDark() {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        vc.view.backgroundColor = .red

        XCTExpectFailure("Snapshot expected to fail because background is different") {
            assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Default_Dark", testName: "TrackersCommon")
        }
    }
    
}
