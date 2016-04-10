/*
 * $Id: A7xGameManager.d,v 1.2 2003/09/19 15:56:11 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xGameManager;

import std.math;
import opengl;
import SDL;
version (PANDORA) {
    import std.conv;
    import std.process;
}
import abagames.util.Rand;
import abagames.util.GameManager;
import abagames.util.ActorPool;
import abagames.util.Vector;
import abagames.util.sdl.Screen3D;
import abagames.util.sdl.Texture;
import abagames.util.sdl.Input;
import abagames.util.sdl.Sound;
import abagames.a7xpg.LuminousActorPool;
import abagames.a7xpg.A7xPrefManager;
import abagames.a7xpg.A7xScreen;
import abagames.a7xpg.Ship;
import abagames.a7xpg.Field;
import abagames.a7xpg.Gold;
import abagames.a7xpg.Enemy;
import abagames.a7xpg.Particle;
import abagames.a7xpg.Bonus;
import abagames.a7xpg.LetterRender;

/**
 * Manage the game status and actor pools.
 */
public class A7xGameManager: GameManager {
 public:

 private:
  const int ENEMY_MAX = 32;
  A7xPrefManager prefManager;
  A7xScreen screen;
  Rand rand;
  Field field;
  Ship ship;
  LuminousActorPool golds;
  LuminousActorPool enemies;
  LuminousActorPool particles;
  ActorPool bonuses;
  const int FIRST_EXTEND = 20000;
  const int EVERY_EXTEND = 50000;
  const int LEFT_MAX = 9;
  int stage, lap;
  int left;
  int score, extendScore;
  int leftGold, appGold;
  int enemyAppInterval;
  int enemyTimer;
  int stageTimer;
  enum {
    TITLE, IN_GAME, STAGE_CLEAR, GAMEOVER, PAUSE
  };
  int state;
  int cnt;
  int timeBonus;
  const int CONTINUE_ENABLE_SCORE = 100000;
  bool continueEnable;
  int contCy;
  int pauseCnt;
  Sound[3] bgm;
  Sound[12] se;
  Texture titleTexture;

