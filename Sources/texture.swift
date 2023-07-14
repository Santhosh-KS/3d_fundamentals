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

func gridLine(_ size: Size, _ color: UInt32) -> [UInt32] {
  let col: [UInt32] = Array.init(repeating: 0, count: size.count)
  let boxWidth = 50
  let indicies = col.indices
  return zip(col, indicies).map { (val: UInt32, idx: Int) -> UInt32 in
    let x = idx % Int(size.width)
    let y = idx / Int(size.width)
    return ((x % boxWidth == 0) || (y % boxWidth == 0)) ? color : 0
  }
}

func render_color_buffer(
  _ renderer: OpaquePointer,
  _ texture: OpaquePointer,
  _ col: UInt32
) {

  let size = Size()
  let rawCol: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: size.count)
  defer { rawCol.deallocate() }
  //var color: [UInt32] = Array.init(repeating: col, count: size.count)
  var color: [UInt32] = gridLine(size, col)
  rawCol.initialize(from: &color, count: size.count)

  var ret = SDL_UpdateTexture(
    texture,
    nil,
    rawCol,
    Int32(Int(size.height) * MemoryLayout<Uint32>.stride)
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
