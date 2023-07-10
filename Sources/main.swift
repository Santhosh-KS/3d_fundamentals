import CSDL2
import Foundation

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |> : ForwardApplication

func |> <A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
  f(a)
}

func createWindow() -> OpaquePointer {
  guard
    let window: OpaquePointer = SDL_CreateWindow(
      nil, Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK), 640, 480,
      SDL_WINDOW_BORDERLESS.rawValue)
  else {
    print("Failed to create the Window")
    fatalError()
  }
  return window
}

func createRenderrer(_ window: OpaquePointer) -> OpaquePointer {
  guard let renderrer = SDL_CreateRenderer(window, -1, 0) else {
    print("Failed to create Renderer")
    fatalError()
  }
  return renderrer
}

struct Context {
  let Valid: Bool
  let renderer: OpaquePointer?
}

extension Context {
  init(_ valid: Bool, _ renderer: OpaquePointer?) {
    self.Valid = valid
    self.renderer = renderer
  }
}

func initialize_window() -> Context {
  if SDL_Init(SDL_INIT_VIDEO) != 0 {
    print("Failed to initial SDL")
    fatalError()
    return Context(false, nil)
  }
  let renderer = createWindow() |> createRenderrer
  return Context(true, renderer.self)
}

func setup() {}
func update() {}

struct RGBA {
  let R: UInt8
  let G: UInt8
  let B: UInt8
  let A: UInt8
}

func render(_ renderer: OpaquePointer) {
  SDL_SetRenderDrawColor(renderer, 255, 125, 64, 255)
  SDL_RenderClear(renderer)
  SDL_RenderPresent(renderer)
}

func processInput() -> Bool {
  var event = SDL_Event()
  SDL_PollEvent(&event)
  switch event.type {
  case SDL_QUIT.rawValue:
    return false
  case SDL_KEYDOWN.rawValue:
    print("KeyDown \(SDL_KEYDOWN.rawValue)")
    print("KeyDown \(SDLK_ESCAPE.rawValue)")
    return event.key.keysym.mod == SDLK_ESCAPE.rawValue ? true : false 
  default:
    return true
  }
}

let context = initialize_window()
var isRunning = context.Valid
while isRunning {
  isRunning = processInput()
  update()
  render(context.renderer!)
//  sleep(2)
//  isRunning = false
}
