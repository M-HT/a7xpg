/*
 * $Id: Screen3D.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.Screen3D;

import string;
import c.stdlib;
import SDL;
import opengl;
import abagames.util.Logger;
import abagames.util.sdl.Screen;
import abagames.util.sdl.SDLInitFailedException;

/**
 * SDL screen handler(3D, OpenGL).
 */
public class Screen3D: Screen {
 public:
  static int width = 640;
  static int height = 480;
  bool lowres = false;
  bool windowMode = false;
  float nearPlane = 0.1;
  float farPlane = 1000;

 private:

  protected abstract void init();
  protected abstract void close();

  public void initSDL() {
    if (lowres) {
      width /= 2;
      height /= 2;
    }
    // Initialize SDL.
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
      throw new SDLInitFailedException(
	"Unable to initialize SDL: " ~ string.toString(SDL_GetError()));
    }
    // Create an OpenGL screen.
    Uint32 videoFlags;
    if (windowMode) {
      videoFlags = SDL_OPENGL | SDL_RESIZABLE;
    } else {
      videoFlags = SDL_OPENGL | SDL_FULLSCREEN;
    } 
    if (SDL_SetVideoMode(width, height, 0, videoFlags) == null) {
      throw new SDLInitFailedException
	("Unable to create SDL screen: " ~ string.toString(SDL_GetError()));
    }
    glViewport(0, 0, width, height);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    resized(width, height);
    SDL_ShowCursor(SDL_DISABLE);
    init();
  }

  // Reset viewport when the screen is resized.

  public void screenResized() {
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //gluPerspective(45.0f, (GLfloat)width/(GLfloat)height, nearPlane, farPlane);
    glFrustum(-nearPlane,
	      nearPlane,
	      -nearPlane * (GLfloat)height / (GLfloat)width,
	      nearPlane * (GLfloat)height / (GLfloat)width,
	      0.1f, farPlane);
    glMatrixMode(GL_MODELVIEW);
  }

  public void resized(int width, int height) {
    this.width = width; this.height = height;
    screenResized();
  }

  public void closeSDL() {
    close();
    SDL_ShowCursor(SDL_ENABLE);
  }

  public void flip() {
    handleError();
    SDL_GL_SwapBuffers();
  }

  public void clear() {
    glClear(GL_COLOR_BUFFER_BIT);
  }

  public void handleError() {
    GLenum error = glGetError();
    if (error == GL_NO_ERROR) return;
    Logger.error("OpenGL error");
    closeSDL();
    exit(EXIT_FAILURE);
  }

  protected void setCaption(char[] name) {
    SDL_WM_SetCaption(string.toStringz(name), null);
  }
}
