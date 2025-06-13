import SwiftUI
import Combine
import WatchKit
import SpriteKit

struct ProgressBar: View {
    var value: Double  // Esperado entre 0.0 e 1.0
    var color: Color
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    ZStack(alignment: .bottom) {
                        // Camada de fundo
                        RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity(0.3)
                            .foregroundColor(color)
                        
                        // Camada da barra de progresso
                        RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * CGFloat(clamp(value/100))
                            )
                            .foregroundColor(color)
                    }
                    // Camada da borda
                    Image("BorderBar")
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // Nova camada com BorderBarIcon no canto inferior direito
                    Image("BorderBarIcon")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .position(x: geometry.size.width - (geometry.size.width * 0.5), y: geometry.size.height - (geometry.size.height * 0.05))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func clamp(_ value: Double) -> Double {
        return min(max(value, 0.0), 1.0)
    }
}
