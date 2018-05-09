import SpriteKit

//overloads for the CGPoint object
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar.x, y: point.y * scalar.y)
}

func / (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x / scalar.x, y: point.y / scalar.y)
}

func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    return CGFloat(hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y)))
}

func round(point:CGPoint) -> CGPoint {
    return CGPoint(x: round(point.x), y: round(point.y))
}

func floor(point:CGPoint) -> CGPoint {
    return CGPoint(x: floor(point.x), y: floor(point.y))
}

func ceil(point:CGPoint) -> CGPoint {
    return CGPoint(x: ceil(point.x), y: ceil(point.y))
}

enum Direction: Int {
    
    case N,NE,E,SE,S,SW,W,NW
    
    var description:String {
        switch self {
        case .N:return "North"
        case .NE:return "North East"
        case .E:return "East"
        case .SE:return "South East"
        case .S:return "South"
        case .SW:return "South West"
        case .W:return "West"
        case .NW:return "North West"
        }
    }
}

enum Tile: Int {
    
    case Ground, Wall, Droid
    
    var description:String {
        switch self {
        case .Ground:return "Ground"
        case .Wall:return "Wall"
        case .Droid:return "Droid"
        }
    }
}

enum Action: Int {
    case Idle, Move
    
    var description:String {
        switch self {
        case .Idle:return "Idle"
        case .Move:return "Move"
        }
    }
}


class GameScene: SKScene {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let view2D:SKSpriteNode
    let viewIso:SKSpriteNode
    let layer2DHighlight:SKNode
    
    let layerIsoGround:SKNode
    let layerIsoObjects:SKNode
    
    var tiles:[[(Int, Int)]]
    
    let tileSize = (width:32, height:32)
    let hero = Droid()
    
    let nthFrame = 6
    var nthFrameCount = 0

