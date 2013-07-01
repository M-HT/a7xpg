/*
 * $Id: Ship.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Ship;

import std.math;
import opengl;
import abagames.util.Vector;
import abagames.util.Rand;
import abagames.util.sdl.Input;
import abagames.a7xpg.Field;
import abagames.a7xpg.A7xGameManager;
import abagames.a7xpg.A7xScreen;

/**
 * My ship.
 */
public class Ship {
 public:
  static const float SIZE = 1;
  Vector pos;
  bool invincible;
  bool restart;
  float speed;
  const float DEFAULT_SPEED = 0.2;
  const int RESTART_CNT = 300;
  const int INVINCIBLE_CNT = 180;
  int cnt;
 private:
  Input input;
  Field field;
  A7xGameManager manager;
  const float SPEED_UP = 0.005;
  const int BOOST_TIME = 72;
  Vector ppos;
  float deg;
  float aimSpeed;
  int boost;
  bool btnPrsd;
  bool hitWall;
  bool blow;
  float a1x, a1y, a2x, a2y, a, b, c; // For checking a collision.
  Rand rand;
  const float GAUGE_DEC = 0.2;
  const float GAUGE_MAX = 200;
  float gauge;
  int enemyDstCnt;
  static const int shipNumVertices = 4 + 6;
  static const int shipLineNumVertices = 3 + 3 + 3;
  static const int shipFireLineNumVertices = 3 + 4;
  static const GLfloat[3*shipNumVertices] shipVertices = [
     0  ,  1  , 0  ,
    -0.8, -1  , 0  ,
     0  , -0.8, 0.6,
     0.8, -1  , 0  ,

    -0.8, -1  , 0  ,
    -1.2,  0.2, 1  ,
     0  , -0.9, 0.2,
     0  , -0.9, 0.2,
     1.2,  0.2, 1  ,
     0.8, -1  , 0
  ];
  static GLfloat[4*shipNumVertices] shipColors = [
    0.3, 1  , 0.2, 0.8,
    0.2, 0.8, 0.2, 0.6,
    0.2, 0.8, 0.2, 0.4,
    0.2, 0.8, 0.2, 0.6,

    0.2, 0.5, 0.8, 0.6,
    0.2, 0.5, 0.8, 0.9,
    0.2, 0.5, 0.8, 0.4,
    0.2, 0.5, 0.8, 0.4,
    0.2, 0.5, 0.8, 0.9,
    0.2, 0.5, 0.8, 0.6
  ];
  static const GLfloat[3*shipLineNumVertices] shipLineVertices = [
    -0.8, -1  ,  0  ,
     0  ,  1  ,  0  ,
     0.8, -1  ,  0  ,

    -0.8, -1  ,  0  ,
    -1.2,  0.2,  1  ,
     0  , -0.9,  0.2,

     0  , -0.9,  0.2,
     1.2,  0.2,  1  ,
     0.8, -1  ,  0
  ];
  static GLfloat[4*shipLineNumVertices] shipLineColors = [
    0.3, 1  , 0.2, 1,
    0.3, 1  , 0.2, 1,
    0.3, 1  , 0.2, 1,

    0.2, 0.6, 0.8, 1,
    0.2, 0.6, 0.8, 1,
    0.2, 0.6, 0.8, 1,

    0.2, 0.6, 0.8, 1,
    0.2, 0.6, 0.8, 1,
    0.2, 0.6, 0.8, 1
  ];
  static const GLfloat[3*shipFireLineNumVertices] shipFireLineVertices = [
    -0.8, -1  ,  0  ,
     0  ,  1  ,  0  ,
     0.8, -1  ,  0  ,

    -0.8, -1  ,  0  ,
     0  , -0.9,  0.2,
     0  , -0.9,  0.2,
     0.8, -1  ,  0
  ];
  static GLfloat[4*shipFireLineNumVertices] shipFireLineColors = [
    1, 0, 0, 1,
    1, 0, 0, 1,
    1, 0, 0, 1,

    1, 0, 0, 1,
    1, 0, 0, 1,
    1, 0, 0, 1,
    1, 0, 0, 1
  ];