  const int STAGE_NUM = 30;
  float[][STAGE_NUM] stgData =
    [
     // width, height, time, #gold, #gold on field, interval enemy appearing, [enemy data]
     // [enemy data] = #, type, size, speed
     [24, 18, 40, 10, 1, 300, 4, 0, 1, 0.2],
     [21, 21, 30, 12, 2, 280, 4, 1, 1, 0.25],
     [25, 20, 35, 15, 2, 320, 5, 2, 1, 0.3],
     [20, 22, 30, 12, 1, 300, 1, 1, 1, 0.2, 2, 0, 1, 0.25, 3, 1, 1, 0.3],
     [24, 18, 45, 20, 2, 150, 1, 3, 2.5, 0.2, 5, 2, 1, 0.35],

     [24, 18, 30, 10, 1, 200, 2, 0, 1, 0.4, 2, 1, 1, 0.3, 2, 2, 1, 0.3],
     [25, 16, 40, 18, 3, 250, 6, 4, 5, 0.3],
     [30, 12, 35, 12, 1, 50, 4, 1, 1.5, 0.28],
     [18, 20, 45, 18, 2, 200, 3, 3, 1, 0.5, 1, 0, 1.5, 0.4, 3, 3, 1, 0.2],
     [30, 28, 50, 22, 2, 100, 1, 4, 12, 0.2, 2, 0, 1.5, 0.2, 3, 1, 1.5, 0.3, 2, 3, 1.5, 0.4],

     [24, 18, 40, 16, 2, 30, 6, 1, 1, 0.32],
     [13, 13, 30, 12, 1, 100, 1, 0, 1, 0.3, 1, 1, 1, 0.3, 1, 2, 1, 0.3, 1, 3, 1, 0.3],
     [25, 16, 45, 18, 2, 200, 2, 1, 3, 0.2, 2, 0, 3, 0.3],
     [8, 22, 30, 15, 3, 180, 1, 4, 8, 0.2, 3, 2, 0.8, 0.3],
     [22, 20, 60, 25, 2, 100, 1, 5, 2, 0.15, 2, 4, 5, 0.2, 4, 0, 1, 0.4],

     [24, 18, 50, 22, 3, 150, 3, 0, 1, 0.35, 3, 4, 5, 0.4, 3, 0, 1, 0.35],
     [16, 26, 40, 15, 2, 100, 7, 2, 1, 0.5],
     [15, 15, 45, 20, 2, 160, 1, 4, 15, 0.1, 3, 5, 1, 0.2],
     [28, 22, 20, 20, 10, 10, 1, 1, 0.5, 0.5, 4, 4, 10, 0.1],
     [26, 26, 60, 25, 2, 100, 3, 0, 4, 0.15, 3, 3, 1, 0.4, 3, 4, 1.5, 0.6],

     [24, 18, 45, 15, 2, 120, 2, 5, 1, 0.4, 3, 0, 1, 0.3, 3, 2, 1.5, 0.4],
     [12, 12, 30, 10, 1, 50, 4, 0, 1, 0.27],
     [20, 25, 50, 25, 4, 100, 8, 5, 0.6, 0.37],
     [27, 18, 55, 20, 2, 150, 3, 4, 6, 0.5, 4, 3, 1, 0.5, 1, 1, 1, 0.5],
     [20, 20, 60, 25, 3, 120, 1, 3, 7, 0.3, 2, 2, 1, 0.4, 3, 1, 1, 0.3, 4, 0, 1, 0.35],

     [24, 18, 50, 20, 2, 75, 1, 0, 1, 0.4, 1, 0, 1.25, 0.35, 1, 0, 1.5, 0.3, 1, 0, 1.75, 0.25,
     1, 0, 2, 0.2, 1, 0, 2.25, 0.15, 1, 0, 2.5, 0.1],
     [29, 25, 60, 25, 3, 100, 1, 4, 15, 0.25, 1, 4, 10, 0.3,
     1, 3, 2, 0.35, 1, 5, 1.5, 0.35, 1, 1, 2, 0.35, 4, 0, 1, 0.3],
     [20, 24, 40, 15, 1, 120, 7, 4, 2, 0.6],
     [22, 22, 60, 30, 5, 100, 4, 4, 8, 0.3, 4, 3, 2, 0.4],
     [24, 18, 40, 10, 1, 20, 4, 0, 1, 0.2, 3, 1, 1, 0.25, 2, 2, 1, 0.3, 1, 3, 1, 0.3,
     1, 4, 3, 0.3, 1, 5, 1, 0.2],
    ];
  float[3][ENEMY_MAX] enemyTable;
  int enemyTableIdx, enemyNum;

  public override void init() {
    prefManager = cast(A7xPrefManager) abstPrefManager;
    screen = cast(A7xScreen) abstScreen;
    screen.makeLuminousTexture();
    rand = new Rand;
    field = new Field;
    field.init();
    Ship.createDisplayLists();
    ship = new Ship;
    ship.init(input, field, this);
    Gold.createDisplayLists();
    scope Gold goldClass = new Gold;
    scope GoldInitializer gi = new GoldInitializer(ship, field, rand, this);
    golds = new LuminousActorPool(16, goldClass, gi);
    Enemy.createDisplayLists();
    scope Enemy enemyClass = new Enemy;
    scope EnemyInitializer ei = new EnemyInitializer(ship, field, rand, this);
    enemies = new LuminousActorPool(ENEMY_MAX, enemyClass, ei);
    scope Particle particleClass = new Particle;
    scope ParticleInitializer pi = new ParticleInitializer(field, rand);
    particles = new LuminousActorPool(256, particleClass, pi);
    scope Bonus bonusClass = new Bonus;
    scope BonusInitializer bi = new BonusInitializer();
    bonuses = new ActorPool(8, bonusClass, bi);
    LetterRender.createDisplayLists();
    for (int i = 0; i < bgm.length; i++)
      bgm[i] = new Sound;
    bgm[0].loadSound("bgm1.ogg");
    bgm[1].loadSound("bgm2.ogg");
    bgm[2].loadSound("bgm3.ogg");
    for (int i = 0; i < se.length; i++)
      se[i] = new Sound;
    se[0].loadChunk("getgold.wav", 0);
    se[1].loadChunk("boost.wav", 1);
    se[2].loadChunk("miss.wav", 2);
    se[3].loadChunk("invincible.wav", 3);
    se[4].loadChunk("invfast.wav", 3);
    se[5].loadChunk("enemyapp.wav", 4);
    se[6].loadChunk("enemycrash.wav", 5);
    se[7].loadChunk("extend.wav", 6);
    se[8].loadChunk("stagestart.wav", 7);
    se[9].loadChunk("stageend.wav", 7);
    se[10].loadChunk("startinv.wav", 7);
    se[11].loadChunk("accel.wav", 2);
    titleTexture = new Texture("title.bmp");
  }

