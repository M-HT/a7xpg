A7Xpg  readme.txt
for Windows98/2000/XP(要OpenGL)
ver. 0.11
(C) Kenta Cho

追いかけアクション、A7Xpg。


○ インストール方法

a7xpg0_11.zipを適当なフォルダに展開してください。
その後、'a7xpg.exe'を実行してください。
（マシンの速度が遅い場合は、'a7xpg_lowres.bat'を実行してください。
  A7Xpgを低解像度で立ち上げます。）


○ 遊び方

 - 移動         矢印, テンキー        / ジョイステック
 - ブースト     [Z][X][左Ctrl][左Alt] / トリガ 1-4
 - ポーズ       [P]
 - 終了         [ESC]

自機を操作して、金塊を集めてください。
自機はブーストボタンを押している間加速します。
ブーストパワーは約1.5秒で尽きるため、速度を保つためには
再度ブーストボタンを押す必要があります。

右下のゲージはパワーゲージです。
パワーは金塊を高速で取得すると貯まります。
パワーゲージがフルになると、自機は一定時間無敵になります。
敵に体当たりして、ボーナス得点を狙ってください。

自機は敵に触れると破壊されます。
一定数の金塊を集めると、次のステージに進みます。
右上のタイマーがなくなった場合も、自機を失います。

自機がすべて破壊されると、ゲームオーバーです。
自機は20,000点および50,000点ごとに1機増えます。
ゲームオーバー時にスコアが100,000点を越えていれば、
コンティニューをすることができます。

以下のオプションが指定できます。
 -brightness n  画面の明るさを指定します(n = 0 - 100, デフォルト100)
 -luminous n    発光エフェクトの強さを指定します(n = 0 - 100, デフォルト50)
 -nosound       音を出力しません。
 -window        ウィンドウモードで起動します。
 -lowres        低解像度モードを利用します。


○ ご意見、ご感想

コメントなどは、cs8k-cyu@asahi-net.or.jp までお願いします。


○ ウェブページ

A7Xpg webpage:
http://www.asahi-net.or.jp/~cs8k-cyu/windows/a7xpg.html


○ 謝辞

A7XpgはD言語で書かれています。
 D Programming Language
 http://www.digitalmars.com/d/index.html

画面の出力にはSimple DirectMedia Layerを利用しています。
 Simple DirectMedia Layer
 http://www.libsdl.org/

BGMとSEの出力にSDL_mixerとOgg Vorbis CODECを利用しています。
 SDL_mixer 1.2
 http://www.libsdl.org/projects/SDL_mixer/
 Vorbis.com
 http://www.vorbis.com/

DedicateDのD言語用OpenGL, SDLヘッダファイルおよび
D - portingのSDL_mixerヘッダファイルを利用しています。
 DedicateD
 http://int19h.tamb.ru/files.html
 D - porting
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

○ ヒストリ

2003  9/20  ver. 0.11
            テキストコンソールが開くのを抑止。
            luminousオプションの追加。
2003  9/20  ver. 0.1
            初公開版。


○ ライセンス

A7XpgはBSDスタイルライセンスのもと配布されます。

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
