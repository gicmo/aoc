import Foundation
import RegexBuilder

enum Overlap {
    case None
    case Contains
    case Contained
    case Overlaps
}

struct Section {

    let start: Int
    let end: Int

    init(_ start: Int, _ end: Int) {
        self.start = start
        self.end = end
    }

    func contains(_ other: Section) -> Bool {
        return self.start <= other.start && self.end >= other.end
    } 

    // very naive implementation
    func overlaps(with other: Section) -> Overlap {
        // self: (,); other: [,]
        // 1: ( ... [ ... ] ... )
        // 2: [ ... ( ... ) ... ]
        //
        // 3: ( ... [ ... ) ... ]
        // 4: [ ... ( ... ] ... )
        //
        // 5: ( ... ) ... [ ... ]
        // 6: [ ... ] ... ( ... )

        if self.contains(other) {
            return .Contains // 1
        } else if other.contains(self) {
            return .Contained // 2
        } else if self.start <= other.start && self.end >= other.start {
            return .Overlaps // 3
        } else if other.start <= self.start && other.end >= self.start {
            return .Overlaps // 4
        } else {
            return .None // 5, 6
        }
     }
}

func parseLine(_ str: String) -> (Section, Section) {

    let SectionDigit = Regex {
        Capture{
            OneOrMore(.digit)
        } transform: {
            str -> Int in Int(str)!
        }
    }

    let SectionPattern = Regex {
        // x-y
            SectionDigit 
            "-"
            SectionDigit
    }

    let regex = Regex {
        SectionPattern
        ","
        SectionPattern
    }

    let m = try! regex.wholeMatch(in: str)

    guard let m = m else {
        preconditionFailure("Unparsble string \(str)")
    }

    let (_, a, b, u, v) = m.output
    return (Section(a, b), Section(u, v))
}

var contained = 0
var overlaps = 0

while let line = readLine() {
    let (l, r) = parseLine(line)
    let o = l.overlaps(with: r)

    if o == .Overlaps {
        overlaps += 1
    }

    if o == .Contains || o == .Contained {
        contained += 1
    }
}

print("Contained: \(contained)")
print("Overlaps: \(overlaps + contained)")

