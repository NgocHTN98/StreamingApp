//
//  UIControl+Combine.swift
//  StreamingApp
//
//  Created by Huynh Ngoc on 13/2/25.
//

import Foundation
import Combine
import UIKit

extension UIControl {
    func controlPublisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        return UIControl.EventPublisher(control: self, event: event)
      }

    // Publisher
    struct EventPublisher: Publisher {
        typealias Output = UIControl
        typealias Failure = Never

        let control: UIControl
        let event: UIControl.Event
        init(control: UIControl, event: UIControl.Event) {
                   self.control = control
                   self.event = event
               }
        func receive<S>(subscriber: S)
        where S: Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = EventSubscription(
                control: control,
                subscriber: subscriber,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }

    // Subscription
    fileprivate class EventSubscription<EventSubscriber: Subscriber>: Subscription
    where EventSubscriber.Input == UIControl, EventSubscriber.Failure == Never {

        let control: UIControl
        let event: UIControl.Event
        var subscriber: EventSubscriber?

        init(control: UIControl, subscriber: EventSubscriber, event: UIControl.Event) {
            self.control = control
            self.subscriber = subscriber
            self.event = event

            control.addTarget(self, action: #selector(eventDidOccur), for: event)
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            control.removeTarget(self, action: #selector(eventDidOccur), for: event)
        }

        @objc func eventDidOccur() {
            _ = subscriber?.receive(control)
        }
    }
}

extension UITextField {
    var textChangedPublisher: AnyPublisher<String, Never> {
        controlPublisher(for: .editingChanged)
            .compactMap { $0 as? UITextField }
            .compactMap { $0.text }
            .eraseToAnyPublisher()
    }

    var textEditingEndPublisher: AnyPublisher<String, Never> {
        controlPublisher(for: .editingDidEnd)
            .compactMap { $0 as? UITextField }
            .compactMap { $0.text }
            .eraseToAnyPublisher()
    }
}

extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchUpInside)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    var touchDownPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchDown)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

extension UISwitch {
    var statePublisher: AnyPublisher<Bool, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISwitch }
            .map { $0.isOn }
            .eraseToAnyPublisher()
    }
}

extension UIRefreshControl {
    var refreshPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIRefreshControl }
            .filter { $0.isRefreshing == true }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
