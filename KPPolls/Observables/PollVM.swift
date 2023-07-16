//
//  PollVM.swift
//  KPPolls
//
//  Created by Karun Pant on 16/07/23.
//

import Foundation
import SwiftUI
import Observation
import ActivityKit
import FirebaseFirestore

@Observable
class PollViewModel {
    
    let db = Firestore.firestore()
    let pollId: String
    var poll: Poll? = nil
    var activity: Activity<LivePollsAttributes>?
    
    init(pollId: String,
         poll: Poll? = nil) {
        self.pollId = pollId
        self.poll = poll
    }
    
    @MainActor
    func listenToPoll() {
        db.document("polls/\(pollId)")
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print("Error: \(error?.localizedDescription ?? "")")
                    return
                }
                do {
                    let poll = try snapshot.data(as: Poll.self)
                    withAnimation {
                        self.poll = poll
                    }
                    self.startActivityIfNeeded()
                } catch {
                    print("Failed to fetch poll")
                }
            }
    }
    
    func vote(_ option: Option) {
        guard let index = poll?.options.firstIndex(where: { $0.id == option.id }) else {
            return
        }
        db.document("polls/\(pollId)")
            .updateData (
                [
                    "totalCount": FieldValue.increment(Int64(1)),
                    "option\(index).count": FieldValue.increment(Int64(1)),
                    "lastUpdatedOptionID": option.id,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
            ) { [weak self] error in
                print(error?.localizedDescription ?? "Error while voting for document polls/\(self?.pollId ?? "")")
            }
    }
    
    func startActivityIfNeeded() {
        guard let poll = poll,
              activity == nil,
              ActivityAuthorizationInfo().frequentPushesEnabled else {
            return
        }
        if let currentLivePollActivity = Activity<LivePollsAttributes>.activities.first(where: { $0.attributes.pollID == pollId }) {
            self.activity = currentLivePollActivity
        } else {
            do {
                let activityAttributes = LivePollsAttributes(pollID: pollId)
                let activityContent = ActivityContent(state: poll, staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date()))
                activity = try Activity.request(attributes: activityAttributes, content: activityContent, pushType: .token)
                print("requested live activity: \(String(describing: activity?.id))")
            } catch {
                print("Error requesting live activity: \(error.localizedDescription)")
            }
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        Task {
            guard let activity else { return }
            for try await token in activity.pushTokenUpdates {
                let tokenParts = token.map { data in String(format: "%02.2hhx", data) }
                let token = tokenParts.joined()
                print("LA Token updated: \(token)")
                do {
                    try await db.collection("polls/\(pollId)/push_tokens")
                        .document(deviceID)
                        .setData([ "token": token ])
                } catch {
                    print("Error pushing LAToken to firestore: \(error.localizedDescription)")
                }
            }
        }
    }
}
