//
//  Publisher+Extension.swift
//  StreamingApp
//
//  Created by Huynh Ngoc on 13/2/25.
//

import Foundation
import Combine

extension Publisher {
    func mapToVoid() -> Publishers.Map<Self, Void> {
        return self.map { _ in Void() }
    }

    func unwrap<Result>() -> Publishers.CompactMap<Self, Result>
    where Output == Result? {
        return self.compactMap { $0 }
    }
}

extension Publisher where Self.Failure == Never {
    
    /// - Note: [Does 'assign(to:)' produce memory leaks?](https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546/9)
    func weakAssign<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
        on object: Root
    ) -> AnyCancellable
    where Root: AnyObject {
        sink { [weak object] (value) in
            object?[keyPath: keyPath] = value
        }
    }
}
