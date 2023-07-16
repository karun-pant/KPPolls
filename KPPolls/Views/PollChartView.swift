//
//  PollChartView.swift
//  KPPolls
//
//  Created by Karun Pant on 16/07/23.
//

import SwiftUI
import Charts

struct PollChartView: View {
    let options: [Option]
    
    var body: some View {
        Chart {
            ForEach(options) { option in
                SectorMark(
                    angle: .value("Count", option.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5)
                .cornerRadius(5)
                .foregroundStyle(by: .value("Name", option.name))
            }
        }
    }
}

struct PollChartView_Previews: PreviewProvider {
    static var previews: some View {
        PollChartView(options: [
            .init (count: 2, name: "PS5"),
            .init(count: 1, name: "Xbox SX"),
            .init(count: 2, name: "Switch"),
            .init (count: 1, name: "PC")
        ])
    }
}
