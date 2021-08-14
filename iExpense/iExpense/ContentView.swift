//
//  ContentView.swift
//  iExpense
//
//  Created by James Chun on 8/13/21.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let name: String
    let type: String
    let amount: Int
    let id = UUID()
}//End of struct

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        
        self.items = []
    }
    
}//End of class

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items/*we don't need id since ExpenseItem conforms to Identifiable, id: \.id*/) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        
                        Spacer()
                        Text("$\(item.amount)")
                    }
                }
                .onDelete(perform: { indexSet in
                    removeItems(at: indexSet)
                })
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
//                let expense = ExpenseItem(name: "Test", type: "Personal", amount: 5)
//                self.expenses.items.append(expense)
                self.showingAddExpense = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddExpense, content: {
                AddView(expenses: self.expenses)
            })
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    
}//End of struct

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