    override init(size: CGSize) {
        
        view2D = SKSpriteNode()
        layer2DHighlight = SKNode()
        layerIsoGround = SKNode()
        layerIsoObjects = SKNode()
        
        tiles =     [[(1,7), (1,0), (1,0), (1,0), (1,0), (1,0), (1,0), (1,0), (1,1)]]
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2)])
        tiles.append([(1,6), (0,0), (2,2), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (1,5), (1,4), (1,4), (1,5)])
        tiles.append([(1,6), (0,0), (0,0), (1,7), (0,0), (0,0), (0,0), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (1,6), (0,0), (0,0), (0,0), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (1,5), (1,4), (1,4), (1,1), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (1,3), (0,0), (0,0)])
        tiles.append([(1,5), (1,4), (1,4), (1,3), (0,0), (0,0), (0,0), (0,0), (0,0)])
        
        viewIso = SKSpriteNode()
        
        super.init(size: size)
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
    }
    
    override func didMove(to view: SKView) {
        
        let deviceScale = self.size.width/667
        
        view2D.position = CGPoint(x:-self.size.width*0.48, y:self.size.height*0.43)
        let view2DScale = CGFloat(0.4)
        view2D.xScale = deviceScale * view2DScale
        view2D.yScale = deviceScale * view2DScale
        
        addChild(view2D)
        
        layer2DHighlight.zPosition = 999
        view2D.addChild(layer2DHighlight)
        
        viewIso.position = CGPoint(x:self.size.width*0, y:self.size.height*0.25)
        viewIso.xScale = deviceScale
        viewIso.yScale = deviceScale
        
        viewIso.addChild(layerIsoGround)
        viewIso.addChild(layerIsoObjects)
        
        addChild(viewIso)
        
        placeAllTiles2D()
        placeAllTilesIso()
        
    }
    
    func placeTile2D(tile:Tile, direction:Direction, position:CGPoint) {
        
        let tileSprite = SKSpriteNode(imageNamed: textureImage(tile: tile, direction: direction, action: Action.Idle))
        
        if (tile == hero.tile) {
            hero.tileSprite2D = tileSprite
            hero.tileSprite2D.zPosition = 1
        }
        
        tileSprite.position = position
        
        tileSprite.anchorPoint = CGPoint(x:0, y:0)
        
        view2D.addChild(tileSprite)
        
    }
    

    
    func placeAllTiles2D() {
        
        for i in 0..<tiles.count {
            
            let row = tiles[i];
            
            for j in 0..<row.count {
                
                let tile = Tile(rawValue: row[j].0)!
                let direction = Direction(rawValue: row[j].1)!
                
                let point = CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height))
                
                if (tile == Tile.Droid) {
                    placeTile2D(tile: Tile.Ground, direction:direction, position:point)
                }
                
                placeTile2D(tile: tile, direction:direction, position:point)
            }
            
        }
    }
    
    func placeTileIso(tile:Tile, direction:Direction, position:CGPoint) {
        
        let tileSprite = SKSpriteNode(imageNamed: "iso_3d_"+textureImage(tile: tile, direction: direction, action: Action.Idle))
        
        if (tile == hero.tile) {
            hero.tileSpriteIso = tileSprite
        }
        
        tileSprite.position = position
        
        tileSprite.anchorPoint = CGPoint(x:0, y:0)
        
        //ensure ground tiles are below
        if (tile == Tile.Ground) {
            layerIsoGround.addChild(tileSprite)
        } else if (tile == Tile.Wall || tile == Tile.Droid) {
            layerIsoObjects.addChild(tileSprite)
        }
        
    }
    
    func placeAllTilesIso() {
        
        for i in 0..<tiles.count {
            
            let row = tiles[i];
            
            for j in 0..<row.count {
                
                let tile = Tile(rawValue: row[j].0)!
                let direction = Direction(rawValue: row[j].1)!
                
                let point = point2DToIso(p: CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height)))
                
                if (tile == Tile.Droid) {
                    placeTileIso(tile: Tile.Ground, direction:direction, position:point)
                }
                
                placeTileIso(tile: tile, direction:direction, position:point)
                
            }
        }
    }
    
    func point2DToIso(p:CGPoint) -> CGPoint {
        
        //invert y pre conversion
        var point = p * CGPoint(x:1, y:-1)
        
        //convert using algorithm
        point = CGPoint(x:(point.x - point.y), y: ((point.x + point.y) / 2))
        
        //invert y post conversion
        point = point * CGPoint(x:1, y:-1)
        
        return point
        
    }
    
    func pointIsoTo2D(p:CGPoint) -> CGPoint {
        
        //invert y pre conversion
        var point = p * CGPoint(x:1, y:-1)
        
        //convert using algorithm
        point = CGPoint(x:((2 * point.y + point.x) / 2), y: ((2 * point.y - point.x) / 2))
        
        //invert y post conversion
        point = point * CGPoint(x:1, y:-1)
        
        return point
        
    }
    
    func point2DToPointTileIndex(point:CGPoint) -> CGPoint {
        
        return floor(point: point / CGPoint(x: tileSize.width, y: tileSize.height))
        
    }
    
    func pointTileIndexToPoint2D(point:CGPoint) -> CGPoint {
        
        return point * CGPoint(x: tileSize.width, y: tileSize.height)
        
    }
    
    override func update(_ currentTime: TimeInterval)  {
        
        hero.tileSpriteIso.position = point2DToIso(p: hero.tileSprite2D.position)
        nthFrameCount += 1
        if (nthFrameCount == nthFrame) {
            nthFrameCount = 0
            updateOnNthFrame()
        }
        
    }
    
    func updateOnNthFrame() {
        sortDepth()
    }
    
    func degreesToDirection(fromDegrees:CGFloat) -> Direction {
        
        var degrees = fromDegrees
        
        if (degrees < 0) {
            degrees = degrees + 360
        }
        let directionRange = 45.0
        
        degrees = degrees + CGFloat(directionRange/2)
        
        var direction = Int(floor(Double(degrees)/directionRange))
        
        if (direction == 8) {
            direction = 0
        }
        
        return Direction(rawValue: direction)!
    }
    
    func sortDepth() {
        
        //1
        let childrenSortedForDepth = layerIsoObjects.children.sorted() {
            
            let p0 = self.pointIsoTo2D(p: $0.position)
            let p1 = self.pointIsoTo2D(p: $1.position)
            
            if ((p0.x+(-p0.y)) > (p1.x+(-p1.y))) {
                return false
            } else {
                return true
            }
            
        }
        //2
        for i in 0..<childrenSortedForDepth.count {
            
            let node = (childrenSortedForDepth[i] as SKNode)
            
            node.zPosition = CGFloat(i)
            
        }
    }

    func traversableTiles() -> [[Int]] {
        
        //1
        var tTiles = [[Int]]()
        
        //2
        func binarize(num:Int) ->Int {
            if (num == 1) {
                return Global.tilePath.nonTraversable
            } else {
                return Global.tilePath.traversable
            }
        }
        
        //3
        for i in 0..<tiles.count {
            let tt = tiles[i].map{i in binarize(num: i.0)}
            tTiles.append(tt)
        }
        
        return tTiles
    }
    
    func findPathFrom(from:CGPoint, to:CGPoint) -> [CGPoint]? {
        
        let traversable = traversableTiles()
        
        //1
        if (Int(to.x) > 0)
            && (Int(to.x) < traversable.count)
            && (Int(-to.y) > 0)
            && (Int(-to.y) < traversable.count)
        {
            
            //2
            if (traversable[Int(-to.y)][Int(to.x)] == Global.tilePath.traversable ) {
                
                //3
                let pathFinder = PathFinder(xIni: Int(from.x), yIni: Int(from.y), xFin: Int(to.x), yFin: Int(to.y), lvlData: traversable)
                let myPath = pathFinder.findPath()
                return myPath
                
            } else {
                
                return nil
            }
            
        } else {
            
            return nil
        }
        
    }
    
    func highlightPath2D(path:[CGPoint]) {
        
        //clear previous path
        layer2DHighlight.removeAllChildren()
        
        for i in 0..<path.count {
            let highlightTile = SKSpriteNode(imageNamed: textureImage(tile: Tile.Ground, direction: Direction.N, action: Action.Idle))
            highlightTile.position = pointTileIndexToPoint2D(point: path[i])
            highlightTile.anchorPoint = CGPoint(x: 0, y: 0)
            
            highlightTile.color = SKColor(red: 1.0, green: 0, blue: 0, alpha: 0.25+((CGFloat(i)/CGFloat(path.count))*0.25))
            highlightTile.colorBlendFactor = 1.0
            
            layer2DHighlight.addChild(highlightTile)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       
        //////////////////////////////////////////////////////////
        // Original code that we still need
        //////////////////////////////////////////////////////////
        
        let touch = touches.first //as! UITouch
        let touchLocation = touch?.location(in: viewIso)
        
        var touchPos2D = pointIsoTo2D(p: touchLocation!)
        
        touchPos2D = touchPos2D + CGPoint(x:tileSize.width/2, y:-tileSize.height/2)
        
        //////////////////////////////////////////////////////////
        // PathFinding code that replaces our old positioning code
        //////////////////////////////////////////////////////////
        
        //1
        let path = findPathFrom(from: point2DToPointTileIndex(point: hero.tileSprite2D.position), to: point2DToPointTileIndex(point: touchPos2D))
        
        if (path != nil) {
            
            //2
            var newHeroPos2D = CGPoint()
            var prevHeroPos2D = hero.tileSprite2D.position
            var actions = [SKAction]()
            
            //3
            for i in 1..<path!.count {
                
                //4
                newHeroPos2D = pointTileIndexToPoint2D(point: path![i])
                let deltaY = newHeroPos2D.y - prevHeroPos2D.y
                let deltaX = newHeroPos2D.x - prevHeroPos2D.x
                let degrees = atan2(deltaX, deltaY) * (180.0 / CGFloat(Double.pi))
                actions.append(SKAction.run({
                    self.hero.facing = self.degreesToDirection(fromDegrees: degrees)
                    self.hero.update()
                }))
                
                //5
                let velocity:Double = Double(tileSize.width)*2
                var time = 0.0
                
                if i == 1 {
                    
                    //6
                    time = TimeInterval(distance(p1: newHeroPos2D, p2: hero.tileSprite2D.position)/CGFloat(velocity))
                    
                } else {
                    
                    //7
                    let baseDuration =  Double(tileSize.width)/velocity
                    var multiplier = 1.0
                    
                    let direction = degreesToDirection(fromDegrees: degrees)
                    
                    if direction == Direction.NE
                        || direction == Direction.NW
                        || direction == Direction.SW
                        || direction == Direction.SE
                    {
                        //8
                        multiplier = 1.4
                    }
                    
                    //9
                    time = multiplier*baseDuration
                }
                
                //10
                actions.append(SKAction.move(to: newHeroPos2D, duration: time))
                
                //11
                prevHeroPos2D = newHeroPos2D
                
            }
            
            //12
            hero.tileSprite2D.removeAllActions()
            hero.tileSprite2D.run(SKAction.sequence(actions))
            
            //13
            highlightPath2D(path: path!)
            
        }
        
    }
    
}
    
    

