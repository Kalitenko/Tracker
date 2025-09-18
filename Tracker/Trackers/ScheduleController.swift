import UIKit

final class ScheduleController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Расписание"
        static let doneButtonText = "Готово"
        
        static let cellHeight: CGFloat = 75
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var optionsTableView: Table = {
        let table = Table(style: tableStyle)
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
    
    private lazy var doneButton: UIButton = {
        let button = BlackButton(title: Layout.doneButtonText)
        button.addTarget(self, action: #selector(Self.didTapDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [doneButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
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
        [optionsTableView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        let optionsTableViewHeight = CGFloat(options.count) * Layout.cellHeight
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            optionsTableView.heightAnchor.constraint(equalToConstant: optionsTableViewHeight),
            optionsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
    }
    
    
    // MARK: - Public Properties
    var onDaysSelected: (([Day]) -> Void)?
    var selectedDays: [Day] = []
    
    // MARK: - Private Properties
    private let options: [Day] = Day.allCases
    private let tableStyle: TableStyle = .toggle
    
    // MARK: - Private Methods
    
    // MARK: - Actions
    @objc private func didTapDoneButton(_ sender: Any) {
        Logger.info("Расписание выбрано")
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onDaysSelected?(selectedDays)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ScheduleController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        if let toggleCell = cell as? ToggleCell {
            let day = options[indexPath.row]
            toggleCell.configure(title: day.rawValue, isOn: selectedDays.contains(day))
            toggleCell.onToggle = { [weak self] isOn in
                guard let self else { return }
                if isOn {
                    self.selectedDays.append(day)
                } else {
                    self.selectedDays.removeAll { $0 == day }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
}

// MARK: - UITableViewDataSource
extension ScheduleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
    
}

// MARK: - Preview
#if DEBUG
extension ScheduleController {
    
}
#endif

#Preview("ScheduleController") {
    let vc = ScheduleController()
    
    return vc
}
