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
    Rectangle.init(Position(x: 300, y: 300), Size(50, 50), 0xFFFF_00FF)
  }
}

public struct Face {
  let a: Int
  let b: Int
  let c: Int
}

// public extension Face {
// var mesh:Vector3D = { return Vector3D(self.a-1,)}
// }

public struct Cube {
  let mesh: () -> [(Float, Float, Float)]
  let faces: () -> [Face]
}

func getCubeMesh() -> [(Float, Float, Float)] {
  return [
    (-1, -1, -1),
    (-1, +1, -1),
    (+1, +1, -1),
    (+1, -1, -1),
    (+1, +1, +1),
    (+1, -1, +1),
    (-1, +1, +1),
    (-1, -1, +1),
  ]
}

func getCubeFace() -> [Face] {
  return [
    // Front
    Face(a: 1, b: 2, c: 3),
    Face(a: 1, b: 3, c: 4),
    // Right
    Face(a: 4, b: 3, c: 5),
    Face(a: 4, b: 5, c: 6),
    // Back
    Face(a: 6, b: 5, c: 7),
    Face(a: 6, b: 7, c: 8),
    // Left
    Face(a: 8, b: 7, c: 2),
    Face(a: 8, b: 2, c: 1),
    // Top
    Face(a: 2, b: 7, c: 5),
    Face(a: 2, b: 5, c: 3),
    // Bottom
    Face(a: 6, b: 8, c: 1),
    Face(a: 6, b: 1, c: 4),
  ]
}

public let defaultCube = Cube.init(mesh: getCubeMesh, faces: getCubeFace)
