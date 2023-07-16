//
//  PollsModel.swift
//  KPPolls
//
//  Created by Karun Pant on 15/07/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Poll: Codable, Identifiable, Hashable {
    let id: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    var name: String
    var option0: Option
    var option1: Option
    var option2: Option?
    var option3: Option?
    var lastUpdatedOptionID: String?
    var totalCount: Int
    
    var options: [Option] {
        var options = [option0, option1]
        if let option2 { options.append(option2) }
        if let option3 { options.append(option3) }
        return options
    }
    var lastUpdatedOption: Option? {
        guard let lastUpdatedOptionID else { return nil }
        return options.first { $0.id == lastUpdatedOptionID }
    }
    
    init(id: String = UUID().uuidString,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         name: String,
         options: [Option],
         lastUpdatedOptionID: String? = nil,
         totalCount: Int) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        assert(options.count >= 2, "Need at least 2 options to start the poll")
        option0 = options[0]
        option1 = options[1]
        option2 = options[safe: 2]
        option3 = options[safe: 3]
        self.lastUpdatedOptionID = lastUpdatedOptionID
        self.totalCount = totalCount
    }
}

struct Option: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var count: Int
    var name: String
    init(id: String = UUID().uuidString,
         count: Int = 0,
         name: String) {
        self.id = id
        self.count = count
        self.name = name
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension String: Identifiable {
    public var id: Self { self }
}
