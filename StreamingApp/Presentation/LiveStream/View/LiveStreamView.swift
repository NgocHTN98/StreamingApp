//
//  LiveStreamView.swift
//  StreamingApp
//
//  Created by Huynh Ngoc on 13/2/25.
//

import Foundation
import UIKit
import SnapKit
import HaishinKit

class LiveStreamView: UIView {
    lazy var hkView = MTHKView(frame: self.bounds)
    lazy var btnViewers: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.imagePadding = 10
        config.image = UIImage(systemName: "face.smiling")
        
        let btn = UIButton()
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setTitleColor(.white, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .fill
        btn.semanticContentAttribute = .forceLeftToRight
        btn.setTitle("11K", for: .normal)
        btn.configuration = config
        return btn
    }()
    
    lazy var btnStart: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Live", for: .normal)
        btn.layer.cornerRadius = 50
        btn.layer.borderWidth = 4
        btn.layer.borderColor = UIColor.gray.cgColor
        return btn
    }()
    lazy var avatarButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .green
        btn.clipsToBounds = true
        btn.contentMode = .scaleAspectFill
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("A", for: .normal)
        return btn
    }()
    lazy var headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.backgroundColor = UIColor.clear
        return stack
    }()
    lazy var liveButtonTapPublisher = btnStart.tapPublisher
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(hkView)
        hkView.addSubview(btnStart)
        self.headerView()
        
        btnStart.snp.makeConstraints({ make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        })
        hkView.videoGravity = .resizeAspectFill
    }
   
    func headerView() {
       
        hkView.addSubview(headerStack)
        headerStack.addArrangedSubview(avatarButton)
        headerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(50)
            
        }
        
        avatarButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        avatarButton.layer.cornerRadius = 15
        btnViewers.backgroundColor = .clear
        headerStack.addArrangedSubview(self.btnViewers)
        btnViewers.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
        
    }
    
    func attachStream(_ stream: RTMPStream) {
        Task {
             await stream.addOutput(self.hkView)
        }
    }
    
    func updateLiveButtonTitle(isStreaming: Bool) {
        if isStreaming {
            self.btnStart.setTitle("Tắt", for: .normal)
        } else {
            self.btnStart.setTitle("Live", for: .normal)
        }
    }
}
