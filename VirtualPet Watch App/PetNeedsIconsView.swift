//
//  PetNeedsIconsView.swift
//  VirtualPet
//
//  Created by Luan Aiezza on 02/07/25.
//

import SwiftUI

struct PetNeedsIconsView: View {
    let showFeed: Bool
    let showJoy: Bool
    let showSleep: Bool
    

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if showFeed {
                Image("Feed_Icon")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            if showJoy {
                Image("Joy_Icon")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(.trailing, 1)
            }
            if showSleep {
                Image("Sleep_Icon")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
        }
        .padding(8)
    }
}
