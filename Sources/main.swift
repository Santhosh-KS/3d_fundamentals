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

var rotator = Vector3D(0, 0, 0)
let rotatorY = Vector3D(0, 0, 0.1)
let points = interpolate(values: (-1, 1), instep: 0.25)
var cubePoints = combination(points).map(Vector3D.init(x:y:z:))

func update(_ container: SomeContainer, _ data: inout [UInt32]) {
  let indices = data.chunkIndices(container.size.height, Int32.init)

  let rotation = curry(rotate)(Axis.x)(0.1)
  /* let rotationY = curry(rotate)(Axis.y)(0.1)
  let rotationZ = curry(rotate)(Axis.z)(0.1)
  let rotation = rotationX >>> rotationY >>> rotationZ
  rotator = rotator + rotatorY  */
  let modifiedCubePoints = cubePoints.map(rotation)
  cubePoints = modifiedCubePoints
  let projectedPoints = cubePoints.map(container.transfrom3dToPosition)
  projectedPoints.forEach { pos in
    let rect = Rectangle(pos, Size(4, 4), 0xFFAA_BBCC)
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
  let container = setup(size, .perspective)
  let color: Uint32 = 0x0412_3412
  var data: [UInt32] = gridLine(size, color)
  while isRunning {
    isRunning = processInput()
    update(container, &data)
    render(context, &data, size)
  }
}

run()
