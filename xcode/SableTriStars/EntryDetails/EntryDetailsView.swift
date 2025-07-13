//
//  DetailsView.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/01.
//

import AppKit
import SwiftUI

struct EntryDetailsView: View {
    @ObservedObject var viewData: EntryDetailsViewData

    @State var showDialogType: ShowDialogViewType? = nil

    enum Action {
        case saveItem
    }

    private let event: (Action) -> Void

    init(
        viewData: EntryDetailsViewData,
        event: @escaping @MainActor (Action) -> Void
    ) {
        self.viewData = viewData
        self.event = event
    }

    var body: some View {
        VStack {
            Text("\(viewData.item.title)")
            HStack {
                Button {
                    // action
                    // go to home
                    viewData.path = viewData.item.home
                } label: {
                    Image(systemName: "house")
                }
                Button {
                    // action
                    // move to the parent directory
                } label: {
                    Image(systemName: "arrow.up")
                }
                TextField(text: $viewData.path) {
                    EmptyView()
                }
                Button {
                    // action
                    // reload current directory
                    handleGetFileList(
                        user: viewData.item.user, path: viewData.path)
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                }
                Button {
                    // action
                    // setting credentials
                    showDialogType = .settingCredentialsDialogView
                } label: {
                    Image(systemName: "key")
                }
                Button {
                    // action
                    // settings
                    showDialogType = .settingsDialogView
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .padding([.leading, .trailing], 8)
            .padding(.top, 8)

            HStack {
                Button {
                    // action
                    // download file or directory
                    if let id = viewData.selectedId {
                        print("selected: \(id)")
                    } else {
                        print("not selected")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                Spacer()
            }
            .padding([.leading, .trailing], 8)

            Table(viewData.entries, selection: $viewData.selectedId) {
                TableColumn("Permissions") { entry in Text(entry.permission) }
                TableColumn("Links") { entry in Text(entry.links) }
                TableColumn("Owner") { entry in Text(entry.owner) }
                TableColumn("Group") { entry in Text(entry.group) }
                TableColumn("Size") { entry in Text(entry.size) }
                TableColumn("Modified") { entry in Text(entry.modified) }
                TableColumn("Name") { entry in Text(entry.name) }
            }
            //            onTapGesture(count: 2) {
            //                if let id = viewData.selectedId {
            //                    print("simple double click: \(id)")
            //                }
            //            }
            .contextMenu(forSelectionType: EntryDetailsViewData.ID.self) { _ in
                // 右クリックメニュー
            } primaryAction: { ids in
                if let id = ids.first {
                    print("double clicked: \(id)")
                }
            }
        }
        .sheet(
            item: $showDialogType,
            content: { dialogType in
                switch dialogType {
                case .settingsDialogView:
                    SettingsDialogView(item: viewData.item.clone()) { item in
                        viewData.item.title = item.title
                        viewData.item.user = item.user
                        viewData.item.home = item.home
                        viewData.item.tempBucketPath = item.tempBucketPath
                        viewData.item.svrTempDirPath = item.svrTempDirPath
                        event(.saveItem)

                        showDialogType = nil
                    } cancel: {
                        showDialogType = nil
                    }

                case .settingCredentialsDialogView:
                    SettingCredentialsDialogView(
                        credentials: viewData.credentials
                    ) { credentials in
                        viewData.credentials = credentials
                        showDialogType = nil
                    } cancel: {
                        showDialogType = nil
                    }
                }
            })
        //        .sheet(isPresented: $showSettings) {
        //            SettingsDialogView(item: viewData.item.clone()) { item in
        //                viewData.item.title = item.title
        //                viewData.item.user = item.user
        //                viewData.item.home = item.home
        //                viewData.item.tempBucketPath = item.tempBucketPath
        //                viewData.item.svrTempDirPath = item.svrTempDirPath
        //                do {
        //                    try modelContext.save()
        //                } catch {
        //                    // ignore
        //                }
        //
        //                showSettings = false
        //            } cancel: {
        //                showSettings = false
        //            }
        //        }
    }
}

@MainActor
class EntryDetailsViewData: ObservableObject, Identifiable, Hashable {
    nonisolated static func == (
        lhs: EntryDetailsViewData, rhs: EntryDetailsViewData
    )
        -> Bool
    {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()

    @Published var item: Item
    @Published var path: String
    @Published var entries: [Entry] = []
    @Published var credentials: String = ""
    @Published var selectedId: ID? = nil

    init(item: Item, path: String) {
        self.item = item
        self.path = path
    }
}

enum ShowDialogViewType: Identifiable {
    case settingsDialogView
    case settingCredentialsDialogView

    var id: Int {
        switch self {
        case .settingsDialogView: 0
        case .settingCredentialsDialogView: 1
        }
    }
}

struct SettingCredentialsDialogView: View {
    @State var credentials: String

    let ok: (String) -> Void
    let cancel: () -> Void

    init(
        credentials: String,
        ok: @escaping @MainActor (String) -> Void,
        cancel: @escaping @MainActor () -> Void
    ) {
        self.credentials = credentials
        self.ok = ok
        self.cancel = cancel
    }

    var body: some View {
        VStack {
            let defaultFontSize = NSFont.preferredFont(forTextStyle: .body)
                .pointSize
            TextEditor(text: $credentials)
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 2)
                .frame(width: 480, height: defaultFontSize * 1.4 * 10)
                .border(.gray, width: 1)

            HStack {
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                }
                Button {
                    ok(credentials)
                } label: {
                    Text("OK")
                }
            }
        }
        .padding(.all, 8)
    }
}

#Preview {
    //    EntryDetailsView(
    //        entries: [
    //            Entry(permission: "drwxr-xr-x", name: "foo"),
    //            Entry(permission: "-rw-r--r--", name: "bar"),
    //            Entry(permission: "-rw-r--r--", name: "baz"),
    //        ],
    //        item: Item())
}
