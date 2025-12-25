import UIKit

protocol StatisticsDataProviderProtocol {
    func completedTrackers() -> Int
    func averagePerDay() -> Double
    func bestPeriod() -> Int
    func bestPeriodPerTracker() -> Int
    func idealDays() -> Int
}

final class StatisticsDataProvider {
    
    // MARK: - Shared Instance
    static let shared = StatisticsDataProvider()
    
    // MARK: - Private Properties
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    // MARK: - Initializers
    private init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        recordStore = TrackerRecordStore(context: context)
        trackerStore = TrackerStore(context: context)
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
    
    private func countIdealDays() -> Int {
        let calendar = Calendar.current
        
        let trackers: [Tracker]
        do {
            trackers = try trackerStore.fetchAllTrackers()
        } catch {
            Logger.error("Не удалось получить трекеры: \(error)")
            return 0
        }
        
        let records: [TrackerRecord]
        do {
            records = try recordStore.fetchAllTrackerRecords()
        } catch {
            Logger.error("Не удалось получить записи: \(error)")
            return 0
        }
        
        var scheduledByWeekday = [Int: Set<Int32>]()
        for tracker in trackers {
            for day in tracker.schedule {
                scheduledByWeekday[day.calendarWeekday, default: []].insert(tracker.id)
            }
        }
        
        var completedByDate = [Date: Set<Int32>]()
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            completedByDate[day, default: []].insert(record.trackerId)
        }
        
        var idealDays = 0
        for (day, completedTrackers) in completedByDate {
            let weekday = calendar.component(.weekday, from: day)
            let scheduledTrackers = scheduledByWeekday[weekday] ?? []
            if !scheduledTrackers.isEmpty && scheduledTrackers.isSubset(of: completedTrackers) {
                idealDays += 1
            }
        }
        return idealDays
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
    
    func idealDays() -> Int {
        countIdealDays()
    }
}

