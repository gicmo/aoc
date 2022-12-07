import Foundation

// poor man's ordered dict
var counter: [Character:Int] = [:]
var window: [Character] = []
var position = 0

var numDistinct = 4 + 1 // default package marker size is 4

if CommandLine.arguments.count > 1 {
    guard let n = UInt8(CommandLine.arguments[1]) else {
        print("WINDOW_SIZE must be between 0 and 254")
        exit(1)
    }
    numDistinct = Int(n) + 1
}

window.reserveCapacity(numDistinct)

while let data = try! FileHandle.standardInput.read(upToCount: 1) {
    guard let str = String(data: data, encoding: String.Encoding.utf8) else {
        print("Could not decode data: \(data)")
        exit(1)
    }

    guard let ch = str.first else {
        print("need character")
        exit(1)
    }

    position += 1

    window.append(ch)

    if let c = counter[ch] {
        counter[ch]! = c + 1
    } else {
        counter[ch] = 1  
    }

    if window.count < numDistinct {
        continue
    }
    
    let rem = window.removeFirst()
    let cnt = counter[rem]!
    
    if cnt > 1 {
        counter[rem] = cnt - 1
    } else {
        counter.removeValue(forKey: rem)
    }
    
    if counter.allSatisfy({ $0.value == 1}) {
        print("Found marker at \(position)")
        print(window)
        break
    }
}
