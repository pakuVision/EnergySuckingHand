//
//  AttractionSystem.swift
//  EnergySuckingHand
//
//  Created by boardguy.vision on 2025/02/12.
//

import RealityKit
import RealityKitContent
import SwiftUI

public class AttractionSystem: System {
    
    let energySuckerQuery = EntityQuery(where: .has(EnergySuckerComponent.self))
    let orbQuery = EntityQuery(where: .has(OrbComponent.self))
    
    var hasFoundEnergySucker = false
    var energySuckerEntity = Entity()
    
    let distanceThreshold: Float = 0.6 // meters
    
    public required init(scene: RealityKit.Scene) {}
    
    
    public func update(context: SceneUpdateContext) {
        
        if !hasFoundEnergySucker {
            context.scene.performQuery(energySuckerQuery).forEach { energySucker in
                energySuckerEntity = energySucker
            }
        }
        
        let orbEntities = context.entities(matching: orbQuery, updatingSystemWhen: .rendering)
        
        for orb in orbEntities {
            
            let pos = energySuckerEntity.position(relativeTo: nil)
            let orbPos = orb.position(relativeTo: nil)
            let distance = distance(orbPos, pos)
            
            // 0.6m以内に縮まったらその球体をdestroy
            if distance < distanceThreshold {
                orb.components[OrbComponent.self] = .none
                destroy(orb: orb)
            }
        }
    }
    
    func destroy(orb: Entity) {
        
        var mat = orb.components[ModelComponent.self]?.materials.first as! ShaderGraphMaterial
        
        guard let param = mat.getParameter(name: "EmissiveColor") else {
            fatalError("cannot get the material parameter")
        }
        
        let frameRate: TimeInterval = 1.0 / 60.0  // 0.1666.. == 60FPS
        let duration: TimeInterval = 2.0
        let totalFrame = Int(duration / frameRate) // 1秒60FPS 2秒120FPS
        
        var currentFrame = 0
        
        Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            currentFrame += 1
            
            // 0.00 ... 1.00
            let progress = Float(currentFrame) / Float(totalFrame)
            
            do {
                try mat.setParameter(name: "Disintergration", value: .float(progress))
                orb.components[ModelComponent.self]?.materials = [mat]
            } catch {
                print("Error!!",error.localizedDescription)
            }
            
            if currentFrame >= totalFrame {
                timer.invalidate()
                
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    orb.removeFromParent()
                }
            }
        }
    }
}
