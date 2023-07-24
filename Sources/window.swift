import CSDL2

public struct Size {
  let width: Int
  let height: Int
}

extension Size {
  public init(_ w: Int = 600, _ h: Int = 600) {
    self.width = w
    self.height = h
  }
}

extension Size {
  public var count: Int { Int(self.width * self.height) }
}

public struct Position {
  let x: Int
  let y: Int
}

extension Position {
  public init(
    _ x: UInt32 = SDL_WINDOWPOS_CENTERED_MASK,
    _ y: UInt32 = SDL_WINDOWPOS_CENTERED_MASK
  ) {
    self.x = Int(x)
    self.y = Int(y)
  }
}

private var windowPtr: OpaquePointer?

public struct Window {
  let title: String
  let position: Position
  let size: Size
  let type: UInt32  // TODO: generate enums for window type SDL_WINDOW_BORDERLESS type
}

extension Window {
  public init(
    _ title: String = "",
    _ position: Position = Position(),
    _ size: Size = Size(),
    _ type: UInt32 = SDL_WINDOW_BORDERLESS.rawValue
  ) {
    self.title = title
    self.position = position
    self.size = size
    self.type = type
  }
}

/* public extension Window {
  var view: OpaquePointer {
    get { windowPtr! }
    set { windowPtr = newValue }
  }
} */

extension Window {
  public func create() -> OpaquePointer {
    guard
      let window: OpaquePointer = SDL_CreateWindow(
        self.title, Int32(self.position.x), Int32(self.position.y),
        Int32(self.size.width), Int32(self.size.height), self.type)
    else {
      print("Failed to create the Window: \(errorMessage())")
      fatalError()
    }
    return window
  }

  /* func destroy() {
    SDL_DestroyWindow(self.view)
  } */
}

/* Create a window with the specified position, dimensions, and flags.

- Parameters:
    - title:  the title of the window, in UTF-8 encoding
    - x:  the x position of the window, `SDL_WINDOWPOS_CENTERED`, or          `SDL_WINDOWPOS_UNDEFINED`
    - y:  the y position of the window, `SDL_WINDOWPOS_CENTERED`, or          `SDL_WINDOWPOS_UNDEFINED`
    - w:  the width of the window, in screen coordinates
    - h:  the height of the window, in screen coordinates
    - flags:  0, or one or more SDL_WindowFlags OR'd together  */
public func getCurrentDisplayMode() -> Size {
  var mode = SDL_DisplayMode()
  SDL_GetCurrentDisplayMode(0, &mode)
  return Size.init(Int(mode.w), Int(mode.h))
}

func createWindow(_ size: Size) -> OpaquePointer {
  let w = Window()
  guard
    let window: OpaquePointer = SDL_CreateWindow(
      w.title, Int32(w.position.x), Int32(w.position.y),
      Int32(w.size.width), Int32(w.size.height),
      w.type
    )
  else {
    print("Failed to create the Window: \(errorMessage())")
    fatalError()
  }
  // SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN.rawValue)
  return window
}

func destroyWindow(_ window: OpaquePointer) {
  SDL_DestroyWindow(window)
}

public struct NewWindow {
  let create: (Size) -> OpaquePointer
  let destroy: (OpaquePointer) -> Void
}

public let defaultWindow = NewWindow(
  create: createWindow, destroy: destroyWindow)
