//
//  ContentView.swift
//  TrailMark
//
//  Created by Kit Sitou on 6/23/26.
//
import TrailMarkCore

import SwiftUI

struct ContentView: View {
 
    @Environment(AppModel.self) private var model
    
    var body: some View {
        TabView{
            TodayDashboardView()
                .tabItem{
                    Label("Today", systemImage: "sum.max.fill")
                }
                .task{
                    await model.health.requestAuthorization()
                    await model.health.refreshToday()
                }
        }
    }
}

#Preview {
    ContentView()
}
