import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let onboardingButtonText = "Вот это технологии!"
        static let bottomOffset: CGFloat = -50
        static let buttonSideInset: CGFloat = 20
        static let pageControlSpacing: CGFloat = 24
    }
    
    // MARK: - UI Elements
    private lazy var onboardingButton: UIButton = {
        let button = BlackButton(title: Layout.onboardingButtonText)
        button.addTarget(self, action: #selector(Self.didTapOnboardingButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .ypBlack)
        pageControl.pageIndicatorTintColor = UIColor(resource: .ypBlack).withAlphaComponent(0.3)
        
        return pageControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setInitialPage()
        setupSubViews()
        setupConstraints()
        
        dataSource = self
        delegate = self
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [onboardingButton, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.buttonSideInset),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.buttonSideInset),
            onboardingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Layout.bottomOffset),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -Layout.pageControlSpacing)
        ])
    }
    
    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        [
            OnboardingViewController(imageName: "page_1", labelText: "Отслеживайте только то, что хотите"),
            OnboardingViewController(imageName: "page_2", labelText: "Даже если это\nне литры воды и йога")
        ]
    }()
    
    // MARK: - Private Methods
    private func setInitialPage() {
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapOnboardingButton(_ sender: Any) {
        OnboardingStorage.shared.hasSeenOnboarding = true
        
        guard let windowScene = view.window?.windowScene,
              let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = TabBarController()
        sceneDelegate.window = window
        window.makeKeyAndVisible()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - Preview
#Preview("OnboardingPageViewController") {
    let vc = OnboardingPageViewController()
    
    return vc
}
