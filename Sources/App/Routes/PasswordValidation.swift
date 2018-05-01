//
//  PasswordValidation.swift
//  App
//
//  Created by Buvi R on 5/1/18.
//

import Foundation
import Validation

class PasswordValidation : Validator {
    func validate(_ input: String) throws {
        if input.count < 8 {
            throw error("Password is of incorrect length")
        }
    }
}
