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
                    Label("Today", systemImage: "sun.max.fill")
                }
            
            FieldJournalView()
                .tabItem{
                    Label("Journal", systemImage: "waveform")

                }
            RecoveryView()
                .tabItem{
                    Label("Recovery", systemImage: "bed.double.fill")
                }

                .task{
                    await model.health.requestAuthorization()
                    await model.health.refreshToday()
                }
            
            RecordJourneyView()
                .tabItem{
                    Label("Journey", systemImage: "map.fill")

                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
