/*
 * $Id: A7xBoot.d,v 1.3 2003/09/21 04:01:26 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xBoot;

import std.c.stdlib;
import std.conv;
import std.string;
import std.stdio;
import abagames.a7xpg.A7xScreen;
import abagames.a7xpg.A7xGameManager;
import abagames.a7xpg.A7xPrefManager;
import abagames.util.Logger;
import abagames.util.sdl.Input;
import abagames.util.sdl.MainLoop;
import abagames.util.sdl.Sound;

/**
 * Boot A7Xpg.
 */
private:
A7xScreen screen;
Input input;
A7xGameManager gameManager;
A7xPrefManager prefManager;
MainLoop mainLoop;

private void usage() {
  Logger.error
    ("Usage: a7xpg [-brightness [0-100]] [-luminous [0-100]] [-nosound] [-window] [-lowres]");
}

private void parseArgs(string[] args) {
  for (int i = 1; i < args.length; i++) {
    switch (args[i]) {
    case "-brightness":
      if (i >= args.length - 1) {
	usage();
	exit(EXIT_FAILURE);
      }
      i++;
      float b = cast(float) to!int(args[i]) / 100;
      if (b < 0 || b > 1) {
	usage();
	exit(EXIT_FAILURE);
      }
      A7xScreen.brightness = b;
      break;
    case "-luminous":
      if (i >= args.length - 1) {
	usage();
	exit(EXIT_FAILURE);
      }
      i++;
      float l = cast(float) to!int(args[i]) / 100;
      if (l < 0 || l > 1) {
	usage();
	exit(EXIT_FAILURE);
      }
      A7xScreen.luminous = l;
      break;
    case "-nosound":
      Sound.noSound = true;
      break;
    case "-window":
      screen.windowMode = true;
      break;
    case "-accframe":
      mainLoop.accframe = 1;
      break;
    case "-lowres":
      screen.lowres = true;
      break;
    default:
      usage();
      exit(EXIT_FAILURE);
    }
  }
}

private int boot(string[] args) {
  screen = new A7xScreen;
  input = new Input;
  try {
    input.openJoystick();
  } catch (Exception e) {}
  gameManager = new A7xGameManager;
  prefManager = new A7xPrefManager;
  mainLoop = new MainLoop(screen, input, gameManager, prefManager);
  parseArgs(args);
  mainLoop.loop();
  return EXIT_SUCCESS;
}

version (linux) {
    public int main(string[] args) {
        return boot(args);
    }
}


version (Win32) {

// Boot as the windows executable.
import windows;

extern (C) void gc_init();
extern (C) void gc_term();
extern (C) void _minit();
extern (C) void _moduleCtor();

extern (Windows)
int WinMain(HINSTANCE hInstance,
	    HINSTANCE hPrevInstance,
	    LPSTR lpCmdLine,
	    int nCmdShow) {
  int result;

  gc_init();
  _minit();
  try {
    _moduleCtor();
    result = boot(split(to!string(lpCmdLine)));
  } catch (Object o) {
    MessageBoxA(null, cast(char *)o.toString(), "Error",
		MB_OK | MB_ICONEXCLAMATION);
    result = 0;
  }
  gc_term();
  return result;
}

}
