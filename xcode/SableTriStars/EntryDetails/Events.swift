//
//  Events.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/03.
//

import Foundation

extension EntryDetailsView {
    func handleGetFileList(user: String, path: String) {
        Task.detached {
            do {
                let r = try await getFileListEvent(user: user, path: path)
                await MainActor.run {
                    viewData.entries = r
                }
            } catch {
                print(error)
            }

        }
        /*
        Task {
//            print(Thread.current.isMainThread)
            do {
                let r = try await getFileListEvent(user: user, path: path)
                viewData.entries = r
            } catch {
                print(error)
            }
        }
         */
    }
}

func getFileListEvent(user: String, path: String) async throws -> [Entry] {
    //    print(Thread.current.isMainThread)
    return [
        Entry(
            permission: "drwxr-xr-x",
            links: "1",
            owner: "user",
            group: "root",
            size: "50",
            modified: "Jun 28 15:48",
            name: "xxx",
            fullPath: "/tmp/xxx"),
        Entry(
            permission: "-rwxr-xr-x",
            links: "1",
            owner: "user",
            group: "root",
            size: "90",
            modified: "Mar 28 19:50",
            name: "aaa.txt",
            fullPath: "/tmp/aaa.txt"),
    ]
}
