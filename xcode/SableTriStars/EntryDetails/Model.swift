//
//  Model.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/10.
//

import Foundation

struct Entry: Identifiable {
    let permission: String
    let links: String
    let owner: String
    let group: String
    let size: String
    let modified: String
    let name: String
    let fullPath: String
    let id = UUID()
}

typealias getFileListFunc = (String, String) async throws -> [String]

func getFileList(user: String, path: String, f: getFileListFunc) async throws
    -> [Entry]
{
    let list = try await f(user, path)
    let ret: [Entry] = list.compactMap { e in
        let tmp = parsels(e: e)
        guard tmp.count == 7 else { return nil }

        let entry = Entry(
            permission: tmp[0],
            links: tmp[1],
            owner: tmp[2],
            group: tmp[3],
            size: tmp[4],
            modified: tmp[5],
            name: tmp[6],
            fullPath: ""
        )

        return entry
    }
    return ret
}

// "drwxr-xr-x@  2 macuser  staff     64 Jul  1 23:48  a   space "
// 0:"drwxr-xr-x@"
// 1:"2"
// 2:"macuser"
// 3:"staff"
// 4:"64"
// 5:"Jul  1 23:48"
// 6:" a   space "
private func parsels(e: String) -> [String] {
    var offset = 0
    var ret: [String] = []
    var cnt = 0
    var dateElementCnt = 0

    for (i, c) in e.enumerated() {
        if c == " " {
            if cnt == 0 {
                continue
            }

            if ret.count == 5 {
                dateElementCnt += 1
                if dateElementCnt < 3 {
                    cnt = 0
                    continue
                }
            }

            let si = e.index(e.startIndex, offsetBy: offset)
            let ei = e.index(e.startIndex, offsetBy: i)
            let s = e[si..<ei].trimmingCharacters(in: .whitespaces)
            ret.append(s)

            offset = i + 1
            cnt = 0

            if ret.count == 6 {
                break
            }
        } else {
            cnt += 1
        }
    }

    let s = e.suffix(e.count - offset)
    ret.append(String(s))

    return ret
}