  public override void start() {
    stage = 0;
    startTitle();
  }

  public override void close() {
    titleTexture.deleteTexture();
    for (int i = 0; i < bgm.length; i++)
      bgm[i].free();
    for (int i = 0; i < se.length; i++)
      se[i].free();
    LetterRender.deleteDisplayLists();
    Enemy.deleteDisplayLists();
    Gold.deleteDisplayLists();
    Ship.deleteDisplayLists();
  }

  public void playSe(int n) {
    if (state != IN_GAME && state != STAGE_CLEAR)
      return;
    se[n].playChunk();
  }

  public void stopSe(int n) {
    se[n].haltChunk();
  }

  public void addGold() {
    Gold gold = cast(Gold) golds.getInstance();
    assert(gold);
    gold.set();
  }

  public void addScore(int sc) {
    score += sc;
    if (score > extendScore) {
      if (left < LEFT_MAX) {
	playSe(7);
	left++;
      }
      if (extendScore <= FIRST_EXTEND)
	extendScore = EVERY_EXTEND;
      else
	extendScore += (EVERY_EXTEND * (lap + 1));
    }
  }

  public void addBonus(int sc, Vector pos, float size) {
    addScore(sc);
    Bonus bonus = cast(Bonus) bonuses.getInstanceForced();
    assert(bonus);
    bonus.set(sc, pos, size);
  }

  public void getGold() {
    playSe(0);
    addBonus((cast(int)(ship.speed / (ship.DEFAULT_SPEED / 2))) * 10, ship.pos, 0.7);
    leftGold--;
    if (leftGold - appGold >= 0)
      addGold();
    ship.addGauge();
    if (leftGold <= 0)
      startStageClear();
  }

  public void shipDestroyed() {
    playSe(2);
    left--;
    if (left < 0)
      startGameover();
  }

  public void addEnemy(int type, float size, float speed) {
    playSe(5);
    Enemy enemy = cast(Enemy) enemies.getInstance();
    if (!enemy) return;
    enemy.set(type, size, speed);
  }

  public void addParticle(Vector pos, float deg, float ofs, float speed,
			  float r, float g, float b) {
    Particle pt = cast(Particle) particles.getInstanceForced();
    assert(pt);
    pt.set(pos, deg, ofs, speed, r, g, b);
  }

  private void startStage(bool cont) {
    int st = stage % STAGE_NUM;
    lap = stage / STAGE_NUM;
    field.size.x = stgData[st][0];
    field.size.y = stgData[st][1];
    field.eyeZ = 300;
    field.alpha = 1;
    stageTimer = cast(int)(stgData[st][2] * 60);
    leftGold = cast(int)(stgData[st][3]);
    appGold = cast(int)(stgData[st][4]);
    enemyAppInterval = cast(int)(stgData[st][5]);
    int ei = 0;
    for (int i = 6; i < stgData[st].length;) {
      int n = cast(int)(stgData[st][i]); i++;
      int tp = cast(int)(stgData[st][i]); i++;
      float sz = stgData[st][i]; i++;
      float sp = stgData[st][i]; i++;
      for (int j = 0; j < n; j++) {
	enemyTable[ei][0] = tp;
	enemyTable[ei][1] = sz;
	enemyTable[ei][2] = sp;
	ei++;
      }
    }
    restartStage();
    enemyTimer = 0;
    enemyNum = ei;
    field.start(st / 5);
    ship.startRound();
    ship.start();
    enemies.clear();
    bonuses.clear();
    particles.clear();
    golds.clear();
    for (int i = 0; i < appGold; i++) {
      addGold();
    }
    cnt = 0;
    if (st % 5 == 0 || cont) {
      bgm[(st / 5) % bgm.length].playMusic();
    }
    playSe(8);
  }

