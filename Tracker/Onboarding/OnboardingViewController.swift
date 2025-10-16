import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let bottomOffset: CGFloat = -270
        static let horizontalInset: CGFloat = 16
    }
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: imageName))
        
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = Label(text: labelText, style: .bold32, color: UIColor(resource: .ypBlack))
        label.numberOfLines = .zero
        
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [imageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Layout.bottomOffset),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalInset),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalInset)
        ])
    }
    
    // MARK: - Private Properties
    private let imageName: String
    private let labelText: String
    
    // MARK: - Initializers
    init(imageName: String, labelText: String) {
        self.imageName = imageName
        self.labelText = labelText
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
}
// MARK: - Preview
#Preview("Page 1") {
    let vc = OnboardingViewController(imageName: "page_1", labelText: "Отслеживайте только то, что хотите")
    
    return vc
}
#Preview("Page 2") {
    let vc = OnboardingViewController(imageName: "page_2", labelText: "Даже если это не литры воды и йога")
    
    return vc
}
