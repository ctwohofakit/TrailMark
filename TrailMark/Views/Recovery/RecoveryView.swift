//
//  RecoveryView.swift
//  TrailMark
//
//  Created by Kit Sitou on 7/7/26.
//
import SwiftUI
import Combine
import TrailMarkCore
import Charts

struct MockDataForRecovery {
    static var mockActivityTrend: [EnergyTrendPoint]{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let mockKcal:[Double] = [320, 540, 610, 100, 236, 456, 121]
        let mockTrend: [EnergyTrendPoint] = mockKcal.enumerated().compactMap{idx, kcal in
            guard let day = calendar.date(byAdding: .day, value: idx - 6, to: today)else { return nil }
            return EnergyTrendPoint(day: day, activeEnergyKcal: kcal)
        }
        return mockTrend
    }
}

struct RecoveryView: View{
    @Environment(AppModel.self) private var model
    @State private var saveState: SaveState = .idle
    
    enum SaveState:Equatable{case idle, saving, saved, failed(String)}
    

    
    var body: some View{
        NavigationStack{
            ScrollView{
                VStack{
                    //1. Sleep Card: card with the sleep data
                    //2. energy Chart; 7-day trend for energy
                    //3. saveWorkoutCard;
                    sleepCard
                    energyChartCard
                    saveWorkoutCard
                    
                }.padding()
                
            }
            .navigationTitle("Recovery")
            .task{
                await model.health.refreshLastNightSleep()
                await model.health.refreshEnergyTrend()
            }.refreshable {
                await model.health.refreshLastNightSleep()
                await model.health.refreshEnergyTrend()
            }
            
        }
        

        
    }
    
    private var sleepCard: some View{
        
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Image(systemName: "bed.double.fill")
                Text("Last night sleep")
            }
            .font(.title)
            .padding(.bottom, 10)
            VStack(alignment: .leading, spacing: 10){
                Label("Sleep cycle - Last 7 Days", systemImage: "clock.badge.fill")
                    .font(.headline)
                HStack{
                    if model.health.sleep.asleepSeconds<=0{
                        Image(systemName: "info.triangle")
                    }
                    Text(model.health.sleep.asleepSeconds>0 ? model.health.sleep.durationText : "Not Sleep Data Yet")
                    }
                .foregroundStyle(model.health.sleep.asleepSeconds>0 ? Color.white: .yellow)
                     .font(.headline)
                    .bold()
                    .frame(height: 40)
                
            }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            .background(Color.blue.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
            
        }
    }
    

    private var energyChartCard: some View{
        VStack(alignment: .leading, spacing: 12){
            Label("Active Energy - Last 7 Days", systemImage: "flame.fill")
                .font(.headline)
            if model.health.energyTrend.isEmpty{
                HStack{
                    Image(systemName: "info.triangle")
                    Text("No Energy Data Yet.")
                }
                .foregroundStyle(.yellow)
                .bold()
                .frame(height: 40)
            } else {
                Chart(model.health.energyTrend){ point in
                    BarMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("kCal", point.activeEnergyKcal)
                    )
                    .foregroundStyle(.yellow.gradient)
                }
                .chartXAxis{
                    AxisMarks(values: .stride(by: .day)){ _ in
                        AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    }
                }
                .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.blue.opacity(0.6), in: RoundedRectangle(cornerRadius:12))

        
        
    }
    
    
    private var saveWorkoutCard: some View{
        VStack(alignment: .leading, spacing: 12){
            Label("Log a sample Workout", systemImage: "figure.walking")
                .font(.headline)
          Text("Aves a 30-min walk to HK so we can confirm appears in the health app")
                .font(.footnote)
//                .background(.secondary)
            Button(action: saveSampleWorkout){
                HStack{
                    if saveState == .saving{ProgressView().padding(.trailing,4)}
                    Text(buttonTitle)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .disabled(saveState == .saving)
            if case .failed(let message) = saveState {
                Text(message).font(.footnote).foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        
    }
    private var buttonTitle:String{
        switch saveState {
        case .saved: return "Saved"
        default: return "Save Sample Workout"
            
        }
    }
    private func saveSampleWorkout(){
        saveState = .saving
        
        let end = Date()
        let record = WorkoutRecord(start: end.addingTimeInterval(-1800), end: end, activeEnergyKcal: 100, distanceMeters: 2400)
        Task{
            do{
                try await model.health.save(record)
                saveState = .saved
                await model.health.refreshEnergyTrend()
            }catch {
                saveState = .failed(error.localizedDescription)
            }
        }
    }
        
}


#Preview{
    
    RecoveryView()
        .environment(AppModel())
}
