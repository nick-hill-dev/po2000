Podantious! 2 readme file
=========================

Version 2.00 build 1A (1.00) [99-00] by Nicholas Hill, connivex@callnetuk.com
(C) 1999 & 2000 Connivex

I once decided to NOT finish this game. However, the millenium is fast approaching and I wanted to do the best program I could do. So, you're looking at my best programming skill for the 20th century - indeed my entire life!

Starting up and basic play
==========================

When you load the game it will configure itself and do a speed test, and then display a menu with several options. You select one of those options and then you get prompted for required information. After all of this is done, the main game starts and you fight other triangles until there is one left, or in some cases, when you die. After each round a scoreboard is displayed as well as relevant information. The game will then continue or end depending on the game type.

Keys
====

When you select an option, you may be prompted for the keys you would like to use for each player. You will only be asked for the keys once for each new player. The only valid keys are the numbered ones (1-0), letters and punctuation. You cannot use the special keys like F11.

The games
=========

CAMPAIGN

In this mode you attempt to complete up to 16 levels. You shoot all of the triangles with your fire button. If you see a full triangle, it has 5 lives, otherwise it has less. An empty triangle has only one life left. The level is over when there is one triangle left on the playfield. You have to be the last triangle standing to pass the level, and if you are not, then you lose one of three lives and must try the level again. If you lose all of your lives, the game is over and you are returned to the main menu.

You may start with less than 5 lives for the level you are on, or in special positions.

DUEL

This is the second one player mode in the game, and I personally found out how addictive this mode was as I was testing it (and testing and testing...). You play a single level where you are the light blue triangle, and the computer opponent is the light red one. You, or the AI opponent, cannot fire to begin with. You require the "Missile additive" powerup (see below) to begin firing.

When you kill the single computer player (if you don't die yourself, that is) it becomes two. From that point on, any triangle that dies is replaced with two other triangles. This keeps on going until there are a total of 32 triangles on screen.

This game will end under two circumstances. You can either die, in which case the triangles remaining turn blue and will eventually kill each other off (spawning doesn't happen any more), or you survive the onslaught and the triangles cannot spawn any more so you yourself can kill the ones left.

My highest score here was 120 hits.

SURVIVAL OF THE FITTEST

This is best played with mostly human players. The gameplay is much the same as "CAMPAIGN" mode explained above, but the triangle with the least number of hits after each level is thrown out of the tournament. Depending on the number of players you can have up to 31 levels. The winner is the triangle with the most number of hits in the final level. Powerups are available.

SINGLE GAME

No powerups. You can have any number of human and AI players up to a maximum of 32 players in total. When you lose a life, you cannot collect one back. This follows the very original design for Podantious! 1999. The winner is the last standing triangle.

BEST OF THREE GAMES

Unlike the single game, you can have powerups here, and you play three levels. Unlike the Survival of the Fittest, no person is left out of the following level. The winner is the triangle that has the most number of hits after the three levels.

CUSTOM GAME

Here you can customise a temporary game. You will be prompted for the number of human players, the number of AI players, the AI skill level, the maximum number of objects allowed on screen, the number of lives for each triangle and the maximum number of missiles allowed on screen for each triangle at once. The winner is the one with most hits.

Powerups
========

In some of these modes you can collect up to three different types of powerup. These are explained below.

EXTRA LIFE

Looking like two pie slices, this will add one life to your player for up to a maximum of 5 lives.

MISSILE ADDATIVE

The plus sign. If you cannot fire, then you must collect this to allow you to begin firing. If you can already fire, then you collect this to allow you to fire more missiles at once. A missile is lost when it hits another player or goes off the play area, and it is under those circumstances that you may fire another missile to take its place.

CIRCLE OF VIOLENCE

A circle with a cross through it resembles one of these. The person collecting it takes one life off each of the other players playing the current level, and adds the hit point to itself. People without lives die. Wrecks havok in the Duel mode...

AI and AI tips
==============

This game is the first one in which I have done some proper AI. In the very first non release version (0.1 or something), the triangles randomly fired and moved. For the purpose of testing I introduced the AI in Podantious! 1999 (This game was not intended to be an AI type game. It was originally designed for more than one human player on the same keyboard) and that AI hasn't changed in this version.

The AI, when choosing a victim (whever it be a powerup, another AI person or a human player) will first of all move DOWN or UP to the same level as that player is on, then move SIDEWAYS to intercept it. The firing is still completely random.

It cannot tell the difference between powerups.

Podantious! 1999 and 2000 engine
================================

The engine has been updated. There have been many game changes and these are shown below in the updates list.

These are the procedures used in the Podantious! engines. Ones NOT used in the previous game are shown with a * next to it, and the ones changed a lot have a / next to it.

 / procedure DrawPlayer
   procedure CreateMissile
   procedure HideMissile
   procedure DelMissile
 * procedure DuelAddPlayer
 / procedure LoseLife
 / procedure DrawObject
   procedure CreateObject
   procedure DeleteObject
 / procedure CheckObjCollisions
   procedure ChooseVictim
   procedure ProcessAI
   procedure CheckMissCollision
 / procedure ProcessMissiles
 / procedure PlayLevel

Tips
====

In campaign mode, always try to get lives for two reasons. First, the AI then cannot get one, and second, you actually get to live.

Get the Circle of Violence before someone else does.

You may find that you need to fire but you can't because you're waiting for a previous missile to leave the screen. Always get the Missile Addatives!

Remember, AI move up or down first before moving directly toward you.

Get behind a triangle before you shoot the triangle or the triangle will kill you first.

Press CAPS LOCK after another player has entered his or her keys, then enter yours. Only tell him or her what you have done after he or she dies as the result of not being able to move. :)

Changes from Podantious! 1999
=============================

There have been literally hundreds of changes from the original version, and here is a short list documenting some of these changes. One of the biggest changes was the introduction of another 16 players at once!

1). After looking at the Campaign mode and seeing how hard it was to complete, I decided to add a life feature. If you die, you get up to 2 retries. You now begin the campaign with 3 lives.

2). The "Survival of the Fittest" game has been made harder. The AI players now put up more of a fight. The only change really made here was the setting for the AI level.

3). The Duel mode implemented! In this game, you can kill one triangle, and see two more appear! This was the last feature implemented in this updated game, and quite difficult to do. This game CAN be completed after a while, and if you do somehow die, the triangles will stop spawning and eventually kill themselves.

4). In the previous Podantious! 1999, you had a single game featuring powerups which has now been removed for this game, and in its place is a "Best of 3 Games" option. Kills are totalled for three games and the one with the most kills is the winner, unlike the previous game where the winner was the last standing triangle.

5). New interface! Windows looking controls and forms, a starry background...etc. Windows zoom in. This is all much better than the comparitavely 'ugly' interface of the previous game.

6). Missiles move slower, the amount of lives left is shown on the triangle itself and the powerup icons have been changed into better looking ones.

7). The stats at the right hand side of the screen and the boundaries of the playfield have been taken out of the game to leave a wrappable full screen play area.

8). New scoreboard and transitions for in-between screens.

9). Less bugs! And also more efficient coding. Some minor speed inprovements, to allow the more advanced features of this new version.

10). New and changed sounds.

11). A special cheat mode that can only be activated by typing a certain letter on the menu screen... :)

Contact
=======

If you need me: connivex@callnetuk.com

Enjoy!