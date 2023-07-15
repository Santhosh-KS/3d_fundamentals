public struct Rectangle {
  let position: Position
  let size: Size
  let color: UInt32
}

public extension Rectangle {
  init(_ p: Position = Position(), _ s: Size = Size(), _ c: UInt32 = 0) {
    self.position = p
    self.size = s
    self.color = c
  }
}

public extension Rectangle {
  func draw() -> [UInt32] {
    return Array.init(repeating: self.color, count: self.size.count)
  }
}

public extension Rectangle {
  static var template: Self {
      Rectangle.init(Position(x: 300, y: 300), Size(300, 150), 0xFFFF00FF)
  }
}
