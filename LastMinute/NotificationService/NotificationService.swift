//
//  NotificationService.swift
//  LastMinute
//
//  Created by Júlia Saboya on 10/08/25.
//

import Foundation

protocol NotificationService {
    func requestNotificationPermission()
    func scheduleNotifications(for aula: DriverClass)
}

