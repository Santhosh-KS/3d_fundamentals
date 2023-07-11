import CSDL2

public struct Renderer {
    let render: (OpaquePointer) -> OpaquePointer
    let destroy: (OpaquePointer) -> Void
}

public let defaultRenderer = Renderer(render:createRenderrer, destroy: destroyRenderer)

public func createRenderrer(_ window: OpaquePointer) -> OpaquePointer {
  guard let renderrer = SDL_CreateRenderer(window, -1, 0) else {
    print("Failed to create Renderer")
    fatalError()
  }
  return renderrer
}

public func destroyRenderer(_ renderer: OpaquePointer) {
  SDL_DestroyRenderer(renderer)
}

