/*
 * $Id: Input.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.Input;

import std.string;
import std.conv;
import SDL;
import abagames.util.sdl.SDLInitFailedException;

/**
 * Joystick and keyboard input.
 */
public class Input {
 public:
  static const int PAD_UP = 1;
  static const int PAD_DOWN = 2;
  static const int PAD_LEFT = 4;
  static const int PAD_RIGHT = 8;
  static const int PAD_BUTTON1 = 16;
  static const int PAD_BUTTON2 = 32;
  Uint8 *keys;
  bool buttonReversed = false;

 private:
  SDL_Joystick *stick = null;
  const int JOYSTICK_AXIS = 16384;

  public void openJoystick() {
    if (SDL_InitSubSystem(SDL_INIT_JOYSTICK) < 0) {
      throw new SDLInitFailedException(
	"Unable to init SDL joystick: " ~ to!string(SDL_GetError()));
    }
    version (PANDORA) {
    } else {
      stick = SDL_JoystickOpen(0);
    }
  }

  public void handleEvent(SDL_Event *event) {
    keys = SDL_GetKeyState(null);
  }

  // Joystick and keyboard handler.

  public int getPadState() {
    int x = 0, y = 0;
    int pad = 0;
    if (stick) {
      x = SDL_JoystickGetAxis(stick, 0);
      y = SDL_JoystickGetAxis(stick, 1);
    }
    if (keys[SDLK_RIGHT] == SDL_PRESSED || keys[SDLK_KP6] == SDL_PRESSED || x > JOYSTICK_AXIS) {
      pad |= PAD_RIGHT;
    }
    if (keys[SDLK_LEFT] == SDL_PRESSED || keys[SDLK_KP4] == SDL_PRESSED || x < -JOYSTICK_AXIS) {
      pad |= PAD_LEFT;
    }
    if (keys[SDLK_DOWN] == SDL_PRESSED || keys[SDLK_KP2] == SDL_PRESSED || y > JOYSTICK_AXIS) {
      pad |= PAD_DOWN;
    }
    if (keys[SDLK_UP] == SDL_PRESSED ||  keys[SDLK_KP8] == SDL_PRESSED || y < -JOYSTICK_AXIS) {
      pad |= PAD_UP;
    }
    return pad;
  }

  public int getButtonState() {
    bool btnx = false, btnz = false;
    int btn = 0;
    int btn1 = 0, btn2 = 0, btn3 = 0, btn4 = 0;
    if (stick) {
      btn1 = SDL_JoystickGetButton(stick, 0);
      btn2 = SDL_JoystickGetButton(stick, 1);
      btn3 = SDL_JoystickGetButton(stick, 2);
      btn4 = SDL_JoystickGetButton(stick, 3);
    }
    version (PANDORA) {
      if (keys[SDLK_HOME] == SDL_PRESSED || keys[SDLK_PAGEUP] == SDL_PRESSED) btnz = true;
      if (keys[SDLK_END] == SDL_PRESSED || keys[SDLK_END] == SDL_PRESSED) btnx = true;
    } else {
      if (keys[SDLK_z] == SDL_PRESSED || keys[SDLK_LCTRL] == SDL_PRESSED || btn1 || btn4) btnz = true;
      if (keys[SDLK_x] == SDL_PRESSED || keys[SDLK_LALT] == SDL_PRESSED || btn2 || btn3) btnx = true;
    }
    if (btnz) {
      if (!buttonReversed)
	btn |= PAD_BUTTON1;
      else
	btn |= PAD_BUTTON2;
    }
    if (btnx) {
      if (!buttonReversed)
	btn |= PAD_BUTTON2;
      else
	btn |= PAD_BUTTON1;
    }
    return btn;
  }
}
