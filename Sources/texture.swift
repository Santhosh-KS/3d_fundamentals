import CSDL2

public struct Texture {
  let create: (OpaquePointer) -> OpaquePointer
  let destroy: (OpaquePointer) -> Void
}

public let defaultTexture = Texture(create: createTexture, destroy: destroyTexture)

func destroyTexture(_ texture: OpaquePointer) {
  SDL_DestroyTexture(texture)
}

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

func grid(_ size: Size, _ color: UInt32) -> [UInt32] {
  let s = Int(size.width * size.height)
  let col: [UInt32] = Array.init(repeating: color, count: s)
  /* for y in 0..<Int(size.height) {
    for x in 0..<Int(size.width) {
        col[(Int(size.width) * y) + x] = 0xFF0000AA 
    }
  } */
  return zip(col, col.indices).map { ($1 % 10 == 0)  ? $0 : 0 }
}

func render_color_buffer(
  _ renderer: OpaquePointer,
  _ texture: OpaquePointer,
  _ col: UInt32
) {

  let size = Size()
  let s = Int(Size().width * Size().height)
  let rawCol: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: s)
  defer { rawCol.deallocate() }
  //var color: [UInt32] = Array.init(repeating: col, count: size)
  var color: [UInt32] = grid(size, col)
  rawCol.initialize(from: &color, count: s)

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
