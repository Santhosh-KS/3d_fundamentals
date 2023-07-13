import CSDL2

struct RGBA {
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
}

func ErrorMessage() -> String {
  String.init(cString: SDL_GetError()!)
}

struct Texture {
  let create: (OpaquePointer) -> OpaquePointer
}

let defaultTexture = Texture(create: createTexture)

func createTexture(_ renderer: OpaquePointer) -> OpaquePointer {
  let s = Size()
  guard
    let texture = SDL_CreateTexture(
      renderer,
      SDL_PIXELFORMAT_ABGR8888.rawValue,
      Int32(SDL_TEXTUREACCESS_STREAMING.rawValue),
      Int32(s.width),
      Int32(s.height)
    )
  else {
    print("Failed to create Texture: \(ErrorMessage())")
    fatalError()
  }
  return texture
}

func render_color_buffer(
  _ renderer: OpaquePointer,
  _ texture: OpaquePointer,
  _ col: UnsafeMutablePointer<UInt32>
) {
  var ret = SDL_UpdateTexture(
    texture,
    nil,
    col,
    Int32(Int(Size().width) * MemoryLayout<Uint32>.stride)
  )
  if ret != 0 {
    print("Texture failed: \(ErrorMessage())")
    return
  }
  ret = SDL_RenderCopy(renderer, texture, nil, nil)
  if ret != 0 {
    print("Texture RenderCopy failed: \(ErrorMessage())")
  }
}

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
    defaultRenderer.destroy(context.renderer!)
    defaultWindow.destroy(context.window!)
  }
  SDL_Quit()
}

func initialize_window() -> Context {
  if SDL_Init(SDL_INIT_VIDEO) != 0 {
    print("Failed to initial SDL: \(ErrorMessage())")
    return Context(false, nil, nil, nil)
  }
  let window = defaultWindow.create()
  let renderer = defaultRenderer.render(window)
  let texture = defaultTexture.create(renderer)
  return Context(true, window.self, renderer.self, texture)
}

func setup() {}
func update() {}

func render(_ c: Context) {
  SDL_SetRenderDrawColor(c.renderer!, 255, 125, 64, 255)
  SDL_RenderClear(c.renderer!)
  let size = Int(Size().width * Size().height)
  let rawCol: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: size)
  defer { rawCol.deallocate() }
  var color:[UInt32] = Array.init(repeating: 0x00FFFF00, count: size) 
  rawCol.initialize(from: &color, count: size)
  render_color_buffer(c.renderer!, c.texture!,  rawCol)
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

let context = initialize_window()
defer { destroySetup(with: context) }
var loopCount = 0;
var isRunning = context.valid
while isRunning {
  loopCount += 1
  // print("lc: \(loopCount)")
  isRunning = processInput()
  update()
  render(context)
}
