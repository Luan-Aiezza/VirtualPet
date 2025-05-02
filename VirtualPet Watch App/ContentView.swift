import SwiftUI
import Combine
import WatchKit

struct ContentView: View {
    
    @ObservedObject private var vm = StatesViewModel()
    
    var body: some View {
        GeometryReader { geo in
            
            ZStack (alignment: .leading){
                
                // Barra lateral à esquerda
                vm.handleCrownValueProgressBar()
                    .frame(width: geo.size.width / 7)
                
                HStack(spacing: 0) {
                    // Conteúdo centralizado: pet + botão
                    VStack{
                        
                        Spacer()
                        
                        Image(vm.currentAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: geo.size.height * 0.6)
                            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                                vm.updatePetState()
                            }
                        
                        Spacer()
                        
                        vm.handleCrownValueButton()
                            .frame(width: geo.size.width/2, height: geo.size.height/7)
                        
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .focusable()
                .digitalCrownRotation($vm.crownValue, from: 0, through: 2, by: 1.0, sensitivity: .low)
                .onAppear { vm.startTimer() }
                .onDisappear { vm.stopTimer() }
            }
            .background(
                Image(vm.currentBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .padding(.bottom, 40)//trocar
            )
        }
    }
}

struct ProgressBar: View {
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                
                    .frame(
                        width: geometry.size.width,
                        height: max(0, min(CGFloat(self.value) * geometry.size.width, geometry.size.height))
                    )
                    .foregroundColor(color)
            }
        }.padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

