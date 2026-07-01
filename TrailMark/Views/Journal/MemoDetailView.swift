//
//  MemoDetailView.swift
//  TrailMark
//
//  Created by Kit Sitou on 6/30/26.
//

import SwiftUI
import TrailMarkCore
import AVKit

struct MemoDetailView: View {
    @Environment(AppModel.self) private var model
    let memo: MediaMemo
    
    @State private var audioPlayer = AudioPlayer()
    
    var body:some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 20){
                switch memo.kind{
                case .video:
                    VideoPlayer(player: AVPlayer(url: model.media.url(for: memo)))
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .audio:
                    audioControlls
                }
                metadata
            }.padding()
        }
    }
    
    private var audioControlls: some View{
        VStack(spacing: 16){
            Image(systemName: "waveform")
                .font(.system(size: 80))
                .foregroundStyle(.teal)
                .symbolEffect(.variableColor, isActive: audioPlayer.isPlaying)
            Button{
                audioPlayer.isPlaying ? audioPlayer.stop() :
                audioPlayer.play(url: model.media.url(for: memo))
            }label : {
                Label(audioPlayer.isPlaying ? "Stop" : "Play", systemImage: audioPlayer.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var metadata: some View{
        VStack(spacing: 8){
            LabeledContent("Recorded", value: memo.createdAt.formatted(date: .abbreviated, time: .shortened))
            LabeledContent("Duration", value: memo.durationText)
        }
        
    }
    
}
