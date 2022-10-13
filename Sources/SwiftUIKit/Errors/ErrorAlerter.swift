//
//  ErrorAlerter.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2022-05-04.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This protocol can be implemented by anything that can alert
 errors, e.g. a view that performs a throwing async function.

 By implementing the protocol, types get access to functions
 like ``alert(error:)``, ``alertAsync(error:)`` and the most
 powerful ``tryWithErrorAlert(_:)``, which makes it possible
 to trigger async functions and alert any errors that occur.

 If you throw errors that conform to ``ErrorAlertConvertible``
 you get full control over what's alerted. Other error types
 will alert their localized description.
 */
public protocol ErrorAlerter {
    
    var alert: AlertContext { get }
}

@MainActor
public extension ErrorAlerter {

    /**
     Alert the provided error.
     */
    func alert(error: Error) {
        if let error = error as? ErrorAlertConvertible {
            return alert.present(error.errorAlert)
        }
        alert.present(Alert(
            title: Text(error.localizedDescription),
            dismissButton: .default(Text("OK"))))        // TODO: Make this configurable
    }
}

public extension ErrorAlerter {
    
    typealias AsyncOperation = () async throws -> Void
    typealias BlockResult<ErrorType: Error> = Result<Void, ErrorType>
    typealias BlockCompletion<ErrorType: Error> = (BlockResult<ErrorType>) -> Void
    typealias BlockOperation<ErrorType: Error> = (BlockCompletion<ErrorType>) -> Void

    /**
     Alert the provided error.
     */
    func alertAsync(error: Error) {
        DispatchQueue.main.async {
            alert(error: error)
        }
    }

    /**
     Try performing a block-based operation and alert if the
     operation fails in any way.

     This function is a good alternative if you need to know
     whether or not the operation fails.
     */
    func tryWithErrorAlert<ErrorType: Error>(
        _ operation: @escaping BlockOperation<ErrorType>,
        completion: @escaping BlockCompletion<ErrorType>
    ) {
        operation { result in
            switch result {
            case .failure(let error): alertAsync(error: error)
            case .success: break
            }
            completion(result)
        }
    }
    
    /**
     Try performing an async operation and alert if it fails.

     This function wraps the async operation in a task, then
     alerts any errors that are thrown. It's convenient when
     performing failing operations from SwiftUI views, where
     handling async functions are a bit messy.
     */
    func tryWithErrorAlert(_ operation: @escaping AsyncOperation) {
        Task {
            do {
                try await operation()
            } catch {
                await alert(error: error)
            }
        }
    }
}