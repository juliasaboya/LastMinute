//
//  ContentView.swift
//  LastMinute
//
//  Created by Júlia Saboya on 05/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var notificationCenter = ClassesNotifier()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\DriverClass.orderNumber)])
    private var classes: [DriverClass]
    @State var openSheet: Bool = false
    @State var number: Int = 1
    @State var classDate: Date = Date()
    @State var classTeacher: String = ""

    init() {
        notificationCenter.requestNotificationPermission()
    }

    var body: some View {
        NavigationView {
            VStack {
                ProgressView(
                    value: Double(classes.filter { $0.isDone }.count),
                    total: Double(classes.count)
                )
                .progressViewStyle(.linear)
                .tint(.darkGreen)
                .frame(width: 300, height: 40)

                List {
                    ForEach(classes) { aula in
                        HStack {
                            Text(aula.orderNumber.description)
                                .font(.title)
                                .bold()
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding()

                            VStack(alignment: .leading) {
                                Text("\(aula.date, format: .dateTime.day().month().year())")
                                    .font(.headline)

                                Text(aula.date, format: .dateTime.hour().minute())
                                    .font(.headline)

                                Text("\(aula.teacher ?? "")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }


                            Button {
                                withAnimation(.bouncy) {
                                    handleClassStatus(ofClass: aula)
                                }

                            } label: {
                                let state = aula.isDone
                                Image(systemName: state ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: state ? 24 : 32, height: state ? 24 : 32)
                                    .foregroundStyle(.darkGreen)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing )

                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .sheet(isPresented: $openSheet){
                    Form {
                        DatePicker("Data e hora", selection: $classDate)
                        TextField("Nome do professor", text: $classTeacher)

                    }
                    Button {
                        addItem(classDate: classDate, classTeacher: classTeacher)
                        openSheet.toggle()
                        number += 1

                    } label: {
                        Text("Salvar")
                            .bold()
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.darkGreen)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.lightGreen)
                            }
                    }
                    .padding(.horizontal)
                    .presentationDetents([.medium])

                }
                .navigationTitle("Aulas Autoescola")
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            openSheet.toggle()
                        }) {
                            HStack {
                                Text("Incluir aula")
                                Image(systemName: "plus")
                            }
                            .foregroundStyle(.darkGreen)

                        }
                    }
                }
            }
        }

    }

    private func handleClassStatus(ofClass aula: DriverClass){
        aula.isDone.toggle()
        try? modelContext.save()

        if aula.isDone {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
                "aula_\(aula.orderNumber)_48h",
                "aula_\(aula.orderNumber)_24h",
                "aula_\(aula.orderNumber)_12h"
            ])
        } else {
            notificationCenter.scheduleNotifications(for: aula)
        }
    }

    private func addItem(classDate: Date, classTeacher: String) {
        withAnimation {
            let nextNumber = (classes.map { $0.orderNumber }.max() ?? 0) + 1
            let newClass = DriverClass(
                orderNumber: nextNumber,
                date: classDate,
                isDone: false,
                teacher: classTeacher
            )
            modelContext.insert(newClass)
            try? modelContext.save()
            notificationCenter.scheduleNotifications(for: newClass)
        }

    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(classes[index])
            }
            try? modelContext.save()

            reorderClasses()
        }
    }

    private func reorderClasses() {
        let sorted = classes.sorted { $0.orderNumber < $1.orderNumber }

        for (index, aula) in sorted.enumerated() {
            aula.orderNumber = index + 1
        }

        try? modelContext.save()
    }
}

#Preview {
    var driverClass = DriverClass(orderNumber: 1, date: Date.now, isDone: false, teacher: "julia")
    ContentView()
        .modelContainer(for: DriverClass.self, inMemory: true)
}
