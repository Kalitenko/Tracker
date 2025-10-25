import UIKit

final class ScheduleController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Расписание"
        static let doneButtonText = "Готово"
        
        static let cellHeight: CGFloat = 75
        static let titleTopInset: CGFloat = 27
        static let tableTopInset: CGFloat = 38
        static let tableSideInset: CGFloat = 16
        static let stackSideInset: CGFloat = 20
        static let stackBottomInset: CGFloat = 16
        static let stackSpacing: CGFloat = 8
    }
    
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
        [optionsTableView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        let optionsTableViewHeight = CGFloat(options.count) * Layout.cellHeight
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.titleTopInset),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            optionsTableView.heightAnchor.constraint(equalToConstant: optionsTableViewHeight),
            optionsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.tableTopInset),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.tableSideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.tableSideInset),
            
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Layout.stackBottomInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.stackSideInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.stackSideInset)
        ])
    }
    
    // MARK: - Public Properties
    var onDaysSelected: (([WeekDay]) -> Void)?
    var selectedDays: [WeekDay] = []
    
    // MARK: - Private Properties
    private let options: [WeekDay] = WeekDay.allCases
    private let tableStyle: TableStyle = .toggle
    
    // MARK: - Actions
    @objc private func didTapDoneButton(_ sender: Any) {
        Logger.info("Расписание выбрано")
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onDaysSelected?(self.selectedDays)
        }
    }
}

// MARK: - UITableViewDataSource
extension ScheduleController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        let isLastElement = indexPath.row == options.count - 1
        
        if let toggleCell = cell as? ToggleCell {
            let day = options[indexPath.row]
            toggleCell.configure(title: day.rawValue, isLastElement: isLastElement, isOn: selectedDays.contains(day))
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
}

// MARK: - UITableViewDelegate
extension ScheduleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
}

// MARK: - Preview
#Preview("ScheduleController") {
    let vc = ScheduleController()
    
    return vc
}
