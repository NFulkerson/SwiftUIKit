//
//  View+Toast.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2020-02-20.
//  Copyright © 2020 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension View {

    /**
     Shows a vertically and horizontally centered toast over
     the view, with a custom `text` and `background`.
     */
    func toast<Background: View>(
        isPresented: Binding<Bool>,
        text: String,
        background: Background,
        style: ToastStyle = .standard,
        duration: TimeInterval = 2) -> some View {
        toast(
            isPresented: isPresented,
            content: Text(text).multilineTextAlignment(.center),
            background: background,
            style: style,
            duration: duration
        )
    }
    
    /**
     Shows a vertically and horizontally centered toast over
     the view, with a custom `content` and `background`.
     */
    func toast<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        content: Content,
        background: Background,
        style: ToastStyle = .standard,
        duration: TimeInterval = 2) -> some View {
        Toast(
            isPresented: isPresented,
            content: content,
            background: background,
            style: style,
            duration: duration,
            presenter: { self }
        )
    }
}
