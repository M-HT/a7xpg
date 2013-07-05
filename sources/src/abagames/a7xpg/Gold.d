/*
 * $Id: Gold.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Gold;

import std.math;
version (USE_GLES) {
  import opengles;
} else {
  import opengl;
}
import abagames.util.Vector;
import abagames.util.Rand;
import abagames.util.Actor;
import abagames.a7xpg.LuminousActor;
import abagames.a7xpg.Ship;
import abagames.a7xpg.Field;
import abagames.a7xpg.A7xGameManager;
import abagames.a7xpg.A7xScreen;

/**
 * Gold items.
 */
public class Gold: LuminousActor {
 public:
  static const float SIZE = 1;
 private:
  Ship ship;
  Field field;
  Rand rand;
  A7xGameManager manager;
  Vector pos;
  int cnt;
  static const float ROLL_DEG = 1.0;
  static const int goldNumVertices = 5;
  static const int goldLineNumVertices = 5;
  static const GLfloat[3*goldNumVertices] goldVertices = [
     0,  0,  1,
     1,  0,  0,
     0,  1,  0,
    -1,  0,  0,
     0, -1,  0
  ];
  static GLfloat[4*goldNumVertices] goldColors = [
    1  , 1  , 0.3, 0.9,
    0.2, 0.5, 0.4, 0.8,
    0.2, 0.5, 0.4, 0.8,
    0.2, 0.5, 0.4, 0.8,
    0.2, 0.5, 0.4, 0.8
  ];
  static const GLfloat[3*goldLineNumVertices] goldLineVertices = [
     1,  0,  0,
     0,  1,  0,
    -1,  0,  0,
     0, -1,  0,
     1,  0,  0
  ];
  static GLfloat[4*goldLineNumVertices] goldLineColors = [
    1, 1, 0.3, 0.9,
    1, 1, 0.3, 0.9,
    1, 1, 0.3, 0.9,
    1, 1, 0.3, 0.9,
    1, 1, 0.3, 0.9
  ];

  public override Actor newActor() {
    return new Gold;
  }

  public override void init(ActorInitializer ini) {
    GoldInitializer gi = cast(GoldInitializer) ini;
    ship = gi.ship;
    field = gi.field;
    rand = gi.rand;
    manager = gi.manager;
    pos = new Vector;
  }

  public void set() {
    for (int i = 0; i < 8 ; i++) {
      pos.x = rand.nextFloat((field.size.x - SIZE) * 2) - field.size.x + SIZE;
      pos.y = rand.nextFloat((field.size.y - SIZE) * 2) - field.size.y + SIZE;
      if (pos.dist(ship.pos) > 8)
	break;
      if (i == 7) {
	pos.x = 0;
	pos.y = -field.size.y / 2;
      }
    }
    cnt = 0;
    isExist = true;
  }

  public override void move() {
    cnt++;
    if (ship.checkHit(pos.x, pos.y - SIZE, pos.x, pos.y + SIZE) ||
    	ship.checkHit(pos.x - SIZE, pos.y, pos.x + SIZE, pos.y)) {
      isExist = false;
      for (int i = 0; i < 16; i++) {
	manager.addParticle(pos, rand.nextFloat(std.math.PI * 2), 0.5, 0,5, 0.8, 0);
      }
      manager.getGold();
    }
  }

  public override void draw() {
    glPushMatrix();
    glTranslatef(pos.x, pos.y, 0.5);
    glRotatef(ROLL_DEG * cnt, 0, 0, 1);
    drawGold();
    drawGoldLine();
    glTranslatef(0, 0, -0.5);
    glScalef(1, 1, -1);
    drawGold();
    glPopMatrix();
  }

  public override void drawLuminous() {
    glPushMatrix();
    glTranslatef(pos.x, pos.y, 0.5);
    glRotatef(ROLL_DEG * cnt, 0, 0, 1);
    drawGoldLine();
    glPopMatrix();
  }

  public static void prepareColors() {
    foreach (i; 0..goldNumVertices) {
      goldColors[i*4 + 0] *= A7xScreen.brightness;
      goldColors[i*4 + 1] *= A7xScreen.brightness;
      goldColors[i*4 + 2] *= A7xScreen.brightness;
    }

    foreach (i; 0..goldLineNumVertices) {
      goldLineColors[i*4 + 0] *= A7xScreen.brightness;
      goldLineColors[i*4 + 1] *= A7xScreen.brightness;
      goldLineColors[i*4 + 2] *= A7xScreen.brightness;
    }
  }

  public static void drawGold() {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(goldVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(goldColors.ptr));
    glDrawArrays(GL_TRIANGLE_FAN, 0, goldNumVertices);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }

  public static void drawGoldLine() {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(goldLineVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(goldLineColors.ptr));
    glDrawArrays(GL_LINE_STRIP, 0, goldLineNumVertices);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }
}

public class GoldInitializer: ActorInitializer {
 public:
  Ship ship;
  Field field;
  Rand rand;
  A7xGameManager manager;

  public this(Ship ship, Field field, Rand rand, A7xGameManager manager) {
    this.ship = ship;
    this.field = field;
    this.rand = rand;
    this.manager = manager;
  }
}
