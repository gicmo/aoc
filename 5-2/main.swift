import Foundation
import RegexBuilder

enum StackElement {
    case Empty
    case Crate(String)
}

func parseStackLine(_ str: String) -> [StackElement] {
    let regex = Regex {
        ChoiceOf {
            Repeat(" ", count: 3) // empty
            Regex {
                "["
                TryCapture {
                    ("A" ... "Z")
                } transform: { w in
                    StackElement.Crate(String(w))
                }
                "]"
            }
        }
        ChoiceOf {
            " "
            Anchor.endOfLine
        }
    }

    let matches = str.matches(of: regex).map{
        m in m.output.1 ?? StackElement.Empty
    }
    return matches
}

func parseStackNumbers(_ str: String) -> [Int] {
    return str.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").map { s in
        Int(s)!
    }
}

struct Instruction {
    let count: Int
    let from: Int
    let to: Int
}

func parseInstruction(_ str: String) -> Instruction {
    // move 1 from 2 to 1
    let regex = Regex {
        "move"
        OneOrMore(CharacterClass.whitespace)
        Capture {
            OneOrMore(.digit)
        } transform: { d in
            Int(d)!
        }
        OneOrMore(CharacterClass.whitespace)
        "from"
        OneOrMore(CharacterClass.whitespace)
        Capture {
            OneOrMore(.digit)
        } transform: { d in
            Int(d)!
        }
        OneOrMore(CharacterClass.whitespace)
        "to"
        OneOrMore(CharacterClass.whitespace)
        Capture {
            OneOrMore(.digit)
        } transform: { d in
            Int(d)!
        }
        ZeroOrMore(CharacterClass.whitespace)
    }

    let m = try! regex.firstMatch(in: str)
    guard let m = m else {
        preconditionFailure("parsing error")
    }
    
    return Instruction(count: m.output.1, from: m.output.2, to: m.output.3)
}

var se: [[StackElement]] = []
var nums: [Int] = []

while let line = readLine() {
    let parsed = parseStackLine(line)
    
    if !parsed.isEmpty {
        se.append(parsed)
        continue
    }
    
    nums = parseStackNumbers(line)
    precondition(!nums.isEmpty, "expected numbers line")
    
    for (i, e) in se.enumerated() {
        precondition(e.count == nums.count, "stack \(i) has wrong number of elements (\(e.count) vs \(nums.count))")
    }
 
    break
}

// Setup the stack
var stack: [[String]] = []
stack.reserveCapacity(nums.count)

for _ in nums {
    var s: [String] = []
    s.reserveCapacity(se.count)
    stack.append(s)
}

for l in se {
    for (i, e) in l.enumerated() {
        switch e {
        case .Crate(let x):
            stack[i].append(x)
        case .Empty:
            break
        }
    }
}

for i in 0..<stack.count {
    stack[i].reverse()
}

print(stack)

while let line = readLine() {
    if line.isEmpty {
        continue
    }
    
    let ins = parseInstruction(line)
    print(ins)
    
    let start = stack[ins.from-1].count - ins.count
    precondition(start >= 0, "negative items left: \(start) \n \(ins) \n \(stack) ")
    
    let e = stack[ins.from-1][start...]
    stack[ins.to-1].append(contentsOf: e)
    stack[ins.from-1].removeLast(ins.count)
}

print(stack)
for s in stack {
    
    if let e = s.last {
        print(e, terminator: "")
    }
}
