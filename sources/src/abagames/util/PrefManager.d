/*
 * $Id: PrefManager.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.PrefManager;

/**
 * Save/load the game preference(ex) high-score).
 */
//public interface PrefManager {
public abstract class PrefManager {
  public void save();
  public void load();
}
