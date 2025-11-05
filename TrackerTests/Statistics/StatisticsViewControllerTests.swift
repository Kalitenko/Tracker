import XCTest
import SnapshotTesting
@testable import Tracker

final class StatisticsViewControllerTests: XCTestCase {
    
    func test_defaultAppearance() {
        let viewModel = MockStatisticsViewModel()
        let vc = StatisticsViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Default", testName: "Statistics")
    }
    
    func test_defaultAppearanceDark() {
        let viewModel = MockStatisticsViewModel()
        let vc = StatisticsViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Default_Dark", testName: "Statistics")
    }
    
    func test_defaultAppearance_empty() {
        let viewModel = MockEmptyStatisticsViewModel()
        let vc = StatisticsViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Empty", testName: "Statistics")
    }
    
    func test_defaultAppearanceDark_empty() {
        let viewModel = MockEmptyStatisticsViewModel()
        let vc = StatisticsViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Empty_Dark", testName: "Statistics")
    }
}
