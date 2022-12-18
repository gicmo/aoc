import Foundation

public struct Matrix<Element> {
    // we store data in row-major
    private var data: [Element]
    public let nRows: UInt8
    public let nCols: UInt8
    
    public init(data: [Element], rows: UInt8, cols: UInt8) {
        precondition(data.count == Int(rows) * Int(cols), "\(data.count) != \(rows) * \(cols)")
        self.data = data
        self.nRows = rows
        self.nCols = cols
    }
    
    public init(data: [Element], rows: Int, cols: Int) {
        precondition(rows < UInt8.max && cols < UInt8.max)
        self.init(data:data, rows:UInt8(rows), cols:UInt8(cols))
    }
   
    public init(repeating repeatedValue: Element, rows: UInt8, cols: UInt8) {
        let data = Array(repeating: repeatedValue, count: Int(rows) * Int(cols))
        self.init(data:data, rows:rows, cols:cols)
    }
    
    public var count: Int {
        get {
            return Int(self.nRows) * Int(self.nCols)
        }
    }
    
    private func getIndex(row: UInt8, col: UInt8) -> Int {
       return Int(row) * Int(nCols) + Int(col)
    }
   
    public subscript(_ row: UInt8, _ col: UInt8) -> Element {
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

extension Matrix: CustomStringConvertible {
    public var description: String {
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
