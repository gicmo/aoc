import Foundation

enum Op {
    case Noop
    case AddX(Int)
}

func parseLine(_ line: String) -> Op {
    if line == "noop" {
        return .Noop
    }
    
    let comps = line.split(separator: " ")
    precondition(comps.count == 2, "failed to parse op")

    precondition(comps[0] == "addx")
    guard let num = Int(comps[1]) else {
        preconditionFailure("argument of addx must be Int")
    }
    
    return .AddX(num)
}

var regX = 1
var cycle = 0

var points: [Character] = []

func onTick() {
    let pixel = (cycle - 1) % 40
    let sprite = [regX-1, regX, regX+1]
    
    var ch: Character = " "
    if sprite.contains(pixel) {
        ch = "#"
    }
    points.append(ch)
}

func tick(_ n: Int = 1) {
    for _ in 0..<n {
        cycle += 1
        onTick()
    }
}

func addX(_ num: Int) {
    tick(2)
    regX += num
}

func noop() {
    tick(1)
}

while let line = readLine() {
    let op = parseLine(line)
    print(op)

    switch op {
    case .AddX(let x):
       addX(x)
    case .Noop:
        noop()
    }
}

for (i, ch) in points.enumerated() {
    print(ch, terminator: "")
    if (i + 1) % 40 == 0 {
        print("")
    }
}
print("")
