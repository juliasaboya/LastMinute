//
//  ContentView.swift
//  LastMinute
//
//  Created by Júlia Saboya on 05/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var classes: [DriverClass]
    @State var openSheet: Bool = false
    @State var number: Int = 1
    @State var classDate: Date = Date()
    @State var classTeacher: String = ""



    var body: some View {

        VStack {
            Button {
                openSheet.toggle()
            } label: {
                Text("Adicionar aula")
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)

                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.blue)
                    }
            }
            .padding(.horizontal)

            List {
                ForEach(classes) { aula in
                    Text("\(aula.orderNumber). \(aula.teacher ?? ""):\(aula.date, format: Date.FormatStyle(date: .numeric, time: .shortened))")

                }
                .onDelete(perform: deleteItems)
            }
            .sheet(isPresented: $openSheet){
                Form {
                    DatePicker("Data da aula", selection: $classDate)
                    TextField("Nome do professor", text: $classTeacher)

                }
                Button {
                    addItem(classDate: classDate, classTeacher: classTeacher)
                    openSheet.toggle()

                } label: {
                    Text("Salvar")
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)

                        .foregroundStyle(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.blue)
                        }
                }
                .padding(.horizontal)

            }

        }


    }

    private func addItem(classDate: Date, classTeacher: String) {
        withAnimation {
            let newClass = DriverClass(orderNumber: number, date: classDate, isDone: false, teacher: classTeacher)
            modelContext.insert(newClass)
            number += 1
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(classes[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DriverClass.self, inMemory: true)
}
