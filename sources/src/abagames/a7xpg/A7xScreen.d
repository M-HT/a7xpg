/*
 * $Id: A7xScreen.d,v 1.3 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xScreen;

import core.stdc.string;
import opengl;
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
  }

  // Draw the luminous effect texture.
 private:
  GLuint luminousTexture;
  const int LUMINOUS_TEXTURE_WIDTH_MAX = 128;
  const int LUMINOUS_TEXTURE_HEIGHT_MAX = 128;
  GLuint[LUMINOUS_TEXTURE_WIDTH_MAX * LUMINOUS_TEXTURE_HEIGHT_MAX * 4 * uint.sizeof] td;
  int luminousTextureWidth = 128, luminousTextureHeight = 128;

  public void makeLuminousTexture() {
    uint *data = td.ptr;
    int i;
    memset(data, 0, luminousTextureWidth * luminousTextureHeight * 4 * uint.sizeof);
    glGenTextures(1, &luminousTexture);
    glBindTexture(GL_TEXTURE_2D, luminousTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, luminousTextureWidth, luminousTextureHeight, 0,
		 GL_RGBA, GL_UNSIGNED_BYTE, data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  }

  public void startRenderToTexture() {
    glViewport(0, 0, luminousTextureWidth, luminousTextureHeight);
  }

  public void endRenderToTexture() {
    glBindTexture(GL_TEXTURE_2D, luminousTexture);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
		     0, 0, luminousTextureWidth, luminousTextureHeight, 0);
    glViewport(screenStartX, screenStartY, screenWidth, screenHeight);
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

  private int[2][5] lmOfs = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]];
  private const float lmOfsBs = 5;

  public void drawLuminous() {
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, luminousTexture);
    viewOrtho();
    glColor4f(1, 0.8, 0.9, luminous);
    glBegin(GL_QUADS);
    for (int i = 0; i < 5; i++) {
      glTexCoord2f(0, 1);
      glVertex2f(0 + lmOfs[i][0] * lmOfsBs, 0 + lmOfs[i][1] * lmOfsBs);
      glTexCoord2f(0, 0);
      glVertex2f(0 + lmOfs[i][0] * lmOfsBs, height + lmOfs[i][1] * lmOfsBs);
      glTexCoord2f(1, 0);
      glVertex2f(width + lmOfs[i][0] * lmOfsBs, height + lmOfs[i][0] * lmOfsBs);
      glTexCoord2f(1, 1);
      glVertex2f(width + lmOfs[i][0] * lmOfsBs, 0 + lmOfs[i][0] * lmOfsBs);
    }
    glEnd();
    viewPerspective();
    glDisable(GL_TEXTURE_2D);
  }

  public static void drawBoxSolid(float x, float y, float width, float height) {
    glPushMatrix();
    glTranslatef(x, y, 0);
    glBegin(GL_TRIANGLE_FAN);
    glVertex3f(0, 0, 0);
    glVertex3f(width, 0, 0);
    glVertex3f(width, height, 0);
    glVertex3f(0, height, 0);
    glEnd();
    glPopMatrix();
  }

  public static void drawBoxLine(float x, float y, float width, float height) {
    glPushMatrix();
    glTranslatef(x, y, 0);
    glBegin(GL_LINE_LOOP);
    glVertex3f(0, 0, 0);
    glVertex3f(width, 0, 0);
    glVertex3f(width, height, 0);
    glVertex3f(0, height, 0);
    glEnd();
    glPopMatrix();
  }

  public static void setColor(float r, float g, float b, float a) {
    glColor4f(r * brightness, g * brightness, b * brightness, a);
  }
}
