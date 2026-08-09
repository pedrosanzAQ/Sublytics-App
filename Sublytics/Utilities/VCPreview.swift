//
//  VCPreview.swift
//  Sublytics
//
//  Created by pedrosanz on 04/03/26.
//

import SwiftUI

struct VCPreview<T: UIViewController>: UIViewControllerRepresentable {
    
    let viewController: T
    
    init(_ viewControllerBuilder: @escaping () -> T) {
        viewController = viewControllerBuilder()
    }
    
    func makeUIViewController(context: Context) -> T {
        viewController
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) { }
}

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    
    let builder: () -> View
    
    func makeUIView(context: Context) -> View {
        builder()
    }
    
    func updateUIView(_ uiView: View, context: Context) { }
}