  public void restartStage() {
    enemyTimer = 120;
    enemyTableIdx = 0;
    enemies.clear();
  }

  private void initShipState() {
    left = 2;
    score = 0;
    extendScore = FIRST_EXTEND;
  }

  private void startInGameContinue() {
    state = IN_GAME;
    initShipState();
    startStage(true);
  }

  private void startInGame() {
    state = IN_GAME;
    initShipState();
    stage = 0;
    startStage(false);
  }

  private void startStageClear() {
    playSe(9);
    state = STAGE_CLEAR;
    field.eyeZa = 300;
    ship.speed = ship.DEFAULT_SPEED;
    cnt = 0;
    if (stageTimer > 0)
      timeBonus = (stageTimer * 17 / 100) * 10;
    else
      timeBonus = 0;
    if (stage % 5 == 4)
      Sound.fadeMusic();
  }

  private void gotoNextStage() {
    state = IN_GAME;
    stage++;
    startStage(false);
  }

  private void startTitle() {
    state = TITLE;
    startStage(false);
    cnt = 0;
    field.eyeZ = field.eyeZa;
    Sound.stopMusic();
  }

  private void startGameover() {
    state = GAMEOVER;
    cnt = 0;
    if (score > prefManager.hiScore)
      prefManager.hiScore = score;
    if (score > CONTINUE_ENABLE_SCORE && stage < STAGE_NUM) {
      continueEnable = true;
      contCy = 0;
    } else {
      continueEnable = false;
    }
    Sound.fadeMusic();

    version (PANDORA) {
        system(escapeShellCommand("fusilli", "--cache", "push", "a7xpg", to!string(score), "0") ~ " >/dev/null 2>&1");
    }
  }

  private void startPause() {
    state = PAUSE;
    pauseCnt = 0;
  }

  private void resumePause() {
    state = IN_GAME;
  }


  private void stageMove() {
    enemyTimer--;
    if (enemyTimer < 0) {
      if (enemyTableIdx == 0 && lap >= 1) {
	int ei = enemyNum - 1;
	for (int i = 0; i < lap * 2; i++) {
	  addEnemy(cast(int)(enemyTable[ei][0]),
		   enemyTable[ei][1] * (1 + lap * 0.1),
		   enemyTable[ei][2] * (1 + lap * 0.1));
	  ei--;
	  if (ei < 0)
	    ei = enemyNum - 1;
	}
      }
      enemyTimer = enemyAppInterval;
      addEnemy(cast(int)(enemyTable[enemyTableIdx][0]),
	       enemyTable[enemyTableIdx][1],
	       enemyTable[enemyTableIdx][2]);
      enemyTableIdx++;
      if (enemyTableIdx >= enemyNum)
	enemyTimer = 999999999;
    }
    if (ship.cnt > -ship.INVINCIBLE_CNT) {
      stageTimer--;
      if (stageTimer <= 0)
	startStageClear();
    }
  }


  private bool pPrsd = true;

  private void inGameMove() {
    stageMove();
    field.move();
    ship.move();
    golds.move();
    enemies.move();
    particles.move();
    bonuses.move();
    if (input.keys[SDLK_p] == SDL_PRESSED) {
      if (!pPrsd) {
	pPrsd = true;
	startPause();
      }
    } else {
      pPrsd = false;
    }
  }

  private bool btnPrsd, gotoNextState;

  private void stageClearMove() {
    if (cnt <= 64) {
      btnPrsd = true;
      gotoNextState = false;
    } else {
      if (input.getButtonState() & (Input.PAD_BUTTON1 | Input.PAD_BUTTON2)) {
	if (!btnPrsd)
	  gotoNextState = true;
      } else {
	btnPrsd = false;
      }
    }
    if (cnt == 64) {
      addScore(timeBonus);
    } else if ((cnt > 64 && gotoNextState) || cnt > 300) {
      if (stageTimer > 0) {
	gotoNextStage();
      } else {
	left--;
	if (left < 0) {
	  ship.start();
	  startGameover();
	} else {
	  gotoNextStage();
	}
      }
    }
    field.move();
    field.alpha *= 0.96;
    particles.move();
    bonuses.move();
  }

