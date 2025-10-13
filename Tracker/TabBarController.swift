import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersTitle = "Трекеры"
        static let statisticsTitle = "Статистика"
    }
    
    // MARK: - Layout
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func configureTabBar() {
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(
            title: Layout.trackersTitle,
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )
        let ntvc = NewTrackersViewController()
        ntvc.tabBarItem = UITabBarItem(
            title: Layout.trackersTitle,
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: Layout.statisticsTitle,
            image: UIImage(resource: .tabBarStatistics),
            selectedImage: nil
        )
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        let ntvcnc = UINavigationController(rootViewController: ntvc)
        
        self.viewControllers = [trackersNavigationController, statisticsNavigationController, ntvcnc]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .white)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(resource: .gray)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(resource: .blue)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .gray),
            .font: UIFont.medium10
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .blue),
            .font: UIFont.medium10
        ]
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.isTranslucent = false
    }
}
#if DEBUG
extension TabBarController {
    func loadPreviewData() {
        viewControllers?.forEach {
            if let nav = $0 as? UINavigationController,
               let trackersVC = nav.viewControllers.first(where: { $0 is TrackersViewController }) as? TrackersViewController {
                trackersVC.loadPreviewData()
            }
        }
    }
}
#endif
