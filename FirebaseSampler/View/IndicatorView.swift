//
//  ProgressView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI

/// 画面全体を覆うインジケータ
struct IndicatorView: View {
    @State var animated = false
    
    var body: some View {
        VStack() {
            Circle()
                .stroke(AngularGradient(gradient: .init(colors: [Color.black, Color.primary.opacity(0)]), center: .center))
                .frame(width: 100, height: 100)
                .rotationEffect(.init(degrees: animated ? 360: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.35)
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                animated.toggle()
            }
        }
        .ignoresSafeArea()
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorView()
    }
}
