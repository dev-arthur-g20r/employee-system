//
//  String+Extensions.swift
//  EmployeeSystem
//
//  Created by Arthur Tristan M. Ramos on 11/6/22.
//

import Foundation

extension String {
    var containsSpecialCharacters: Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        return self.rangeOfCharacter(from: characterset.inverted) != nil
    }
}
    
