//
//  FieldJournalView.swift
//  TrailMark
//
//  Created by Kit Sitou on 6/30/26.
//

import SwiftUI
import TrailMarkCore

struct FieldJournalView: View {
    @Environment(AppModel.self) private var model

    @State private var showingAudioRecorder = false
    @State private var showingVideoPicker = false
    
    var body: some View {
        NavigationStack{
           
                Group{
                    if model.media.memos.isEmpty{
                        ContentUnavailableView(
                            "No memo yet",
                            systemImage: "waveform",
                            description: Text("Record a voice or video memo to start your field Journey")
                        )} else {

                                List{
                                    ForEach(model.media.memos){memo in
                                        NavigationLink(value: memo){
                                            MemoRow(memo: memo)
                                            
                                            
                                        }
                                    }
                                    //                                onDelete(model.mdeia.delete(at: 0))
                                    
                                    //TODO: Create Delete Method
                                }
                            
                        }
                    
                }
                .navigationTitle(Text("Field Journal"))
                .navigationDestination(for: MediaMemo.self){ memo in
                    MemoDetailView(memo: memo)
                    
                }
                .toolbar{
                    ToolbarItemGroup(placement: .primaryAction){
                        Button{showingVideoPicker = true}label:{Image(systemName: "video.badge.plus")
                        }
                        Button{showingAudioRecorder = true} label: {Image(systemName:"microphone.fill")}
                    }
                }
                .sheet(isPresented: $showingAudioRecorder){
                    //show record audio view
                    RecordAudioView()
                }
                .sheet(isPresented: $showingVideoPicker){
                    VideoCaptureView{url, duration in
                        saveVideo(url: url, duration: duration)
                    }
                    
                }
            }
            
        }
    
    private func saveVideo(url: URL, duration: TimeInterval){
        try? model.media.add(kind: .video, movingFileFrom: url, duration: duration)
    }
}

struct MemoRow: View {
    @Environment(AppModel.self) private var model
    let memo: MediaMemo
    
    @State private var thumbnail: UIImage?
    var body: some View {
        HStack(){
            ZStack{
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background.secondary)
                if let thumbnail{
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                }else {
                    Image(systemName: memo.kind.symbolName)
                }
            }
            .frame(width: 54, height:54)
            
            VStack(alignment: .leading, spacing: 4){
                Text(memo.title).font(.headline).lineLimit(1)
                HStack(spacing: 4){
                    Label(memo.durationText, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(Color.secondary)
            }
        }
        .task(id: memo.id){
            
        }
    }
    
    
}


#Preview {
    NavigationStack {
        FieldJournalView()
    }
    .environment(AppModel())
}
