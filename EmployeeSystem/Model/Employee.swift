//
//  Employee.swift
//  EmployeeSystem
//
//  Created by Arthur Tristan M. Ramos on 11/6/22.
//

import Foundation

struct Employee: Codable {
    let name: String?
    let position: String?
    var isResigned: Bool
}
