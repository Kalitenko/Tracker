import UIKit

final class CreateTrackerController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Создание трекера"
        static let habitButtonText = "Привычка"
        static let irregularEventButtonText = "Нерегулярное событие"
        
        static let cellHeight: CGFloat = 75
        static let stackSpacing: CGFloat = 16
        static let stackSideInset: CGFloat = 20
        static let titleTopInset: CGFloat = 27
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var habitButton: UIButton = {
        let button = BlackButton(title: Layout.habitButtonText)
        button.addTarget(self, action: #selector(Self.didTapHabitButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = BlackButton(title: Layout.irregularEventButtonText)
        button.addTarget(self, action: #selector(Self.didTapIrregularEventButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
        setupSubViews()
        setupConstraints()
        
    }
    
    // MARK: - Setup Methods
    private func setupTitleLabel() {
        self.titleLabel.text = Layout.titleText
    }
    
    private func setupSubViews() {
        [stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.titleTopInset),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.stackSideInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.stackSideInset)
        ])
    }
    
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private let tableStyle: TableStyle = .toggle
    
    // MARK: - Actions
    @objc private func didTapHabitButton(_ sender: Any) {
        let vc = NewTrackerController(trackerType: .habit)
        present(vc, animated: true)
    }
    
    @objc private func didTapIrregularEventButton(_ sender: Any) {
        let vc = NewTrackerController(trackerType: .irregular)
        present(vc, animated: true)
    }
    
}

// MARK: - Preview
#Preview("CreateTrackerController") {
    let vc = CreateTrackerController()
    
    return vc
}
