//
//  WithBinding.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 4/17/24.
//

import SwiftUI

public struct WithBinding<T, Content: View>: View {
    @State private(set) var data: T
    private(set) var content: (Binding<T>) -> Content


    public var body: some View {
      content($data)
    }
}
