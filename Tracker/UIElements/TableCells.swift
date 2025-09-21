import UIKit

class TableCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let separatorHeight: CGFloat = 1
        static let stackSpacing: CGFloat = 1
    }
    
    // MARK: - UI Elements
    lazy var titleLabel: UILabel = {
        let label = Label(style: .standard)
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = Label(style: .subtitle)
        
        return label
    }()
    
    lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        
        return stackView
    }()
    
    lazy var rightContainer = UIView()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .gray)
        
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        backgroundColor = UIColor(resource: .background)
    }
    
    private func setupSubViews() {
        [labelsStackView, rightContainer, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            rightContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),
            rightContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Layout.separatorHeight)
        ])
    }
    
    // MARK: - Public Methods
    func configure(title: String, subtitle: String? = nil, isLastElement: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil)
        separatorView.isHidden = isLastElement
    }
    
}

// MARK: - Checkmark Cell
final class CheckmarkCell: TableCell {
    
    private lazy var checkmark = UIImageView(image: UIImage(resource: .checkmark))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCheckmark()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCheckmark() {
        checkmark.isHidden = true
        rightContainer.addSubview(checkmark)
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkmark.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            checkmark.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor),
            checkmark.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            checkmark.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
        ])
    }
    
    func configure(title: String, subtitle: String? = nil, isLastElement: Bool, selected: Bool) {
        super.configure(title: title, subtitle: subtitle, isLastElement: isLastElement)
        subtitleLabel.isHidden = (subtitle == nil)
        checkmark.isHidden = !selected
    }
}

// MARK: - Arrow Cell
final class ArrowCell: TableCell {
    
    private lazy var arrow = UIImageView(image: UIImage(resource: .chevron))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupArrow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupArrow() {
        rightContainer.addSubview(arrow)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrow.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            arrow.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor),
            arrow.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            arrow.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
        ])
    }
    
}

// MARK: - Toggle Cell
final class ToggleCell: TableCell {
    
    private lazy var  toggle = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupToggle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupToggle() {
        rightContainer.addSubview(toggle)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemBlue
        toggle.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        NSLayoutConstraint.activate([
            toggle.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            toggle.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor),
            toggle.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            toggle.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
        ])
    }
    
    func configure(title: String, subtitle: String? = nil, isLastElement: Bool, isOn: Bool) {
        super.configure(title: title, subtitle: subtitle, isLastElement: isLastElement)
        subtitleLabel.isHidden = (subtitle == nil)
        toggle.isOn = isOn
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
    
    var onToggle: ((Bool) -> Void)?
    
}

// MARK: - Controller
final class TableStylesViewController: UITableViewController {
    private enum Row {
        case checkmark(String, Bool)
        case arrow(String, String?)
        case toggle(String, Bool)
    }
    
    private var rows: [Row] = [
        .checkmark("Выбор 1", false),
        .checkmark("Выбор 2", true),
        .arrow("Открыть список", "Выбрано: 3 элемента"),
        .arrow("Открыть список", "Выбрано: 3 элемента"),
        .arrow("Открыть список", "Выбрано: 3 элемента"),
        .toggle("Включить уведомления", true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CheckmarkCell.self, forCellReuseIdentifier: "CheckmarkCell")
        tableView.register(ArrowCell.self, forCellReuseIdentifier: "ArrowCell")
        tableView.register(ToggleCell.self, forCellReuseIdentifier: "ToggleCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isLastElement = indexPath.isLastRow(in: tableView)
        switch rows[indexPath.row] {
        case let .checkmark(title, selected):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkCell", for: indexPath) as! CheckmarkCell
            cell.configure(title: title, isLastElement: isLastElement, selected: selected)
            return cell
        case let .arrow(title, subtitle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArrowCell", for: indexPath) as! ArrowCell
            cell.configure(title: title, subtitle: subtitle, isLastElement: isLastElement)
            return cell
        case let .toggle(title, isOn):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleCell
            cell.configure(title: title, isLastElement: isLastElement, isOn: isOn)
            return cell
        }
    }
}
#Preview("ScheduleController") {
    let vc = TableStylesViewController()
    
    return vc
}
