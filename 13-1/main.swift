import Foundation

extension String {
    func peek(after i: Self.Index) -> Character {
        let pos = self.index(after: i)
        return self[pos]
    }
}

func expect(_ str: String, _ idx: String.Index, _ chr: Character) {
    
}

enum Data: Equatable {
    case Integer(Int)
    indirect case List(Array<Data>)
    
    static func makeList(_ data: [Int]) -> Data {
        .List(data.map({.Integer($0)}))
    }
}

extension Data: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .Integer(let x):
            return "\(x)"
            
        case .List(let l):
            var res = "["
            res += l.map({ d in d.description }).joined(separator: ", ")
            res += "]"
            return res
        }
    }
}

enum Token: Equatable {
    case EOL
    
    case ListBegin
    case ListSeparator
    case ListEnd
    
    case Integer(Int)
    
    var isEnd: Bool {
        switch self {
        case .ListEnd, .EOL:
            return true
        default:
            return false
        }
    }
    
    }

class Scanner {
    var data: String
    var pos: String.Index
    
    var token: Token?
    
    init(data: String) {
        self.data = data
        self.pos = data.startIndex
    }
    
    private func parseNumber() -> Token {

        let start = pos
       
        repeat {
            pos = data.index(after: pos)
        } while data[pos].isNumber
        
        let str = data[start..<pos]
        guard let num = Int(str) else {
            preconditionFailure("Could not parse number \(str)")
        }
       
        return Token.Integer(num)
    }
    
    private func read() -> Token {
        if pos == data.endIndex {
            return Token.EOL
        }
        
        let ch = data[pos]
        pos = data.index(after: pos)
       
        switch (ch) {
        case "[":
            return Token.ListBegin
            
        case "]":
            return Token.ListEnd
            
        case ",":
            return Token.ListSeparator
            
        case let x where x.isWhitespace:
            return read()
            
        case let x where x.isNumber:
            // rewind!
            pos = data.index(before: pos)
            return parseNumber()
            
        default:
            break
        }
       
        preconditionFailure("parser error: \(ch) unexpected")
    }
    
    
    func next() -> Token {
        if let res = token {
            token = nil
            return res
        }
       
        return read()
    }
    
    func peek() -> Token {
        if token == nil {
           token = read()
        }

        return token!
    }
    
    func expect(token want: Token) {
        let have = next()
        precondition(have == want, "Unexpected token \(have), wanted \(want)")
    }
    
}

func parseList(_ scanner: Scanner) -> Data {
    var payload: [Data] = []
   
    while case let token = scanner.next(), !token.isEnd {
        
        switch token {
        case .Integer(let n):
            payload.append(Data.Integer(n))
        case .ListBegin:
            let nested = parseList(scanner)
            payload.append(nested)
        default:
            precondition(token == .ListSeparator, "Unexpected token \(token)")
            break
        }
    }
    
    return Data.List(payload)
}

func parseData(_ str: String) -> Data {
    var scanner = Scanner(data: str)
    scanner.expect(token: Token.ListBegin)
    return parseList(scanner)
}

assert(parseData("[]") == Data.List([]))
assert(parseData("[1]") == Data.List([Data.Integer(1)]))
assert(parseData("[[[]]]") == Data.List([Data.List([Data.List([])])]))

func parseLine() -> Data? {
    let line = readLine()
    guard let line = line else {
        return nil
    }
    
    return parseData(line)
}

func parseTuple() -> (Data, Data)? {
    let a = parseLine()
    guard let a = a else {
        return nil
    }
    
    let b = parseLine()
    guard let b = b else {
        preconditionFailure("Expected second tuple line")
    }
    
    _ = readLine()
    
    return (a, b)
}

func checkPair(left: Data, right: Data) -> Bool? {
    print("[P] \(left) | \(right)")
    
    switch (left, right) {
    case (.Integer(let l), .Integer(let r)):
        let res: Bool?
        
        if l < r {
            res = true
        } else if l > r {
            res = false
        } else {
            res = nil
        }
        
        print("[C] Int(\(l)) | Int(\(r)) -> \(String(describing: res))")
        return res
        
    case (.List(let l), .List(let r)):
     
        print("[C] List(\(l.count)) | List(\(r.count))")
        
        let n = min(r.count, l.count)
        
        for (a, b) in zip(l[0..<n], r[0..<n]) {
            
            if let res = checkPair(left: a, right: b) {
                return res
            }
        }
        
        if l.count == r.count {
            return nil
        }
      
        // If the right list runs out of items first,
        // the inputs are not in the right order.
        // If the left list runs out of items first,
        // the inputs are in the right order.
        return l.count == n
                
    case (.List(let l), .Integer(let n)):
        print("[>] mixed, \(n) -> [\(n)]")
        return checkPair(left: Data.List(l), right: Data.makeList([n]))
        
    case (.Integer(let n), .List(let l)):
        return checkPair(left: Data.makeList([n]), right: Data.List(l))
    }
}

var results: [Bool] = []

while let pair = parseTuple() {
    print("* CHECK\n\t\(pair.0)\n\t\(pair.1)\n")
    let correct = checkPair(left: pair.0, right: pair.1)
    guard let correct = correct else {
        preconditionFailure("got optional return")
        continue
    }
    
    results.append(correct)
    print("* \(correct)\n")
}

for r in results {
    print(r)
}

print(results.enumerated().filter({(i, v) in v}).map({i, v in i+1}).reduce(0, +))
