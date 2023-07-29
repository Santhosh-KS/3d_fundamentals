import CSDL2

struct Context {
  let valid: Bool
  let window: OpaquePointer?
  let renderer: OpaquePointer?
  let texture: OpaquePointer?
}

extension Context {
  init(
    _ valid: Bool,
    _ window: OpaquePointer?,
    _ renderer: OpaquePointer?,
    _ texture: OpaquePointer?
  ) {
    self.valid = valid
    self.window = window
    self.renderer = renderer
    self.texture = texture
  }
}

func destroySetup(with context: Context) {
  if context.valid {
    defaultTexture.destroy(context.texture!)
    defaultRenderer.destroy(context.renderer!)
    defaultWindow.destroy(context.window!)
  }
  SDL_Quit()
}

func initWindow() -> Context {
  if SDL_Init(SDL_INIT_VIDEO) != 0 {
    print("Failed to initial SDL: \(errorMessage())")
    return Context(false, nil, nil, nil)
  }
  let window = defaultWindow.create(getCurrentDisplayMode())
  let renderer = defaultRenderer.render(window)
  let texture = defaultTexture.create(renderer)
  return Context(true, window.self, renderer.self, texture)
}

struct SomeContainer {
  let size: Size
  var pointGenerator: ((min: Int, max: Int), Float) -> [Float]
  var combination: ([Float]) -> [(Float, Float, Float)]
  var transfrom3dToPosition: (Vector3D) -> Position
  var cameraTransformation: (Vector3D) -> Vector3D
}

struct Data<A, B> {
  /// given a min and max value and the steps this function will generate the
  /// array of values
  /// var pointGenerator: ((min: Int, max: Int), Float) -> [Float]
  let gen: (A, A, B) -> [B]
}

struct Combinator<A, B, C> {
  /// var combination: ([Float]) -> [(Float, Float, Float)]
  let gen: ([A], [B], [C]) -> [(A, B, C)]
}

struct Transformer {
  //var transfrom3dToPosition: (Vector3D) -> position
  let scale: (Vector3D, Float) -> Vector3D
  let rotate: (Vector3D, Axis, Float) -> Vector3D
  let translate: (Vector3D, Vector3D) -> Vector3D
}

func setup(
  _ size: Size,
  _ projectionType: ProjectionType,
  _ cameraPosition: Vector3D = Vector3D(0, 0, -5)
) -> SomeContainer {
  let windowCenter = Size(size.width / 2, size.height / 2)
  let translateToCenter = curry(moveToLocation)(windowCenter)
  let adjustCamera = curry(adjustCameraPosition)(cameraPosition)

  // rotate(_ axis: Axis, _ angle: Float, _ p: Vector3D)
  let perspective =
    adjustCamera
    >>> perspectiveProjection
    >>> scale
    >>> translateToCenter

  let orthographic =
    adjustCamera
    >>> orthographicProjection
    >>> scale
    >>> translateToCenter

  var transform3dPositon: (Vector3D) -> Position

  switch projectionType {
  case .perspective:
    transform3dPositon = perspective
  case .orthographic:
    transform3dPositon = orthographic
  }

  return SomeContainer.init(
    size: size,
    pointGenerator: interpolate,
    combination: combination,
    transfrom3dToPosition: transform3dPositon,
    cameraTransformation: adjustCamera)
}

let FPS: UInt8 = 30
let FRAME_TARGET_TIME = Float(1000) / Float(FPS)
var prevFrameTime: UInt32 = 0  //SDL_GetTicks()

func sdlTicksPassed(_ a: UInt32, _ b: UInt32) -> Bool {
  Sint32(a - b) <= 0
}

enum PointType {
  case swarm, vertex
  case line(Vector3D, Vector3D)
}

func getPoints(_ type: PointType) -> [Vector3D] {
  switch type {
  case .swarm:
    let points = interpolate(values: (-1, 1), instep: 0.25)
    return combination(points).map(Vector3D.init(x:y:z:))
  case .vertex:
    let m = defaultCube.mesh()
    var points = [Vector3D]()
    defaultCube.faces().forEach { face in
      points.append(m[face.a - 1] |> Vector3D.init(x:y:z:))
      points.append(m[face.b - 1] |> Vector3D.init(x:y:z:))
      points.append(m[face.c - 1] |> Vector3D.init(x:y:z:))
    }
    return points
  // case let .line(x0, y0, x1, y1):
  case let .line(p1, p2):
    return getLinePoints(p1, p2)
  }
}

func floatRound(_ x: Float) -> Float {
  Float(round(Double(x)))
}

