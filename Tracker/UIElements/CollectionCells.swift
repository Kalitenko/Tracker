import UIKit

class CollectionCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    private func setupSubViews() {
        [container].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - Emoji Cell
final class EmojiCell: CollectionCell {
    
    // MARK: - Public Static Properties
    static let identifier = "EmojiCollectionViewCell"
    
    // MARK: - UI Elements
    lazy var emojiLabel: UILabel = {
        let label = Label(font: UIFont.bold32, alignment: .center)
        label.layer.masksToBounds = true
        
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmojiLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: - Color Cell
final class ColorCell: CollectionCell {
    
    // MARK: - Public Static Properties
    static let identifier = "ColorCollectionViewCell"
    
    // MARK: - UI Elements
    lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupColorView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor)
        ])
    }
}
