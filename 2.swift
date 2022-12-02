import Foundation

enum Shape: Int, CaseIterable {
    case Rock = 1
    case Paper = 2
    case Scissors = 3
}

enum Outcome: Int {
    case Loss = 0
    case Draw = 3
    case Win = 6
}

func play(_ ours: Shape, against theirs: Shape) -> Outcome {

    switch (ours, theirs) {
        case let (x, y) where x == y: 
            return .Draw
        case (.Rock, .Paper):
            return .Loss
        case (.Paper, .Scissors):
            return .Loss
        case (.Scissors, .Rock):
            return .Loss
        default:
            return .Win
    }
}

var score: Int = 0
while let line = readLine() {
    let m = [
       "A": Shape.Rock,
       "B": Shape.Paper,
       "C": Shape.Scissors,
       "X": Shape.Rock,
       "Y": Shape.Paper,
       "Z": Shape.Scissors,

    ]
    let cmps = line.split(separator: " ", maxSplits: 1).map { m[String($0)]! }
    let (t, o) = (cmps.first!, cmps.last!)
    let res = play(o, against:t)
    score += res.rawValue + o.rawValue
}

print(score)