  private void titleMove() {
    if (cnt <= 8) {
      btnPrsd = true;
    } else {
      if (input.getButtonState() & (Input.PAD_BUTTON1 | Input.PAD_BUTTON2)) {
	if (!btnPrsd)
	  startInGame();
      } else {
	btnPrsd = false;
      }
    }
    stageMove();
    field.addSpeed(ship.DEFAULT_SPEED / 2);
    field.move();
    enemies.move();
    particles.move();
  }

  private void gameoverMove() {
    if (cnt <= 64) {
      btnPrsd = true;
      gotoNextState = false;
    } else {
      if (input.getButtonState() & (Input.PAD_BUTTON1 | Input.PAD_BUTTON2)) {
	if (!btnPrsd)
	  gotoNextState = true;
      } else {
	btnPrsd = false;
      }
      if (continueEnable) {
	int pad = input.getPadState();
	if (pad & Input.PAD_UP) {
	  contCy = 0;
	  cnt = 65;
	} else if (pad & Input.PAD_DOWN) {
	  contCy = 1;
	  cnt = 65;
	}
      }
    }
    if (cnt > 64 && gotoNextState) {
      if (continueEnable && contCy == 0)
	startInGameContinue();
      else
	startTitle();
    } else if (cnt > 500) {
	startTitle();
    }
    field.addSpeed(ship.DEFAULT_SPEED / 2);
    field.move();
    enemies.move();
    particles.move();
  }

  private void pauseMove() {
    pauseCnt++;
    if (input.keys[SDLK_p] == SDL_PRESSED) {
      if (!pPrsd) {
	pPrsd = true;
	resumePause();
      }
    } else {
      pPrsd = false;
    }
  }

  public override void move() {
    switch (state) {
    case IN_GAME:
      inGameMove();
      break;
    case STAGE_CLEAR:
      stageClearMove();
      break;
    case TITLE:
      titleMove();
      break;
    case GAMEOVER:
      gameoverMove();
      break;
    case PAUSE:
      pauseMove();
      break;
    default:
    }
    cnt++;
  }


  private void inGameDraw() {
    bonuses.draw();
    field.draw();
    golds.draw();
    glBegin(GL_LINES);
    particles.draw();
    glEnd();
    ship.draw();
    enemies.draw();
  }

  private void stageClearDraw() {
    if (cnt < 32)
      field.draw();
    glBegin(GL_LINES);
    particles.draw();
    glEnd();
  }

  private void titleDraw() {
    glBegin(GL_LINES);
    particles.draw();
    glEnd();
    enemies.draw();
  }

  private void gameoverDraw() {
    field.draw();
    glBegin(GL_LINES);
    particles.draw();
    glEnd();
    enemies.draw();
  }

  private void inGameDrawLuminous() {
    field.drawLuminous();
    golds.drawLuminous();
    glLineWidth(2);
    glBegin(GL_LINES);
    particles.drawLuminous();
    glEnd();
    glLineWidth(1);
    ship.drawLuminous();
    enemies.drawLuminous();
  }

  private void stageClearDrawLuminous() {
    if (cnt < 32)
      field.drawLuminous();
    glBegin(GL_LINES);
    particles.drawLuminous();
    glEnd();
  }

  private void titleDrawLuminous() {
    field.drawLuminous();
    glBegin(GL_LINES);
    particles.drawLuminous();
    glEnd();
    enemies.drawLuminous();
  }

  private void gameoverDrawLuminous() {
    field.drawLuminous();
    glBegin(GL_LINES);
    particles.drawLuminous();
    glEnd();
    enemies.drawLuminous();
  }

  private void drawScore() {
    LetterRender.drawNum(score, 300, 20, 10);
  }

  private void drawHiScore() {
    LetterRender.drawNum(prefManager.hiScore, 620, 20, 10);
  }

  private void drawStageTimer() {
    LetterRender.drawTime(stageTimer * 17, 620, 20, 10);
  }

