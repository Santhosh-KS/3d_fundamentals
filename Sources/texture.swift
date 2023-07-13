import CSDL2

public struct Texture {
  let create: (OpaquePointer) -> OpaquePointer
  // let destroy: (OpaquePointer) -> Void
}

public let defaultTexture = Texture(create: createTexture)

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
  _ col: UInt32 
) {

  let size = Int(Size().width * Size().height)
  let rawCol: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: size)
  defer { rawCol.deallocate() }
  var color: [UInt32] = Array.init(repeating: col, count: size)
  rawCol.initialize(from: &color, count: size)

  var ret = SDL_UpdateTexture(
    texture,
    nil,
    rawCol,
    Int32(Int(Size().height) * MemoryLayout<Uint32>.stride)
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
