//
//  OffsetObservingScrollView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 3/30/23.
//

import SwiftUI

/// View that observes its position within a given coordinate space,
/// and assigns that position to the specified Binding.
struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(GeometryReader {
                geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) {
                position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    enum PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(
            value: inout CGPoint,
            nextValue: () -> CGPoint
        ) {
            // No-op
        }
    }
}

/// Specialized scroll view that observes its content offset (scroll position)
/// and assigns it to the specified Binding.
struct OffsetObservingScrollView<Content: View>: View {
    var axis: Axis.Set = .vertical
    var showsIndicators = true
    var enablePaging: Bool
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    private let coordinateSpaceName = UUID()
    
    public var body: some View {
        
        ScrollView(
            axis,
            showsIndicators: showsIndicators
        ) {
            
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                            x: -newOffset.x,
                            y: -newOffset.y
                        )
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    
    WithBinding(data: CGPoint(x: 0, y: 0)) {
        data in
        
        
        GeometryReader {
            geometry in
            
            OffsetObservingScrollView(
                axis: .horizontal,
                showsIndicators: false,
                enablePaging: true,
                offset: data
            ) {
                
                
                HStack(spacing: 0) {
                    VStack {
                        
                    }
                    .frame(width: geometry.size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.purple)
                    .padding(0)
                    
                    VStack {
                        
                    }
                    .frame(width: geometry.size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.yellow)
                    .padding(0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }

    }
}