  public void init(Input input, Field field, A7xGameManager manager) {
    this.input = input;
    this.field = field;
    this.manager = manager;
    pos = new Vector;
    ppos = new Vector;
    rand = new Rand;
  }

  public void start() {
    ppos.x = pos.x = 0;
    ppos.y = pos.y = -field.size.y / 2;
    deg = 0;
    speed = aimSpeed = DEFAULT_SPEED;
    hitWall = false;
    invincible = false;
    restart = true;
    cnt = -INVINCIBLE_CNT;
    gauge = 0;
    boost = 0;
    btnPrsd = true;
    blow = false;
  }

  public void miss() {
    manager.shipDestroyed();
    start();
    cnt = -RESTART_CNT;
  }

  private const int[] ENEMY_SCORE_TABLE =
    [100, 200, 400, 800, 1600, 3200, 4850, 5730, 7650, 8560];

  public void destroyEnemy() {
    manager.addBonus(ENEMY_SCORE_TABLE[enemyDstCnt], pos, 1 + enemyDstCnt * 0.2);
    if (enemyDstCnt < ENEMY_SCORE_TABLE.length - 1)
      enemyDstCnt++;
  }

  public void startRound() {
  }

  public void addGauge() {
    if (invincible)
      gauge += (speed - DEFAULT_SPEED) * 10;
    else
      gauge += (speed - DEFAULT_SPEED) * 80;
  }

