//
//  Data.swift
//  SleepyBell
//
//  Created by James Nikolas on 2/3/25.
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

func fetchLatestAlarm() -> AlarmList {
    if fetchAlarmList().count == 0 {
        return AlarmList()
    } else {
        return fetchAlarmList().last!
    }
}
