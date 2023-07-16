//
//  LivePollsLiveActivity.swift
//  LivePolls
//
//  Created by Karun Pant on 16/07/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LivePollsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LivePollsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Text(context.state.name)
                    Spacer()
                    Image(systemName: "chart.bar.xaxis")
                    Text(String(context.state.totalCount))
                }
                .lineLimit(1)
                .padding(.bottom, 4)
                PollChartView(options: context.state.options)
            }
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.name)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(alignment: .top) {
                        Text(String(context.state.totalCount))
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    PollChartView(options: context.state.options)
                    // more content
                }
            } compactLeading: {
                Text(context.state.lastUpdatedOption?.name ?? "-")
            } compactTrailing: {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                    Text(String(context.state.lastUpdatedOption?.count ?? 0))
                }
            } minimal: {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                    Text(String(context.state.totalCount))
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LivePollsAttributes {
    fileprivate static var preview: LivePollsAttributes {
        LivePollsAttributes(pollID: "console")
    }
}

extension LivePollsAttributes.ContentState {
    
    fileprivate static var first: LivePollsAttributes.ContentState {
        LivePollsAttributes.ContentState(
            updatedAt: Date(),
            name: "Favorite Console",
            options: [
                Option(count: 20, name: "XBOX S|X"),
                Option(id: "ps5", count: 80, name: "PS5")
            ],
            lastUpdatedOptionID: "ps5",
            totalCount: 100)
       
    }
    fileprivate static var second: LivePollsAttributes.ContentState {
        LivePollsAttributes.ContentState(
            updatedAt: Date().addingTimeInterval(3600),
            name: "Favorite Console",
            options: [
                Option(count: 80, name: "XBOX S|X"),
                Option(id: "ps5", count: 90, name: "PS5")
            ],
            lastUpdatedOptionID: "ps5",
            totalCount: 170)
    }
}

#Preview("Notification", as: .content, using: LivePollsAttributes.preview) {
   LivePollsLiveActivity()
} contentStates: {
    LivePollsAttributes.ContentState.first
    LivePollsAttributes.ContentState.second
}
