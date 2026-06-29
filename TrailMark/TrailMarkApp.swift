//
//  TrailMarkApp.swift
//  TrailMark
//
//  Created by Kit Sitou on 6/23/26.
//
import TrailMarkCore
import SwiftUI

@main
struct TrailMarkApp: App {
    @State private var model = AppModel()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
    }
}
