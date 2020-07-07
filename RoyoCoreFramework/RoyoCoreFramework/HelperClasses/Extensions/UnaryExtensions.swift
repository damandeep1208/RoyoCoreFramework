//
//  UnaryExtensions.swift
//  RoyoCoreFramework
//
//  Created by Daman on 02/07/20.
//  Copyright © 2020 Daman. All rights reserved.
//

import UIKit

prefix operator /

public prefix func /(value: Int?) -> Int {
    return value ?? 0
}
public prefix func /(value : String?) -> String {
    return value ?? ""
}
public prefix func /(value : Bool?) -> Bool {
    return value ?? false
}
public prefix func /(value : Double?) -> Double {
    return value ?? 0.0
}
public prefix func /(value : Array<AnyObject>) -> Array<AnyObject> {
    return value
}
