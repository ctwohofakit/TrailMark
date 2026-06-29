//
//  TodayDashboardView.swift
//  TrailMark
//
//  Created by Kit Sitou on 6/25/26.
//
import TrailMarkCore
import SwiftUI

struct TodayDashboardView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        NavigationStack{
            Group{
                switch model.health.authorizationState{
                case .unavailable:
                    ContentUnavailableView("Health Data Unavaliable", systemImage: "heart.slash", description: Text("This device can't provide health data"))
                case .denied:
                    ContentUnavailableView {
                        Label("Health Access needed", systemImage: "lock.fill")
                    } description: {
                        Text("TrailMark requires access to health data")
                    } actions:{
                        Button("Try again"){
                            Task {
                                await model.health.requestAuthorization();
                                await model.health.refreshToday()
                            }
                        }
                    }
                default:
                    summary
                }
            }
//            .navigationTitle(Text("Today"))
            .task {
                await model.health.refreshToday()
            }
            .refreshable {
                await model.health.refreshToday()
            }
            
        }
    }//view
    
    private var summary: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .blue.opacity(0.6)],
                startPoint:.topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            VStack{
                Text("Today")
                    .font(.title)
                    .foregroundStyle(LinearGradient(
                        colors: [.white, .blue.opacity(0.6)],
                        startPoint:.topTrailing,
                        endPoint: .bottomLeading
                    ))
                
                ScrollView{
                    HStack(spacing: 5){
                        MetricCard(title: "Steps", value: "\(Int(model.health.todaySummary.steps))", symbol: "figure.walk.departure", tint: .orange)
                        MetricCard(title: "Distance", value: "\(Int(model.health.todaySummary.distanceMeters))", symbol: "figure.walk.motion", tint: .mint)
                        MetricCard(title: "Calories", value: "\(Int(model.health.todaySummary.activeEnergyKcal))", symbol: "bolt.ring.closed", tint: .pink)
                        
                        
                    }.padding()
                    
                }
            }
            
        }
    }
    
    
    struct MetricCard: View {
        let title: String
        let value: String
        let symbol: String
        let tint: Color
        
        var body: some View {
            VStack(spacing: 16){
                Image(systemName: symbol)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(tint.opacity(0.8))
                
                VStack(alignment: .center, spacing: 2){
                    Text(title)
                        .font(.headline).bold()
                        .foregroundColor(.white)
                    Text(value)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .contentTransition(.numericText())
                }
                //            Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        }
        
        
    }
}
