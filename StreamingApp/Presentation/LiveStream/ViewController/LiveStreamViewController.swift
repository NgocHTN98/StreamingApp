//
//  LievStreamViewController.swift
//  StreamingApp
//
//  Created by Ngọc on 9/2/25.
//

import Foundation
import UIKit
import Combine

class LiveStreamViewController: UIViewController {
    
    private var liveStreamView: LiveStreamView {
        guard let view = view as? LiveStreamView else {
            return LiveStreamView()
        }
        return view
    }
    private var viewModel: LiveStreamViewModel
    private var isPlay: Bool = false
    private var attachToViewPublisher = PassthroughSubject<LiveStreamView, Never>()
    private var cancelBag = Set<AnyCancellable>()
    
    init(viewModel: LiveStreamViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = LiveStreamView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }
    
    private func bind() {
        
        let input = LiveStreamViewModel.Input(
            attachToViewPublisher: self.attachToViewPublisher.eraseToAnyPublisher(),
            liveButtonDidTapPublisher: self.liveStreamView.liveButtonTapPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        output.statusStreaming.receive(on: DispatchQueue.main).sink { value in
            self.liveStreamView.updateLiveButtonTitle(isStreaming: value)
        }.store(in: &cancelBag)

        attachToViewPublisher.send(self.liveStreamView)
    }
}
