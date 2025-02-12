//
//  LievStreamViewController.swift
//  StreamingApp
//
//  Created by Ngọc on 9/2/25.
//

import Foundation
import UIKit
import SnapKit
import AVFoundation
import HaishinKit

class LiveStreamViewController: UIViewController {
    
    var mixer = MediaMixer()
    private var rtmpConnection = RTMPConnection()
    private lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
    lazy var hkView = MTHKView(frame: view.bounds)
    lazy var btnViewers: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "face.smiling")?.withTintColor(.white), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setTitleColor(.white, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .fill
        btn.semanticContentAttribute = .forceLeftToRight
        btn.setTitle("11K", for: .normal)
        return btn
    }()
    
    lazy var btnStart: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Live", for: .normal)
        btn.layer.cornerRadius = 50
        btn.layer.borderWidth = 4
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        return btn
    }()
    
    private var isPlay: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiveStream()
        
    }
    
    func setupLiveStream() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Quyền Camera đã được cấp")
            } else {
                print("Người dùng từ chối quyền Camera")
            }
        }
        
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("Quyền Microphone đã được cấp")
            } else {
                print("Người dùng từ chối quyền Microphone")
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
        }
        
        // Hiển thị video lên màn hình
        hkView.addSubview(btnStart)
        self.headerView()
        
        btnStart.snp.makeConstraints({ make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        })
        btnStart.backgroundColor = .red
        btnStart.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
        hkView.videoGravity = .resizeAspectFill
        Task {
            await rtmpStream.addOutput(hkView)
            view.addSubview(hkView)
        }
    }
    
    func headerView() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        hkView.addSubview(stack)
        stack.backgroundColor = UIColor.clear
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(50)
            
        }
        let avatar = UIButton()
        avatar.backgroundColor = .green
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.setTitle("A", for: .normal)
        stack.addArrangedSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            
        }
        avatar.layer.cornerRadius = 15
        
        btnViewers.backgroundColor = .clear
        stack.addArrangedSubview(self.btnViewers)
        btnViewers.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
        
    }
    
    @objc func captureTapped() {
        print("Button tapped!")
        self.isPlay = !self.isPlay
        if isPlay {
            btnStart.setTitle("Tắt", for: .normal)
            Task {
                print("Connecting to RTMP Server...")
                try await _ = rtmpConnection.connect("rtmp://a.rtmp.youtube.com/live2")
                print("Starting live stream...")
                try await _ = rtmpStream.publish("karh-8dsx-0ma9-h5hm-0uyf")
                print("✅ Live stream started successfully!")
            }
        }else {
            Task {
                btnStart.setTitle("Live", for: .normal)
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
}
