/*
 * $Id: LetterRender.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.LetterRender;

version (USE_GLES) {
  import opengles;
} else {
  import opengl;
}
import abagames.a7xpg.A7xScreen;

/**
 * Letters renderer.
 */
public class LetterRender {
 private:
  static const int boxNumVertices = 4;
  static GLfloat[3*boxNumVertices][][42] letterVertices;
  static GLfloat[4*boxNumVertices][2] boxColors = [
    [1, 1, 1, 0.5,
     1, 1, 1, 0.5,
     1, 1, 1, 0.5,
     1, 1, 1, 0.5
    ],
    [1, 1, 1, 1  ,
     1, 1, 1, 1  ,
     1, 1, 1, 1  ,
     1, 1, 1, 1
    ]
  ];

  private static void drawLetter(int n, float x, float y, float s) {
    glPushMatrix();
    glTranslatef(x, y, 0);
    glScalef(s, s, s);
    drawLetter(n);
    glPopMatrix();
  }

  private static void drawLetterReverse(int n, float x, float y, float s) {
    glPushMatrix();
    glTranslatef(x, y, 0);
    glScalef(s, -s, s);
    drawLetter(n);
    glPopMatrix();
  }

  public static void drawString(string str, float lx, float y, float s) {
    float x = lx;
    int c;
    int idx;
    for (int i = 0; i < str.length; i++) {
      c = str[i];
      if (c != ' ') {
	if (c >= '0' && c <='9') {
	  idx = c - '0';
	} else if (c >= 'A' && c <= 'Z') {
	  idx = c - 'A' + 10;
	} else if (c >= 'a' && c <= 'z') {
	  idx = c - 'a' + 10;
	} else if (c == '.') {
	  idx = 36;
	} else if (c == '-') {
	  idx = 38;
	} else if (c == '+') {
	  idx = 39;
	} else {
	  idx = 37;
	}
	drawLetter(idx, x, y, s);
      }
      x += s * 1.7f;
    }
  }

  public static void drawNum(int num, float lx ,float y, float s) {
    int n = num;
    float x = lx;
    for (;;) {
      drawLetter(n % 10, x, y, s);
      x -= s * 1.7f;
      n /= 10;
      if (n <= 0) break;
    }
  }

  public static void drawNumReverse(int num, float lx ,float y, float s) {
    int n = num;
    float x = lx;
    for (;;) {
      drawLetterReverse(n % 10, x, y, s);
      x -= s * 1.7f;
      n /= 10;
      if (n <= 0) break;
    }
  }

  public static void drawTime(int time, float lx ,float y, float s) {
    int n = time;
    float x = lx;
    for (int i = 0; i < 7; i++) {
      if (i != 4) {
	drawLetter(n % 10, x, y, s);
	n /= 10;
      } else {
	drawLetter(n % 6, x, y, s);
	n /= 6;
      }
      if ((i & 1) == 1 || i == 0) {
	switch (i) {
	case 3:
	  drawLetter(41, x + s * 1.16f, y, s);
	  break;
	case 5:
	  drawLetter(40, x + s * 1.16f, y, s);
	  break;
	default:
	  break;
	}
	x -= s * 1.7f;
      } else {
	x -= s * 2.2f;
      }
      if (n <= 0) break;
    }
  }

  private static void prepareBox(int idx, float x, float y, float width, float height) {
    ++letterVertices[idx].length;
    letterVertices[idx][letterVertices[idx].length - 1] = [
      x - width, y - height, 0,
      x + width, y - height, 0,
      x + width, y + height, 0,
      x - width, y + height, 0
    ];
  }

  private static void prepareLetter(int idx) {
    int i;
    float x, y, length, size, t;
    int deg;
    for ( i=0 ; ; i++ ) {
      deg = cast(int) spData[idx][i][4];
      if (deg > 99990) break;
      x = -spData[idx][i][0];
      y = -spData[idx][i][1];
      size = spData[idx][i][2];
      length = spData[idx][i][3];
      size *= 0.66f;
      length *= 0.6f;
      x = -x;
      y = y;
      deg %= 180;
      if (deg <= 45 || deg > 135)
	prepareBox(idx, x, y, size, length);
      else
	prepareBox(idx, x, y, length, size);
    }
  }

