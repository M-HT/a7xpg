/*
 * $Id: Texture.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.Texture;

import string;
import opengl;
import SDL;
import abagames.util.sdl.SDLInitFailedException;

/**
 * Manage OpenGL textures;
 */
public class Texture {
 public:
  static char[] imagesDir = "images/";

 private:
  GLuint num;

  public this(char[] name) {
    char[] fileName = imagesDir ~ name;
    SDL_Surface *surface;    
    surface = SDL_LoadBMP(string.toStringz(fileName));
    if (!surface) {
      throw new SDLInitFailedException("Unable to load: " ~ fileName);
    }
    glGenTextures(1, &num);
    glBindTexture(GL_TEXTURE_2D, num);
    glTexImage2D(GL_TEXTURE_2D, 0, 3, surface.w, surface.h, 0,
		 GL_RGB, GL_UNSIGNED_BYTE, surface.pixels);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    /*gluBuild2DMipmaps(GL_TEXTURE_2D, 3, surface.w, surface.h, 
      GL_RGB, GL_UNSIGNED_BYTE, surface.pixels);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);*/
  }

  public void deleteTexture() {
    glDeleteTextures(1, &num);
  }

  public void bind() {
    glBindTexture(GL_TEXTURE_2D, num);
  }
}
