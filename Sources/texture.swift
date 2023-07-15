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
  return zip(col, indicies.dropFirst()).map { (val: UInt32, idx: Int) -> UInt32 in
    let x = idx % Int(size.height)
    let y = idx / Int(size.height)
    return ((x % boxWidth == 0) || (y % boxWidth == 0)) ? color : 0
  }
}

/* func draw(rect r: Rectangle, inside window: Size) -> [UInt32] {

  if r.size.count > window.count { return [UInt32]() }

  let a = Array.init(repeating: UInt32(0), count: window.count)
  let c = a.chunks(a.count / Int(window.height))
  return zip(c, c.indices).map { (val: [UInt32], index: Int) -> [UInt32] in
    var val = val
    if (Int(r.position.y)..<Int(r.size.height)).contains(index) {
      val.replaceSubrange(
        Int(r.position.x)..<Int(r.size.width),
        with: r.draw())
    }
    val = val.count > window.width ? val.dropLast(val.count - Int(window.width)) : val
    return val
  }.reduce([], +)
} */

func draw(rectangle r: Rectangle, pixels p: inout [Uint32]) {
  for i in 0..<r.size.width {
    for j in 0..<r.size.height {
      let currentX = r.position.x + i
      let currentY = r.position.y + j
      let v = Int((r.size.width * currentY) + currentX)
      p[v] = r.color
    }
  }
  /* void draw_grid(void) {
    for (int y = 0; y < window_height; y += 10) {
        for (int x = 0; x < window_width; x += 10) {
            color_buffer[(window_width * y) + x] = 0xFF444444;
        }
    }
} */
}

func render_color_buffer(
  _ renderer: OpaquePointer,
  _ texture: OpaquePointer,
  _ col: UInt32
) {

  let size = Size()
  let rawCol: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: size.count)
  defer { rawCol.deallocate() }
  var color: [UInt32] = Array.init(repeating: 0xFF00_0000, count: size.count)
  draw(rectangle: Rectangle.template, pixels: &color)
  // var color: [UInt32] = gridLine(size, col)
  // let color1: [UInt32] = gridLine(size, col)
  // var color: [UInt32] = zip(color1, color2).map { $1 ^ $0}
  rawCol.initialize(from: &color, count: size.count)
  // let rect = Rectangle.template

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
