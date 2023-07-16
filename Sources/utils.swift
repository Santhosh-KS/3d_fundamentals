import CSDL2
import Foundation

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |> : ForwardApplication

public func |> <A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
  f(a)
}

public func ErrorMessage() -> String {
  String.init(cString: SDL_GetError()!)
}

extension Array {
  public func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
}

public func combination<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    ys.map { y in (x, y) }
  }
}

public func combination<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  combination(combination(xs, ys), zs).map { (a, b) in (a.0, a.1, b) }
}

public func scale(between min: Int, and max: Int) -> Int {
  abs(min) + abs(max)
}

public func generate(values between: (min: Int, max: Int), instep of: Float) -> [Float] {
  let scale = scale(between: between.min, and: between.max)
  let count = Float(scale) / of  
  return (0...Int(count)).map { number in
     (Float(scale)*(Float(number) / Float(count))) - Float(between.max) 
  }
}

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
