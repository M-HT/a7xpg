/*
 * $Id: A7xScreen.d,v 1.3 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xScreen;

import std.c.string;
version (USE_GLES) {
  import opengles;
  import opengles_fbo;
  alias glOrthof glOrtho;
} else {
  import opengl;
}
import abagames.util.sdl.Screen3D;

/**
 * Initialize an OpenGL and set the caption.
 */
public class A7xScreen: Screen3D {
 public:
  static const char[] CAPTION = "A7Xpg";
  static float brightness = 1;
  static float luminous = 0.5;

  protected override void init() {
    setCaption(CAPTION);

    glLineWidth(1);
    glEnable(GL_LINE_SMOOTH);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnable(GL_BLEND);
    glDisable(GL_LIGHTING);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_COLOR_MATERIAL);
  }

  protected override void close() {
    glDeleteTextures(1, &luminousTexture);
    version (USE_GLES) {
      glDeleteFramebuffersOES(1, &luminousFramebuffer);
    }
  }

  // Draw the luminous effect texture.
 private:
  GLuint luminousTexture;
  const int LUMINOUS_TEXTURE_WIDTH_MAX = 128;
  const int LUMINOUS_TEXTURE_HEIGHT_MAX = 128;
  GLuint td[LUMINOUS_TEXTURE_WIDTH_MAX * LUMINOUS_TEXTURE_HEIGHT_MAX * 4 * uint.sizeof];
  int luminousTextureWidth = 128, luminousTextureHeight = 128;
  version (USE_GLES) {
    GLuint luminousFramebuffer;
  }

  public void makeLuminousTexture() {
    uint *data = td.ptr;
    int i;
    memset(data, 0, luminousTextureWidth * luminousTextureHeight * 4 * uint.sizeof);
    glGenTextures(1, &luminousTexture);
    glBindTexture(GL_TEXTURE_2D, luminousTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, luminousTextureWidth, luminousTextureHeight, 0,
		 GL_RGBA, GL_UNSIGNED_BYTE, data);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    version (USE_GLES) {
      glGenFramebuffersOES(1, &luminousFramebuffer);
      glBindFramebufferOES(GL_FRAMEBUFFER_OES, luminousFramebuffer);
      glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, luminousTexture, 0);
      glClear(GL_COLOR_BUFFER_BIT);
      glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    }
  }

  public void startRenderToTexture() {
    version (USE_GLES) {
      glBindFramebufferOES(GL_FRAMEBUFFER_OES, luminousFramebuffer);
      glClear(GL_COLOR_BUFFER_BIT);
    }
    glViewport(0, 0, luminousTextureWidth, luminousTextureHeight);
  }

  public void endRenderToTexture() {
    version (USE_GLES) {
      glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    } else {
      glBindTexture(GL_TEXTURE_2D, luminousTexture);
      glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
		       0, 0, luminousTextureWidth, luminousTextureHeight, 0);
    }
    glViewport(startx, starty, width, height);
  }

  public void viewOrtho() {
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0, width, height, 0, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
  }

  public void viewOrthoFixed() {
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0, 640, 480, 0, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
  }

  public void viewPerspective() {
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
  }

  private int lmOfs[5][2] = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]];
  private const float lmOfsBs = 5;

  public void drawLuminous() {
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, luminousTexture);
    viewOrtho();
    glColor4f(1, 0.8, 0.9, luminous);
    {
      static const GLfloat[2*4] luminousTexCoords = [
        0, 1,
        0, 0,
        1, 0,
        1, 1
      ];
      GLfloat[2*4] luminousVertices;

      glEnableClientState(GL_VERTEX_ARRAY);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);

      glVertexPointer(2, GL_FLOAT, 0, cast(void *)(luminousVertices.ptr));
      glTexCoordPointer(2, GL_FLOAT, 0, cast(void *)(luminousTexCoords.ptr));

      foreach (i; 0..5) {
        luminousVertices[0] = 0 + lmOfs[i][0] * lmOfsBs;
        luminousVertices[1] = 0 + lmOfs[i][1] * lmOfsBs;

        luminousVertices[2] = 0 + lmOfs[i][0] * lmOfsBs;
        luminousVertices[3] = height + lmOfs[i][1] * lmOfsBs;

        luminousVertices[4] = width + lmOfs[i][0] * lmOfsBs;
        luminousVertices[5] = height + lmOfs[i][0] * lmOfsBs;

        luminousVertices[6] = width + lmOfs[i][0] * lmOfsBs;
        luminousVertices[7] = 0 + lmOfs[i][0] * lmOfsBs;

        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
      }

      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      glDisableClientState(GL_VERTEX_ARRAY);
    }
    viewPerspective();
    glDisable(GL_TEXTURE_2D);
  }

  public static void drawBoxSolid(float x, float y, float width, float height) {
    const int numBoxVertices = 4;
    GLfloat[3*numBoxVertices] boxVertices = [
      0, 0, 0,
      width, 0, 0,
      width, height, 0,
      0, height, 0
    ];

    glPushMatrix();
    glTranslatef(x, y, 0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(boxVertices.ptr));
    glDrawArrays(GL_TRIANGLE_FAN, 0, numBoxVertices);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
  }

  public static void drawBoxLine(float x, float y, float width, float height) {
    const int numBoxVertices = 4;
    GLfloat[3*numBoxVertices] boxVertices = [
      0, 0, 0,
      width, 0, 0,
      width, height, 0,
      0, height, 0
    ];

    glPushMatrix();
    glTranslatef(x, y, 0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(boxVertices.ptr));
    glDrawArrays(GL_LINE_LOOP, 0, numBoxVertices);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
  }

  public static void setColor(float r, float g, float b, float a) {
    glColor4f(r * brightness, g * brightness, b * brightness, a);
  }
}
