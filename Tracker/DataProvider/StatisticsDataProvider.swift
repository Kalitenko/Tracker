import UIKit

protocol StatisticsDataProviderProtocol {
    func completedTrackers() -> Int
    func averagePerDay() -> Double
    func bestPeriod() -> Int
    func bestPeriodPerTracker() -> Int
}

final class StatisticsDataProvider {
    
    // MARK: - Shared Instance
    static let shared = StatisticsDataProvider()
    
    // MARK: - Private Properties
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializers
    private init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        recordStore = TrackerRecordStore(context: context)
    }
    
    // MARK: - Private Methods
    private func fetchCompletedTrackers() -> Int {
        let total: Int
        do {
            total = try recordStore.totalCompletedTrackers()
        } catch {
            Logger.error("Ошибка получения общего числа всех завершенных трекеров: \(error)")
            total = 0
        }
        return total
    }
    
    private func calculateAveragePerDay() -> Double {
        var records: [TrackerRecord] = []
        do {
            records = try recordStore.fetchAllTrackerRecords()
        } catch {
            Logger.error("Ошибка получения всех записей о завершенных трекерах: \(error)")
        }
        guard !records.isEmpty else { return 0 }
        let groupedByDate = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        let dailyCounts = groupedByDate.values.map { $0.count }
        
        guard !dailyCounts.isEmpty else { return 0 }
        return Double(dailyCounts.reduce(0, +)) / Double(dailyCounts.count)
    }
    
    private func calculateBestStreak(for dates: [Date], calendar: Calendar = .current) -> Int {
        let uniqueDays = Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()
        guard !uniqueDays.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<uniqueDays.count {
            let previous = uniqueDays[i - 1]
            let current = uniqueDays[i]
            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }
        return max(maxStreak, currentStreak)
    }
    
    private func findBestPeriod() -> Int {
        do {
            let records = try recordStore.fetchAllTrackerRecords()
            let dates = records.map { $0.date }
            return calculateBestStreak(for: dates)
        } catch {
            Logger.error("Ошибка получения всех записей: \(error)")
            return 0
        }
    }

    private func findBestPeriodPerTracker() -> Int {
        do {
            let records = try recordStore.fetchAllTrackerRecords()
            let groupedByTracker = Dictionary(grouping: records) { $0.trackerId }

            return groupedByTracker
                .values
                .map { trackerRecords in
                    calculateBestStreak(for: trackerRecords.map { $0.date })
                }
                .max() ?? 0
        } catch {
            Logger.error("Ошибка получения всех записей: \(error)")
            return 0
        }
    }

}

// MARK: - StatisticsDataProviderProtocol
extension StatisticsDataProvider: StatisticsDataProviderProtocol {
    func averagePerDay() -> Double {
        calculateAveragePerDay()
    }
    
    func bestPeriod() -> Int {
        findBestPeriod()
    }
    
    func bestPeriodPerTracker() -> Int {
        findBestPeriodPerTracker()
    }
    
    func completedTrackers() -> Int {
        fetchCompletedTrackers()
    }
}

