A7Xpg  readme_e.txt
for Windows98/2000/XP(OpenGL required)
ver. 0.11
(C) Kenta Cho

Chase action game 'A7Xpg'.


- How to install.

Unpack a7xpg0_11.zip, and execute 'a7xpg.exe'.
(If the game is too heavy for your PC, please try 'a7xpg_lowres.bat'.
 This batch file launches the A7Xpg in the low resolution mode.)


- How to play.

 - Movement  Arrow, Num key        / Joystick
 - Boost     [Z][X][L-Ctrl][L-Alt] / Trigger 1-4
 - Pause     [P]
 - Quit      [ESC]

Control your ship and gather golds. 
The ship accelerates while holding the boost button.
A boost power runs out about 1.5 seconds, so
you have to push the boost button again to maintain the speed.

The gauge at the right-down corner is the power gauge.
The power increases when you take a gold at high speed.
When the power gauge becomes full, your ship becomes invincible 
for a while. Attack enemies and earn the bonus score.

The ship is destroyed when you touch the enemy.
When you gather a given number of golds,
you can go to the next stage.
If the timer at the right-up corner runs out, 
you also lose the ship. 

When all ships are destroyed, the game is over.
The ship extends 20,000 and every 50,000 points.
If your score is over 100,000, you can continue the game.

These options are available:
 -brightness n  Set the brightness of the screen.(n = 0 - 100, default = 100)
 -luminous n    Set the luminous intensity.(n = 0 - 100, default = 50)
 -nosound       Stop the sound.
 -window        Launch the game in the window, not use the full-screen.
 -lowres        Use the low resolution mode.


- Comments

If you have any comments, please mail to cs8k-cyu@asahi-net.or.jp


- Webpage

A7Xpg webpage:
http://www.asahi-net.or.jp/~cs8k-cyu/windows/a7xpg_e.html


- Acknowledgement

A7Xpg is written by the D Programming Language.
 D Programming Language
 http://www.digitalmars.com/d/index.html
 
Simple DirectMedia Layer is used for the display handling. 
 Simple DirectMedia Layer
 http://www.libsdl.org/

Using SDL_mixer and Ogg Vorbis CODEC to play BGM/SE. 
 SDL_mixer 1.2
 http://www.libsdl.org/projects/SDL_mixer/
 Vorbis.com
 http://www.vorbis.com/

Using D Header files at DedicateD for OpgnGL and SDL
and at D - porting for SDL_mixer.
 DedicateD
 http://int19h.tamb.ru/files.html
 D - porting
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

- History

2003  9/21  ver. 0.11
            Stop opening a text console window.
            Add the luminous option.
2003  9/20  ver. 0.1


-- License

License
-------

Copyright 2003 Kenta Cho. All rights reserved. 

Redistribution and use in source and binary forms, 
with or without modification, are permitted provided that 
the following conditions are met: 

 1. Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer. 

 2. Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
