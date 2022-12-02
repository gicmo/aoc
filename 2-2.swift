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
    let shapes: [String: Shape] = [
       "A": Shape.Rock,
       "B": Shape.Paper,
       "C": Shape.Scissors,
    ]

    let outcomes: [String: Outcome] = [
       "X": Outcome.Loss,
       "Y": Outcome.Draw,
       "Z": Outcome.Win,
    ]

    let cmps = line.split(separator: " ", maxSplits: 1)
    let (s, o) = (shapes[String(cmps[0])]!, outcomes[String(cmps[1])]!)

    var p: Shape

    switch (o, s) {
        case (.Draw, _):
            p = s

        case (.Win, .Paper), (.Loss, .Rock):
            p = .Scissors

        case (.Win, .Rock), (.Loss, .Scissors):
            p = .Paper

        case (.Win, .Scissors), (.Loss, .Paper):
            p = .Rock
    }

    score += p.rawValue + o.rawValue
}

print(score)
