//
//  SettingsDialogView.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/08.
//

import SwiftUI

struct SettingsDialogView: View {
    @State var item: Item

    private let save: (Item) -> Void
    private let cancel: () -> Void

    init(
        item: Item,
        save: @escaping @MainActor (Item) -> Void,
        cancel: @escaping @MainActor () -> Void
    ) {
        self.item = item
        self.save = save
        self.cancel = cancel
    }

    var body: some View {
        VStack {
            HStack {
                Text("Title")
                Spacer()
                TextField("untitled", text: $item.title)
            }
            HStack {
                Text("User")
                Spacer()
                TextField("root", text: $item.user)
            }
            HStack {
                Text("Home")
                Spacer()
                TextField("/home", text: $item.home)
            }
            HStack {
                Text("Temporary Bucket Path")
                Spacer()
                TextField("bucket/path", text: $item.tempBucketPath)
            }
            HStack {
                Text("Server Temporary Directory Path")
                Spacer()
                TextField("/tmp", text: $item.svrTempDirPath)
            }
            HStack {
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                }
                Button {
                    save(item)
                } label: {
                    Text("Save")
                }
            }

        }
        .padding(.all, 12)
    }
}
