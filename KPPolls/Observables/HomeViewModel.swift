//
//  HomeViewModel.swift
//  KPPolls
//
//  Created by Karun Pant on 15/07/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Observation

@Observable
class HomeViewModel {
    let db = Firestore.firestore()
    var polls = [Poll]()
    
    // New Poll Creation
    var error: String? = nil
    var newPollName: String = ""
    var newOptionName: String = ""
    var newPollOptions: [String] = []
    
    var isLoading = false
    var isNewPollButtonDisabled: Bool {
        isLoading
        || newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || newPollOptions.count < 2
    }
    var isAddOptionButtonDisabled: Bool {
        isLoading
        || newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || newOptionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || newPollOptions.count == 4
    }
    
    var modalPollID: String? = nil
    var existingPollID: String = ""
    var isJoinPollButtonDisabled: Bool {
        isLoading
        || existingPollID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    
    @MainActor
    func listenUserUpdates() {
        
    }
    
    @MainActor
    func listenLivePolls() {
        db.collection("polls")
            .order(by: "updatedAt", descending: true)
            .limit(toLast: 10)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print("Error fetching snapshot: \(error?.localizedDescription ?? "")")
                    return
                }
                let docs = snapshot.documents
                let polls = docs.compactMap {
                    try? $0.data(as: Poll.self)
                }
                withAnimation {
                    self.polls = polls
                }
            }
    }
    
    @MainActor
    func createPoll() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        let poll = Poll(
            name: newPollName.trimmingCharacters(in: .whitespacesAndNewlines),
            options: newPollOptions.map {
                Option(name: $0)
            },
            totalCount: 0)
        do {
            try db.document("polls/\(poll.id)")
                .setData(from: poll)
            self.newPollName = ""
            self.newOptionName = ""
            self.newPollOptions = []
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func addOption() {
        self.newPollOptions.append(newOptionName.trimmingCharacters(in: .whitespacesAndNewlines))
        newOptionName = ""
    }
    
    @MainActor
    func joinExistingPoll() async {
        isLoading = true
        defer {
            isLoading = false
        }
        guard let existingPoll = try? await db.document("polls/\(existingPollID)").getDocument(),
              existingPoll.exists else {
            error = "Poll with id \(existingPollID) does not exist."
            return
        }
        modalPollID = existingPollID
        error = nil
    }
}
