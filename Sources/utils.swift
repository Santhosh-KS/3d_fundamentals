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
