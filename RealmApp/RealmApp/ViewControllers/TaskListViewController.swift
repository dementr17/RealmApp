//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift
//импорт чтобы был доступна коллекция Results<TaskList>

class TaskListViewController: UITableViewController {

    var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        //инициализируем коллекцию по типу данных, массив с точкой доступа в БД
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        
        createTempData()
        // подгрузка данных из датаменеджера и обновление экрана по выполнению подгрузки
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //обновляем методы (галки, счетчики)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.name
        
        let count = processing(taskList)
        content.secondaryText = "\(count)"
        
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: taskList) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
    
//MARK: Sorting Tasks
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        sorting(sender)
    }
    
    @objc private func  addButtonPressed() {
        showAlert()
    }
    
    private func processing(_ taskList: TaskList) -> String {
        let countCurrentTask = taskList.tasks.filter("isComplete = false").count
        let countCompletedTask = taskList.tasks.filter("isComplete = true").count
        var resultCountTask: String!
        if countCurrentTask == 0 && countCompletedTask != 0 {
            resultCountTask = "✓"
        } else {
            resultCountTask = "\(countCurrentTask)"
        }
        return resultCountTask
    }
    
    //метод обращения к дата менеджеру, перезагружаем экран
    private func createTempData() {
        DataManager.shared.createTempDataV2 {
            self.tableView.reloadData()
        }
    }
}

extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList, newValue: newValue)
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        //метод из show alert
        let taskList = TaskList(value: [taskList])
        //экземпляр, передаем в него значение
        StorageManager.shared.save(taskList)
        //сохраняем в БД
        
        //визульно отображаем, по ячейке определяем (перебор массива, определение индекса)
        let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
        //обновляем ячейку по индексу
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
    private func sorting(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: StorageManager.shared.sorting(taskLists, true)
        default:
            StorageManager.shared.sorting(taskLists, false)
        }
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        tableView.reloadData()
    }
}
