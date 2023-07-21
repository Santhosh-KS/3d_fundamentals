import Foundation

public struct Vector2D {
  let x: Float
  let y: Float
}
struct Santhosh {
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

// Orthographic projection
func orthographicProjection(_ v: Vector3D) -> Vector2D {
  Vector2D(v.x, v.y)
}

func getPosition(_ v: Vector2D) -> Position {
  let fovConst: Float = 128.0  // TODO: Fix this adjustments
  return Position.init(UInt32(v.x * fovConst), UInt32(v.y * fovConst))
}