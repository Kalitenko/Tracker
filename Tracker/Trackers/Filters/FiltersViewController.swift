import UIKit

final class FiltersViewController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Фильтры"
        
        static let cellHeight: CGFloat = 75
        static let tableTopInset: CGFloat = 38
        static let tableSideInset: CGFloat = 16
        static let tableBottomInset: CGFloat = 16
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var optionsTableView: Table = {
        let table = Table(style: tableStyle)
        table.delegate = self
        table.dataSource = self
        
        return table
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
        [optionsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        
        let optionsTableViewHeight = Layout.cellHeight * CGFloat(options.count)
        
        NSLayoutConstraint.activate([
            optionsTableView.heightAnchor.constraint(equalToConstant: optionsTableViewHeight),
            optionsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.tableTopInset),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.tableSideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.tableSideInset)
        ])
    }
    
    // MARK: - Public Properties
    var onFilterSelected: Binding<TrackerFilter>?
    
    // MARK: - Private Properties
    private var options: [TrackerFilter] = TrackerFilter.allCases
    private let tableStyle: TableStyle = .checkmark
    private var selectedFilter: TrackerFilter?
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Initializers
    init(filter: TrackerFilter? = .all) {
        
        if let index = options.firstIndex(of: filter ?? .all) {
            let isActive = filter?.isActive ?? false
            self.selectedIndexPath = isActive ? IndexPath(row: index, section: 0) : nil
            self.selectedFilter = isActive ? filter : nil
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        let isLastElement = indexPath.row == options.count - 1
        
        if let checkmarkCell = cell as? CheckmarkCell {
            let filter = options[indexPath.row]
            checkmarkCell.configure(title: filter.title, isLastElement: isLastElement)
            if filter == selectedFilter {
                selectedIndexPath = indexPath
            }
            let isSelected = indexPath == selectedIndexPath
            checkmarkCell.setChecked(isSelected)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousIndexPath = selectedIndexPath,
           let previousCell = tableView.cellForRow(at: previousIndexPath) as? CheckmarkCell {
            previousCell.setChecked(false)
        }
        
        if let currentCell = tableView.cellForRow(at: indexPath) as? CheckmarkCell {
            currentCell.setChecked(true)
        }
        
        selectedIndexPath = indexPath
        selectedFilter = options[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let filter = selectedFilter {
            onFilterSelected?(filter)
        }
        dismiss(animated: true)
    }
    
}

// MARK: - Preview
#Preview("FiltersViewController") {
    FiltersViewController()
}


