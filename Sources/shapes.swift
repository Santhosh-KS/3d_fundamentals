public struct Rectangle {
  let position: Position
  let size: Size
  let color: UInt32
}

extension Rectangle {
  public init(_ p: Position = Position(), _ s: Size = Size(), _ c: UInt32 = 0) {
    self.position = p
    self.size = s
    self.color = c
  }
}

extension Rectangle {
  public func draw() -> [UInt32] {
    return Array.init(repeating: self.color, count: self.size.count)
  }
}

extension Rectangle {
  public static var template: Self {
    Rectangle.init(Position(x: 300, y: 100), Size(100, 50), 0xFFFF_00FF)
  }
}
