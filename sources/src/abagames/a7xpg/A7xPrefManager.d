/*
 * $Id: A7xPrefManager.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xPrefManager;

import stream;
import abagames.util.PrefManager;

/**
 * Save/Load a high score.
 */
public class A7xPrefManager: PrefManager {
 public:
  static const int VERSION_NUM = 10;
  static const char[] PREF_FILE = "a7xpg.prf";
  int hiScore;

  private void init() {
    hiScore = 0;
  }

  public void load() {
    auto File fd = new File;
    try {
      int ver;
      fd.open(PREF_FILE);
      fd.read(ver);
      if (ver != VERSION_NUM)
	throw new Error("Wrong version num");
      fd.read(hiScore);
    } catch (Error e) {
      init();
    } finally {
      fd.close();
    }
  }

  public void save() {
    auto File fd = new File;
    fd.create(PREF_FILE);
    fd.write(VERSION_NUM);
    fd.write(hiScore);
    fd.close();
  }
}
