import Foundation

struct Matrix<Element> {
    // we store data in row-major
    private var data: [Element]
    let nRows: UInt8
    let nCols: UInt8
    
    init(data: [Element], rows: UInt8, cols: UInt8) {
        precondition(data.count == Int(rows) * Int(cols), "\(data.count) != \(rows) * \(cols)")
        self.data = data
        self.nRows = rows
        self.nCols = cols
    }
    
    init(data: [Element], rows: Int, cols: Int) {
        precondition(rows < UInt8.max && cols < UInt8.max)
        self.init(data:data, rows:UInt8(rows), cols:UInt8(cols))
    }
   
    init(repeating repeatedValue: Element, rows: UInt8, cols: UInt8) {
        let data = Array(repeating: repeatedValue, count: Int(rows) * Int(cols))
        self.init(data:data, rows:rows, cols:cols)
    }
    
    var count: Int {
        get {
            return Int(self.nRows) * Int(self.nCols)
        }
    }
    
    private func getIndex(row: UInt8, col: UInt8) -> Int {
       return Int(row) * Int(nCols) + Int(col)
    }
   
    subscript(_ row: UInt8, _ col: UInt8) -> Element {
        get {
            precondition(row < self.nRows && col < self.nCols)
            let idx = getIndex(row: row, col: col)
            return self.data[idx]
        }
        set(newValue) {
            precondition(row < self.nRows && col < self.nCols)
            let idx = getIndex(row: row, col: col)
            self.data[idx] = newValue
        }
    }
}

struct MatrixView<Element> {
    var base: Matrix<Element>
    let nRows: UInt8
    let nCols: UInt8
    
    typealias Transform = ((UInt8, UInt8) -> (UInt8, UInt8))
    
    static func identityTransform(row: UInt8, col: UInt8) -> (UInt8, UInt8) {
        return (row, col)
     }
   
    static func transposeTransform(row: UInt8, col: UInt8) -> (UInt8, UInt8) {
        return (col, row)
     }
    
    var transfrom: Transform = identityTransform(row:col:)

    var count: Int {
        get {
            return Int(self.nRows) * Int(self.nCols)
        }
    }
    
    private func getIndex(row: UInt8, col: UInt8) -> (UInt8, UInt8) {
        return (row, col)
     }
    
    subscript(_ row: UInt8, _ col: UInt8) -> Element {
        get {
            precondition(row < self.nRows && col < self.nCols)
            let (row, col) = self.transfrom(UInt8(row), UInt8(col))
            return self.base[row, col]
        }
        set(newValue) {
            precondition(row < self.nRows && col < self.nCols)
            let (row, col) = self.transfrom(UInt8(row), UInt8(col))
            self.base[row, col] = newValue
        }
    }
    
}

extension Matrix: CustomStringConvertible {
    var description: String {
        get {
            var str = ""

            for r in 0..<self.nRows {
                for c in 0..<self.nCols {
                    str += "\(self[r, c]) "
                }
                str += "\n"
            }
            return str
        }
    }
}

func parseInput() -> Matrix<UInt8> {
    var buffer: [UInt8] = []
    var nCols = 0
    var nRows = 0
    while let line = readLine() {
        let nums = line.map { v in UInt8(String(v))! }
        if nCols == 0 {
            nCols = nums.count
        } else {
            assert(nCols == nums.count)
        }
        buffer.append(contentsOf: nums)
        nRows += 1
    }
    print(nCols, nRows, buffer.count)
    return Matrix(data: buffer, rows: nRows, cols: nCols)
}

let mat = parseInput()
print(mat)

// dumb and naive version, with repetitions
var maxHeight = -1
var result = Matrix(repeating: 0, rows: mat.nRows, cols: mat.nCols)

func scenicScore(forest m: Matrix<UInt8>, row r: UInt8, col c: UInt8) -> Int {
    let height = m[r, c]
    var score = 1
    
    debugPrint("height: \(height) at \(r) \(c)")
   
    debugPrint("looking up [\(score)]")
    var trees = 0
    for v in (0..<r).reversed() {
        trees += 1
        let h = m[v, c]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
  
    score *= trees
    
    debugPrint("looking down [\(score)]")
    trees = 0
    for v in ((r+1)..<m.nRows) {
        trees += 1
        let h = m[v, c]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
    
    debugPrint("looking left [\(score)]")
    trees = 0
    for v in (0..<c).reversed() {
        trees += 1
        let h = m[r, v]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
    
    debugPrint("looking right [\(score)]")
    trees = 0
    for v in ((c+1)..<m.nCols) {
        trees += 1
        let h = m[r, v]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
        
    return score
}

var candidate = 0
for r in 0..<mat.nRows {
    for c in 0..<mat.nCols {
        let score = scenicScore(forest: mat, row: r, col: c)
        if score > candidate {
            debugPrint("FOUND CANDIDATE AT \(r), \(c) [\(score)]")
            candidate = score
        }
    }
}

print(candidate)
