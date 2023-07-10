import CSDL2

let sdlInit = SDL_Init(SDL_INIT_VIDEO)
let window:OpaquePointer = SDL_CreateWindow("Test From Swift", 30, 30, 640, 480, SDL_WINDOW_SHOWN.rawValue)!

SDL_UpdateWindowSurface(window)
SDL_Delay(2000)

SDL_DestroyWindow(window)