  public void move() {
    blow = false;
    cnt++;
    if (cnt < -INVINCIBLE_CNT) {
      field.addSpeed(DEFAULT_SPEED / 2);
      return;
    }
    if (cnt == 0)
      restart = false;
    field.addSpeed(speed);
    int prtNum = 0;
    float pSpeed = speed;
    if (!hitWall) {
      ppos.x = pos.x; ppos.y = pos.y;
    } else {
      ppos.x = pos.x - sin(deg) * DEFAULT_SPEED;
      ppos.y = pos.y - cos(deg) * DEFAULT_SPEED;
    }
    int pad = input.getPadState();
    if (pad & Input.PAD_UP) {
      if (pad & Input.PAD_RIGHT)
	deg = std.math.PI / 4;
      else if (pad & Input.PAD_LEFT)
	deg = std.math.PI / 4 * 7;
      else
	deg = 0;
    } else if (pad & Input.PAD_DOWN) {
      if (pad & Input.PAD_RIGHT)
	deg = std.math.PI / 4 * 3;
      else if (pad & Input.PAD_LEFT)
	deg = std.math.PI / 4 * 5;
      else
	deg = std.math.PI / 4 * 4;
    } else {
      if (pad & Input.PAD_RIGHT)
	deg = std.math.PI / 4 * 2;
      else if (pad & Input.PAD_LEFT)
	deg = std.math.PI / 4 * 6;
    }
    int btn = input.getButtonState();
    if (btn & (Input.PAD_BUTTON1 | Input.PAD_BUTTON2)) {
      if (!hitWall && boost > 0) {
	if (!btnPrsd) {
	  manager.playSe(1);
	  manager.playSe(11);
	  blow = true;
	  btnPrsd = true;
	  aimSpeed = DEFAULT_SPEED * 2;
	  prtNum += 24;
	} else {
	  boost--;
	  aimSpeed += SPEED_UP;
	  prtNum++;
	}
      } else {
	aimSpeed *= 0.96;
	if (aimSpeed < DEFAULT_SPEED)
	  aimSpeed = DEFAULT_SPEED;
      }
    } else {
      manager.stopSe(11);
      boost = BOOST_TIME;
      btnPrsd = false;
      aimSpeed *= 0.96;
      if (aimSpeed < DEFAULT_SPEED)
	aimSpeed = DEFAULT_SPEED;
      hitWall = false;
    }
    if (invincible)
      gauge -= GAUGE_DEC * 3;
    else
      gauge -= GAUGE_DEC / 5;
    if (gauge < 0) {
      gauge = 0;
      invincible = false;
    } else if (gauge > GAUGE_MAX) {
      gauge = GAUGE_MAX;
      if (!invincible) {
	manager.playSe(10);
	invincible = true;
	enemyDstCnt = 0;
	for (int i = 0; i < 50; i++) {
	  manager.addParticle(pos, rand.nextFloat(std.math.PI * 2), SIZE, rand.nextFloat(4),
			      0.9, 0.5, 0.5);
	}
      }
    }
    if (rand.nextInt(4) == 0)
      prtNum++;
    speed += (aimSpeed - speed) * 0.2;
    pos.x += sin(deg) * speed;
    pos.y += cos(deg) * speed;
    if (pos.x < -field.size.x + SIZE) {
      pos.x = -field.size.x + SIZE;
      speed = aimSpeed = DEFAULT_SPEED;
      hitWall = true;
    } else if (pos.x > field.size.x - SIZE) {
      pos.x = field.size.x - SIZE;
      speed = aimSpeed = DEFAULT_SPEED;
      hitWall = true;
    }
    if (pos.y < -field.size.y + SIZE) {
      pos.y = -field.size.y + SIZE;
      speed = aimSpeed = DEFAULT_SPEED;
      hitWall = true;
    } else if (pos.y > field.size.y - SIZE) {
      pos.y = field.size.y - SIZE;
      speed = aimSpeed = DEFAULT_SPEED;
      hitWall = true;
    }
    if (pos.x < ppos.x) {
      a1x = pos.x - SIZE; a2x = ppos.x + SIZE;
    } else {
      a1x = ppos.x - SIZE; a2x = pos.x + SIZE;
    }
    if (pos.y < ppos.y) {
      a1y = pos.y - SIZE; a2y = ppos.y + SIZE;
    } else {
      a1y = ppos.y - SIZE; a2y = pos.y + SIZE;
    }
    a = pos.y - ppos.y;
    b = ppos.x - pos.x;
    c = ppos.x * pos.y - ppos.y * pos.x;

    float ps = speed * 4;
    if (prtNum > 8)
      ps *= 2;
    for (int i = 0; i < prtNum; i++) {
      float pr, pg, pb;
      if (invincible) {
	pr = 0.3 + 0.6 * gauge / GAUGE_MAX;
	pg = 0.4;
	pb = 0.9 - 0.6 * gauge / GAUGE_MAX;
      } else {
	pr = 0.3; pg = 0.3; pb = 0.9;
      }
      manager.addParticle(pos, deg + std.math.PI + rand.nextFloat(0.5) - 0.25, SIZE, ps, pr, pg, pb);
    }
    if (hitWall && pSpeed > DEFAULT_SPEED * 1.1) {
      int pn = cast(int)(pSpeed / (DEFAULT_SPEED / 4));
      for (int i = 0; i < pn; i++) {
	manager.addParticle(pos, deg + rand.nextFloat(1.2) - 0.6, SIZE, pSpeed * 3,
			    0.8, 0.6, 0.1);
      }
    }
    if (invincible) {
      if (gauge < GAUGE_MAX / 4) {
	if ((cnt % 30) == 0)
	  manager.playSe(4);
      } else {
	if ((cnt % 40) == 0)
	  manager.playSe(3);
      }
    }
  }

  public void draw() {
    if (cnt < -INVINCIBLE_CNT || (cnt < 0 && (-cnt % 32) < 16))
      return;
    glPushMatrix();
    glTranslatef(pos.x, pos.y, 0.5);
    glRotatef(-deg * 180 / std.math.PI, 0, 0, 1);
    drawShip();
    drawShipLine();
    glTranslatef(0, 0, -0.5);
    glScalef(1, 1, -1);
    drawShip();
    glPopMatrix();
  }

  public void drawLuminous() {
    if (cnt < -INVINCIBLE_CNT || (cnt < 0 && (-cnt % 32) < 16))
      return;
    glPushMatrix();
    glTranslatef(pos.x, pos.y, 0.5);
    glRotatef(-deg * 180 / std.math.PI, 0, 0, 1);
    if (invincible)
      drawShipFireLine();
    else
      drawShipLine();
    glPopMatrix();
  }

