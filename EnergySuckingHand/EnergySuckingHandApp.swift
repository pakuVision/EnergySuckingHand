//
//  EnergySuckingHandApp.swift
//  EnergySuckingHand
//
//  Created by boardguy.vision on 2025/02/09.
//

import SwiftUI
import RealityKitContent

@main
struct EnergySuckingHandApp: App {

    @State private var appModel = AppModel()

    init() {
        AttractionSystem.registerSystem()
        OrbComponent.registerComponent()
        EnergySuckerComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
