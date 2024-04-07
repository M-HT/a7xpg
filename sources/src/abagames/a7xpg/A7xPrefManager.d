/*
 * $Id: A7xPrefManager.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.A7xPrefManager;

import std.stdio;
import abagames.util.PrefManager;

/**
 * Save/Load a high score.
 */
public class A7xPrefManager: PrefManager {
 public:
  static const int VERSION_NUM = 10;
  static string PREF_FILE = "a7xpg.prf";
  int hiScore;

  private void init() {
    hiScore = 0;
  }

  public override void load() {
    scope File fd;
    try {
      int[1] read_data;
      fd.open(PREF_FILE);
      fd.rawRead(read_data);
      if (read_data[0] != VERSION_NUM)
	throw new Exception("Wrong version num");
      fd.rawRead(read_data);
      hiScore = read_data[0];
    } catch (Exception e) {
      init();
    } finally {
      fd.close();
    }
  }

  public override void save() {
    scope File fd;
    try {
      fd.open(PREF_FILE, "wb");
      const int[2] write_data = [VERSION_NUM, hiScore];
      fd.rawWrite(write_data);
    } finally {
      fd.close();
    }
  }
}
