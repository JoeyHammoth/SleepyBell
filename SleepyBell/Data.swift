//
//  Data.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/3/25.
//

import CoreData


extension AlarmListEntity { // Extension computed variables to convert between arrays and binary data in the core database
    var idArray: [Int] {
        get {
            guard let data = idList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            idList = try? JSONEncoder().encode(newValue)
        }
    }
    
    var secArray: [Int] {
        get {
            guard let data = secList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            secList = try? JSONEncoder().encode(newValue)
        }
    }
    
    var minArray: [Int] {
        get {
            guard let data = minList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            minList = try? JSONEncoder().encode(newValue)
        }
    }
    
    var hourArray: [Int] {
        get {
            guard let data = hourList else { return [] }
            return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        }
        set {
            hourList = try? JSONEncoder().encode(newValue)
        }
    }
    
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

extension NotificationEntity {
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

extension StatisticsEntity {
    var wakeArray: [String] {
        get {
            guard let data = wokenList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            wokenList = try? JSONEncoder().encode(newValue)
        }
    }
    
    var sleepArray: [String] {
        get {
            guard let data = sleepingList else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            sleepingList = try? JSONEncoder().encode(newValue)
        }
    }
    
    var alarmModesDict: [String:Int] {
        get {
            guard let data = modeDict else { return [:] }
            return (try? JSONDecoder().decode([String:Int].self, from: data)) ?? [:]
        }
        set {
            modeDict = try? JSONEncoder().encode(newValue)
        }
    }
}

class PersistenceController { // Persistence controller to load database and save stuff inside it
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
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
    
    func saveStats(sleepList: [String], wakingList: [String], modesDict: [String:Int]) {
        let context = container.viewContext
        let statEntity = StatisticsEntity(context: context)
        
        statEntity.wakeArray = wakingList
        statEntity.sleepArray = sleepList
        statEntity.alarmModesDict = modesDict
        
        do {
            try context.save()  // Save to Core Data
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
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

func fetchAlarmList() -> [AlarmList] { // For fetching stuff from the database
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<AlarmListEntity> = AlarmListEntity.fetchRequest()
    
    do {
        let AlarmListEntities = try context.fetch(fetchRequest)
        return AlarmListEntities.map { AlarmList(idList: $0.idArray, secList: $0.secArray, minList: $0.minArray, hourList: $0.hourArray, dayList: $0.dayArray) }
    } catch {
        print("Failed to fetch users: \(error)")
        return []
    }
}

func fetchSoundList() -> [[String:String]] { // For fetching stuff from the database
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
    
    do {
        let NotificationEntities = try context.fetch(fetchRequest)
        return NotificationEntities.map { $0.soundTitleDict }
    } catch {
        print("Failed to fetch notifications: \(error)")
        return []
    }
}

func fetchAlarmWakeList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let StatEntities = try context.fetch(fetchRequest)
        return StatEntities.map { $0.wakeArray }
    } catch {
        print("Failed to fetch wakes: \(error)")
        return []
    }
}

func fetchAlarmSleepList() -> [[String]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let StatEntities = try context.fetch(fetchRequest)
        return StatEntities.map { $0.sleepArray }
    } catch {
        print("Failed to fetch sleeps: \(error)")
        return []
    }
}

func fetchAlarmModeList() -> [[String:Int]] {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<StatisticsEntity> = StatisticsEntity.fetchRequest()
    
    do {
        let StatEntities = try context.fetch(fetchRequest)
        return StatEntities.map { $0.alarmModesDict }
    } catch {
        print("Failed to fetch modes: \(error)")
        return []
    }
}

func fetchLatestAlarm() -> AlarmList {
    if fetchAlarmList().count == 0 {
        return AlarmList()
    } else {
        return fetchAlarmList().last!
    }
}

func fetchLatestSoundDict() -> [String:String] {
    if fetchSoundList().count == 0 {
        return [:]
    } else {
        return fetchSoundList().last!
    }
}

func fetchLatestAlarmWakeList() -> [String] {
    if fetchAlarmWakeList().count == 0 {
        return []
    } else {
        return fetchAlarmWakeList().last!
    }
}

func fetchLatestAlarmSleepList() -> [String] {
    if fetchAlarmSleepList().count == 0 {
        return []
    } else {
        return fetchAlarmSleepList().last!
    }
}

func fetchLatestAlarmModeList() -> [String:Int] {
    if fetchAlarmModeList().count == 0 {
        return [:]
    } else {
        return fetchAlarmModeList().last!
    }
}
