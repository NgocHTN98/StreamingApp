//
//  OnboardingVC.swift
//  Streaming
//
//  Created by NghiaDao on 23/1/25.
//

import UIKit
import SnapKit

class OnboardingVC: UIViewController {

    private lazy var button: UIButton = {
        let view = UIButton()
        view.setTitle("test API", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var service: DemoNetworkService!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let client = HTTPClientHandler()
        service = DefaultDemoNetworkService(client: client)

        view.backgroundColor = .red
        view.addSubview(button)

        button.snp.makeConstraints({ make in
            make.height.equalTo(50)
            make.width.equalTo(100)
            make.top.equalToSuperview().offset(150)
        })

        button.addTarget(self, action: #selector(action), for: .touchUpInside)
    }

    @objc func action() {
        Task {
            do {
                print("ABC")
                print(try await service.loadMockData())

            } catch {
                print(error)
            }

        }
    }

}
