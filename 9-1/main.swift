import Foundation

enum Delta {
    case None
    case Up(Int)
    case Down(Int)
    case Left(Int)
    case Right(Int)
    case Diagonal(Int)
}

struct Position {
    let x: Int
    let y: Int

    static func * (left: Position, right: Int) -> Position {
        return Position(x: left.x * right, y: left.y * right)
    }

    static func + (left: Position, right: Position) -> Position {
        let (x, y) = (left.x + right.x, left.y + right.y)
        return Position(x: x, y: y)
    }

    static func - (left: Position, right: Position) -> Position {
        let (x, y) = (left.x - right.x, left.y - right.y)
        return Position(x: x, y: y) 
    }

    public static var zero: Position { 
        Position(x: 0, y: 0)
    }

    public var isOrigin: Bool {
        return x == 0 && y == 0
    }
    
    public func abs() -> Position {
        return Position(x: Swift.abs(x), y: Swift.abs(y))
    }
    
    public func signum() -> Position {
        let val = self.abs()
        
        let a: Int
        if x != 0 {
            a = x / val.x
        } else {
            a = 0
        }
        
        let b: Int
        if y != 0 {
            b = y / val.y
        } else {
            b = 0
        }
        
        return Position(x: a, y: b)
    }

    static let Up = Position(x: 0, y: 1)
    static let Down = Position(x: 0, y: -1)
    static let Left = Position(x: -1, y: 0)
    static let Right = Position(x: 1, y: 0)
}

extension Position: Sendable {}
extension Position: Equatable {}
extension Position: Hashable {}

extension Position: CustomStringConvertible {
  public var description: String {
    return "(\(x), \(y))"
  }
}

extension Position: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Position(\(String(reflecting: x)), \(String(reflecting: y)))"
  }
}

enum Move: Equatable {
    case Up(Int)
    case Down(Int)
    case Left(Int)
    case Right(Int)
}

func parseMove(_ line: String) -> Move {
    let comps = line.split(separator:" ")
    assert(comps.count == 2, "failed to parse line")
    let to = comps[0]
    let amount = Int(comps[1])!

    switch to {
        case "U":
            return Move.Up(amount)
        case "D":
            return Move.Down(amount)
        case "L":
            return Move.Left(amount)
        case "R":
            return Move.Right(amount)
        default:
            preconditionFailure()
    }
}

class Knot {
    var _pos: Position
    var _history: [Position]
    
    var pos: Position {
        return self._pos
    }
    
    var history: [Position] {
        return self._history + [self._pos]
    }
    
    init() {
        _pos = Position.zero
        _history = []
    }
    
    func move(by amount: Position) {
        let old = _pos
        _history.append(_pos)
        _pos = old + amount
    }
    
    func delta(to other: Knot) -> Position {
        return _pos - other._pos
    }
    
    func catchUp(to other: Knot) {
        let diff = other.delta(to: self)
        
        let dir = diff.signum()
        let dist = diff.abs()
        
        // print("CatchUp: \(dir), \(dist)")
        
        if dir == Position.Right || dir == Position.Left {
            if dist.x > 1 {
                move(by: dir * (dist.x - 1))
            }
        } else if dir == Position.Up || dir == Position.Down {
            if dist.y > 1 {
                move(by: dir * (dist.y - 1))
            }
        } else {
            // print("Diagonal catch up [\(dist)]")
            let n = max(dist.x, dist.y)
            
            if n > 1 {
                move(by: dir * (n - 1))
            }
        }
    }
}

extension Knot: CustomStringConvertible {
  public var description: String {
      return "[\(_pos.x), \(_pos.y)]"
  }
}

assert(parseMove("U 2") == Move.Up(2))

var head = Knot()
var tail = Knot()

func execMove(_ m: Move) {
    let dir: Position
    let amount: Int
    switch m {
    case .Up(let x):
        amount = x
        dir = Position.Up
        
    case .Left(let x):
        amount = x
        dir = Position.Left
        
    case .Down(let x):
        amount = x
        dir = Position.Down
        
    case .Right(let x):
        amount = x
        dir = Position.Right
    }
   
    for _ in 0..<amount {
        head.move(by: dir)
        tail.catchUp(to: head)
        print("  \(head), \(tail)")
    }
}

while let line = readLine() {
    let move = parseMove(line)
    debugPrint(move)
   
    execMove(move)
    
    print("head: \(head), tail: \(tail))")
}


let limits = head.history.reduce((0, 0, 0, 0)) { res, pos in
    (min(res.0, pos.x), min(res.1, pos.y), max(res.2, pos.x), max(res.3, pos.y))
}

print("limits: \(limits)")

func drawGrid(start: Int, size: Int, pos: Set<Position>) {
    for y in (start..<size).reversed() {
        for x in start..<size {
            let p = Position(x: x, y: y)
            
            let ch: String
            if p == Position.zero {
                ch = "s"
            } else if pos.contains(p) {
                ch = "#"
            } else {
                ch = "."
            }
            
            print(ch, terminator: "")
        }
        print("")
    }
}

let unique: Set<Position> = Set<Position>(tail.history)
drawGrid(start: min(limits.0, limits.1), size: max(limits.2, limits.3), pos: unique)
print("unique positions: \(unique.count)")
