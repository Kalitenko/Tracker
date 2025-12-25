import UIKit

final class GradientOutlineView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientBorder(
            colors: [
                UIColor(red: 0.0, green: 0.48, blue: 0.98, alpha: 1.0),  // #007BFA
                UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1.0), // #46E69D
                UIColor(red: 0.99, green: 0.3, blue: 0.29, alpha: 1.0)  // #FD4C49
            ],
            lineWidth: 1,
            cornerRadius: 16
        )
    }
}

final class StatisticsCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Layout {
        static let horizontalInset: CGFloat = 12
        static let separatorHeight: CGFloat = 12
        static let stackSpacing: CGFloat = 7
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 16
    }
    
    // MARK: - UI Elements
    lazy var titleLabel: UILabel = {
        let label = Label(style: .statisticsTitle)
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = Label(style: .statisticsSubtitle)
        
        return label
    }()
    
    lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        
        return stackView
    }()
    
    lazy var outlineView: UIView = {
        let view = GradientOutlineView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        backgroundColor = .clear
    }
    
    private func setupSubViews() {
        [outlineView, labelsStackView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            outlineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            outlineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            outlineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.separatorHeight),
            
            labelsStackView.leadingAnchor.constraint(equalTo: outlineView.leadingAnchor, constant: Layout.horizontalInset),
            labelsStackView.trailingAnchor.constraint(equalTo: outlineView.trailingAnchor, constant: -Layout.horizontalInset),
            labelsStackView.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: outlineView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Layout.separatorHeight)
        ])
    }
    
    // MARK: - Public Methods
    func configure(title: String, subtitle: String, isLastElement: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        separatorView.isHidden = isLastElement
    }
}
