;"MIT License

Copyright (c) 2020-2025 Henrik Åsman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."


;"==========================================================================
  =                                                                        =
  =  Constants and globals that controls how the compiled game behaves     =
  =                                                                        =
  =========================================================================="
;"
Here you define the compiling target. The options are:
XZIP  The game compiles to version 5 (z5). This is the prefered option
      because all features are available.
ZIP   The game compiles to version 3 (z3). You lose the following:
        - Game mode 'split screen' is not available, only conversational.
        - The player can obviously not change game mode with 'CHANGE MODE'.
        - You have to live with a status line (always there in V3).
        - '70 CLS - clear' doesn't work in V3 (it is simply ignored).
        - '88 DELAY - pause' doesn't work in V3 (it is simply ignored)."
<VERSION XZIP>

;"Set this to change the gameflow between conversational or split screen.
    T   True = Coversational flow
    <>  False = Split screen"
<GLOBAL GAME-CONVERSATIONAL T>

;"Set this to the screen width your aiming. 64 is the original TRS-80 width. In conversational mode ignored, intrepreter does the word-wrap"
<CONSTANT SCREEN-WIDTH 64>      ;"TRS-80"

;"Character to use as seperation in classic mode"
<CONSTANT SEPERATION-CHAR !\_>

;"Set if the game should use fixed font, or not"
<CONSTANT USE-FIXED-FONT T>

;"Determines if the instruction '70 CLS - clear' should clear screen or be ignored. In conversational mode it is always ignored."
<CONSTANT NO-CLS T>

;"Determines (in conversational):
    <>  Brief mode. Only print full room description on first visit
    T   Verbose mode. Always print full room description"
<GLOBAL CAN-PLAYER-CHANGE-GAME-MODE T>

;"Determines if there should be blank lines between DESC, ITEMS & EXITS in classic mode"
<CONSTANT COMPACT-ROOM-DESC <>>

;"Sets on wich row the split line should be start. If there during the game is to few lines the game will
  add new lines to the upper area lines. Note that if you set COMPACT-ROOM-DESC the actual split line is decreased by 3."
<GLOBAL STARTING-SPLITROW 8>

;"Sets if AutoGet/Drop should be handled as defined in 'The Adventure System' manual or handled as in ScottFree
  THE ADVENTURE SYSTEM
    If a verb-noun match was found in at least one action entry, but the conditions were not true in any of the
    matched actions, then the message 'I can’t do that…yet' is displayed after all of the action entries have
    been checked.
    AutoGet/Drop is only called if there is no verb-noun match found.
  ScottFree
    Does the same as above but tries to do an AutoGet/Drop before the message 'I can’t do that…yet'.

  Castle Adventure needs T"
<CONSTANT AUTOGET-AS-SCOTTFREE <>>

;"Allow player to use GET/DROP ALL for all AutoGet items"
<CONSTANT GET-DROP-ALL-ALLOWED? T>

;"Allow player to use pronoun IT"
<CONSTANT IT-PRONOUN-ALLOWED? T>

;"Determines in wich order room descriptions should print
    0   DESC, ITEMS, EXITS
    1   DESC, EXITS, ITEMS"
<CONSTANT ROOM-DESC-ORDER 0>

;"Sets if an exitless room should print 'Obvious exits: none' or nothing. The same with items."
<CONSTANT PRINT-NONE-WHEN-NO-EXITS <>>
<CONSTANT PRINT-NONE-WHEN-NO-ITEMS <>>
<CONSTANT CHARS-BETWEEN-EXITS ", ">
<CONSTANT CHARS-BETWEEN-ITEMS " - ">

;"Light soutce settings"
<CONSTANT PREHISTORIC-LAMP? <>>             ;"Should light source be destroyed when empty? See -p in ScottFree, use when flag 16 is not handled in game."
<CONSTANT LIGHT-WARNING-EVERY-TURN? <>>     ;"<> = every turn, T = every fifth turn (when under warning threshold)"

;"Text formatting settings"
<CONSTANT PRINT-DOT-AFTER-DESC T>
<CONSTANT PRINT-DOT-AFTER-EXITS <>>
<CONSTANT PRINT-EXITS-IN-UCASE <>>
<CONSTANT EXTRA-NEWLINE-BEFORE-PROMPT-IN-CONVERSATIONAL? T>

;"Set the standard messages you want for the game."
<CONSTANT MSG-INTRO
"You can always change presentation between classic|
Scott Adams split screen style an a more conversational|
flow style with the meta command: CHANGE MODE.|
|
Other meta commands are: SAVE GAME, LOAD GAME and|
ABOUT GAME.|
|
">

;"Command Parsing
    scott_spec                              ScottFree                               Scottkit                            C64
    ==========                              =========                               ========                            ===
    Tell me what to do?                     Tell me what to do ?                    Tell me what to do ?                ---TELL ME WHAT TO DO ?
    You use word(s) I don’t know!           You use word(s) I don't know!           You use word(s) I don't know!       I don't know how to <WORD> something
    I don’t understand your command.        I don't understand your command.        I don't understand your command.    I don't know what a <WORD> is
    I can’t do that yet.                    I can't do that yet.                    I can't do that yet.                I can't do that...yet!
    OK                                      O.K.                                    O.K.                                O.K.
