//
//  LivePollsAttributes.swift
//  KPPolls
//
//  Created by Karun Pant on 16/07/23.
//

import ActivityKit

struct LivePollsAttributes: ActivityAttributes {
   
    typealias ContentState = Poll

    // Fixed non-changing properties about your activity go here!
    public var pollID: String
    
    init(pollID: String) {
        self.pollID = pollID
    }
}
