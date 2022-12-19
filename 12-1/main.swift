import Foundation
import DequeModule
import Common

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

//

protocol Graph<Element> {
    associatedtype Element
    associatedtype Index

    var count: Int { get }
    func neighbours(at: Index) -> [Index]
    subscript(_ index: Index) -> Element { get set }
}

extension Matrix: Graph {
    typealias Index = Matrix<Element>.Index
    
    func calcIndex(row: Int, col: Int) -> Index {
        return row * Int(nCols) + col
    }
    
    func resolveIndex(at: Index) -> (Int, Int) {
        let row = at / Int(nCols)
        let col = at % Int(nCols)
        
        return (row, col)
    }
    
    func neighbours(at index: Index) -> [Index] {
        var res: [Index] = []
        res.reserveCapacity(4)
     
        let (row, col) = resolveIndex(at: index)
    
        // up
        if row > 0 {
            res.append(calcIndex(row: row - 1, col: col))
        }
        
        // right
        if (col + 1) < nCols {
            res.append(calcIndex(row: row, col: col + 1))
        }
        
        // down
        if (row + 1) < nRows {
            res.append(calcIndex(row: row + 1, col: col))
        }
        
        // left
        if col > 0 {
            res.append(calcIndex(row: row, col: col - 1))
        }
       
        return res
    }
}

//

func parseInput() -> Matrix<Int> {
    var ncols = -1
    var nrows = 0
    var data: [Int] = []
    
    while let line = readLine() {
        let nums = line.map { ch in
            charValue(ch)
        }
        
        if ncols == -1 {
            ncols = nums.count
        } else {
            precondition(ncols == nums.count, "parser error")
        }
        
        data.append(contentsOf: nums)
        nrows += 1
    }
   
    return Matrix(data: data, rows: nrows, cols: ncols)
}

var graph = parseInput()
print(graph)

let start = graph.firstIndex(of: charValue("S"))
guard let start = start else {
    preconditionFailure("Could not find start")
}

let end = graph.firstIndex(of: charValue("E"))
guard let end = end else {
    preconditionFailure("Could not find end")
}

enum Color {
    case White
    case Gray
    case Black
    
}

extension Graph where Element == Int, Index == Int {
    func bfs(start s: Index, until: (Index) -> Bool, filter predicate: (Self, Index, Index) -> Bool) -> ([Index], [Int], Index?) {
        var pred = Array<Index>(repeating: -1, count: self.count)
        var dist = Array<Int>(repeating: Int.max, count: self.count)
        var color = Array<Color>(repeating: .White, count: self.count)
        
        var q: Deque<Index> = [s]
        dist[s] = 0
        color[s] = .Gray
        
        var goal: Index? = nil
        
        while let node = q.popFirst() {
            let neighbours = self.neighbours(at: node)
            
            let reachable = neighbours.filter { x in
                predicate(self, node, x)
            }
            
            for n in reachable {
                if color[n] == .White {
                    dist[n] = dist[node] + 1
                    pred[n] = node
                    color[n] = .Gray
                    q.append(n)
                }
            }
            color[node] = .Black
            
            if until(node) {
                goal = node
                break
            }
        }
        return (pred, dist, goal)
    }

    func resolvePath(pred: [Index], end e: Index) -> [Index] {
        var res: [Index] = []
        var cur: Index = e

        while cur != -1 {
            cur = pred[cur]
            res.append(cur)
        }
        
       return res
    }
}

graph[start] = charValue("a")
graph[end] = charValue("z")

func filterNeighbours<G: Graph>(_ graph: G, _ node: G.Index, _ neighbour: G.Index) -> Bool where G.Element == Int {
    return
        graph[neighbour] <= graph[node] ||
        graph[neighbour] == graph[node] + 1
}

let (predData, distData, _) = graph.bfs(start: start, until: {$0 == end}, filter: filterNeighbours)

let pred = Matrix(data: predData, rows: graph.nRows, cols: graph.nCols)

var indices = Matrix(repeating: 0, rows: graph.nRows, cols: graph.nCols)
for i in 0..<indices.count {
    indices[i] = i
}

print("indices: ")
print(indices)

print("graph: ")
print(graph)

print("pred:")
print(pred)

let path = graph.resolvePath(pred: predData, end: end)
print("start: \(start), end: \(end)")
print("path: \(path), len: \(path.count)")

func filterNeighboursDown<G: Graph>(_ graph: G, _ node: G.Index, _ neighbour: G.Index) -> Bool where G.Element == Int {
    return
        graph[neighbour] >= graph[node] ||
        graph[neighbour] == graph[node] - 1
}

let (predData2, _, goal) = graph.bfs(start: end, until: { graph[$0] == charValue("a")}, filter: filterNeighboursDown)

guard let goal = goal else {
    preconditionFailure("Could not find goal node")
}

let path2 = graph.resolvePath(pred: predData2, end: goal)
print("Solution 2")
print(Matrix(data: predData2, rows: graph.nRows, cols: graph.nCols))
print("path2: \(path2), len2: \(path2.count)")
print("goal: \(goal): \(graph[goal])")

print(graph.neighbours(at: end).filter{x in filterNeighboursDown(graph, end, x)})
