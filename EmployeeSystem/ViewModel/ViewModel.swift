//
//  ViewModel.swift
//  EmployeeSystem
//
//  Created by Arthur Tristan M. Ramos on 11/6/22.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    var employees = BehaviorSubject(value: [Employee]())
    
    func fetchEmployees() {
        do {
            let fileName = "EmployeeData.json"
            let filePath = self.getDocumentsDirectoryUrl().appendingPathComponent(fileName)
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let employeeData = try decoder.decode([Employee].self, from: data)
            self.employees.on(.next(employeeData))
            print(self.employees)
        } catch {
            print("error:\(error)")
        }
    }
    
    func add(employee: Employee) {
        guard var employees = try? employees.value() else { return }
        employees.append(employee)
        self.employees.on(.next(employees))
        updateJsonFile()
    }
    
    func resign(indexPathRow: Int) {
        guard var employees = try? employees.value() else { return }
        employees[indexPathRow].isResigned = !employees[indexPathRow].isResigned
        self.employees.on(.next(employees))
        updateJsonFile()
    }
    
    func edit(employee: Employee, indexPathRow: Int) {
        guard var employees = try? employees.value() else { return }
        employees[indexPathRow] = employee
        self.employees.on(.next(employees))
        updateJsonFile()
    }
    
    
}


// MARK: File manipulation
extension ViewModel {
    func getDocumentsDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func updateJsonFile() {
        do {
            let fileName = "EmployeeData.json"
            let filePath = self.getDocumentsDirectoryUrl().appendingPathComponent(fileName)
            print(filePath)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let JsonData = try encoder.encode(self.employees.value())
            print(JsonData)
            try JsonData.write(to: filePath)
        } catch{
            print("Error in updating JSON file.")
        }
    }
}
