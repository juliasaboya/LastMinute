//
//  Item.swift
//  LastMinute
//
//  Created by Júlia Saboya on 05/08/25.
//

import Foundation
import SwiftData

@Model
final class DriverClass: Identifiable {
    var id = UUID()
    var orderNumber: Int
    var date: Date
    var isDone: Bool
    var teacher: String?

    init (orderNumber: Int, date: Date, isDone: Bool, teacher: String?) {
        self.orderNumber = orderNumber
        self.date = date
        self.isDone = isDone
        self.teacher = teacher
    }
}