"
<CONSTANT MSG-PROMPT "Tell me what to do? ">                        ;"Prompt"
<CONSTANT MSG-UNKNOWN-WORDS "You use word(s) I don't know!">        ;"Message when verb is unknown"
<CONSTANT MSG-DONT-UNDERSTAND "I don't understand your command.">   ;"Message when pair verb+noun not found"
<CONSTANT MSG-CANT-DO-THAT-YET "I can't do that yet.">              ;"Message when matching verb+noun, but failed conditions"
<CONSTANT MSG-OK "OK">                                              ;"sucessful get/drop"

;"Room Descriptions
    I can’t see. It is too dark!            [I/You] can't see. It is too dark!      I can't see. It is too dark!
    I’m in a <ROOM NAME>                    [I’m in a/You are] <ROOM NAME>          I’m in a <ROOM NAME>                I’m in a <ROOM NAME>
    Obvious exits:                          Obvious exits: <DIRS>/none [,].         Obvious exits: <DIRS> [,].          Some obvious exits are: <DIRS> [ ]
    Visible items here:                     [I/You] can also see: <ITEMS> [-]       I can also see: <ITEMS> [.].        Visible items: <ITEMS> [,].
"
<CONSTANT MSG-TOO-DARK-TO-SEE "I can't see. It's too dark!">
<CONSTANT MSG-IM-IN-A "I'm in a ">
<CONSTANT MSG-OBVIOUS-EXITS "Obvious exits: ">
<CONSTANT MSG-VISIBLE-ITEMS-HERE "Visible items here: ">
<CONSTANT MSG-WHEN-NO-EXITS-ITEMS "none.">

