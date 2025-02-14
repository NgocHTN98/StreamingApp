//
//  LiveStreamViewModel.swift
//  StreamingApp
//
//  Created by Huynh Ngoc on 13/2/25.
//

import Foundation
import HaishinKit
import AVFoundation
import Combine

class LiveStreamViewModel {
    var mixer = MediaMixer()
    private var rtmpConnection = RTMPConnection()
    private lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
    private var cancelBag = Set<AnyCancellable>()
    private var isStreaming = CurrentValueSubject<Bool, Never>(false)
    struct Input {
        let attachToViewPublisher: AnyPublisher<LiveStreamView, Never>
        let liveButtonDidTapPublisher: AnyPublisher<Void, Never>
    }
    
    struct Output {
            let statusStreaming: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input) -> Output {
        
        input.attachToViewPublisher.sink { view in
            self.setupLiveStream(view: view)
        }.store(in: &cancelBag)
        
        input.liveButtonDidTapPublisher.sink {
            Task {
                self.observeLiveStatus()
                self.isStreaming.sink { value in
                    print("State Live", value)
                    if value {
                        self.stopStream()
                    } else {
                        self.startStream()
                    }
                }.store(in: &self.cancelBag)
            }
        }.store(in: &cancelBag)
        
        let output = Output(statusStreaming: self.isStreaming.eraseToAnyPublisher())
        return output
    }
    private func observeLiveStatus() {
        Task {
            self.isStreaming.send(await self.rtmpStream.readyState == .publishing)
        }
    }

    func setupLiveStream(view: LiveStreamView) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Quyền Camera đã được cấp")
            } else {
                print("Người dùng từ chối quyền Camera")
            }
        }
        
        Task {
            do {
                try await mixer.attachAudio(AVCaptureDevice.default(for: .audio))
            } catch {
                print(error)
            }
            
            do {
                try await mixer.attachVideo(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back))
            } catch {
                print(error)
            }
            
            await mixer.addOutput(rtmpStream)
            await view.attachStream(self.rtmpStream)
        }
    }
    
    func startStream() {
        Task {
            print("Connecting to RTMP Server...")
            try await _ = rtmpConnection.connect("rtmp://a.rtmp.youtube.com/live2")
            print("Starting live stream...")
            try await _ = rtmpStream.publish("karh-8dsx-0ma9-h5hm-0uyf")
            print("Live stream started successfully!")
        }
    }
    
    func stopStream() {
        Task {
            do {
                try await _ = rtmpStream.close()
                try await rtmpConnection.close()
            } catch RTMPConnection.Error.requestFailed(let response) {
                print(response)
            } catch RTMPStream.Error.requestFailed(let response) {
                print(response)
            } catch {
                print(error)
            }
        }
    }
 
}
