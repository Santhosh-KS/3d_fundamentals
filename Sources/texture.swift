import CSDL2

public struct Texture {
  let create: (OpaquePointer) -> OpaquePointer
  let destroy: (OpaquePointer) -> Void
}

public let defaultTexture = Texture(
  create: createTexture, destroy: destroyTexture)

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
    print("Failed to create Texture: \(errorMessage())")
    fatalError()
  }
  return texture
}

func gridLine(_ size: Size, _ color: UInt32) -> [UInt32] {
  let col: [UInt32] = Array.init(repeating: 0, count: size.count)
  let boxWidth = 50
  let indicies = col.indices
  return zip(col, indicies.dropFirst()).map {
    (val: UInt32, idx: Int) -> UInt32 in
    let x = idx % Int(size.height)
    let y = idx / Int(size.height)
    return ((x % boxWidth == 0) || (y % boxWidth == 0)) ? color : 0
  }
}

func renderColorBuffer(
  _ renderer: OpaquePointer,
  _ texture: OpaquePointer,
  _ pixels: UnsafeMutablePointer<UInt32>
) {

  let size = Size()
  var ret = SDL_UpdateTexture(
    texture,
    nil,
    pixels,
    Int32(Int(size.height) * MemoryLayout<Uint32>.stride)
  )
  if ret != 0 {
    print("Texture failed: \(errorMessage())")
    return
  }

  ret = SDL_RenderCopy(renderer, texture, nil, nil)
  if ret != 0 {
    print("Texture RenderCopy failed: \(errorMessage())")
  }
}
