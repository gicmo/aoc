import Foundation

func charValue(_ ch: Character) -> Int {
    guard let v = ch.asciiValue else {
        return 0
    }

    var r: Int

    // tiny bit sloppy w.r.t. integer underflow
    if v > 96 {
        r = Int(v - Character("a").asciiValue!) + 1
    } else {
        r = Int(v - Character("A").asciiValue!) + 27
    }

    return r
}

var sum: Int = 0

while let line = readLine() {
    let c = line.count
    
    precondition(c % 2 == 0, "Even characters in line")
    let h = c/2
   
    let l = Array(line)
    let (left, right) = (Set(l[0..<h]), Set(l[h...]))

    let common = left.intersection(right)

    guard let ch = common.first else {
        preconditionFailure("More than one common element")
        break
    }

    sum += charValue(ch)
}

print(sum)
