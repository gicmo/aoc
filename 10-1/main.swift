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

var points: [Int] = []
var signals: [Int: Int] = [:]

for i in stride(from: 20, through: 220, by: 40) {
    points.append(i)
}

func onTick() {
    if points.contains(cycle) {
        signals[cycle] = cycle * regX
    }
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

print(signals)
let total = signals.reduce(0) { (r, e) in
    r + e.value
}
print(total)
