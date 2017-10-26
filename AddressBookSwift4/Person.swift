//
//  Person.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import Foundation

extension Person {
    var firstLetter: String {
        if let first = familyName?.characters.first {
            return String(first)
        } else {
            return "?"
        }
    }
}