;"Inventory
    I’m carrying:                       [I'm/You are] carrying:                     I'm carrying: <ITEMS>/Nothing [-].  I'm carrying the following: <ITEMS> [.].
                                          <ITEMS>/Nothing [-/.].
    Nothing!
"
<CONSTANT MSG-IM-CARRYING "I'm carrying:">
<CONSTANT MSG-CARRYING-NOTHING "Nothing">

;"Save and Restore
    Save failed.                        Unable to create save file.                 -
    Load failed.                        Unable to restore game.                     -
    Saved.                              Saved.                                      -
"
<CONSTANT MSG-SAVE-FAILED "Save failed.">
<CONSTANT MSG-LOAD-FAILED "Load failed.">
<CONSTANT MSG-SAVE-SUCESS "Saved.">

;"Winning and Losing
    I’ve stored <NUM>                   [I’ve/You have] stored <NUM>                I’ve stored <NUM>                   I’ve stored <NUM>
       treasures. On a scale of 0         treasures. On a scale of 0                  treasures. On a scale of 0          TREASURES. On a scale of 0
       to 100, that rates a <NUM>.        to 100, that rates <NUM>.                   to 100, that rates <NUM>.           to 100, that rates <NUM>
    Well done.                          Well done.                                  Well done.
    I am dead.                          [I am/You are] dead.                        I am dead.                          I'm DEAD!!
    The game is now over.               The game is now over.                       The game is now over.               The Adventure is over.
    Another game?                       -                                           -                                   Want to try this Adventure again ?
"
<CONSTANT MSG-SCORE-1 "I've stored ">
<CONSTANT MSG-SCORE-2 " treasures. On a scale of 0 to 100 that rates ">         ;"If this msg have text then #stored treasures is printed + this text"
<CONSTANT MSG-SCORE-3 ".">                                                      ;"If this msg have text then total percentage is printed + this text"
<CONSTANT MSG-WINNING "Well done.">
<CONSTANT MSG-DEAD "I'm dead.">
<CONSTANT MSG-GAME-OVER "The game is now over.">

;"Moving Around
    Give me a direction too.            Give me a direction too.                    -                                   I need a direction too
    Dangerous to move in the dark!      Dangerous to move in the dark!              Dangerous to move in the dark!      It's dangerous to move in the dark!
    I fell down and broke my neck.      [I/You] fell down and broke your neck.      I fell down and broke my neck.      I fell and broke my neck! I'm DEAD!
    I can’t go in that direction.       [I/You] can't go in that direction.         I can't go in that direction.       I can't go in THAT direction
"
<CONSTANT MSG-MISSING-DIRECTION "Give me a direction too.">                     ;"go without direction"
<CONSTANT MSG-DANGEROUS-TO-MOVE "Dangerous to move in the dark!">               ;"sucessful move while dark"
<CONSTANT MSG-DARK-DEATH "I fell down and broke my neck.">                      ;"unsucessful move while dark"
<CONSTANT MSG-UNKNOWN-DIRECTION "I can't go in that direction.">                ;"unsucessful move"

;"Get and Drop
    What?                               What ?                                      What ?                              Huh?
    Nothing taken.                      Nothing taken.                              - [no get all]                                                          get all when nothing to get
    Nothing dropped.                    Nothing dropped.                            - [no drop all]                                                         drop all when nothing to drop
    It is dark.                         It is dark.                                 -
    It’s beyond my power to do that.    It is beyond [my/your] power to do that.    It's beyond my power to do that.    -                                   get/drop noun that's not in room/carried
    I don’t see it here.                - [It is beyond...]                         - [It is beyond...]                 I don’t see it here
    I’m not carrying it!                - [It is beyond...]                         - [It is beyond...]                 I’m not carrying it!
    I already have it.                  - [It is beyond...]                         - [It is beyond...]                 -
    I’ve too much to carry!             [I've too much to carry!/                   I've too much to carry!
                                          You are carrying too much.]
"
<CONSTANT MSG-WHAT "What?">                                 ;"get/drop without noun"
<CONSTANT MSG-DONT-SEE-IT-HERE "I don't see it here.">      ;"get noun that's not in room"
<CONSTANT MSG-DONT-CARRY-IT "I'm not carrying it.">         ;"drop noun that's not in carried"
<CONSTANT MSG-ALREADY-HAVE-IT "I already have it.">         ;"get noun that's in inventory"
<CONSTANT MSG-TOO-MUCH-TO-CARRY "I've too much to carry!">
<CONSTANT MSG-NOTHING-DROPPED "Nothing dropped.">
<CONSTANT MSG-NOTHING-TAKEN "Nothing taken.">

;"The Lamp                              SCOTTLIGHT = T/<>
    Light runs out in <NUM> turns.      Light runs out in <NUM> turns.              Your light is growing dim.
                                          /Your light is growing dim.
    Light has run out!                  Light has run out!/Your light has run out.  Your light has run out
"
<CONSTANT MSG-LIGHTS-OUT-WARNING-1 "Your light is growing dim.">
<CONSTANT MSG-LIGHTS-OUT-WARNING-2 "">                              ;"If this msg have text then #turn until light run is printed + this text"
<CONSTANT MSG-LIGHT-HAS-RUN-OUT "Light has run out!">

;"==========================================================================
  =                                                                        =
  =  Paste your data from the *.dat or *.sao in this table.                =
  =                                                                        =
  =========================================================================="

;"In this table you paste the *.dat or *.sao file. For example the output
  from Mike Taylors ScottKit https://github.com/MikeTaylor/scottkit"
<CONSTANT GAME-DAT <TABLE
 5953 
 65 
 169 
 69 
 33 
 6 
 11 
 13 
 3 
 125 
 75 
 3 
 75 
 161 
 386 
 160 
 200 
 0 
 17612 
 0 
 10 
 421 
 667 
 0 
 0 
 0 
 2011 
 0 
 10 
 401 
 420 
 400 
 146 
 0 
 1874 
 8850 
 8 
 523 
 520 
 260 
 349 
 0 
 2622 
 0 
 100 
 108 
 760 
 820 
 420 
 100 
 8312 
 9064 
 100 
 484 
 0 
 0 
 0 
 0 
 5613 
 0 
 5 
 141 
 140 
 20 
 246 
 0 
 6062 
 0 
 8 
 406 
 426 
 400 
 842 
 146 
 11145 
 0 
 8 
 482 
 152 
 0 
 0 
 0 
 2311 
 0 
 100 
 104 
 308 
 0 
 0 
 0 
 8626 
 0 
 50 
 161 
 246 
 160 
 1100 
 0 
 7259 
 7800 
 100 
 148 
 140 
 940 
 500 
 0 
 9062 
 9900 
 30 
 841 
 426 
 406 
 400 
 146 
 11145 
 0 
 50 
 542 
 143 
 0 
 0 
 0 
 10504 
 9150 
 100 
 248 
 642 
 720 
 640 
 700 
 8005 
 7950 
 100 
 248 
 542 
 1040 
 540 
 0 
 8005 
 0 
 100 
 28 
 49 
 20 
 40 
 0 
 6360 
 8700 
 100 
 288 
 260 
 280 
 0 
 0 
 11160 
 9150 
 100 
 248 
 240 
 0 
 0 
 0 
 9660 
 0 
 100 
 269 
 260 
 0 
 0 
 0 
 16558 
 17357 
 100 
 28 
 48 
 20 
 40 
 0 
 4110 
 9000 
 100 
 320 
 328 
 1200 
 180 
 0 
 9072 
 11400 
 100 
 524 
 583 
 580 
 1220 
 0 
 10800 
 0 
 4404 
 682 
 0 
 0 
 0 
 0 
 6900 
 0 
 4407 
 82 
 0 
 0 
 0 
 0 
 6900 
 0 
 1521 
 142 
 421 
 420 
 140 
 0 
 8902 
 17703 
 1542 
 462 
 146 
 482 
 0 
 0 
 2311 
 0 
 1521 
 142 
 401 
 400 
 140 
 0 
 8902 
 17703 
 2742 
 461 
 460 
 502 
 780 
 500 
 8864 
 8005 
 2742 
 461 
 460 
 0 
 0 
 0 
 7950 
 0 
 1523 
 482 
 146 
 0 
 0 
 0 
 2311 
 0 
 1523 
 482 
 141 
 266 
 0 
 0 
 2400 
 0 
 1523 
 482 
 141 
 261 
 260 
 520 
 10918 
 0 
 1533 
 0 
 0 
 0 
 0 
 0 
 9900 
 0 
 8454 
 364 
 0 
 0 
 0 
 0 
 7650 
 0 
 5100 
 0 
 0 
 0 
 0 
 0 
 9900 
 0 
 7209 
 581 
 344 
 460 
 0 
 0 
 8118 
 8614 
 2100 
 566 
 0 
 0 
 0 
 0 
 2850 
 0 
 2125 
 621 
 561 
 620 
 0 
 0 
 3021 
 9209 
 8716 
 523 
 340 
 0 
 0 
 0 
 8818 
 0 
 2125 
 622 
 561 
 620 
 240 
 0 
 10555 
 8720 
 184 
 404 
 702 
 380 
 0 
 0 
 8170 
 9600 
 1525 
 24 
 806 
 0 
 0 
 0 
 2400 
 0 
 1525 
 24 
 801 
 800 
 620 
 0 
 10918 
 0 
 2725 
 621 
 620 
 800 
 0 
 0 
 10918 
 3450 
 2125 
 362 
 561 
 0 
 0 
 0 
 3300 
 0 
 6803 
 0 
 0 
 0 
 0 
 0 
 17100 
 0 
 185 
 384 
 0 
 0 
 0 
 0 
 3750 
 0 
 1510 
 762 
 760 
 505 
 0 
 0 
 7918 
 0 
 2710 
 761 
 760 
 582 
 20 
 0 
 7986 
 8700 
 6343 
 921 
 920 
 0 
 0 
 0 
 509 
 0 
 1513 
 122 
 261 
 260 
 240 
 0 
 8902 
 17700 
 900 
 384 
 420 
 726 
 0 
 0 
 8164 
 0 
 900 
 424 
 380 
 0 
 0 
 0 
 8164 
 0 
 185 
 424 
 502 
 0 
 0 
 0 
 3900 
 0 
 185 
 424 
 505 
 440 
 0 
 0 
 8170 
 9600 
 8754 
 723 
 0 
 680 
 900 
 682 
 10853 
 11400 
 204 
 364 
 0 
 0 
 0 
 0 
 7650 
 0 
 2723 
 521 
 502 
 520 
 480 
 280 
 4259 
 8008 
 1513 
 122 
 266 
 0 
 0 
 0 
 2400 
 0 
 5751 
 62 
 0 
 0 
 0 
 0 
 300 
 0 
 207 
 40 
 102 
 0 
 0 
 0 
 8170 
 9600 
 2713 
 241 
 240 
 260 
 367 
 0 
 10918 
 4350 
 8267 
 443 
 1201 
 440 
 1200 
 0 
 8909 
 6669 
 1257 
 100 
 102 
 292 
 80 
 221 
 8303 
 1050 
 10370 
 104 
 322 
 286 
 0 
 0 
 900 
 0 
 5570 
 104 
 322 
 286 
 0 
 0 
 900 
 0 
 3611 
 221 
 60 
 220 
 0 
 0 
 4558 
 7950 
 10370 
 322 
 281 
 320 
 340 
 0 
 8303 
 11400 
 8400 
 0 
 0 
 0 
 0 
 0 
 3750 
 0 
 900 
 384 
 721 
 0 
 0 
 0 
 5011 
 0 
 8604 
 723 
 0 
 680 
 900 
 682 
 10853 
 11400 
 1537 
 722 
 720 
 0 
 0 
 0 
 7918 
 4800 
 4800 
 0 
 0 
 0 
 0 
 0 
 5100 
 0 
 3900 
 0 
 0 
 0 
 0 
 0 
 9813 
 0 
 1510 
 762 
 502 
 0 
 0 
 0 
 3900 
 0 
 2710 
 761 
 585 
 820 
 760 
 0 
 5303 
 8850 
 1088 
 68 
 765 
 60 
 0 
 0 
 18410 
 16710 
 1089 
 68 
 60 
 542 
 0 
 0 
 18339 
 9000 
 4950 
 0 
 0 
 0 
 0 
 0 
 9750 
 0 
 7050 
 401 
 0 
 0 
 0 
 0 
 10610 
 17055 
 7050 
 421 
 0 
 0 
 0 
 0 
 10610 
 17055 
 184 
 364 
 0 
 0 
 0 
 0 
 15300 
 0 
 1554 
 682 
 0 
 0 
 0 
 0 
 7650 
 0 
 7650 
 502 
 860 
 360 
 500 
 0 
 6212 
 8250 
 2723 
 521 
 542 
 480 
 880 
 540 
 8003 
 8293 
 1069 
 68 
 60 
 0 
 0 
 0 
 9001 
 16607 
 10370 
 342 
 0 
 0 
 0 
 0 
 9600 
 0 
 166 
 702 
 380 
 0 
 0 
 0 
 10554 
 9600 
 1088 
 68 
 760 
 100 
 80 
 762 
 8308 
 4710 
 6761 
 0 
 0 
 0 
 0 
 0 
 16614 
 0 
 5400 
 0 
 0 
 0 
 0 
 0 
 197 
 0 
 207 
 82 
 60 
 0 
 0 
 0 
 8170 
 9600 
 1257 
 102 
 221 
 100 
 80 
 281 
 8303 
 1200 
 5888 
 502 
 0 
 0 
 0 
 0 
 3947 
 0 
 5889 
 542 
 0 
 0 
 0 
 0 
 5897 
 0 
 6313 
 241 
 240 
 260 
 0 
 0 
 509 
 7800 
 6313 
 122 
 0 
 0 
 0 
 0 
 450 
 0 
 6342 
 463 
 460 
 0 
 0 
 0 
 509 
 0 
 1070 
 322 
 68 
 320 
 340 
 60 
 8303 
 810 
 4050 
 524 
 10 
 0 
 0 
 0 
 4950 
 0 
 4050 
 524 
 11 
 200 
 0 
 0 
 8170 
 9600 
 1200 
 226 
 0 
 0 
 0 
 0 
 5700 
 0 
 7232 
 943 
 221 
 220 
 500 
 140 
 12768 
 9358 
 7232 
 221 
 527 
 220 
 500 
 0 
 12768 
 9366 
 4217 
 183 
 0 
 0 
 0 
 0 
 7650 
 0 
 1521 
 142 
 140 
 0 
 0 
 0 
 7918 
 0 
 4217 
 203 
 169 
 960 
 160 
 0 
 7403 
 8700 
 4217 
 203 
 228 
 0 
 0 
 0 
 150 
 0 
 4217 
 203 
 208 
 220 
 960 
 0 
 7558 
 9209 
 4217 
 203 
 188 
 200 
 980 
 0 
 7558 
 9209 
 4217 
 203 
 168 
 980 
 180 
 0 
 7403 
 8700 
 7650 
 401 
 400 
 420 
 0 
 0 
 462 
 10800 
 7650 
 421 
 0 
 0 
 0 
 0 
 463 
 9150 
 4050 
 527 
 0 
 0 
 0 
 0 
 15300 
 0 
 9000 
 0 
 0 
 0 
 0 
 0 
 150 
 0 
 7232 
 222 
 0 
 0 
 0 
 0 
 17785 
 18600 
 2117 
 183 
 0 
 0 
 0 
 0 
 1500 
 0 
 6807 
 0 
 0 
 0 
 0 
 0 
 15450 
 0 
 2723 
 521 
 480 
 520 
 260 
 0 
 8022 
 17700 
 6780 
 0 
 0 
 0 
 0 
 0 
 15450 
 0 
 6771 
 0 
 0 
 0 
 0 
 0 
 15450 
 0 
 1110 
 68 
 60 
 524 
 220 
 200 
 9062 
 17700 
 207 
 224 
 560 
 0 
 0 
 0 
 8170 
 9600 
 7050 
 524 
 0 
 0 
 0 
 0 
 16605 
 16350 
 7050 
 224 
 0 
 0 
 0 
 0 
 16605 
 0 
 7050 
 384 
 0 
 0 
 0 
 0 
 16605 
 0 
 7050 
 464 
 0 
 0 
 0 
 0 
 16606 
 0 
 7050 
 264 
 0 
 0 
 0 
 0 
 16609 
 0 
 7050 
 344 
 0 
 0 
 0 
 0 
 16609 
 0 
 7050 
 304 
 0 
 0 
 0 
 0 
 16609 
 0 
 7050 
 424 
 0 
 0 
 0 
 0 
 16605 
 0 
 7050 
 164 
 0 
 0 
 0 
 0 
 16608 
 0 
 5570 
 281 
 322 
 340 
 320 
 0 
 8005 
 0 
 206 
 342 
 120 
 0 
 0 
 0 
 8156 
 10564 
 2117 
 203 
 200 
 180 
 0 
 0 
 10810 
 11400 
 5567 
 183 
 180 
 200 
 0 
 0 
 10918 
 1426 
 1551 
 62 
 0 
 0 
 0 
 0 
 1711 
 0 
 166 
 1042 
 480 
 0 
 0 
 0 
 8170 
 9600 
 1549 
 0 
 0 
 0 
 0 
 0 
 16611 
 0 
 2100 
 561 
 365 
 0 
 0 
 0 
 3600 
 0 
 7650 
 0 
 0 
 0 
 0 
 0 
 150 
 0 
 7209 
 581 
 347 
 340 
 667 
 527 
 8118 
 8464 
 7050 
 24 
 0 
 0 
 0 
 0 
 16605 
 0 
 3611 
 226 
 0 
 0 
 0 
 0 
 5700 
 0 
 7050 
 404 
 0 
 0 
 0 
 0 
 16616 
 15450 
 7232 
 0 
 0 
 0 
 0 
 0 
 17785 
 150 
 166 
 84 
 100 
 0 
 0 
 0 
 8170 
 9600 
 1542 
 462 
 460 
 0 
 0 
 0 
 7918 
 0 
 7050 
 0 
 0 
 0 
 0 
 0 
 270 
 0 
 1200 
 0 
 0 
 0 
 0 
 0 
 197 
 0 
 3600 
 0 
 0 
 0 
 0 
 0 
 16800 
 0 
 1050 
 68 
 60 
 0 
 0 
 0 
 9122 
 150 
 5315 
 0 
 0 
 0 
 0 
 0 
 17771 
 0 
 4200 
 0 
 0 
 0 
 0 
 0 
 150 
 0 
 7200 
 0 
 0 
 0 
 0 
 0 
 17785 
 150 
 6300 
 0 
 0 
 0 
 0 
 0 
 17850 
 0 
 2713 
 241 
 364 
 240 
 260 
 0 
 15673 
 10800 
 0 
 2 
 1120 
 0 
 0 
 0 
 10800 
 0 
 1559 
 2 
 0 
 0 
 0 
 0 
 7650 
 0 
 1559 
 1122 
 1120 
 0 
 0 
 0 
 17752 
 0 
 6750 
 0 
 0 
 0 
 0 
 0 
 17100 
 0 
 5762 
 1243 
 0 
 0 
 0 
 0 
 10623 
 0 
 4366 
 0 
 0 
 0 
 0 
 0 
 6900 
 0 
 900 
 0 
 0 
 0 
 0 
 0 
 15300 
 0 
 5868 
 0 
 0 
 0 
 0 
 0 
 17100 
 0 
 5850 
 0 
 0 
 0 
 0 
 0 
 3750 
 0 
 4350 
 0 
 0 
 0 
 0 
 0 
 17825 
 11400 
 1050 
 0 
 0 
 0 
 0 
 0 
 18150 
 0 
 166 
 584 
 600 
 0 
 0 
 0 
 8176 
 0 
"AUT"
"ANY"
"GO"
"NORTH"
"*ENT"
"SOUTH"
"*RUN"
"EAST"
"*WAL"
"WEST"
"*CLI"
"UP"
"JUM"
"DOWN"
"AT"
"NET"
"CHO"
"FIS"
"*CUT"
"AWA"
"GET"
"MIR"
"*TAK"
"AXE"
"*PIC"
"*AX"
"*CAT"
"WAT"
"LIG"
"BOT"
"*."
"*CON"
"*IGN"
"HOL"
"*BUR"
"LAM"
"DRO"
"SPI"
"*REL"
"WIN"
"*SPI"
"DOO"
"*LEA"
"MUD"
"*GIV"
"*MED"
"*POU"
"BEE"
"THR"
"ROC"
"*TOS"
"GAS"
"QUI"
"FLI"
"SWI"
"EGG"
"RUB"
"OIL"
"LOO"
"*SLI"
"*EXA"
"KEY"
"*DES"
"HEL"
"STO"
"BUN"
"SCO"
"INV"
"INV"
"LED"
"SAV"
"THR"
"WAK"
"CRO"
"UNL"
"BRI"
"REA"
"BEA"
"ATT"
"DRA"
"*SLA"
"RUG"
"*KIL"
"RUB"
"DRI"
"HON"
"*EAT"
"FRU"
"."
"OX"
"FIN"
"RIN"
"*LOC"
"CHI"
"HEL"
"*BIT"
"SAY"
"BRA"
"*SPE"
"SIG"
"*CAL"
"BLA"
"SCR"
"WEB"
"*YEL"
"*WRI"
"*HOL"
"SWA"
"."
"LAV"
"FIL"
"*DAM"
"CRO"
"HAL"
"DAM"
"TRE"
"MAK"
"*STU"
"*BUI"
"FIR"
"WAV"
"SHO"
"*TIC"
"*BAN"
"*KIC"
"ADV"
"*KIS"
"GLA"
"*TOU"
"ARO"
"*FEE"
"GAM"
"*FUC"
"BOO"
"*HIT"
"CHA"
"*POK"
"LAK"
"OPE"
"YOH"
 0 
 7 
 10 
 1 
 0 
 24 
""
 23 
 0 
 29 
 25 
 0 
 0 
"dismal swamp"
 0 
 0 
 0 
 0 
 0 
 1 
"top of a tall cypress tree"
 0 
 0 
 0 
 0 
 1 
 4 
"damp hollow stump in the swamp"
 0 
 0 
 0 
 0 
 3 
 0 
"root chamber under the stump"
 0 
 0 
 0 
 0 
 4 
 0 
"semi-dark hole by the root chamber"
 0 
 0 
 0 
 0 
 5 
 7 
"long down sloping hall"
 31 
 9 
 0 
 27 
 6 
 12 
"large cavern"
 0 
 31 
 0 
 0 
 0 
 0 
"large 8 sided room"
 7 
 0 
 0 
 0 
 20 
 0 
"royal anteroom"
 26 
 29 
 0 
 23 
 0 
 0 
"*I'm on the shore of a lake"
 11 
 11 
 23 
 11 
 0 
 0 
"forest"
 13 
 15 
 15 
 0 
 0 
 13 
"maze of pits"
 0 
 0 
 0 
 14 
 12 
 0 
"maze of pits"
 17 
 12 
 13 
 16 
 16 
 17 
"maze of pits"
 12 
 0 
 13 
 12 
 13 
 0 
"maze of pits"
 0 
 17 
 0 
 0 
 14 
 17 
"maze of pits"
 17 
 12 
 12 
 15 
 14 
 18 
"maze of pits"
 0 
 0 
 0 
 0 
 17 
 0 
"*I'm at the bottom of a very deep chasm. High above me is
a pair of ledges. One has a bricked up window across its face
the other faces a Throne-room"
 0 
 0 
 0 
 20 
 0 
 0 
"*I'm on a narrow ledge by a chasm. Across the chasm is
the Throne-room"
 0 
 0 
 0 
 0 
 0 
 9 
"royal chamber"
 0 
 0 
 0 
 0 
 0 
 0 
"*I'm on a narrow ledge by a Throne-room
Across the chasm is another ledge"
 0 
 0 
 0 
 21 
 0 
 0 
"throne room"
 0 
 1 
 10 
 11 
 0 
 0 
"sunny meadow"
 0 
 0 
 0 
 0 
 0 
 0 
"*I think I'm in real trouble now. There's a fellow here with
a pitchfork and pointed tail. ...Oh Hell!"
 11 
 0 
 1 
 0 
 0 
 0 
"hidden grove"
 0 
 0 
 0 
 0 
 0 
 0 
"quick-sand bog"
 0 
 0 
 7 
 0 
 0 
 0 
"Memory chip of a COMPUTER!
I took a wrong turn!"
 0 
 0 
 0 
 0 
 0 
 11 
"top of an oak.
To the East I see a meadow, beyond that a lake."
 10 
 0 
 0 
 1 
 0 
 0 
"*I'm at the edge of a BOTTOMLESS hole"
 0 
 0 
 0 
 0 
 29 
 24 
"*I'm on a ledge just below the rim of the BOTTOMLESS hole. I
don't think I want to go down"
 8 
 7 
 0 
 0 
 0 
 0 
"long tunnel. I hear buzzing ahead"
 32 
 33 
 32 
 32 
 32 
 32 
"*I'm in an endless corridor"
 32 
 24 
 11 
 24 
 28 
 24 
"large misty room with strange
unreadable letters over all the exits."
""
"Nothing happens"
"Chop 'er down!"
"BOY that really hit the spot!"
"Dragon smells something. Awakens & attacks me!"
"Lock shatters"
"I can't its locked"
"TIMBER. Something fell from the tree top & vanished in the swamp"
"TIMBER!"
"Lamp is off"
"Lamp burns with a cold flameless blue glow."
"I'm bit by a spider"
"
My chigger bites are now INFECTED!
"
"My bites have rotted my whole body!"
"Bear eats the honey and falls asleep."
"Bees sting me"
"First I need an empty container."
"The bees all suffocated and disappeared"
"Something I'm holding vibrates and..."
"nothing to light it with"
"Gas bladder blew up"
"in my hands!"
"gas needs to be contained before it will burn"
"Gas dissipates. (I think you blew it)"
"That won't ignite"
"How?"
"Bear won't let me"
"`Don't waste honey, get mad instead! Dam lava!?`"
"Bees madden bear, bear then attacks me!"
"It soaks into the ground"
"In 2 words tell me at what...like: AT TREE"
"OH NO... Bear dodges... CRASH!"
"Its heavy!"
"Somethings too heavy. I fall."
"To stop game say QUIT"
"Mirror hits floor and shatters into a MILLION pieces"
"Mirror lands softly on rug, lights up and says:"
"You lost *ALL* treasures."
"I'm not carrying ax, take inventory!"
"It doesn't seem to bother him at all!"
"The mud dried up and fell off."
"Bear is so startled that he FELL off the ledge!"
"` DRAGON STING ` and fades. I don't get it, I hope you do."
"The bees attack the dragon which gets so annoyed it gets up
and flys away..."
"Lamp is now full & lit"
"
I'm bitten by chiggers.
"
"There's something there all right! Maybe I should go there?"
"Maybe if I threw something?..."
"Too dry, the fish died."
"A glowing Genie appears, drops somehting, then vanishes."
"A glowing Genie appears, says `Boy you're selfish`, takes
something and then makes `ME` vanish!"
"No, its too hot."
"Not here."
"Try the swamp"
"Sizzle..."
"Try --> `LOOK, JUMP, SWIM, CLIMB, FIND, TAKE, SCORE, DROP`
and any other verbs you can think of..."
"There are only 3 ways to wake the Dragon!"
"Remember you can always say `HELP`"
"Read the sign in the meadow!"
"You may need to say magic words here"
"A voice BOOOOMS out:"
"please leave it alone"
"Sorry, I can only throw the ax."
"Medicine is good for bites."
"I don't know where it is"
"
Welcome to Adventure number: 1 `ADVENTURELAND`.
In this Adventure you're to find *TREASURES* & store them away.

To see how well you're doing say: `SCORE`"
"Blow it up!"
"Fish have escaped back to the lake."
"OK"
"Huh? I don't think so!"
"You might try examining things..."
"What?"
"OK, I threw it."
"
Check with your favorite computer dealer for the next Adventure
program: PIRATE ADVENTURE. If they don't carry `ADVENTURE` have
them call: 1-305-862-6917 today!
"
"The ax vibrated!"
"I see nothing special"
"Glowing *FIRESTONE*" 0 
"Dark hole" 4 
"*Pot of RUBIES*/RUB/" 4 
"Spider web with writing on it" 2 
"-HOLLOW- stump and remains of a felled tree" 0 
"Cypress tree" 1 
"Water" 10 
"Evil smelling mud/MUD/" 1 
"*GOLDEN FISH*/FIS/" 10 
"Lit brass lamp/LAM/" 0 
"Old fashioned brass lamp/LAM/" 3 
"Rusty axe (Magic word `BUNYON` on it)/AXE/" 10 
"Water in bottle/BOT/" 3 
"Empty bottle/BOT/" 0 
"Ring of skeleton keys/KEY/" 2 
"Sign `Leave *TREASURES* here, then say: SCORE`" 3 
"Locked door" 5 
"Open door with a hallway beyond" 0 
"Swamp gas" 1 
"*GOLDEN NET*/NET/" 18 
"Chigger bites" 0 
"Infected chigger bites" 0 
"Patches of `OILY` slime/OIL/" 1 
"*ROYAL HONEY*/HON/" 8 
"Large african bees" 8 
"Very thin black bear" 21 
"Bees in a bottle/BOT/" 0 
"Large sleeping dragon" 23 
"Flint & steel/FLI/" 30 
"*Thick PERSIAN RUG*/RUG/" 17 
"Sign: `magic word's AWAY! Look la...`
(Rest of sign is missing!)" 18 
"Distended gas bladder/BLA/" 0 
"Bricked up window" 20 
"Sign here says `In many cases mud is good. In others...`" 23 
"Stream of lava" 18 
"Bricked up window with a hole in it" 0 
"Loose fire bricks/BRI/" 0 
"*GOLD CROWN*/CRO/" 22 
"*MAGIC MIRROR*" 21 
"Sleeping bear" 0 
"Empty wine bladder/BLA/" 9 
"Broken glass/GLA/" 0 
"Chiggers/CHI/" 1 
"Slightly woozy bear" 0 
"*DRAGON EGGS* (very rare)/EGG/" 0 
"Lava stream with brick dam" 0 
"*JEWELED FRUIT*/FRU/" 25 
"*Small statue of a BLUE OX*/OX/" 26 
"*DIAMOND RING*/RIN/" 0 
"*DIAMOND BRACELET*/BRA/" 0 
"Strange scratchings on rock says: `ALADIN was here`" 14 
"Sign says `LIMBO. Find right exit and live again!`" 33 
"Smoking hole. pieces of dragon and gore." 0 
"Sign says `No swimming allowed here`" 10 
"Arrow pointing down" 17 
"Dead fish/FIS/" 0 
"*FIRESTONE* (cold now)/FIR/" 0 
"Sign says `Paul's place`" 25 
"Trees" 11 
"Sign here says `Opposite of LIGHT is UNLIGHT`" 12 
"Empty lamp/LAM/" 0 
"Muddy worthless old rug/RUG/" 0 
"Large outdoor Advertisement/ADV/" 29 
"Hole" 29 
"" 0 
"" 0 
"FISH ESCAPE"
"DIE BITES"
"BITE INFECT"
"BEES DIE"
"HIT MIRROR"
"IN HADES"
"MUD OFF"
"BIT CHIG"
"BEE STING"
"LITE"
"FISH DIE"
"MOVE OX"
"GET CHIG"
"MUD DRAGON"
"BLAST WALL"
"BLAS DRAGON"
"1ST MIRROR CLUE"
"BEAR MAD"
"RESET BLAST"
"INTRO"
"2ND MIRROR CLUE"
"DEAD LAMP"
"MUDDY RUG"
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
"BUILD DAM"
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
 416 
 1 
 819 
>>
