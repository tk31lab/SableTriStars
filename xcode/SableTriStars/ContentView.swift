//
//  ContentView.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/06.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var selectedViewData: EntryDetailsViewData? = nil
    @State private var viewDataList: [EntryDetailsViewData] = []

    @State var showSettings: Bool = false

    var body: some View {
        NavigationSplitView {
            List(viewDataList, id: \.self, selection: $selectedViewData) {
                viewData in
                NavigationLink(value: viewData) {
                    HStack {
                        Text("\(viewData.item.title)")
                        Spacer()
                        Button {
                            if let index = viewDataList.firstIndex(where: { e in
                                e.item.id == viewData.item.id
                            }) {
                                deleteItem(index: index)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }

                    }
                }
                //                NavigationLink("\(viewData.item.title)", value: viewData)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let data = selectedViewData {
                EntryDetailsView(viewData: data) { action in
                    switch action {
                    case .saveItem:
                        do {
                            try modelContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            } else {
                Text("Select an item")
            }
        }
        .onAppear(perform: {
            updateViewDataList()
        })
        .onChange(of: items) {
            updateViewDataList()
        }
        .sheet(isPresented: $showSettings) {
            SettingsDialogView(item: Item()) { item in
                addItem(item: item)
                showSettings = false
            } cancel: {
                showSettings = false
            }
        }
    }

    private func updateViewDataList() {
        for item in items {
            if !viewDataList.contains(where: { $0.item.id == item.id }) {
                let d = EntryDetailsViewData(item: item, path: item.home)
                viewDataList.append(d)
            }
        }
        viewDataList.removeAll { vd in
            !items.contains(where: { $0.id == vd.item.id })
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item()
            modelContext.insert(newItem)
        }
    }

    private func addItem(item: Item) {
        withAnimation {
            modelContext.insert(item)
        }
    }

    private func deleteItem(index: Int) {
        let delItem = items[index]
        if selectedViewData?.item.id == delItem.id {
            selectedViewData = nil
        }
        withAnimation {
            modelContext.delete(delItem)
        }
    }

    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            for index in offsets {
    //                let delItem = items[index]
    //                if selectedViewData?.item.id == delItem.id {
    //                    selectedViewData = nil
    //                }
    //                modelContext.delete(items[index])
    //            }
    //        }
    //    }
}

//class CacheDataStore: ObservableObject {
//    @Published var caches: [Item: CacheDetailsViewData] = [:]
//
//    func updateValue(forKey key: Item, newValue: CacheDetailsViewData) {
//        caches[key] = newValue
//    }
//
//    func initCache(forKey key: Item) {
//        if caches[key] == nil {
//            caches[key] = CacheDetailsViewData()
//        }
//    }
//}

//class CacheDetailsViewData: ObservableObject {
//    var path: String = ""
//}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
