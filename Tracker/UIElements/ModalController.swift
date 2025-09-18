import UIKit

class ModalController: UIViewController {
    // MARK: - Constants
    private enum Layout {
        
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    lazy var titleLabel: UILabel = {
        let label = Label(text: "Пример заголовка", style: .modalControllerTitle)
        
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
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupSubViews() {
        [titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}


// MARK: - Preview
#Preview("Modal Controller") {
    let vc = ModalController()
    
    return vc
}