/* func getLinePoints(_ x0: Float, _ y0: Float, _ x1: Float, _ y1: Float) -> [Vector3D] {
  let deltaX = (x1 - x0)
  let deltaY = (y1 - y0)

  let longestSideLength =
    (abs(deltaX) >= abs(deltaY)) ? abs(deltaX) : abs(deltaY)
  print("longestSideLength: \(longestSideLength)")
  let xInc = deltaX / longestSideLength
  let yInc = deltaY / longestSideLength
  var currentX = x0
  var currentY = y0
  var linePoints = [Vector3D]()
  //(0 ... Int(longestSideLength)).forEach { index in
  (0 ... 10).forEach { index in
    linePoints.append(
      // Vector3D.init(x: floatRound(currentX), y: floatRound(currentX), z: 0))
      Vector3D.init(x: currentX, y: currentX, z: 0))
    currentX += xInc
    currentY += yInc
  }
  return linePoints
} */

// DDA algorithm to drawLine
// func getLinePoints(_ x0: Float, _ y0: Float, _ x1: Float, _ y1: Float) -> [Vector3D] {
func getLinePoints(_ p1:Vector3D, _ p2:Vector3D) -> [Vector3D] {
  let deltaPoint = p2 - p1

  let slope = deltaPoint.y/(deltaPoint.x + 0.0001)
  let ys = interpolate(values:(-1, 1), instep: 0.0025)
  let xs = ys.map { $0 * slope}
  let points = zip(xs, ys).map { pairs in Vector3D(pairs.0, pairs.1, 0)}
  return points 
}

func update(
  _ container: SomeContainer, _ points: inout [Vector3D],
  _ data: inout [UInt32]
) {
  /*
  let a = Int(FRAME_TARGET_TIME)
  let b = SDL_GetTicks()
  let c = prevFrameTime
  let timeToWait: Int = a - Int(b - c)
  if timeToWait > 0 && timeToWait <= Int(FRAME_TARGET_TIME) {
    SDL_Delay(UInt32(FRAME_TARGET_TIME))
  }
  prevFrameTime = SDL_GetTicks() */
  let indices = data.chunkIndices(container.size.height, Int32.init)

  let rotationX = curry(rotate)(Axis.x)(0.15)
  let rotationY = curry(rotate)(Axis.y)(0.2)
  let rotationZ = curry(rotate)(Axis.z)(0.01)
  let rotation = rotationX >>> rotationY >>> rotationZ

  let modifiedPoints = points.map(rotation)
  points = modifiedPoints

  let projectedPoints = points.map(container.transfrom3dToPosition)
  projectedPoints.forEach { pos in
    let rect = Rectangle(pos, Size(1, 1), 0xFFAA_BBCC)
    draw(indices, &data, rect, container.size)
  }
}

func render(_ c: Context, _ data: inout [UInt32], _ size: Size) {
  let pixels: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(
    capacity: size.count)
  defer { pixels.deallocate() }
  pixels.initialize(from: &data, count: size.count)
  renderColorBuffer(c.renderer!, c.texture!, pixels)
  // NOTE: DONOT USE pixels variable after the renderColorBuffer() call
  SDL_RenderPresent(c.renderer!)
}

func processInput() -> Bool {
  var event = SDL_Event()
  SDL_PollEvent(&event)
  switch event.type {
  case SDL_QUIT.rawValue:
    return false
  case SDL_KEYDOWN.rawValue:
    /* print("KeyDown \(SDL_KEYDOWN.rawValue)")
    print("KeyDown \(SDLK_ESCAPE.rawValue)")
    print("KeyDown \(event.key.keysym.sym)") */
    return event.key.keysym.sym == SDLK_ESCAPE.rawValue ? false : true
  default:
    return true
  }
}

func draw(
  _ indices: [Int32],
  _ data: inout [UInt32],
  _ rect: Rectangle,
  _ windowSize: Size
) {
  for i in indices {
    if i < 0 { continue }
    if (rect.position.x ..< rect.position.x + rect.size.height).contains(
      Int(i) / Int(windowSize.height))
    {
      // print("indicies \(Int(i)): \(Int(i)/Int(windowSize.height)) ")
      for j in (rect.position.y ..< rect.position.y + rect.size.width) {
        if j < 0 { continue }
        data[Int(i) + j] = rect.color
      }
    }
  }
}

func run() {
  let context = initWindow()
  defer { destroySetup(with: context) }
  var isRunning = context.valid
  let size = Size()
  let color: Uint32 = 0x0412_3412
  var data: [UInt32] = gridLine(size, color)
  let container = setup(size, .perspective)
  var points = getPoints(.vertex)
  var linePoints = getPoints(.line(points.first!,points.last!))
  print("linePoints count: \(linePoints.count)")
  while isRunning {
    isRunning = processInput()
    update(container, &linePoints, &data)
    render(context, &data, size)
    /// reset the data
    data = gridLine(size, color)
  }
}

run()
