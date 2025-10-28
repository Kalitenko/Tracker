// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Добавить категорию
  internal static let addCategory = L10n.tr("Localizable", "add_category", fallback: "Добавить категорию")
  /// Отменить
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Отменить")
  /// Отменить
  internal static let cancelAction = L10n.tr("Localizable", "cancel_action", fallback: "Отменить")
  /// Категория
  internal static let category = L10n.tr("Localizable", "category", fallback: "Категория")
  /// Категория с таким названием уже существует
  internal static let categoryExists = L10n.tr("Localizable", "category_exists", fallback: "Категория с таким названием уже существует")
  /// Привычки и события можно
  /// объединить по смыслу
  internal static let categoryHint = L10n.tr("Localizable", "category_hint", fallback: "Привычки и события можно\nобъединить по смыслу")
  /// ================================
  ///    CategoryListViewController
  ///    ================================
  internal static let categoryTitle = L10n.tr("Localizable", "category_title", fallback: "Категория")
  /// Цвет
  internal static let color = L10n.tr("Localizable", "color", fallback: "Цвет")
  /// Создать
  internal static let create = L10n.tr("Localizable", "create", fallback: "Создать")
  /// ================================
  ///    CreateTrackerController
  ///    ================================
  internal static let createTracker = L10n.tr("Localizable", "create_tracker", fallback: "Создание трекера")
  /// Удалить
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "Удалить")
  /// ================================
  ///    AlertHelper
  ///    ================================
  internal static let deleteAction = L10n.tr("Localizable", "delete_action", fallback: "Удалить")
  /// Эта категория точно не нужна?
  internal static let deleteConfirmation = L10n.tr("Localizable", "delete_confirmation", fallback: "Эта категория точно не нужна?")
  /// Готово
  internal static let done = L10n.tr("Localizable", "done", fallback: "Готово")
  /// ================================
  ///    CategoryController
  ///    ================================
  internal static let doneButton = L10n.tr("Localizable", "done_button", fallback: "Готово")
  /// Редактировать
  internal static let edit = L10n.tr("Localizable", "edit", fallback: "Редактировать")
  /// Редактирование категории
  internal static let editCategory = L10n.tr("Localizable", "edit_category", fallback: "Редактирование категории")
  /// ================================
  ///    CollectionHandlers
  ///    ================================
  internal static let emoji = L10n.tr("Localizable", "emoji", fallback: "Emoji")
  /// Введите название категории
  internal static let enterCategoryName = L10n.tr("Localizable", "enter_category_name", fallback: "Введите название категории")
  /// ================================
  ///    NewTrackerController
  ///    ================================
  internal static let enterTrackerName = L10n.tr("Localizable", "enter_tracker_name", fallback: "Введите название трекера")
  /// Каждый день
  internal static let everyDay = L10n.tr("Localizable", "every_day", fallback: "Каждый день")
  /// Пт
  internal static let friShort = L10n.tr("Localizable", "fri_short", fallback: "Пт")
  /// Пятница
  internal static let friday = L10n.tr("Localizable", "friday", fallback: "Пятница")
  /// Привычка
  internal static let habit = L10n.tr("Localizable", "habit", fallback: "Привычка")
  /// Нерегулярное событие
  internal static let irregularEvent = L10n.tr("Localizable", "irregular_event", fallback: "Нерегулярное событие")
  /// Пн
  internal static let monShort = L10n.tr("Localizable", "mon_short", fallback: "Пн")
  /// ================================
  ///    WeekDay
  ///    ================================
  internal static let monday = L10n.tr("Localizable", "monday", fallback: "Понедельник")
  /// ================================
  ///    Mode
  ///    ================================
  internal static let newCategory = L10n.tr("Localizable", "new_category", fallback: "Новая категория")
  /// ================================
  ///    TrackerType
  ///    ================================
  internal static let newHabit = L10n.tr("Localizable", "new_habit", fallback: "Новая привычка")
  /// Новое нерегулярное событие
  internal static let newIrregularEvent = L10n.tr("Localizable", "new_irregular_event", fallback: "Новое нерегулярное событие")
  /// Даже если это
  /// не литры воды и йога
  internal static let notWaterYoga = L10n.tr("Localizable", "not_water_yoga", fallback: "Даже если это\nне литры воды и йога")
  /// Сб
  internal static let satShort = L10n.tr("Localizable", "sat_short", fallback: "Сб")
  /// Суббота
  internal static let saturday = L10n.tr("Localizable", "saturday", fallback: "Суббота")
  /// ================================
  ///    ScheduleController
  ///    ================================
  internal static let schedule = L10n.tr("Localizable", "schedule", fallback: "Расписание")
  /// Расписание
  internal static let scheduleLabel = L10n.tr("Localizable", "schedule_label", fallback: "Расписание")
  /// Поиск
  internal static let search = L10n.tr("Localizable", "search", fallback: "Поиск")
  /// Вс
  internal static let sunShort = L10n.tr("Localizable", "sun_short", fallback: "Вс")
  /// Воскресенье
  internal static let sunday = L10n.tr("Localizable", "sunday", fallback: "Воскресенье")
  /// ================================
  ///    CategoryViewModel
  ///    ================================
  internal static func symbolLimit(_ p1: Int) -> String {
    return L10n.tr("Localizable", "symbol_limit", p1, fallback: "Ограничение %d символов")
  }
  /// ================================
  ///    NewTrackerViewModel
  ///    ================================
  internal static func symbolLimitTracker(_ p1: Int) -> String {
    return L10n.tr("Localizable", "symbol_limit_tracker", p1, fallback: "Ограничение %d символов")
  }
  /// Статистика
  internal static let tabStatistics = L10n.tr("Localizable", "tab_statistics", fallback: "Статистика")
  /// ================================
  ///    TabBarController
  ///    ================================
  internal static let tabTrackers = L10n.tr("Localizable", "tab_trackers", fallback: "Трекеры")
  /// ================================
  ///    OnboardingPageViewController
  ///    ================================
  internal static let techExclamation = L10n.tr("Localizable", "tech_exclamation", fallback: "Вот это технологии!")
  /// Чт
  internal static let thuShort = L10n.tr("Localizable", "thu_short", fallback: "Чт")
  /// Четверг
  internal static let thursday = L10n.tr("Localizable", "thursday", fallback: "Четверг")
  /// Отслеживайте только то, что хотите
  internal static let trackOnlyWhatYouWant = L10n.tr("Localizable", "track_only_what_you_want", fallback: "Отслеживайте только то, что хотите")
  /// ================================
  ///    TrackersViewController
  ///    ================================
  internal static let trackers = L10n.tr("Localizable", "trackers", fallback: "Трекеры")
  /// Вт
  internal static let tueShort = L10n.tr("Localizable", "tue_short", fallback: "Вт")
  /// Вторник
  internal static let tuesday = L10n.tr("Localizable", "tuesday", fallback: "Вторник")
  /// Ср
  internal static let wedShort = L10n.tr("Localizable", "wed_short", fallback: "Ср")
  /// Среда
  internal static let wednesday = L10n.tr("Localizable", "wednesday", fallback: "Среда")
  /// Что будем отслеживать?
  internal static let whatToTrack = L10n.tr("Localizable", "what_to_track", fallback: "Что будем отслеживать?")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
