//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    //входная точка в БД
    
    private init() {}
    
    // MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        try! realm.write {
            realm.add(taskLists)
        }
        //метод записи для DataManager(внесения изменений) всех списков, добавляем переданный массив
    }
    
    func sorting(_ taskLists: Results<TaskList>, _ indicator: Bool) {
        write {
            if indicator {
//                realm.delete(taskLists)
                let taskLists = taskLists.sorted { $0.date > $1.date }
                realm.add(taskLists)
            } else {
//                realm.delete(taskLists)
                let taskLists = taskLists.sorted { $0.name > $1.name }
                realm.add(taskLists)
            }
        }
    }
    
    func save(_ taskList: TaskList) {
        write {
            realm.add(taskList)
        }
        //метод записи списка задачи внизу
    }
    
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            //сначала удаляем задачи, а потом списки, т.к. это 2 класса и если удалить список, в бд останутся задачи, но доступа к ним не будет
            //связи между моделями нет
            realm.delete(taskList)
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
            //по ключу добавляем значение true выполненной задаче
        }
    }

    // MARK: - Tasks
    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
            //метод сохранения задачи
        }
    }
    
    func delete(_ task: Task) {
        write {
            //связи между моделями нет
            realm.delete(task)
        }
    }
    
    func edit(_ task: Task, newValue: String) {
        write {
            task.name = newValue
        }
    }
    func done(_ task: Task) {
        write {
            if task.isComplete {
                task.isComplete = false
            } else {
                task.isComplete = true
            }
//            taskList.tasks.setValue(true, forKey: "isComplete")
            //по ключу добавляем значение true выполненной задаче
        }
    }
    
    //MARK: Write Realm
    private func write(completion: () -> Void) {
        //метод для безопасной работы с БД
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
