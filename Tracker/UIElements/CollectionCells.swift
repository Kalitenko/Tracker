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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
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
    
    // MARK: - Public Methods
    func configure(emoji: String, isSelected: Bool = false) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? UIColor(resource: .lightGray) : .clear
    }
}

final class ColorCell: CollectionCell {
    
    static let identifier = "ColorCollectionViewCell"
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupSubViews() {
        [borderView, colorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        container.addSubview(borderView)
        borderView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 49),
            borderView.heightAnchor.constraint(equalTo: borderView.widthAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor)
        ])
    }
    
    func configure(color: UIColor, isSelected: Bool = false) {
        colorView.backgroundColor = color
        let borderLayer = borderView.layer
        if isSelected {
            borderLayer.borderWidth = 3
            borderLayer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            borderLayer.borderWidth = 0
            borderLayer.borderColor = UIColor.clear.cgColor
        }
    }
}