  private static void drawLetter(int idx) {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    foreach (i; 0..letterVertices[idx].length) {
      glVertexPointer(3, GL_FLOAT, 0, cast(void *)(letterVertices[idx][i].ptr));

      glColorPointer(4, GL_FLOAT, 0, cast(void *)(boxColors[0].ptr));
      glDrawArrays(GL_TRIANGLE_FAN, 0, boxNumVertices);
      glColorPointer(4, GL_FLOAT, 0, cast(void *)(boxColors[1].ptr));
      glDrawArrays(GL_LINE_LOOP, 0, boxNumVertices);
    }

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }

  public static void prepareLetters() {
    foreach (l; 0..42) {
        prepareLetter(l);
    }

    foreach (j; 0..2) {
      foreach (i; 0..boxNumVertices) {
        boxColors[j][i*4 + 0] *= A7xScreen.brightness;
        boxColors[j][i*4 + 1] *= A7xScreen.brightness;
        boxColors[j][i*4 + 2] *= A7xScreen.brightness;
      }
    }
  }

  private static float[5][16][] spData =
    [[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.6f, 0.55f, 0.65f, 0.3f, 90], [0.6f, 0.55f, 0.65f, 0.3f, 90],
     [-0.6f, -0.55f, 0.65f, 0.3f, 90], [0.6f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     //A
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.1f, 1.15f, 0.45f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.45f, 0.55f, 0.65f, 0.3f, 90],
     [-0.1f, 0, 0.45f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.1f, 1.15f, 0.45f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.45f, 0.4f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[// F
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0.25f, 0, 0.25f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.75f, 0.25f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[//K
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.45f, 0.55f, 0.65f, 0.3f, 90],
     [-0.1f, 0, 0.45f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.3f, 1.15f, 0.25f, 0.3f, 0], [0.3f, 1.15f, 0.25f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[//P
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0.2f, -0.6f, 0.45f, 0.3f, 360-300],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.1f, 0, 0.45f, 0.3f, 0],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.45f, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [-0.65f, 0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0.65f, 0.3f, 0],
     [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.4f, 1.15f, 0.45f, 0.3f, 0], [0.4f, 1.15f, 0.45f, 0.3f, 0],
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[//U
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.5f, -0.55f, 0.65f, 0.3f, 90], [0.5f, -0.55f, 0.65f, 0.3f, 90],
     [0, -1.15f, 0.45f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.65f, 0.55f, 0.65f, 0.3f, 90], [0.65f, 0.55f, 0.65f, 0.3f, 90],
     [-0.65f, -0.55f, 0.65f, 0.3f, 90], [0.65f, -0.55f, 0.65f, 0.3f, 90],
     [-0.3f, -1.15f, 0.25f, 0.3f, 0], [0.3f, -1.15f, 0.25f, 0.3f, 0],
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.4f, 0.6f, 0.85f, 0.3f, 360-120],
     [0.4f, 0.6f, 0.85f, 0.3f, 360-60],
     [-0.4f, -0.6f, 0.85f, 0.3f, 360-240],
     [0.4f, -0.6f, 0.85f, 0.3f, 360-300],
     [0, 0, 0, 0, 99999],
    ],[
     [-0.4f, 0.6f, 0.85f, 0.3f, 360-120],
     [0.4f, 0.6f, 0.85f, 0.3f, 360-60],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[
     [0, 1.15f, 0.65f, 0.3f, 0],
     [0.35f, 0.5f, 0.65f, 0.3f, 360-60],
     [-0.35f, -0.5f, 0.65f, 0.3f, 360-240],
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[// .
     [0, -1.15f, 0.05f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[// _
     [0, -1.15f, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[// -
     [0, 0, 0.65f, 0.3f, 0],
     [0, 0, 0, 0, 99999],
    ],[//+
     [-0.4f, 0, 0.45f, 0.3f, 0], [0.4f, 0, 0.45f, 0.3f, 0],
     [0, 0.55f, 0.65f, 0.3f, 90],
     [0, -0.55f, 0.65f, 0.3f, 90],
     [0, 0, 0, 0, 99999],
    ],[//'
     [0, 1.0f, 0.4f, 0.2f, 90],
     [0, 0, 0, 0, 99999],
    ],[//''
     [-0.19f, 1.0f, 0.4f, 0.2f, 90],
     [0.2f, 1.0f, 0.4f, 0.2f, 90],
     [0, 0, 0, 0, 99999],
    ]];
}
