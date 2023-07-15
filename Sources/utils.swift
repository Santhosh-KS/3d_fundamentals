import CSDL2

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

public extension Array {
  func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
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
