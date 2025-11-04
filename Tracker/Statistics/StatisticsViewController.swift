import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let statisticsLabelText = "Статистика"
        
        static let cellHeight: CGFloat = 102
        static let tableTopInset: CGFloat = 77
        static let tableSideInset: CGFloat = 16
        static let emptyStateViewHorizontalInset: CGFloat = 16
        static let emptyStateViewHalfSize: CGFloat = 62
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var uiNavigationBarAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        
        let textColor = UIColor(resource: .black)
        let font = UIFont.bold34
        
        appearance.titleTextAttributes = [
            .foregroundColor: textColor,
            .font: font
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: textColor,
            .font: font
        ]
        
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(resource: .white)
        
        return appearance
    }()
    
    private lazy var optionsTableView: Table = {
        let table = Table(style: .statistics)
        table.delegate = self
        table.dataSource = self
        table.bounces = false
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        
        return table
    }()
    
    private lazy var emptyStateView = EmptyStateView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        configureUINavigationBar()
        bindViewModel()
        viewModel.loadStatistics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.openScreen(name: Screen.statistics.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.closeScreen(name: Screen.statistics.rawValue)
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [optionsTableView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        let tableHeightConstraint = optionsTableView.heightAnchor.constraint(equalToConstant: 0)
        self.tableHeightConstraint = tableHeightConstraint
        
        NSLayoutConstraint.activate([
            tableHeightConstraint,
            optionsTableView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.tableTopInset),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.tableSideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.tableSideInset),
            optionsTableView.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor),
            
            middleGuide.topAnchor.constraint(equalTo: guide.topAnchor),
            middleGuide.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            emptyStateView.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor, constant: -Layout.emptyStateViewHalfSize),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.emptyStateViewHorizontalInset),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.emptyStateViewHorizontalInset)
        ])
    }
    
    private func configureUINavigationBar() {
        navigationItem.title = Layout.statisticsLabelText
        
        let appearance = uiNavigationBarAppearance
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Public Properties
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var selectedCategory: TrackerCategory?
    
    // MARK: - Private Properties
    private var options: [StatisticsData] = []
    private let tableStyle: TableStyle = .statistics
    private let viewModel: StatisticsViewModel
    private var tableHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.onEmptyStateChanged = { [weak self] emptyStateViewType in
            guard let type = emptyStateViewType else {
                self?.emptyStateView.hide()
                return
            }
            self?.emptyStateView.show(type: type)
        }
        
        viewModel.onStatisticsChanged = { [weak self] statistics in
            guard let self else { return }
            options = statistics
            updateTableHeight()
            optionsTableView.reloadData()
        }
        
        viewModel.onIdealDaysRecalculated = { [weak self] statisticData in
            guard let self, let statisticData else { return }
            if !options.isEmpty {
                let row = self.options.firstIndex { $0.metric == .idealDays } ?? 0
                options[row] = statisticData
                let idealDaysIndex: IndexPath = .init(row: row, section: 0)
                optionsTableView.reloadRows(at: [idealDaysIndex], with: .none)
            }
        }
    }
    
    private func updateTableHeight() {
        optionsTableView.layoutIfNeeded()
        
        guard let tableHeightConstraint else { return }
        
        let contentHeight = CGFloat(options.count) * Layout.cellHeight
        let tableTop = optionsTableView.frame.minY
        let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
        let availableHeight = safeAreaBottom - tableTop
        
        tableHeightConstraint.constant = min(contentHeight, availableHeight)
        optionsTableView.isScrollEnabled = contentHeight > availableHeight
    }
    
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        if options.isEmpty {
            return cell
        }
        
        let isLastElement = indexPath.row == options.count - 1
        
        if let statisticsCell = cell as? StatisticsCell {
            let metric = options[indexPath.row].metric.title
            let data = options[indexPath.row].data
            statisticsCell.configure(title: data, subtitle: metric, isLastElement: isLastElement)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
}
