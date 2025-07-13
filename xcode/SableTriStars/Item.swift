//
//  Item.swift
//  SableTriStars
//
//  Created by macuser on 2025/07/06.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String

    var user: String
    var home: String
    var tempBucketPath: String
    var svrTempDirPath: String
    var localTempDirPath: String

    init() {
        self.title = "Untitled"
        self.user = ""
        self.home = "/home"
        self.tempBucketPath = ""
        self.svrTempDirPath = ""
        self.localTempDirPath = ""
    }

    func clone() -> Item {
        let new = Item()
        new.title = title
        new.user = user
        new.home = home
        new.tempBucketPath = tempBucketPath
        new.svrTempDirPath = svrTempDirPath
        new.localTempDirPath = localTempDirPath
        return new
    }
}