  private void inGameDrawStatus() {
    if (state == IN_GAME && cnt < 120) {
      LetterRender.drawString("STAGE", 200, 180, 22);
      LetterRender.drawNum(stage + 1, 440, 180, 22);
    }
    drawScore();
    if (state == STAGE_CLEAR || cnt > 120)
      drawStageTimer();
    LetterRender.drawNum(left, 80, 460, 10);
    glPushMatrix();
    glTranslatef(30, 460, 0);
    glScalef(11, -11, 1);
    glCallList(Ship.displayListIdx);
    glCallList(Ship.displayListIdx + 1);
    glPopMatrix();
    if (state == IN_GAME) {
      ship.drawGauge();
      LetterRender.drawNum(leftGold, 80, 430, 10);
      glPushMatrix();
      glTranslatef(30, 430, 0);
      glScalef(11, -11, 1);
      glCallList(Gold.displayListIdx);
      glCallList(Gold.displayListIdx + 1);
      glPopMatrix();
    }
  }

  private void stageClearDrawStatus() {
    if (stageTimer > 0) {
      LetterRender.drawString("STAGE CLEAR", 100, 150, 24);
      if (cnt > 32)
	LetterRender.drawString("TIME BONUS", 80, 240, 15);
      if (cnt > 64)
	LetterRender.drawNum(timeBonus, 550, 290, 15);
    } else {
      LetterRender.drawString("TIME OVER", 124, 150, 24);
    }
  }

  private void titleDrawStatus() {
    if ((cnt % 120) < 60)
      LetterRender.drawString("PUSH BUTTON TO START", 320, 400, 8);
    drawScore();
    drawHiScore();
    glEnable(GL_TEXTURE_2D);
    titleTexture.bind();
    A7xScreen.setColor(1, 1, 1, 1);
    glBegin(GL_TRIANGLE_FAN);
    glTexCoord2f(0, 0);
    glVertex3f(80, 50, 0);
    glTexCoord2f(1, 0);
    glVertex3f(180, 50, 0);
    glTexCoord2f(1, 1);
    glVertex3f(180, 150, 0);
    glTexCoord2f(0, 1);
    glVertex3f(80, 150, 0);
    glEnd();
    glDisable(GL_TEXTURE_2D);
  }

  private void gameoverDrawStatus() {
    if (cnt > 64) {
      LetterRender.drawString("GAME OVER", 220, 200, 15);
      if (continueEnable) {
	LetterRender.drawString("CONTINUE", 250, 270, 9);
	if (contCy == 0) {
	  LetterRender.drawString("YES", 380, 260, 10);
	  LetterRender.drawString("NO", 395, 280, 5);
	} else {
	  LetterRender.drawString("YES", 395, 260, 5);
	  LetterRender.drawString("NO", 395, 280, 10);
	}
      }
    }
    drawScore();
    drawHiScore();
  }

  private void pauseDrawStatus() {
    if ((pauseCnt % 60) < 30)
      LetterRender.drawString("PAUSE", 280, 220, 12);
  }

  private void setEyepos() {
    glTranslatef(0, 0, -field.eyeZ);
  }

  public override void draw() {
    SDL_Event e = mainLoop.event;
    if (e.type == SDL_VIDEORESIZE) {
      SDL_ResizeEvent re = e.resize;
      screen.resized(re.w, re.h);
    }

    screen.startRenderToTexture();
    glPushMatrix();
    setEyepos();
    switch (state) {
    case IN_GAME:
    case PAUSE:
      inGameDrawLuminous();
      break;
    case STAGE_CLEAR:
      stageClearDrawLuminous();
      break;
    case TITLE:
      titleDrawLuminous();
      break;
    case GAMEOVER:
      gameoverDrawLuminous();
      break;
    default:
    }
    glPopMatrix();
    screen.endRenderToTexture();

    screen.clear();
    glPushMatrix();
    setEyepos();
    switch (state) {
    case IN_GAME:
    case PAUSE:
      inGameDraw();
      break;
    case STAGE_CLEAR:
      stageClearDraw();
      break;
    case TITLE:
      titleDraw();
      break;
    case GAMEOVER:
      gameoverDraw();
      break;
    default:
    }
    glPopMatrix();

    screen.drawLuminous();

    screen.viewOrthoFixed();
    switch (state) {
    case IN_GAME:
      inGameDrawStatus();
      break;
    case STAGE_CLEAR:
      inGameDrawStatus();
      stageClearDrawStatus();
      break;
    case TITLE:
      titleDrawStatus();
      break;
    case GAMEOVER:
      gameoverDrawStatus();
      break;
    case PAUSE:
      pauseDrawStatus();
      break;
    default:
    }
    screen.viewPerspective();
  }
}
