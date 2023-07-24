import CSDL2
import Foundation

precedencegroup ForwardApplication {
  associativity: left
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator |> : ForwardApplication
infix operator >>> : ForwardComposition

public func |> <A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
  f(a)
}

public func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (
  A
) -> C {
  return { a in g(f(a)) }
}

public func errorMessage() -> String {
  String.init(cString: SDL_GetError()!)
}

extension Array {
  public func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)])
    }
  }
}

extension Array {
  public func chunkIndices<A>(
    _ chunkSize: Int, _ f: @escaping (Int) -> A = UInt32.init
  )
    -> [A]
  {
    stride(from: 0, to: self.count, by: chunkSize).map(f)
  }
}

extension Array {
  public mutating func append(repeating val: Element, count: Int) {
    self.append(contentsOf: Self.init(repeating: val, count: count))
  }
}
/// If
/// A = [1,2,3]
/// and
/// B = ["a", "b"]
/// then
/// Combination(A,B) => [(1,"a"), (1, "b"), (2, "a"), (2, "b"), (3,"a"), (3, "b")]
public func combination<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    ys.map { y in (x, y) }
  }
}

/// Extensts Combination(A,B) to Combination(A, B, C)
/// See also: Combination(A,B)
public func combination<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)]
{
  combination(combination(xs, ys), zs).map { (a, b) in (a.0, a.1, b) }
}

public func combination<A>(_ xs: [A]) -> [(A, A, A)] {
  combination(xs, xs, xs)
}

public func scale(between min: Int, and max: Int) -> Int {
  abs(min) + abs(max)
}

public func interpolate(values between: (min: Int, max: Int), instep of: Float)
  -> [Float]
{
  let scale = scale(between: between.min, and: between.max)
  let count = Float(scale) / of
  return (0 ... Int(count)).map { number in
    (Float(scale) * (Float(number) / Float(count))) - Float(between.max)
  }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

public func curry<A, B, C>(_ f: @escaping (A, B, C) -> Void) -> (A) -> (B) -> (
  C
) -> Void {
  return { a in { b in { c in f(a, b, c) } } }
}

/* let fixedWindowRectangle = curry(draw)(indices, &mv)

// draw(indices, &mv, testRect)
fixedWindowRectangle(testRect)
mv.chunks(windowSize.width).map { print($0) } */
// TODO: Fix the issues with @escaping with inout argument B
public func curry<A, B, C>(_ f: @escaping (A, inout B, C) -> Void)
  -> (A, inout B) -> (C) -> Void
{
  return { a, b in
    var localb = b
    defer { b = localb }
    return { c in
      f(a, &localb, c)
    }
  }
}

extension Camera {
  public init(
    _ p: Vector3D = Vector3D(),
    _ r: Vector3D = Vector3D(),
    _ a: Float = 0
  ) {
    self.position = p
    self.rotation = r
    self.angle = a
  }
}

public enum ProjectionType {
  case orthographic
  case perspective
}

// TODO: Example code to draw rectangle inside a window
/* let testRect = Rectangle.init(Position(2, 1), Size(4, 3), 2)
let testRect1 = Rectangle.init(Position(3, 3), Size(4, 3), 3)
let testRect2 = Rectangle.init(Position(1, 6), Size(3, 3), 4)

var rectPos = Position(x: 3, y: 0)
let windowSize = Size(width: 48, height: 48)
var mv = [UInt32]()
mv.append(repeating: 1, count: windowSize.count)
let indices = mv.chunkIndices(Int(windowSize.width), Int32.init)

//for i in indices {
/* indices.forEach { i in
  if (testRect.position.y ... testRect.size.height).contains(
    Int(i) / Int(windowSize.width))
  {
    (testRect.position.x ... testRect.size.width + 1).forEach { j in
      mv[Int(i) + j] = testRect.color
    }
  }
} */

draw(indices, &mv, testRect, windowSize)
mv.chunks(windowSize.width).map { print($0) }

/* draw(indices, &mv, testRect1)
mv.chunks(windowSize.width).map { print($0) }

draw(indices, &mv, testRect2)
mv.chunks(windowSize.width).map { print($0) } */ */

// Example code end

/* struct RGBA {
  let R: UInt8
  let G: UInt8
  let B: UInt8
  let A: UInt8
}

struct ColorBuffer {
  let width: UInt64
  let height: UInt64
}

extension ColorBuffer {
  init(as windowSize: Size) {
    self.width = windowSize.width
    self.height = windowSize.height
  }
} */
