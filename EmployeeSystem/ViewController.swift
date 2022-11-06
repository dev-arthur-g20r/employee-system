//
//  ViewController.swift
//  EmployeeSystem
//
//  Created by Arthur Tristan M. Ramos on 11/6/22.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private var viewModel = ViewModel()
    private var bag = DisposeBag()
    
    lazy var employeeList : UITableView = {
        let tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "EmployeeTableViewCell", bundle: nil), forCellReuseIdentifier: "EmployeeTableViewCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(employeeList)
        viewModel.fetchEmployees()
        bindEmployeeList()
        setupNavigation()
    }


}

// MARK: UINavigationController
extension ViewController {
    func setupNavigation() {
        updateNumberOfEmployees()
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addEmployee))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func updateNumberOfEmployees() {
        var numberOfEmployees = 0
        do {
            numberOfEmployees = try self.viewModel.employees.value().count
        } catch {
            print("Failed to get number of employees.")
        }
        let navigationTitle = numberOfEmployees != 1 ? "TechnoRock (\(numberOfEmployees) employees)" : "TechnoRock (\(numberOfEmployees) employee)"
        self.title = navigationTitle
    }
}

// MARK: Data bindings
extension ViewController {
    func bindEmployeeList() {
        employeeList.rx.setDelegate(self).disposed(by: bag)
        viewModel.employees.bind(to: employeeList.rx.items(cellIdentifier: "EmployeeTableViewCell", cellType: EmployeeTableViewCell.self)) { (row, item, cell) in
            cell.nameLabel.text = item.name ?? ""
            cell.positionLabel.text = item.position ?? ""
            cell.resignedLabel.isHidden = !item.isResigned
        }.disposed(by: bag)
        
        setupAlertForEditingEmployee()
    }
}

// MARK: CRUD Operations
extension ViewController {
    
    @objc func addEmployee() {
        let alert = UIAlertController(title: "Edit Employee", message: "Fill up name and position.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Position"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alert.dismiss(animated: true)
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            if alert.textFields?.count ?? 0 == 2 {
                guard let textFields = alert.textFields else { return }
                let name = textFields[0].text ?? ""
                let position = textFields[1].text ?? ""
                let employee = Employee(name: name, position: position, isResigned: false)
                
                let hasBlankInputs = name.isEmpty || position.isEmpty
                let inputHasSpecialChars = name.containsSpecialCharacters || position.containsSpecialCharacters
                
                if hasBlankInputs || inputHasSpecialChars {
                    self.displayErrorAlert(isBlank: hasBlankInputs, hasInvalidCharacters: inputHasSpecialChars)
                } else {
                    self.viewModel.add(employee: employee)
                }
                
                self.updateNumberOfEmployees()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true)
    }
    
    func setupAlertForEditingEmployee() {
        employeeList.rx.itemSelected.subscribe { indexPath in
            //guard var employees
            //guard let strongSelf = self else { return }
            var name = ""
            var position = ""
            var isResigned = false
            do {
                name = try self.viewModel.employees.value()[indexPath.row].name ?? ""
                position = try self.viewModel.employees.value()[indexPath.row].position ?? ""
                isResigned = try self.viewModel.employees.value()[indexPath.row].isResigned
            } catch {
                print("Failed to parse data to view.")
            }
            
            let alert = UIAlertController(title: "Edit Employee", message: "Fill up name and position.", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = name
                textField.placeholder = "Name"
            }
            alert.addTextField { textField in
                textField.text = position
                textField.placeholder = "Position"
            }
            let resignText = !isResigned ? "Resign" : "Rehire"
            
            let resignAction = UIAlertAction(title: resignText, style: .destructive) { action in
                self.viewModel.resign(indexPathRow: indexPath.row)
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { action in
                if alert.textFields?.count ?? 0 == 2 {
                    guard let textFields = alert.textFields else { return }
                    let name = textFields[0].text ?? ""
                    let position = textFields[1].text ?? ""
                    let employee = Employee(name: name, position: position, isResigned: isResigned)
                    
                    let hasBlankInputs = name.isEmpty || position.isEmpty
                    let inputHasSpecialChars = name.containsSpecialCharacters || position.containsSpecialCharacters
                    
                    if hasBlankInputs || inputHasSpecialChars {
                        self.displayErrorAlert(isBlank: hasBlankInputs, hasInvalidCharacters: inputHasSpecialChars)
                    } else {
                        self.viewModel.edit(employee: employee, indexPathRow: indexPath.row)
                    }
                    
                    self.updateNumberOfEmployees()
                }
            }
            
            alert.addAction(resignAction)
            alert.addAction(updateAction)
            self.present(alert, animated: true)
            
        }.disposed(by: bag)
    }
}

// MARK: Error Alert
extension ViewController {
    
    // Prioritize if some inputs are blank then if inputs have special characters.
    func displayErrorAlert(
        isBlank: Bool,
        hasInvalidCharacters: Bool
    ) {
        var errorMessage = ""
        
        if isBlank {
            errorMessage = "Please fill up all fields."
        } else if hasInvalidCharacters {
            errorMessage = "Fields cannot have numbers and special characters."
        }
        
        let alert = UIAlertController(title: "Field Input Error", message: errorMessage, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { action in
            alert.dismiss(animated: true)
        }
        alert.addAction(okayAction)
        self.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate {}

