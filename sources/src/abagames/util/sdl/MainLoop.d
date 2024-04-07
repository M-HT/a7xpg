/*
 * $Id: MainLoop.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.MainLoop;

import std.string;
import core.stdc.stdlib;
import bindbc.sdl;
import abagames.util.Logger;
import abagames.util.Rand;
import abagames.util.GameManager;
import abagames.util.PrefManager;
import abagames.util.sdl.Screen;
import abagames.util.sdl.Input;
import abagames.util.sdl.Sound;
import abagames.util.sdl.SDLInitFailedException;

/**
 * SDL main loop.
 */
public class MainLoop {
 public:
  const int INTERVAL_BASE = 16;
  int interval = INTERVAL_BASE;
  int accframe = 0;
  int maxSkipFrame = 5;

 private:
  Screen screen;
  Input input;
  GameManager gameManager;
  PrefManager prefManager;

  public this(Screen screen, Input input,
	      GameManager gameManager, PrefManager prefManager) {
    this.screen = screen;
    this.input = input;
    gameManager.setMainLoop(this);
    gameManager.setUIs(screen, input);
    gameManager.setPrefManager(prefManager);
    this.gameManager = gameManager;
    this.prefManager = prefManager;
  }

  // Initialize and load preference.
  private void initFirst() {
    prefManager.load();
    try {
      Sound.init();
    } catch (SDLInitFailedException e) {
      Logger.error(e);
    }
    gameManager.init();
  }

  // Quit and save preference.
  private void quitLast() {
    gameManager.close();
    Sound.close();
    prefManager.save();
    screen.closeSDL();
    SDL_Quit();
  }

  public void loop() {
    int done = 0;
    long prvTickCount = 0;
    int i;
    long nowTick;
    int frame;
    SDL_Event event;

    try {
      screen.initSDL();
    } catch (SDLInitFailedException e) {
      Logger.error(e);
      exit(EXIT_FAILURE);
    }
    initFirst();
    gameManager.start();

    while (!done) {
      while (!done && SDL_PollEvent(&event)) {
        switch (event.type) {
          case SDL_KEYDOWN:
            if (event.key.keysym.sym == SDLK_ESCAPE) {
              done = 1;
            }
            break;
          case SDL_QUIT:
            done = 1;
            break;
          case SDL_WINDOWEVENT:
            if (event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED) {
              screen.resized(event.window.data1, event.window.data2);
            }
            break;
          default:
            break;
        }
      }
      input.handleEvents();

      nowTick = SDL_GetTicks();
      frame = cast(int) (nowTick-prvTickCount) / interval;
      if (frame <= 0) {
	frame = 1;
	SDL_Delay(cast(uint)(prvTickCount+interval-nowTick));
	if (accframe) {
	  prvTickCount = SDL_GetTicks();
	} else {
	  prvTickCount += interval;
	}
      } else if (frame > maxSkipFrame) {
	frame = maxSkipFrame;
	prvTickCount = nowTick;
      } else {
	prvTickCount += frame * interval;
      }
      for (i = 0; i < frame; i++) {
	gameManager.move();
      }
      screen.clear();
      gameManager.draw();
      screen.flip();
    }
    quitLast();
  }
}
