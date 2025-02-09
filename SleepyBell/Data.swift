//
//  Data.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/3/25.
//

import CoreData

// MARK: - AlarmListEntity Extensions

/// Extension for `AlarmListEntity` to provide computed properties for converting stored binary data
/// into Swift arrays and vice versa. These properties use JSON encoding and decoding to bridge between
/// Core Data's binary storage and native Swift types.
extension AlarmListEntity {
    
    /// A computed property to get and set the alarm identifier array.
    var idArray: [Int] {
        get {
            guard let data = idList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            idList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the seconds array for alarms.
    var secArray: [Int] {
        get {
            guard let data = secList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            secList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the minutes array for alarms.
    var minArray: [Int] {
        get {
            guard let data = minList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            minList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the hours array for alarms.
    var hourArray: [Int] {
        get {
            guard let data = hourList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            hourList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the day list (e.g., "AM"/"PM") for alarms.
    var dayArray: [String] {
        get {
            guard let data = dayList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            dayList = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - NotificationEntity Extensions

/// Extension for `NotificationEntity` to provide a computed property for converting the stored binary data
/// representing a sound dictionary into a native Swift dictionary.
extension NotificationEntity {
    
    /// A computed property to get and set the alarm sound dictionary.
    var soundTitleDict: [String:String] {
        get {
            guard let data = soundDict else { return [:] }
            return (try? JSONDecoder().decode([String:String].self, from: data)) ?? [:]
        }
        set {
            soundDict = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - StatisticsEntity Extensions

/// Extension for `StatisticsEntity` to provide computed properties for converting stored statistical data
/// into native Swift types. This includes arrays for wake and sleep times, as well as dictionaries and arrays
/// for alarm modes and corresponding dates.
extension StatisticsEntity {
    
    /// A computed property to get and set the array of wake times.
    var wakeArray: [String] {
        get {
            guard let data = wokenList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            wokenList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the array of sleep times.
    var sleepArray: [String] {
        get {
            guard let data = sleepingList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            sleepingList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the alarm modes dictionary.
    var alarmModesDict: [String:Int] {
        get {
            guard let data = modeDict else { return [:] }
            return (try? JSONDecoder().decode([String:Int].self, from: data)) ?? [:]
        }
        set {
            modeDict = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the array of wake dates.
    var wakeDateArray: [String] {
        get {
            guard let data = wokenDateList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            wokenDateList = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// A computed property to get and set the array of sleep dates.
    var sleepDateArray: [String] {
        get {
            guard let data = sleepingDateList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            sleepingDateList = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - PersistenceController

/// A controller class that manages Core Data persistence operations.
///
/// The `PersistenceController` encapsulates the Core Data stack and provides methods for saving,
/// fetching, and deleting data related to alarms, notification sounds, and statistical information.
class PersistenceController {
    
    /// A shared singleton instance of `PersistenceController`.
    static let shared = PersistenceController()
    
    /// The Core Data persistent container.
    let container: NSPersistentContainer
    
    /// Initializes a new instance of `PersistenceController` and loads the persistent stores.
    init() {
        container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    /// Saves an `AlarmList` to the Core Data store.
    ///
    /// - Parameter alarms: An `AlarmList` object containing arrays for alarm IDs, seconds, minutes, hours, and day indicators.
    func saveAlarmList(alarms: AlarmList) {
        let context = container.viewContext
        let alarmEntity = AlarmListEntity(context: context)
        
        alarmEntity.idArray = alarms.idList
        alarmEntity.secArray = alarms.secList
        alarmEntity.minArray = alarms.minList
        alarmEntity.hourArray = alarms.hourList
        alarmEntity.dayArray = alarms.dayList
        
        do {
            try context.save()  // Save to Core Data
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    /// Saves a dictionary of notification sound settings to the Core Data store.
    ///
    /// - Parameter soundDict: A dictionary mapping sound identifiers to their titles.
    func saveNotificationSounds(soundDict: [String:String]) {
        let context = container.viewContext
        let notiEntity = NotificationEntity(context: context)
        
        notiEntity.soundTitleDict = soundDict
        
        do {
            try context.save()  // Save to Core Data
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    /// Saves statistical data to the Core Data store.
    ///
    /// - Parameters:
    ///   - sleepList: An array of sleep times.
    ///   - wakingList: An array of wake times.
    ///   - modesDict: A dictionary mapping alarm identifiers to usage counts.
    ///   - sleepDateList: An array of dates corresponding to sleep times.
    ///   - wakingDateList: An array of dates corresponding to wake times.
    func saveStats(sleepList: [String], wakingList: [String], modesDict: [String:Int], sleepDateList: [String], wakingDateList: [String]) {
        let context = container.viewContext
        let statEntity = StatisticsEntity(context: context)
        
        statEntity.wakeArray = wakingList
        statEntity.sleepArray = sleepList
        statEntity.alarmModesDict = modesDict
        statEntity.wakeDateArray = wakingDateList
        statEntity.sleepDateArray = sleepDateList
        
        do {
            try context.save()  // Save to Core Data
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    /// Deletes all data from the Core Data store by destroying and recreating the persistent store.
    func deleteAll() {
        let persistentContainer = PersistenceController.shared.container
        
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            print("Persistent store URL not found.")
            return
        }
        
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        do {
            try coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            print("Core Data store reset successfully.")
        } catch {
            print("Failed to reset Core Data: \(error)")
        }
    }
}

// MARK: - Data Fetching Functions

/// Fetches an array of `AlarmList` objects from the Core Data store.
///
/// - Returns: An array of `AlarmList` objects, or an empty array if fetching fails.
func fetchAlarmList() -> [AlarmList] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<AlarmListEntity> = AlarmListEntity.fetchRequest()
    
    do {
        let alarmListEntities = try context.fetch(fetchRequest)
        return alarmListEntities.map { AlarmList(idList: $0.idArray, secList: $0.secArray, minList: $0.minArray, hourList: $0.hourArray, dayList: $0.dayArray) }
    } catch {
        print("Failed to fetch users: \(error)")
        return []
    }
}

/// Fetches a list of sound dictionaries from the Core Data store.
///
/// - Returns: An array of dictionaries mapping sound identifiers to their titles.
func fetchSoundList() -> [[String:String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
    
    do {
        let notificationEntities = try context.fetch(fetchRequest)
        return notificationEntities.map { $0.soundTitleDict }
    } catch {
        print("Failed to fetch notifications: \(error)")
        return []
    }
}

/// Fetches a list of wake time arrays from the Core Data store.
///
/// - Returns: An array of string arrays representing wake times.
func fetchAlarmWakeList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let statEntities = try context.fetch(fetchRequest)
        return statEntities.map { $0.wakeArray }
    } catch {
        print("Failed to fetch wakes: \(error)")
        return []
    }
}

/// Fetches a list of sleep time arrays from the Core Data store.
///
/// - Returns: An array of string arrays representing sleep times.
func fetchAlarmSleepList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let statEntities = try context.fetch(fetchRequest)
        return statEntities.map { $0.sleepArray }
    } catch {
        print("Failed to fetch sleeps: \(error)")
        return []
    }
}

/// Fetches a list of alarm mode dictionaries from the Core Data store.
///
/// - Returns: An array of dictionaries mapping alarm identifiers to usage counts.
func fetchAlarmModeList() -> [[String:Int]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let statEntities = try context.fetch(fetchRequest)
        return statEntities.map { $0.alarmModesDict }
    } catch {
        print("Failed to fetch modes: \(error)")
        return []
    }
}

/// Fetches a list of wake date arrays from the Core Data store.
///
/// - Returns: An array of string arrays representing wake dates.
func fetchAlarmWakeDateList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let statEntities = try context.fetch(fetchRequest)
        return statEntities.map { $0.wakeDateArray }
    } catch {
        print("Failed to fetch wakes: \(error)")
        return []
    }
}

/// Fetches a list of sleep date arrays from the Core Data store.
///
/// - Returns: An array of string arrays representing sleep dates.
func fetchAlarmSleepDateList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let statEntities = try context.fetch(fetchRequest)
        return statEntities.map { $0.sleepDateArray }
    } catch {
        print("Failed to fetch sleeps: \(error)")
        return []
    }
}

/// Fetches the latest (most recent) `AlarmList` from the Core Data store.
///
/// - Returns: An `AlarmList` object. If none are found, returns an empty `AlarmList`.
func fetchLatestAlarm() -> AlarmList {
    let alarms = fetchAlarmList()
    if alarms.isEmpty {
        return AlarmList()
    } else {
        return alarms.last!
    }
}

/// Fetches the latest (most recent) sound dictionary from the Core Data store.
///
/// - Returns: A dictionary mapping sound identifiers to their titles, or an empty dictionary if none are found.
func fetchLatestSoundDict() -> [String:String] {
    let sounds = fetchSoundList()
    if sounds.isEmpty {
        return [:]
    } else {
        return sounds.last!
    }
}

/// Fetches the latest (most recent) wake time array from the Core Data store.
///
/// - Returns: An array of wake times, or an empty array if none are found.
func fetchLatestAlarmWakeList() -> [String] {
    let wakes = fetchAlarmWakeList()
    if wakes.isEmpty {
        return []
    } else {
        return wakes.last!
    }
}

/// Fetches the latest (most recent) sleep time array from the Core Data store.
///
/// - Returns: An array of sleep times, or an empty array if none are found.
func fetchLatestAlarmSleepList() -> [String] {
    let sleeps = fetchAlarmSleepList()
    if sleeps.isEmpty {
        return []
    } else {
        return sleeps.last!
    }
}

/// Fetches the latest (most recent) alarm mode dictionary from the Core Data store.
///
/// - Returns: A dictionary mapping alarm identifiers to usage counts, or an empty dictionary if none are found.
func fetchLatestAlarmModeList() -> [String:Int] {
    let modes = fetchAlarmModeList()
    if modes.isEmpty {
        return [:]
    } else {
        return modes.last!
    }
}

/// Fetches the latest (most recent) wake date array from the Core Data store.
///
/// - Returns: An array of wake dates, or an empty array if none are found.
func fetchLatestAlarmWakeDateList() -> [String] {
    let wakeDates = fetchAlarmWakeDateList()
    if wakeDates.isEmpty {
        return []
    } else {
        return wakeDates.last!
    }
}

/// Fetches the latest (most recent) sleep date array from the Core Data store.
///
/// - Returns: An array of sleep dates, or an empty array if none are found.
func fetchLatestAlarmSleepDateList() -> [String] {
    let sleepDates = fetchAlarmSleepDateList()
    if sleepDates.isEmpty {
        return []
    } else {
        return sleepDates.last!
    }
}
