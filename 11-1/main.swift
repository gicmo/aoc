import Foundation
import RegexBuilder

enum Op {
    case Multiply(Int)
    case Add(Int)
    case Square
    
    func apply(to: Int) -> Int {
        switch self {
        case .Multiply(let x):
            return x * to
        case .Add(let x):
            return x + to
        case .Square:
            return to * to
        }
    }
}

struct Action {
    let onTrue: String
    let onFalse: String
}

struct Test {
    let condition: Int
    let action: Action
}

class Monkey {
    let name: String
    let op: Op
    var items: [Int]
    let test: Test
    
    var count: Int = 0
    
    init(name: String, op: Op, items: [Int], test: Test) {
        self.name = name
        self.op = op
        self.items = items
        self.test = test
    }
    
    func turn(monkeys: [String: Monkey]) {
        items.reverse()
        
        while let item = items.popLast() {
            var num = op.apply(to: item)
            num /= 3
            
            let target: Monkey
            if num % test.condition == 0 {
                target = monkeys[test.action.onTrue]!
            } else {
                target = monkeys[test.action.onFalse]!
            }
        
            target.receiveThrow(item: num)

            count += 1
        }
    }
    
    func receiveThrow(item: Int) {
        items.append(item)
    }
}

extension Monkey: CustomStringConvertible {
    var description: String {
        return "Monkey(\(name) [\(op)] {\(test)}: \(items))"
    }
}

func parseActionLine() -> (Bool, String) {
    let regex = /^    If (true|false): throw to monkey (.+)$/
    
    guard let line = readLine(strippingNewline: true) else {
        preconditionFailure("parser error: action line expected")
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        preconditionFailure("parser error: action line: '\(line)'")
    }
    
    let condStr = match.output.1
    let cond: Bool
    if condStr == "true" {
        cond = true
    } else if condStr == "false" {
        cond = false
    } else {
        preconditionFailure("parser error: action condition: '\(condStr)'")
    }
   
    return (cond, String(match.output.2))
}

func parseAction() -> Action {
   
    let (a1, m1) = parseActionLine()
    let (a2, m2) = parseActionLine()
    
    precondition(a1 == true)
    precondition(a2 == false)
    
    return Action(onTrue: m1, onFalse: m2)
}

func parseTest() -> Test {
    let regex = /^  Test: divisible by (.+)$/
    
    guard let line = readLine(strippingNewline: true) else {
        preconditionFailure("parser error: test line expected")
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        preconditionFailure("parser error: test line: '\(line)'")
    }
    
    let num = Int(match.output.1)!
    let action = parseAction()
    
    return Test(condition: num, action: action)
}

func parseItems() -> [Int] {
    let regex = /^  Starting items:(( \d+,?)+)$/
    
    guard let line = readLine(strippingNewline: true) else {
        preconditionFailure("parser error: items line expected")
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        preconditionFailure("parser error: items line: '\(line)'")
    }
    
    let itemsStr = match.output.1
    
    let items = itemsStr.split(separator:",").map({
        String($0)
    }).map({
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }).map({
        Int($0)!
    })
    
    return items
}

func parseOperation() -> Op {
    let regex = /^  Operation: new = (.+)$/
    
    guard let line = readLine(strippingNewline: true) else {
        preconditionFailure("parser error: operations line expected")
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        preconditionFailure("parser error: operations line: '\(line)'")
    }
    
    let opStr = match.output.1
   
    let multiply = /old \* (\d+)/
    let addition = /old \+ (\d+)/
    let square = /old \* old/
    
    if let m = opStr.wholeMatch(of: multiply) {
        return Op.Multiply(Int(m.output.1)!)
    } else if let m = opStr.wholeMatch(of: addition) {
        return Op.Add(Int(m.output.1)!)
    } else if let _ = opStr.wholeMatch(of: square) {
        return Op.Square
    } else {
        preconditionFailure("parser error: op not matched: '\(opStr)'")
    }
}

func parseMonkey() -> Monkey {
    let regex = /^Monkey (\d+):$/
    
    guard let line = readLine(strippingNewline: true) else {
        preconditionFailure("parser error: Monkey line expected")
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        preconditionFailure("parser error: Monkey line: \(line)")
    }
   
    let name = String(match.output.1)
   
    let items = parseItems()
    let op = parseOperation()
    let test = parseTest()
    
    return Monkey(name: name, op: op, items: items, test: test)
}

var monkeys: [String: Monkey] = [:]

repeat {
    let monkey = parseMonkey()
    monkeys[monkey.name] = monkey
    
} while readLine() != nil

print(monkeys)

for round in 0..<20 {
    print("Round \(round)")
    for i in 0..<monkeys.count {
        let m = monkeys["\(i)"]!
        m.turn(monkeys: monkeys)
    }
    for i in 0..<monkeys.count {
        let m = monkeys["\(i)"]!
        print("  Monkey \(m.name): \(m.items)")
    }
}

for i in 0..<monkeys.count {
    let m = monkeys["\(i)"]!
    print("  Monkey \(m.name) inspected items \(m.count)")
}

let counted = monkeys.map { (_, m) in
    m.count
}.sorted(by: >)

print(counted)

print(Int64(counted[0]) * Int64(counted[1]))
