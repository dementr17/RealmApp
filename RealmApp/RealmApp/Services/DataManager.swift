//
//  DataManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempDataV2(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "Buzz") {
            //если по ключу buzz нет объекта, то создаем список, присваиваем ему имя, сохраняем в юзер дефолт
            let shoppingList = TaskList()
            shoppingList.name = "Shopping List"
            // создвем задачу и наполняем ее
            let milk = Task()
            milk.name = "Milk"
            milk.note = "2L"
            //еще задачи (value имеет тип  Any, т.е. можно передавать любой тип)
            let bread = Task(value: ["Bread", "", Date(), true])
            let apples = Task(value: ["name": "Apples", "note": "2Kg"])
            
            shoppingList.tasks.append(milk)
            shoppingList.tasks.insert(contentsOf: [bread, apples], at: 0)
            //свойство tasks является массивом, передаем туда экземпляры (во втором случае по индексу)
            
            DispatchQueue.main.async {
                StorageManager.shared.save([shoppingList])
                //передаем массив списков в асихнонном потоке т.к. он может много весить
                UserDefaults.standard.set(true, forKey: "Buzz")
                //по ключу передаем
                completion()
                //при вызове обновляем данные
            }
        }
    }
}
