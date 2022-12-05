import Foundation
import RegexBuilder


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

var dups = 0

while let line = readLine() {
    let (l, r) = parseLine(line)
    if l.contains(r) || r.contains(l) {
        dups += 1
    }
}

print(dups)
