//
//  PollView.swift
//  KPPolls
//
//  Created by Karun Pant on 16/07/23.
//

import SwiftUI

struct PollView: View {
    
    var vm: PollViewModel
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("Poll ID")
                    Text(vm.pollId)
                        .font(.caption)
                        .textSelection(.enabled)
                }
                if let poll = vm.poll {
                    HStack(alignment: .top) {
                        Text("Updated At")
                        Spacer()
                        if let updatedAt = poll.updatedAt{
                            Text(updatedAt, style: .time)
                        }
                    }
                    HStack(alignment: .top) {
                        Text("Total Count")
                        Spacer()
                        Text(String(poll.totalCount))
                    }
                }
            }
            
            if let poll = vm.poll {
                Section {
                    PollChartView(options: poll.options)
                        .frame(height: 200)
                }
                Section("Vote") {
                    ForEach(poll.options) { option in
                        Button() {
                            vm.vote(option)
                        } label: {
                            HStack {
                                Text("+1")
                                Text(option.name)
                                Spacer()
                                Text(String(option.count))
                            }
                        }
                        
                    }
                }
            }
        }
        .navigationTitle(vm.poll?.name ?? "Poll")
        .onAppear {
            vm.listenToPoll()
        }
    }
}

#Preview {
    // dummy poll id to be fetched from document in emulator or cloud
    NavigationStack {
        PollView(vm: .init(pollId: "hlGGhBo4gT8lePBwSlQS"))
    }
}
