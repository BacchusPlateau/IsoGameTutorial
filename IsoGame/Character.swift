import UIKit
import SpriteKit

//1
protocol TileObject {
    var tile:Tile {get}
}

//2
class Character {
    
    var facing:Direction
    var action:Action
    
    var tileSprite2D:SKSpriteNode!
    var tileSpriteIso:SKSpriteNode!
    
    init() {
        facing = Direction.E
        action = Action.Idle
    }
    
}

//3
class Droid:Character, TileObject {
    
    let tile = Tile.Droid
    
    func update() {
        
        if (self.tileSpriteIso != nil) {
            
            self.tileSpriteIso.texture = TextureDroid.sharedInstance.texturesIso[self.action.rawValue]![self.facing.rawValue]
            
        }
        if (self.tileSprite2D != nil) {
            
            self.tileSprite2D.texture = TextureDroid.sharedInstance.textures2D[self.action.rawValue]![self.facing.rawValue]
        }
    }
}