  public void drawGauge() {
    if (invincible) {
      if ((cnt % 2) == 1)
	A7xScreen.setColor(1, 0.5, 0.5, 1);
      else
	A7xScreen.setColor(1, 1, 0.5, 1);
    } else {
      A7xScreen.setColor(1, 1, 1, 1);
    }
    A7xScreen.drawBoxLine(420, 455, GAUGE_MAX, 20);
    A7xScreen.drawBoxLine(420, 455, gauge, 20);
    if (invincible) {
      if ((cnt % 2) == 1)
	A7xScreen.setColor(1, 0.5, 0.5, 0.5);
      else
	A7xScreen.setColor(1, 1, 0.5, 0.5);
    } else {
      A7xScreen.setColor(1, 1, 1, 0.5);
    }
    A7xScreen.drawBoxSolid(420, 455, gauge, 20);
  }

  public bool checkHit(float x1, float y1, float x2, float y2) {
    float b1x, b1y, b2x, b2y;
    float d, e, f, dnm;
    float x, y;
    if (y2 < y1) {
      b1y = y2 - SIZE; b2y = y1 + SIZE;
    } else {
      b1y = y1 - SIZE; b2y = y2 + SIZE;
    }
    if (a2y >= b1y && b2y >= a1y) {
      if (x2 < x1) {
	b1x = x2 - SIZE; b2x = x1 + SIZE;
      } else {
	b1x = x1 - SIZE; b2x = x2 + SIZE;
      }
      if (a2x >= b1x && b2x >= a1x) {
	d = y2 - y1;
	e = x1 - x2;
	f = x1 * y2 - y1 * x2;
	dnm = b * d - a * e;
	if (dnm != 0) {
	  x = (b * f - c * e) / dnm;
	  y = (c * d - a * f) / dnm;
	  if (a1x <= x && x <= a2x && a1y <= y && y <= a2y &&
	      b1x <= x && x <= b2x && b1y <= y && y <= b2y ) {
	    return true;
	  }
	}
      }
    }
    return false;
  }

  public void addBlowedForce(Vector p, Vector v, float s) {
    if (!blow) return;
    float d = atan2(pos.x - p.x, pos.y - p.y);
    float wd = d;
    if (d < 0)
      d += std.math.PI * 2;
    d -= deg;
    if (d < -std.math.PI)
      d += std.math.PI * 2;
    else if (d > std.math.PI)
      d -= std.math.PI * 2;
    if (d < 0)
      d = -d;
    if (d > std.math.PI / 4)
      return;
    d *= 2; d++;
    float ds = pos.dist(p);
    ds += 2;
    v.x -= sin(wd) * 10 / d / ds;
    v.y -= cos(wd) * 10 / d / ds;
  }

  public static void prepareColors() {
    foreach (i; 0..shipNumVertices) {
      shipColors[i*4 + 0] *= A7xScreen.brightness;
      shipColors[i*4 + 1] *= A7xScreen.brightness;
      shipColors[i*4 + 2] *= A7xScreen.brightness;
    }

    foreach (i; 0..shipLineNumVertices) {
      shipLineColors[i*4 + 0] *= A7xScreen.brightness;
      shipLineColors[i*4 + 1] *= A7xScreen.brightness;
      shipLineColors[i*4 + 2] *= A7xScreen.brightness;
    }

    foreach (i; 0..shipFireLineNumVertices) {
      shipFireLineColors[i*4 + 0] *= A7xScreen.brightness;
      shipFireLineColors[i*4 + 1] *= A7xScreen.brightness;
      shipFireLineColors[i*4 + 2] *= A7xScreen.brightness;
    }
  }

  public static void drawShip() {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(shipVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(shipColors.ptr));
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDrawArrays(GL_TRIANGLES, 4, 6);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }

  public static void drawShipLine() {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(shipLineVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(shipLineColors.ptr));
    glDrawArrays(GL_LINE_STRIP, 0, 3);
    glDrawArrays(GL_LINE_STRIP, 3, 3);
    glDrawArrays(GL_LINE_STRIP, 6, 3);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }

  private static void drawShipFireLine() {
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(shipFireLineVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(shipFireLineColors.ptr));
    glDrawArrays(GL_LINE_STRIP, 0, 3);
    glDrawArrays(GL_LINES, 3, 4);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }
}
