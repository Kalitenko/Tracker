import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerCategoryTests: XCTestCase {
    
    func testCategoryListViewController_defaultAppearance() {
        let viewModel = MockCategoryListViewModel()
        let vc = CategoryListViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Default", testName: "CategoryList")
    }
    
    func testCategoryListViewController_defaultAppearanceDark() {
        let viewModel = MockCategoryListViewModel()
        let vc = CategoryListViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Default_Dark", testName: "CategoryList")
    }
    
    func testCategoryListViewController_defaultAppearance_empty() {
        let viewModel = MockCategoryListViewModel()
        deleteCategories(viewModel: viewModel)
        let vc = CategoryListViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "Empty", testName: "CategoryList")
    }
    
    func testCategoryListViewController_defaultAppearanceDark_empty() {
        let viewModel = MockCategoryListViewModel()
        deleteCategories(viewModel: viewModel)
        let vc = CategoryListViewController(viewModel: viewModel)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "Empty_Dark", testName: "CategoryList")
    }
    
    private func deleteCategories(viewModel: CategoryListViewModelProtocol) {
        viewModel.deleteCategory(TrackerCategory(title: "Health", trackers: []))
        viewModel.deleteCategory(TrackerCategory(title: "Work", trackers: []))
    }
    
}
