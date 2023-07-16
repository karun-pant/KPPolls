//
//  HomeView.swift
//  KPPolls
//
//  Created by Karun Pant on 15/07/23.
//

import SwiftUI

struct HomeView: View {
    
    @Bindable var vm = HomeViewModel()
    
    var body: some View {
        List {
            existingPollSection
            livePollSection
            createPollSection
        }
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") {
                vm.error = nil
            }
        } message: {
            Text(vm.error ?? "An Error Occured.")
        }
        .sheet(item: $vm.modalPollID, content: { id in
            NavigationStack {
                PollView(vm: .init(pollId: id))
            }
        })
        .onAppear {
            vm.listenLivePolls()
        }
        .navigationTitle("Live Polls")
    }
    var livePollSection: some View {
        Section {
            DisclosureGroup("Latest Live Polls") {
                ForEach(vm.polls) { poll in
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text(poll.name)
                            Spacer()
                            Image(systemName: "chart.bar.xaxis")
                            Text(String(poll.totalCount))
                            if let updatedAt = poll.updatedAt {
                                Image(systemName: "clock.fill")
                                Text(updatedAt, style: .time)
                            }
                        }
                        PollChartView(options: poll.options)
                            .frame(height: 160)
                    }
                    .padding(.vertical)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.vm.modalPollID = poll.id
                    }
                }
            }
        }
    }
    var createPollSection: some View {
        Section() {
            DisclosureGroup("Create a Poll") {
                Text("Enter poll name and 2-4 options to submit.")
                    .foregroundStyle(.gray)
                    .font(.caption)
                TextField("Poll Name",
                          text: $vm.newPollName,
                          axis: .vertical)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                TextField("Option Name",
                          text: $vm.newOptionName,
                          axis: .vertical)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                Button("Add Option \(vm.newOptionName)") {
                    vm.addOption()
                }
                .disabled(vm.isAddOptionButtonDisabled)
                ForEach(vm.newPollOptions) {
                    Text($0)
                }
                .onDelete(perform: { indexSet in
                    vm.newPollOptions.remove(atOffsets: indexSet)
                })
                Button() {
                    Task { await vm.createPoll() }
                } label: {
                    HStack {
                        Spacer()
                        Text("Submit")
                            .foregroundStyle(.white)
                            .font(.system(size: 20, weight: .medium))
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(vm.isNewPollButtonDisabled ? Color.gray : Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(vm.isNewPollButtonDisabled)
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
    }
    var existingPollSection: some View {
        Section {
            DisclosureGroup("Join Existing Poll") {
                Text("Enter poll id shared to you.")
                    .foregroundStyle(.gray)
                    .font(.caption)
                TextField("Poll ID",
                          text: $vm.existingPollID,
                          axis: .vertical)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                Button() {
                    Task { await vm.joinExistingPoll() }
                } label: {
                    HStack {
                        Spacer()
                        Text("Join")
                            .foregroundStyle(.white)
                            .font(.system(size: 20, weight: .medium))
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(vm.isJoinPollButtonDisabled ? Color.gray : Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(vm.isJoinPollButtonDisabled)
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
