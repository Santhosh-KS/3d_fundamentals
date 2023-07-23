import Foundation

public struct Vector2D {
  let x: Float
  let y: Float
}

extension Vector2D {
  public init(_ x: Float = 0, _ y: Float = 0) {
    self.x = x
    self.y = y
  }
}

public struct Vector3D {
  let x: Float
  let y: Float
  let z: Float
}

extension Vector3D {
  public init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0) {
    self.x = x
    self.y = y
    self.z = z
  }
}

extension Vector3D {
  static func - (_ lhs: Self, _ rhs: Self) -> Self {
    Vector3D(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
  }

  static func + (_ lhs: Self, _ rhs: Self) -> Self {
    Vector3D(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
  }
}

public struct Camera {
  let position: Vector3D
  let rotation: Vector3D
  let angle: Float
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

enum ProjectionType {
  case orthographic(_ v: Vector3D)
  case perspective(_ v: Vector3D)
}

// Orthographic projection
func orthographicProjection(_ v: Vector3D) -> Vector2D {
  Vector2D(v.x, v.y)
}

func getPosition(_ v: Vector2D) -> Position {
  let fovConst: Float = 640.0  // TODO: Fix this adjustments
  return Position.init(x: Int(v.x * fovConst), y: Int(v.y * fovConst))
}

func perspectiveProjection(_ v: Vector3D) -> Vector2D {
  if v.z != 0 {
    return Vector2D(v.x / v.z, v.y / v.z)
  }
  return Vector2D(v.x, v.y)
}

func adjustCameraPosition(_ v: Vector3D, _ camPos: Vector3D) -> Vector3D {
  v - camPos
}

func moveToLocation(_ s: Size, _ p: Position) -> Position {
  Position(x: p.x + s.width, y: p.y + s.height)
}
