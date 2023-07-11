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

struct Texture {
  let create: (OpaquePointer) -> OpaquePointer
}

let defaultTexture = Texture(create: createTexture)

func createTexture(_ renderer: OpaquePointer) -> OpaquePointer {
  let w = Window()
  guard
    let texture = SDL_CreateTexture(
      renderer,
      SDL_PIXELFORMAT_ABGR8888.rawValue,
      Int32(SDL_TEXTUREACCESS_STREAMING.rawValue),
      Int32(w.size.width),
      Int32(w.size.height)
    )
  else {
    print("Failed to create Texture")
    fatalError()
  }
  return texture
}

func clearColorBuffer(_ size: Size = Size()) -> [[Uint32]] {
  let c: Uint32 = 0xFFFF_FFFF
  return Array(repeating: Array(repeating: c, count: Int(size.height)), count: Int(size.width))
}

func render_color_buffer(_ texture: OpaquePointer, _ renderer: OpaquePointer) {
  var col = clearColorBuffer()
  let ret = SDL_UpdateTexture(
    texture,
    nil, &col,
    Int32(
     Int(Size().width) * MemoryLayout<[[Uint32]]>.size
    )
  )
  if ret != 0 {
    print("Texture failed")
    fatalError()
  }
  SDL_RenderCopy(renderer, texture, nil, nil)
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
    print("Failed to initial SDL")
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
  render_color_buffer(c.renderer!, c.texture!)
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

/* Create a texture for a rendering context.

- Parameters:
    - renderer:  the rendering context
    - format:  one of the enumerated values in SDL_PixelFormatEnum
    - access:  one of the enumerated values in SDL_TextureAccess
    - w:  the width of the texture in pixels
    - h:  the height of the texture in pixels
SDL_PixelFormat
SDL_PIXELFORMAT_ABGR8888
SDL_TEXTUREACCESS_STREAMING
SDL_CreateTexture(renderer: OpaquePointer!, format: Uint32, access: Int32, w: Int32, h: Int32) */

/* Update the given texture rectangle with new pixel data.

- Parameters:
    - texture:  the texture to update
    - rect:  an SDL_Rect structure representing the area to update, or NULL             to update the entire texture
    - pixels:  the raw pixel data in the format of the texture
    - pitch:  the number of bytes in a row of pixel data, including padding              between lines
SDL_UpdateTexture(texture: OpaquePointer!, rect: UnsafePointer<SDL_Rect>!, pixels: UnsafeRawPointer!, pitch: Int32) */

var isRunning = context.valid
while isRunning {
  isRunning = processInput()
  update()
  render(context)
}
