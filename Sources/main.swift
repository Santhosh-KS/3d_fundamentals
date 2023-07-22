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
    print("Failed to initial SDL: \(ErrorMessage())")
    return Context(false, nil, nil, nil)
  }
  let window = defaultWindow.create(getCurrentDisplayMode())
  let renderer = defaultRenderer.render(window)
  let texture = defaultTexture.create(renderer)
  return Context(true, window.self, renderer.self, texture)
}

//func setup() {
let points = generate(values: (-1, 1), instep: 0.25)
let cubePoints = combination(points, points, points).map(Vector3D.init(x:y:z:))
let projectedPoints = cubePoints.map(orthographicProjection >>> getPosition)
//}

func update() {}

func render(_ c: Context) {
  SDL_SetRenderDrawColor(c.renderer!, 255, 125, 64, 255)
  SDL_RenderClear(c.renderer!)
  let size = Size()
  // var data: [UInt32] = Array.init(repeating: 0xFF00_0000, count: size.count)
  var data: [UInt32] = gridLine(size, 0x0412_3412)
  let pixels: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(
    capacity: size.count)
  defer { pixels.deallocate() }
  let indices = data.chunkIndices(size.height, Int32.init)
  let rect = Rectangle(Position(10, 10), Size(10, 10), 0xFFAA_BBCC)
  draw(indices, &data, rect, size)
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
    if (rect.position.x ..< rect.position.x + rect.size.height).contains(
      Int(i) / Int(windowSize.height))
    {
      print("indicies \(Int(i)): \(Int(i)/Int(windowSize.height)) ")
      for j in (rect.position.y ..< rect.position.y + rect.size.width) {
        data[Int(i) + j] = rect.color
      }
    }
  }
}

let context = initWindow()
defer { destroySetup(with: context) }
var loopCount = 0
var isRunning = context.valid
while isRunning {
  loopCount += 1
  // print("lc: \(loopCount)")
  isRunning = processInput()
  update()
  render(context)
}
