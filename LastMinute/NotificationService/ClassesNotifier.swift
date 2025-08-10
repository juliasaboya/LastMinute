//
//  ClassesNotifier.swift
//  LastMinute
//
//  Created by Júlia Saboya on 10/08/25.
//

import Foundation
import UserNotifications

class ClassesNotifier: NotificationService {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permissão concedida")
            } else if let error = error {
                print("Erro ao pedir permissão: \(error.localizedDescription)")
            }
        }
    }

    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Teste"
        content.body = "Notificação disparada 1 minuto após agendamento"
        content.sound = .default

        let triggerDate = Date().addingTimeInterval(60) // daqui 1 minuto
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: "teste_1min", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação teste: \(error.localizedDescription)")
            } else {
                print("Notificação teste agendada com sucesso.")
            }
        }
    }

    func scheduleNotifications(for aula: DriverClass) {
        let center = UNUserNotificationCenter.current()

        // Remove notificações anteriores para essa aula (evita duplicar)
        center.removePendingNotificationRequests(withIdentifiers: [
            "aula_\(aula.orderNumber)_48h",
            "aula_\(aula.orderNumber)_24h",
            "aula_\(aula.orderNumber)_12h"
        ])

        let intervals: [(String, TimeInterval)] = [
            ("48h", 48 * 60 * 60),
            ("24h", 24 * 60 * 60),
            ("12h", 12 * 60 * 60)
        ]

        for (suffix, interval) in intervals {
            let content = UNMutableNotificationContent()
            content.title = "Aula \(aula.orderNumber)"

            // Formata a data para dia da semana ou "hoje", "amanhã"
            let formattedDate = formatRelativeDate(aula.date)
            let formattedTime = DateFormatter.localizedString(from: aula.date, dateStyle: .none, timeStyle: .short)
            content.body = "Aula \(aula.orderNumber): \(formattedDate) às \(formattedTime)"
            content.sound = .default

            // Data da notificação = data da aula menos intervalo
            let triggerDate = aula.date.addingTimeInterval(-interval)

            if triggerDate > Date() {
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "aula_\(aula.orderNumber)_\(suffix)",
                    content: content,
                    trigger: trigger
                )

                center.add(request) { error in
                    if let error = error {
                        print("Erro ao agendar notificação: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "hoje"
        } else if calendar.isDateInTomorrow(date) {
            return "amanhã"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // dia da semana completo
            return formatter.string(from: date).capitalized
        }
    }
}
