//
//  ImmersiveView.swift
//  EnergySuckingHand
//
//  Created by boardguy.vision on 2025/02/09.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @State private var orb = Entity()
    
    // Material Colorは UIColor
    let orbColors: [UIColor] = [.red, .green, .blue, .yellow, .cyan, .orange, .magenta]
    
    let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
    let session = SpatialTrackingSession()
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {

                if let orb = immersiveContentEntity.findEntity(named: "Orb") {
                    self.orb = orb
                }
                
                // 右の手の裏にAnchorを持つ
                // Sceneに手のAnchorを追加
                let rightHandEntity = AnchorEntity(.hand(.right, location: .palm))
                let energySuckerEntity = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .green, isMetallic: false)])
                
                energySuckerEntity.position = [0, 0.1, 0]
                
                energySuckerEntity.components.set(EnergySuckerComponent())
                
                rightHandEntity.addChild(energySuckerEntity)
                content.add(rightHandEntity)
                
                for i in 0..<7 {
                    let orbClone = orb.clone(recursive: true)
                    orbClone.name = "Orb_\(i)"
                    
                    orbClone.position = [
                        Float.random(in: -1 ... 1),
                        Float.random(in: 0.5 ... 1.5),
                        Float.random(in: -2 ... -1)
                    ]
                    
                    // モジュロ演算: 割り算の余りを求める計算
                    // 5 / 2 = 1
                    
                    // color.countが3だとした場合
                    // iがcolorの範囲を超えたとしても余りを返すことで繰り返すパターン
                    // i(0) / 3 = 0
                    // i(1) / 3 = 1
                    // i(2) / 3 = 2
                    
                    // i(3) / 3 = 0
                    // i(4) / 3 = 1
                    // i(5) / 3 = 2
                    let color = orbColors[i % orbColors.count]
                    
                    var material = orbClone.components[ModelComponent.self]?.materials.first as! ShaderGraphMaterial
                    do {
                        try material.setParameter(name: "EmissiveColor", value: .color(color))
                        orbClone.components[ModelComponent.self]?.materials = [material]
                    } catch {
                        print(error.localizedDescription)
                    }
                    content.add(orbClone)
                }
            }
        }
        .task {
            if let unavailableCapabilities = await session.run(configuration) {
                if unavailableCapabilities.anchor.contains(.hand) {
                    print("Access to hand data failed")
                } else {
                    print("All is well with hand tracking")
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
