;"Copyright (C) 2020 heasm66
You can redistribute and/or modify this file under the terms of the
GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any
later version.
This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.
You should have received a copy of the GNU General Public License
along with this file. If not, see <https://www.gnu.org/licenses/>."


<CONSTANT RELEASEID 8>

;"Insert the gamedata-file"
<INSERT-FILE "game-dat">
<INSERT-FILE "unpack">

;"=====================================================================================
  Definition of constants and globals
  ====================================================================================="

<CONSTANT SCREEN-BAR <ISTRING ,SCREEN-WIDTH !\=>>

;"Define global variables and constants"
<CONSTANT FLAG-LAMP-EMPTY 16>
<CONSTANT FLAG-DARK 15>
<CONSTANT LIGHT-SOURCE-ID 9>
<CONSTANT LIGHT-WARNING-THRESHOLD 25>
<CONSTANT VERB-GET 10>
<CONSTANT VERB-DROP 18>
<CONSTANT VERB-GO 1>
<CONSTANT STATUS-FLAGS 32>
<CONSTANT DIRECTION-NOUNS 6>        ;"Directions ARE always noun 1-6"
<CONSTANT ROOM-INVENTORY -1>
<CONSTANT COUNTER-TIME-LIMIT 8>

<CONSTANT ABBREVIATIONS
    <TABLE
        <STRING-TO-TABLE "go north">
        <STRING-TO-TABLE "go south">
        <STRING-TO-TABLE "go east">
        <STRING-TO-TABLE "go west">
        <STRING-TO-TABLE "go up">
        <STRING-TO-TABLE "go down">
        <STRING-TO-TABLE "look">
        <STRING-TO-TABLE "take inventory">
    >
>
<CONSTANT SPECIAL-COMMANDS
    <TABLE
        <STRING-TO-TABLE "load">
        <STRING-TO-TABLE "game">
        <STRING-TO-TABLE "change">
        <STRING-TO-TABLE "mode">
        <STRING-TO-TABLE "about">
    >
>

<GLOBAL CURRENT-ROOM <>>
<GLOBAL SA-FLAGS <ITABLE NONE ,STATUS-FLAGS (BYTE)>>
<GLOBAL READBUF <ITABLE NONE 63 (BYTE)>>
<GLOBAL PARSEBUF <ITABLE NONE 63 (BYTE)>>
<GLOBAL SA-VERB <ITABLE NONE 10 (BYTE)>>
<GLOBAL SA-NOUN <ITABLE NONE 10 (BYTE)>>
<GLOBAL CONTINUE-FLAG <>>
<GLOBAL ALTERNATE-ROOM <TABLE 0 0 0 0 0 0 0 0 0 0>>
<GLOBAL ALTERNATE-COUNTER <TABLE 0 0 0 0 0 0 0 0 0 0>>
<GLOBAL COUNTER-REGISTER 0>
<GLOBAL ALTERNATE-ROOM-REGISTER 0>
<GLOBAL INSTRUCTION-ARG-INDEX 1>

;"Version 3 always has a statusline. These are for that!"
<GLOBAL SCORE 0>
<GLOBAL MOVES 0>
<OBJECT ROOMS <LIST DESC " ">>      ;"Create one empty room for V3 statusline"
<GLOBAL HERE 1>                     ;"Position player in the empty room (only for V3 statusline)"

<GLOBAL CURPOS <TABLE 0 0>>

<GLOBAL ROOM-DESC-PRINTED? <>>      ;"Flag to assure that room-desc only prints once every cycle"

;"The game-loop starts here"
<ROUTINE GO ()
    <COND (<VERSION? (ZIP)>     ;"Version 3 is always conversational"
        <SETG GAME-CONVERSATIONAL T>
        <SETG CAN-PLAYER-CHANGE-GAME-MODE <>>
    )>
    <COND (,COMPACT-ROOM-DESC <SETG STARTING-SPLITROW <- ,STARTING-SPLITROW 3>>)>
    <CRLF>
    <COND (,USE-FIXED-FONT <FIXED-FONT-ON>)>            ;"Use fixed font?"
    <SETG CURRENT-ROOM ,STARTING-ROOM>
    <PUT ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT ,TIME-LIGHT-SOURCE-LASTS>  ;"Set time limit counter. Counter 8 is always for light source."
    <SHOW-INTRO>
    <COND (,GAME-CONVERSATIONAL <RUN-ACTIONS 0 0> <SHOW-ROOM-DESC> )
          (ELSE <SHOW-ROOM-DESC> <RUN-ACTIONS 0 0>)>
    <MAIN-LOOP>
>

<ROUTINE MAIN-LOOP ()
    <REPEAT (TEMP NUMBER-OF-WORDS WLEN LOOP-START LOOP-END VERB-ID NOUN-ID NON-SYN-VERB-ID NON-SYN-NOUN-ID STORED-TREASURES)
        ;"Clear buffers"
        <DO (I 0 62) <PUTB ,READBUF .I 0>>
        <DO (I 0 62) <PUTB ,PARSEBUF .I 0>>
        <DO (I 0 9) <PUTB ,SA-VERB .I 0>>
        <DO (I 0 9) <PUTB ,SA-NOUN .I 0>>

        <SETG ROOM-DESC-PRINTED? <>>    ;"Clear flag"

        <COND (<AND ,EXTRA-NEWLINE-BEFORE-PROMPT-IN-CONVERSATIONAL? ,GAME-CONVERSATIONAL> <CRLF>)>
        <TELL ,MSG-PROMPT>
        <PUTB ,READBUF 0 60>
        <PUTB ,PARSEBUF 0 6>
        <READ ,READBUF ,PARSEBUF>
        <SET NUMBER-OF-WORDS <GETB ,PARSEBUF 1>> ;"Contains number of parsed words"
        <SET WLEN <GETB ,PARSEBUF 4>>  ;"Length of first word"
        <SET LOOP-START <GETB ,PARSEBUF 5>>

        ;"Replace n, s, e, w, u, d, l & i with go north, go south, ..."
        <COND (<AND <=? .NUMBER-OF-WORDS 1> <=? .WLEN 1>>
            <CHECK-ABBREVIATIONS .LOOP-START>
            <SET NUMBER-OF-WORDS <GETB ,PARSEBUF 1>> ;"reread number of parsed words"
        )>

        ;"Put the first word in SA-VERB and (if exists) the second word   in SA-NOUN. If there is more
        than two words (or no words) both tables are left blank."
        <COND (<AND <L=? .NUMBER-OF-WORDS 2> <G=? .NUMBER-OF-WORDS 1>>
            ;"Word 1 --> SA-VERB (up to 9 chars)"
            <SET WLEN <GETB ,PARSEBUF 4>>
            <COND (<G? .WLEN 9> <SET WLEN 9>)>
            <SET LOOP-START <GETB ,PARSEBUF 5>>
            <SET LOOP-END <+ .LOOP-START <- .WLEN 1>>>
            <DO (I .LOOP-START .LOOP-END) <PUTB ,SA-VERB <- .I .LOOP-START> <GETB ,READBUF .I>>>

            <COND (<=? .NUMBER-OF-WORDS 2>
                ;"Word 2 --> SA-NOUN (up to 9 chars)"
                <SET WLEN <GETB ,PARSEBUF 8>>
                <COND (<G? .WLEN 9> <SET WLEN 9>)>
                <SET LOOP-START <GETB ,PARSEBUF 9>>
                <SET LOOP-END <+ .LOOP-START <- .WLEN 1>>>
                <DO (I .LOOP-START .LOOP-END) <PUTB ,SA-NOUN <- .I .LOOP-START> <GETB ,READBUF .I>>>
            )>
        )>

        ;"load game?"
        <COND (<AND <WORD-EQUAL? ,SA-VERB <GET ,SPECIAL-COMMANDS 0>> <WORD-EQUAL? ,SA-NOUN <GET ,SPECIAL-COMMANDS 1>>>
            <COND (<RESTORE>
                <SHOW-ROOM-DESC>)
            (ELSE
                <TELL ,MSG-LOAD-FAILED CR>
            )>
        <AGAIN>
        )>

        ;"change mode?"
        <COND (<AND <WORD-EQUAL? ,SA-VERB <GET ,SPECIAL-COMMANDS 2>> <WORD-EQUAL? ,SA-NOUN <GET ,SPECIAL-COMMANDS 3>>
                    ,CAN-PLAYER-CHANGE-GAME-MODE>
            <CHANGE-GAME-MODE>
            <AGAIN>
        )>

        ;"about game?"
        <COND (<AND <WORD-EQUAL? ,SA-VERB <GET ,SPECIAL-COMMANDS 4>> <WORD-EQUAL? ,SA-NOUN <GET ,SPECIAL-COMMANDS 1>>>
            <ABOUT>
            <AGAIN>
        )>

        ;"Identify verb and noun"
        <SET VERB-ID 0>
        <SET NOUN-ID 0>
        <COND (<AND <L=? .NUMBER-OF-WORDS 2> <G=? .NUMBER-OF-WORDS 1>>
            <DO (I 0 ,NUMBER-VOCABULARY)
                ;"Identify verb"
                <COND (<0? .VERB-ID>   ;"Get the FIRST match"
                    <SET TEMP <GET <GET ,VOCABULARY-TABLE .I> 1>>  ;"Current verb"
                    <COND (<=? <GETB .TEMP 0> !\*>
                        <SET TEMP <REST .TEMP>>     ;"If synonym remove the * for before comparing"
                    )
                    (ELSE
                        <SET NON-SYN-VERB-ID .I>
                    )>
                    <COND (<WORD-EQUAL? .TEMP ,SA-VERB> <SET VERB-ID .NON-SYN-VERB-ID>)>
                )>

                ;"Identify noun"
                <COND (<=? .NUMBER-OF-WORDS 2>
                    <COND (<0? .NOUN-ID>   ;"Get the FIRST match"
                        <SET TEMP <GET <GET ,VOCABULARY-TABLE .I> 2>>  ;"Current noun"
                        <COND (<=? <GETB .TEMP 0> !\*>
                            <SET TEMP <REST .TEMP>>     ;"If synonym remove the * for before comparing"
                        )
                        (ELSE
                            <SET NON-SYN-NOUN-ID .I>
                        )>
                        <COND (<WORD-EQUAL? .TEMP ,SA-NOUN> <SET NOUN-ID .NON-SYN-NOUN-ID>)>
                    )>
                )>
            >
        )>

        <COND (<AND <OR <0? .VERB-ID> <AND <=? .NUMBER-OF-WORDS 2> <0? .NOUN-ID>>>
                    <NOT <OR <=? .VERB-ID ,VERB-GET> <=? .VERB-ID ,VERB-DROP>>>>
            <TELL ,MSG-UNKNOWN-WORDS CR>
            <AGAIN>
        )>

        <RUN-ACTIONS .VERB-ID .NOUN-ID>
        <SET VERB-ID 0>

        ;"Check and change light status"
        <COND (<AND <NOT <=? <GET-ITEM-LOC ,LIGHT-SOURCE-ID> 0>>                    ;"0 = Destroyed"
                    <NOT <=? <GET ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT> -1>>>    ;"-1 on counter mean lights never run out"
            <PUT ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT <- <GET ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT> 1>>

            <COND (<L? <GET ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT> 0>
                <TELL ,MSG-LIGHT-HAS-RUN-OUT CR>
                <SET-ITEM-LOC ,LIGHT-SOURCE-ID 0>
            )
            (ELSE
                <COND (<L=? <GET ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT> ,LIGHT-WARNING-THRESHOLD>
                    <TELL ,MSG-LIGHTS-OUT-WARNING-1>
                    <COND (<NOT <=? ,MSG-LIGHTS-OUT-WARNING-2 "">>
                        <TELL N <GET ,ALTERNATE-COUNTER ,COUNTER-TIME-LIMIT> ,MSG-LIGHTS-OUT-WARNING-2>
                    )>
                    <TELL CR>
                )>
            )>
        )>

        ;"Update moves and score (for V3 statusline)"
        <SETG MOVES <+ ,MOVES 1>>
        <SETG SCORE 0>
        <SET STORED-TREASURES 0>
        <DO (I 0 ,NUMBER-ITEMS)
            <COND (<AND <ITEM-TREASURE? .I> <=? <GET-ITEM-LOC .I> ,TREASURE-ROOM>>
                <SET STORED-TREASURES <+ .STORED-TREASURES 1>>
            )>
        >
        <COND (<NOT <0? ,TOTAL-TREASURES>> <SETG SCORE </ <* .STORED-TREASURES 100> ,TOTAL-TREASURES>>)>


        <RUN-ACTIONS .VERB-ID .NOUN-ID>         ;"Chek if possible AUT-actions needs to run"

        <COND (<AND <NOT ,GAME-CONVERSATIONAL> <NOT ,ROOM-DESC-PRINTED?>> <SHOW-ROOM-DESC>)>    ;"Refresh if split screen"
    >
>

<ROUTINE RUN-ACTIONS (VERB-ID NOUN-ID
                        "AUX" ROOM-DARK DEST FOUND-WORD WORD-ACTION-DONE
                              ACTION-VERB-ID ACTION-NOUN-ID)

    ;"Handle GO [direction]"
    <COND (<AND <=? .VERB-ID ,VERB-GO> <L=? .NOUN-ID ,DIRECTION-NOUNS>>
        <SET ROOM-DARK <AND <GET-FLAG ,FLAG-DARK>
                            <NOT <=? <GET-ITEM-LOC ,LIGHT-SOURCE-ID> ,CURRENT-ROOM>>
                            <NOT <=? <GET-ITEM-LOC ,LIGHT-SOURCE-ID> ,ROOM-INVENTORY>>>>
        <COND (.ROOM-DARK <TELL ,MSG-DANGEROUS-TO-MOVE CR>)>

        <COND (<0? .NOUN-ID> <TELL ,MSG-MISSING-DIRECTION CR> <RETURN>)>

        <SET DEST <GET-ROOM-EXIT ,CURRENT-ROOM .NOUN-ID>>

        <COND (<0? .DEST>
            <COND (.ROOM-DARK
                <TELL ,MSG-DARK-DEATH CR>
                <SET DEST ,NUMBER-ROOMS>
                <SET-FLAG ,FLAG-DARK <>>        ;"Turn on the light for LIMBO or DEATH"
            )
            (ELSE
                <TELL ,MSG-UNKNOWN-DIRECTION CR>
                <RETURN>
            )>
        )>

        <SETG ,CURRENT-ROOM .DEST>
        <SHOW-ROOM-DESC>
        <RETURN>
    )>

    ;"Run through all actions"
    <SET FOUND-WORD <>>
    <SETG CONTINUE-FLAG <>>
    <SET WORD-ACTION-DONE <>>
    <DO (I 0 ,NUMBER-ACTIONS)
        <SET ACTION-VERB-ID <GET-ACTION-VERB-ID .I>>
        <SET ACTION-NOUN-ID <GET-ACTION-NOUN-ID .I>>

        ;"Continue-action?"
        <COND (<AND ,CONTINUE-FLAG <0? .ACTION-VERB-ID> <0? .ACTION-NOUN-ID>>
            <COND (<EVALUATE-CONDITIONS .I> <EXECUTE-COMMANDS .I>)>
        )
        (ELSE
            <SET CONTINUE-FLAG <>> ;"'CONT' condition failures won't reset the CONT flag!"
        )>

        ;"AUT action - Is this an 'occur' action?"
        <COND (<AND <0? .VERB-ID> <0? .ACTION-VERB-ID> <G? .ACTION-NOUN-ID 0>>
            <SET CONTINUE-FLAG <>>
            <COND (<L=? <RANDOM 100> .ACTION-NOUN-ID>
                <COND (<EVALUATE-CONDITIONS .I> <EXECUTE-COMMANDS .I>)>
            )>
        )>

        ;"Word action"
        <COND (<G? .VERB-ID 0>
            <COND (<=? .ACTION-VERB-ID .VERB-ID>
                <COND (<NOT .WORD-ACTION-DONE>
                    <SET CONTINUE-FLAG <>>
                    <COND (<OR <0? .ACTION-NOUN-ID> <=? .ACTION-NOUN-ID .NOUN-ID>>
                        <SET FOUND-WORD T>
                        <COND (<EVALUATE-CONDITIONS .I>
                            <EXECUTE-COMMANDS .I>
                            <SET .WORD-ACTION-DONE T>
                            <COND (<NOT ,CONTINUE-FLAG> <RETURN>)>
                        )>
                    )>
                )>
            )>
        )>
    >

    <COND (<0? .VERB-ID> <RETURN>)>

    <COND (.WORD-ACTION-DONE <RETURN>)>

    <COND (<OR <NOT .FOUND-WORD> ,AUTOGET-AS-SCOTTFREE>
        <COND (<HANDLE-GET-DROP .VERB-ID .NOUN-ID> <RETURN>)>
    )>

    <COND (.FOUND-WORD
        <TELL ,MSG-CANT-DO-THAT-YET CR>
    )
    (ELSE
        <TELL ,MSG-DONT-UNDERSTAND CR>
    )>
>

<ROUTINE EVALUATE-CONDITIONS (ACTION-ID "AUX" CONDITION-CODE CONDITION-ARG)
    ;"Iterate over conditions. All needs to be true, one false fails test"
    <DO (I 1 5)
        <SET CONDITION-CODE <GET-CONDITION-CODE .ACTION-ID .I>>
        <SET CONDITION-ARG <GET-CONDITION-ARG .ACTION-ID .I>>
        <COND (<NOT <TEST-CONDITION .CONDITION-CODE .CONDITION-ARG>> <RFALSE>)>
    >
    <RTRUE>
>

<ROUTINE TEST-CONDITION (CODE ARG)
    ;"0 Par - param - <arg> is a parameter to one of the following actions. Always RTRUErue."
    <COND (<=? .CODE 0>
        <RTRUE>
    )>

    ;"1 HAS - carried - Item <arg> carried"
    <COND (<=? .CODE 1>
        <COND (<=? <GET-ITEM-LOC .ARG> ,ROOM-INVENTORY> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"2 IN/W - here - Item <arg> in room with player"
    <COND (<=? .CODE 2>
        <COND (<=? <GET-ITEM-LOC .ARG> ,CURRENT-ROOM> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"3 AVL - present - Item <arg> carried or in room with player"
    <COND (<=? .CODE 3>
        <COND (<OR <=? <GET-ITEM-LOC .ARG> ,ROOM-INVENTORY> <=? <GET-ITEM-LOC .ARG> ,CURRENT-ROOM>> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"4 IN - at - In room <arg>"
    <COND (<=? .CODE 4>
        <COND (<=? .ARG ,CURRENT-ROOM> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"5 -IN/W - !here, Item <arg> not in room with player"
    <COND (<=? .CODE 5>
        <COND (<NOT <=? <GET-ITEM-LOC .ARG> ,CURRENT-ROOM>> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"6 -HAVE - !carried, Item <arg> not carried"
    <COND (<=? .CODE 6>
        <COND (<NOT <=? <GET-ITEM-LOC .ARG> ,ROOM-INVENTORY>> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"7 -IN - !at - Not in room <arg>"
    <COND (<=? .CODE 7>
        <COND (<NOT <=? .ARG ,CURRENT-ROOM>> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"8 BIT - flag - BitFlag <arg> is set. "
    <COND (<=? .CODE 8>
        <COND (<GET-FLAG .ARG> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"9 .BIT - !flag - BitFlag <arg> is cleared"
    <COND (<=? .CODE 9>
        <COND (<NOT <GET-FLAG .ARG>> <RTRUE>)(ELSE <RFALSE>)>
    )>

    ;"10 ANY - loaded - Something carried   (arg unused)"
    <COND (<=? .CODE 10>
        <DO (I 0 ,NUMBER-ITEMS)
            <COND (<=? <GET-ITEM-LOC .I> ,ROOM-INVENTORY> <RTRUE>)>
        >
        <RFALSE>
    )>

    ;"11 -ANY - !loaded - Nothing carried (arg unused)"
    <COND (<=? .CODE 11>
        <DO (I 0 ,NUMBER-ITEMS)
            <COND (<=? <GET-ITEM-LOC .I> ,ROOM-INVENTORY> <RFALSE>)>
        >
        <RTRUE>
    )>

    ;"12 -AVL - !present - Item <arg> not carried nor in room with player"
    <COND (<=? .CODE 12>
        <COND (<NOT <OR <=? <GET-ITEM-LOC .ARG> ,ROOM-INVENTORY> <=? <GET-ITEM-LOC .ARG> ,CURRENT-ROOM>>> <RTRUE>)(ELSE <RFALSE>)>
    )>


    ;"13 -RM0 - exists - Item <arg> is in game [not in room 0]"
    <COND (<=? .CODE 13>
        <RETURN <NOT <=? <GET-ITEM-LOC .ARG> 0>>>
    )>

    ;"14 RM0 - !exists - Item <arg> is not in game [in room 0]"
    <COND (<=? .CODE 14>
        <RETURN <=? <GET-ITEM-LOC .ARG> 0>>
    )>

    ;"15 CT<= - counter_le - CurrentCounter <= <arg>"
    <COND (<=? .CODE 15>
        <RETURN <L=? ,COUNTER-REGISTER .ARG>>
    )>

    ;"16 CT> - counter_gt - CurrentCounter > <arg>"
    <COND (<=? .CODE 16>
        <RETURN <G? ,COUNTER-REGISTER .ARG>>
    )>

    ;"17 ORIG - !moved - Object still in initial room (arg unused)"
    <COND (<=? .CODE 17>
        <RETURN <=? <GET-ITEM-LOC .ARG> <GET-ITEM-ORIGINAL-LOC .ARG>>>
    )>

    ;"18 -ORIG - moved - Object not in initial room (arg unused)"
    <COND (<=? .CODE 18>
        <RETURN <NOT <=? <GET-ITEM-LOC .ARG> <GET-ITEM-ORIGINAL-LOC .ARG>>>>
    )>

    ;"19 CT= - counter_eq - CurrentCounter = <arg>"
    <COND (<=? .CODE 19>
        <RETURN <=? ,COUNTER-REGISTER .ARG>>
    )>

    <RFALSE>
>

<ROUTINE EXECUTE-COMMANDS (ACTION-ID "AUX" INSTRUCTION CONTINUE-EXECUTING-COMMANDS)
    <SETG INSTRUCTION-ARG-INDEX 1>
    <SET CONTINUE-EXECUTING-COMMANDS T>
    <DO (I 1 4)
        <COND (.CONTINUE-EXECUTING-COMMANDS
            <SET INSTRUCTION <GET-ACTION-INSTRUCTION .ACTION-ID .I>>

            ;"Instructions 102- are messages"
            <COND (<G=? .INSTRUCTION 102> <TELL <GET-MESSAGE <- .INSTRUCTION 50>> CR>)>

            ;"Instructions 1-51 are messages"
            <COND (<AND <G? .INSTRUCTION 0> <L? .INSTRUCTION 52> <TELL <GET-MESSAGE .INSTRUCTION> CR>>)>

            ;"Instructions 52-101 are commands"
            <COND (<AND <G? .INSTRUCTION 51> <L? .INSTRUCTION 102>>
                <SET CONTINUE-EXECUTING-COMMANDS <EXECUTE-INSTRUCTION .ACTION-ID .INSTRUCTION>>)>
        )>
    >
>

<ROUTINE EXECUTE-INSTRUCTION (ACTION-ID CODE "AUX" STORED-TREASURES ITEM-FOUND NOT-FIRST-ITEM CURPOS ARG1 ARG2 TEMP)

    ;"52 GETx - get - Get item <arg>. Checks if you can carry it first"
    <COND (<=? .CODE 52>
        <COND (<NOT <CAN-CARRY-MORE?>> <RFALSE>)> ;"Stop processing later instructions if this one fails"

        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> ,ROOM-INVENTORY>
    )>

    ;"53 DROPx - drop - Drops item <arg>"
    <COND (<=? .CODE 53>
        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> ,CURRENT-ROOM>
    )>

    ;"54 GOTOy - goto - Moves to room <arg>"
    <COND (<=? .CODE 54>
        <SETG CURRENT-ROOM <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
    )>

    ;"55 x->RM0 - destroy - Item <arg> is removed from the game (put in room 0)"
    <COND (<=? .CODE 55>
        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> 0>
    )>

    ;"56 NIGHT - set_dark - The darkness flag is set"
    <COND (<=? .CODE 56>
        <SET-FLAG ,FLAG-DARK T>
    )>

    ;"57 DAY - clear_dark - The darkness flag is cleared"
    <COND (<=? .CODE 57>
        <SET-FLAG ,FLAG-DARK <>>
    )>

    ;"58 SETz - set_flag - Bitflag <arg> is set"
    <COND (<=? .CODE 58>
        <SET-FLAG <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> T>
    )>

    ;"59 x->RM0 - destroy2 - The same as 55 (it seems - I'm cautious about this)"
    <COND (<=? .CODE 59>
        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> 0>
    )>

    ;"60 CLRz - clear_flag - BitFlag <arg> is cleared"
    <COND (<=? .CODE 60>
        <SET-FLAG <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> <>>
    )>

    ;"61 DEAD - die - Death. Dark flag cleared, player moved to last room"
    <COND (<=? .CODE 61>
        <TELL ,MSG-DEAD CR>
        <SET-FLAG ,FLAG-DARK <>>
        <SETG CURRENT-ROOM ,NUMBER-ROOMS>
        <SHOW-ROOM-DESC>
    )>

    ;"62 x->y - put - Item <arg1> put in room <arg2>"
    <COND (<=? .CODE 62>
        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
    )>

    ;"63 FINI - game_over - Game over."
    <COND (<=? .CODE 63>
        <TELL ,MSG-GAME-OVER CR>
        <QUIT>
    )>

    ;"64 DspRM - look - Describe room"
    <COND (<=? .CODE 64>
        <SHOW-ROOM-DESC>
    )>

    ;"65 SCORE - score - Score"
    <COND (<=? .CODE 65>
        <SET STORED-TREASURES 0>
        <DO (I 0 ,NUMBER-ITEMS)
            <COND (<AND <ITEM-TREASURE? .I> <=? <GET-ITEM-LOC .I> ,TREASURE-ROOM>>
                <SET STORED-TREASURES <+ .STORED-TREASURES 1>>
            )>
        >
        <TELL ,MSG-SCORE-1>
        <COND (<NOT <=? ,MSG-SCORE-2 "">> <TELL N .STORED-TREASURES ,MSG-SCORE-2>)>
        <COND (<NOT <=? ,MSG-SCORE-3 "">> <TELL N </ <* .STORED-TREASURES 100> ,TOTAL-TREASURES> ,MSG-SCORE-3>)>
        <TELL CR>
        <COND (<=? .STORED-TREASURES ,TOTAL-TREASURES>
            <TELL ,MSG-WINNING CR>
            <QUIT>
        )>
    )>

    ;"66 INV - inventory - Inventory"
    <COND (<=? .CODE 66>
        <TELL ,MSG-IM-CARRYING CR>
        <SET ITEM-FOUND <>>
        <SET NOT-FIRST-ITEM <>>
        <SET CURPOS 0>
        <DO (I 0 ,NUMBER-ITEMS)
            <COND (<=? <GET-ITEM-LOC .I> ,ROOM-INVENTORY>
                <COND (.NOT-FIRST-ITEM <TELL ,CHARS-BETWEEN-ITEMS>)>
                <SET NOT-FIRST-ITEM T>
                <COND (<AND <NOT ,GAME-CONVERSATIONAL> <G=? <+ <GET-ITEM-DESC-LENGTH .I> .CURPOS 2> ,SCREEN-WIDTH>> <TELL CR> <SET .CURPOS 0>)>
                <TELL <GET-ITEM-DESC .I>>
                <SET CURPOS <+ .CURPOS <GET-ITEM-DESC-LENGTH .I> 2>>
                <SET ITEM-FOUND T>
            )>
        >
        <COND (.ITEM-FOUND <TELL ".">)(ELSE <TELL ,MSG-CARRYING-NOTHING>)>
        <TELL CR>
    )>

    ;"67 SET0 - set_flag0 - Bitflag 0 is set"
    <COND (<=? .CODE 67>
        <SET-FLAG 0 T>
    )>

    ;"68 CLR0 - clear_flag0 - Bitflag 0 is cleared"
    <COND (<=? .CODE 68>
        <SET-FLAG 0 <>>
    )>

    ;"69 FILL - refill_lamp - Refill lamp (reset its time to live) and put it in player's inventory"
    <COND (<=? .CODE 69>
        <PUT ,ALTERNATE-COUNTER 8 ,TIME-LIGHT-SOURCE-LASTS>  ;"Set time limit counter. Counter 8 is always for light source."
        <SET-ITEM-LOC ,LIGHT-SOURCE-ID ,ROOM-INVENTORY>
        <SET-FLAG ,FLAG-LAMP-EMPTY <>>
    )>

    ;"70 CLS - clear - Screen is cleared. This varies by driver from no effect upwards"
    <COND (<=? .CODE 70>
        <CLEAR-SCREEN>
    )>

    ;"71 SAVE - save_game - Saves the game. Choices of filename etc depend on the driver alone."
    <COND (<=? .CODE 71>
        ;"SAVE return 0 for failed save, 1 for sucessfull save and 2 for sucessfull RESTORE. The logic being that the
          game resumes from this point (where it was saved) after the RESTORE."
        <SET TEMP <SAVE>>
        <COND (<=? .TEMP 0> <TELL ,MSG-SAVE-FAILED CR>)>
        <COND (<=? .TEMP 1> <TELL ,MSG-SAVE-SUCESS CR>)>
        <COND (<=? .TEMP 2> <SHOW-ROOM-DESC>)>
    )>

    ;"72 EXx,x - swap - Swap item <arg1> and item <arg2> locations"
    <COND (<=? .CODE 72>
        <SET ARG1 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SET ARG2 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SET TEMP <GET-ITEM-LOC .ARG1>>
        <SET-ITEM-LOC .ARG1 <GET-ITEM-LOC .ARG2>>
        <SET-ITEM-LOC .ARG2 .TEMP>
    )>

    ;"73 CONT - continue - Continue: when finished with the current action, proceed to
                                     attempt all subsequent actions that have both noun and verb
                                     equal to 0 (subject to their conditions being satisfied)."
    <COND (<=? .CODE 73>
        <SETG CONTINUE-FLAG T>
    )>

    ;"74 AGETx - superget - Take item <arg> - no check is done too see if it can be carried."
    <COND (<=? .CODE 74>
        <SET-ITEM-LOC <GET-NEXT-INSTRUCTION-ARG .ACTION-ID> ,ROOM-INVENTORY>
    )>

    ;"75 BYx<-x - put_with - Put item <arg1> with item <arg2> - Not certain seems to do this
                             from examination of Claymorgue"
    <COND (<=? .CODE 75>
        <SET ARG1 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SET ARG2 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SET-ITEM-LOC .ARG1 <GET-ITEM-LOC .ARG2>>
    )>

    ;"76 DspRM - look2 - Look (same as 64 ?? - check)"
    <COND (<=? .CODE 76>
        <SHOW-ROOM-DESC>
    )>

    ;"77 CT-1 - dec_counter - Decrement current counter. Will not go below 0"
    <COND (<=? .CODE 77>
        <COND (<G? ,COUNTER-REGISTER 0> <SETG COUNTER-REGISTER <- ,COUNTER-REGISTER 1>>)>
    )>

    ;"78 DspCT - print_counter - Print current counter value. Some drivers only cope with 0-99 apparently"
    <COND (<=? .CODE 78>
        <TELL N ,COUNTER-REGISTER>
    )>

    ;"79 CT<-n - set_counter - Set current counter value to <arg>"
    <COND (<=? .CODE 79>
        <SETG COUNTER-REGISTER <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
    )>

    ;"80 EXRM0 - swap_room - Swap location with current location-swap flag"
    <COND (<=? .CODE 80>
        <SET TEMP ,CURRENT-ROOM>
        <SETG CURRENT-ROOM <GET ,ALTERNATE-ROOM 0>>
        <PUT ,ALTERNATE-ROOM 0 .TEMP>
    )>

    ;"81 EXm,CT - select_counter - Select a counter. Current counter is swapped with backup counter <arg>"
    <COND (<=? .CODE 81>
        <SET TEMP ,COUNTER-REGISTER>
        <SET ARG1 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SETG COUNTER-REGISTER <GET ,ALTERNATE-COUNTER .ARG1>>
        <PUT ,ALTERNATE-COUNTER .ARG1 .TEMP>
    )>

    ;"82 CT+n - add_to_counter - Add <arg> to current counter"
    <COND (<=? .CODE 82>
        <SETG COUNTER-REGISTER <+ ,COUNTER-REGISTER <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>>
    )>

    ;"83 CT-n - subtract_from_counter - Subtract <arg> from current counter"
    <COND (<=? .CODE 83>
        <SETG COUNTER-REGISTER <- ,COUNTER-REGISTER <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>>

        ;"According to ScottFree source, the counter has a minimum value of -1"
        <COND (<L? ,COUNTER-REGISTER -1> <SETG COUNTER-REGISTER -1>)>
    )>

    ;"84 SAYw - print_noun - Echo noun player typed without CR"
    <COND (<=? .CODE 84>
        <PRINT-NOUN>
    )>

    ;"85 SAYwCR - println_noun - Echo noun player typed without CR"
    <COND (<=? .CODE 85>
        <PRINT-NOUN>
        <CRLF>
    )>

    ;"86 SAYCR - println - CR"
    <COND (<=? .CODE 86>
        <CRLF>
    )>

    ;"87 EXc,CR - swap_specific_room - Swap current location value with backup location-swap value <arg>"
    <COND (<=? .CODE 87>
        <SET ARG1 <GET-NEXT-INSTRUCTION-ARG .ACTION-ID>>
        <SET TEMP ,CURRENT-ROOM>
        <SETG CURRENT-ROOM <GET ,ALTERNATE-ROOM .ARG1>>
        <PUT ,ALTERNATE-ROOM .ARG1 .TEMP>

    )>

    ;"88 DELAY - pause - Wait 1 seconds"
    <COND (<=? .CODE 88>
        <DELAY>
    )>

    ;"89 xxx - draw -   SAGA - draw picture <n> (actually <n+number of rooms>, as each
                        Look() draws picture <room number> automatically)
                        Older spectrum driver - crashes
                        Spectrum Seas of Blood - seems to start Fighting Fantasy combat mode"
    <COND (<=? .CODE 90>
        ;"Not implemented"
    )>

    <RTRUE>     ;"Continue with next instruction"
>

<ROUTINE PRINT-NOUN ("AUX" C)
    <DO (I 0 9)
        <SET C <GETB ,SA-NOUN .I>>
        <COND (<NOT <0? .C>> <PRINTC .C>)>
    >
>

<ROUTINE GET-NEXT-INSTRUCTION-ARG (ID)
    ;"Move pointer to next argument (ConditionCode=0). There is at most 5 arguments per action."
    <COND (<AND <G? <GET-CONDITION-CODE .ID ,INSTRUCTION-ARG-INDEX> 0> <L? ,INSTRUCTION-ARG-INDEX 5>> <SETG INSTRUCTION-ARG-INDEX <+ ,INSTRUCTION-ARG-INDEX 1>>)>
    <COND (<AND <G? <GET-CONDITION-CODE .ID ,INSTRUCTION-ARG-INDEX> 0> <L? ,INSTRUCTION-ARG-INDEX 5>> <SETG INSTRUCTION-ARG-INDEX <+ ,INSTRUCTION-ARG-INDEX 1>>)>
    <COND (<AND <G? <GET-CONDITION-CODE .ID ,INSTRUCTION-ARG-INDEX> 0> <L? ,INSTRUCTION-ARG-INDEX 5>> <SETG INSTRUCTION-ARG-INDEX <+ ,INSTRUCTION-ARG-INDEX 1>>)>
    <COND (<AND <G? <GET-CONDITION-CODE .ID ,INSTRUCTION-ARG-INDEX> 0> <L? ,INSTRUCTION-ARG-INDEX 5>> <SETG INSTRUCTION-ARG-INDEX <+ ,INSTRUCTION-ARG-INDEX 1>>)>
    <COND (<G? ,INSTRUCTION-ARG-INDEX 5> <SETG ,INSTRUCTION-ARG-INDEX 5>)>

    <SETG INSTRUCTION-ARG-INDEX <+ ,INSTRUCTION-ARG-INDEX 1>>       ;"Move the pointer"
    <RETURN <GET-CONDITION-ARG .ID <- ,INSTRUCTION-ARG-INDEX 1>>>   ;"but RTRUEhe old pointers argument"
>

<ROUTINE HANDLE-GET-DROP (VERB-ID NOUN-ID "AUX" ITEM-ID NOUN ITEM-NOUN SEARCH-LOC ITEM-NOUN-MATCH ITEM-IN-INV)
    ;"Exit if the verb isn't get or drop"
    <COND (<AND <NOT <=? .VERB-ID ,VERB-GET>> <NOT <=? .VERB-ID ,VERB-DROP>>> <RFALSE>)>

    ;"If verb is get then search for an item in the room. If verb is drop then search for item in inventory."
    <COND (<=? .VERB-ID ,VERB-GET> <SET SEARCH-LOC ,CURRENT-ROOM>)(ELSE <SET SEARCH-LOC ,ROOM-INVENTORY>)>

    ;"Search for noun among items (the /XXX/ part)"
    <SET ITEM-ID -1>
    <SET ITEM-NOUN-MATCH <>>
    <SET ITEM-IN-INV <>>
    <SET NOUN <GET <GET ,VOCABULARY-TABLE .NOUN-ID> 2>>  ;"Current noun"
    ;"<COND (<=? .NOUN-ID 0> <SET NOUN ,SA-NOUN>)>" ;"If noun not in vocabulary, try parser-noun against items"
    <DO (I 0 ,NUMBER-ITEMS)
        <SET ITEM-NOUN <GET <GET ,ITEMS-TABLE .I> 5>>
        <COND (<WORD-EQUAL? .NOUN .ITEM-NOUN> <SET ITEM-NOUN-MATCH T>)>                                             ;"Found noun in vocabulary or item"
        <COND (<AND <=? <GET-ITEM-LOC .I> ,ROOM-INVENTORY> <WORD-EQUAL? .NOUN .ITEM-NOUN>> <SET ITEM-IN-INV T>)>    ;"Is the item in inventory and have a matching noun?"
        <COND (<AND <=? <GET-ITEM-LOC .I> .SEARCH-LOC> <WORD-EQUAL? .NOUN .ITEM-NOUN>> <SET ITEM-ID .I>)>           ;"Is the item in room or inventory and have a matching noun?"
    >

    ;"If noun is undefined, return with an error text"
    <COND (<AND <=? .NOUN-ID 0> <NOT .ITEM-NOUN-MATCH>> <TELL ,MSG-WHAT CR> <RTRUE>)>

    ;"GET"
    <COND (<=? .VERB-ID ,VERB-GET>
        ;"Item in inventory?"
        <COND (.ITEM-IN-INV <TELL ,MSG-ALREADY-HAVE-IT CR> <RTRUE>)>

        ;"Item in room?"
        <COND (<NOT <=? <GET-ITEM-LOC .ITEM-ID> ,CURRENT-ROOM>> <TELL ,MSG-DONT-SEE-IT-HERE CR> <RTRUE>)>

        ;"Can I carry one more item?"
        <COND (<NOT <CAN-CARRY-MORE?>> <RTRUE>)>

        ;"Pick up the item"
        <SET-ITEM-LOC .ITEM-ID ,ROOM-INVENTORY>
        <TELL ,MSG-OK CR>
        <RTRUE>
    )>

    ;"DROP"
    <COND (<=? .VERB-ID ,VERB-DROP>
        ;"Item in inventory?"
        <COND (<NOT <=? <GET-ITEM-LOC .ITEM-ID> ,ROOM-INVENTORY>> <TELL ,MSG-DONT-CARRY-IT CR> <RTRUE>)>

        ;"Drop the item"
        <SET-ITEM-LOC .ITEM-ID ,CURRENT-ROOM>
        <TELL ,MSG-OK CR>
        <RTRUE>
    )>
>

<ROUTINE CAN-CARRY-MORE? ("AUX" CARRIED-ITEMS)
    <SET CARRIED-ITEMS 0>
    <DO (I 0 ,NUMBER-ITEMS)
        <COND (<=? <GET-ITEM-LOC .I> ,ROOM-INVENTORY> <SET CARRIED-ITEMS <+ .CARRIED-ITEMS 1>>)>
    >
    <COND (<G=? .CARRIED-ITEMS ,MAX-ITEMS-CARRY>
        <COND (<G=? ,MAX-ITEMS-CARRY 0>
            <TELL ,MSG-TOO-MUCH-TO-CARRY CR>
            <RFALSE>
        )>
    )>
    <RTRUE>
>

<ROUTINE FIXED-FONT-ON () <PUT 0 8 <BOR <GET 0 8> 2>>>

<ROUTINE FIXED-FONT-OFF() <PUT 0 8 <BAND <GET 0 8> -3>>>

<ROUTINE REPARSE (TBL)
    <REPEAT ((N 0) C (W 1) (L 0))
        <SET C <GETB .TBL .N>>
        <PUTB ,READBUF <+ .N 2> .C>
        <COND (<=? .C 32>
            <SET W <+ .W 1>>
            <SET L .N>
        )>
        <COND (<=? .C 0>
            <COND (<0? .L> <SET L .N>)>
            <PUTB ,READBUF 1 .N>            ;"Length to byte 1 in readbuf"
            <PUTB ,PARSEBUF 1 .W>           ;"Number of words in #1"
            <PUTB ,PARSEBUF 4 .L>           ;"Length of first word in #4"
            <PUTB ,PARSEBUF 5 2>            ;"Startpos of first word in #5"
            <PUTB ,PARSEBUF 8 <- .N .L 1>>  ;"Length of second word in #8"
            <PUTB ,PARSEBUF 9 <+ .L 3>>     ;"Startpos of second word in #9"
            <RTRUE>
        )>
        <SET N <+ .N 1>>
    >
>

;"Compares two ZASCII-tables. The tables must each be at least WORD-LENGTH"
<ROUTINE WORD-EQUAL? (TBL1 TBL2 "AUX" MAX C1 C2)
    <SET MAX ,WORD-LENGTH>
    <DO (I 1 .MAX)
        <SET C1 <GETB .TBL1 <- .I 1>>>
        <SET C2 <GETB .TBL2 <- .I 1>>>
        <COND (<NOT <=? .C1 .C2>> <RFALSE>)>
    >
    <RTRUE>
>

<ROUTINE PRINT-ROOM-DESC ()
    ;"Dark?"
    <COND (<GET-FLAG ,FLAG-DARK>
        <COND (<NOT <OR <=? <GET-ITEM-LOC ,LIGHT-SOURCE-ID> ,ROOM-INVENTORY>  <=? <GET-ITEM-LOC ,LIGHT-SOURCE-ID> ,CURRENT-ROOM>>>
            <TELL ,MSG-TOO-DARK-TO-SEE CR>
            <COND (<NOT ,GAME-CONVERSATIONAL> <TELL CR>)>       ;"Extra CR"
            <RETURN>
         )>
    )>

    ;"Show room message"
    <COND (,GAME-CONVERSATIONAL <CRLF>)>
    <COND (<NOT <GET-ROOM-DESC-SUPPRESS ,CURRENT-ROOM>>
        <TELL ,MSG-IM-IN-A>
    )>
    <TELL <GET-ROOM-DESC ,CURRENT-ROOM> CR>

    <COND (<0? ,ROOM-DESC-ORDER>
        <PRINT-ROOM-ITEMS>
        <PRINT-ROOM-EXITS>
    )
    (ELSE
        <PRINT-ROOM-EXITS>
        <PRINT-ROOM-ITEMS>
    )>
    <COND (<NOT ,GAME-CONVERSATIONAL> <TELL CR>)>       ;"Extra CR, just in case there was no exits or no items"

    <SETG ROOM-DESC-PRINTED? T>    ;"Set flag to stop ROOM-DESC to be printed more times this cycle"
>

<ROUTINE PRINT-ROOM-ITEMS ("AUX" (ITEM-FOUND <>) (NOT-FIRST-ITEM <>) CURPOS)
    ;"Show items"
    <DO (I 0 ,NUMBER-ITEMS)
        <COND (<=? <GET-ITEM-LOC .I> ,CURRENT-ROOM>
            <COND (<NOT .ITEM-FOUND>
                <COND (<NOT ,COMPACT-ROOM-DESC> <TELL CR>)>
                <TELL ,MSG-VISIBLE-ITEMS-HERE>
                <SET .CURPOS 20>
                <SET .ITEM-FOUND T>
            )>
            <COND (.NOT-FIRST-ITEM <TELL ,CHARS-BETWEEN-ITEMS>)>
            <SET NOT-FIRST-ITEM T>
            <COND (<AND <NOT ,GAME-CONVERSATIONAL> <G=? <+ <GET-ITEM-DESC-LENGTH .I> .CURPOS 2> ,SCREEN-WIDTH>> <TELL CR> <SET .CURPOS 0>)>
            <TELL <GET-ITEM-DESC .I>>
            <SET CURPOS <+ .CURPOS <GET-ITEM-DESC-LENGTH .I> 2>>
        )>
    >
    <COND (.ITEM-FOUND <TELL "." CR>)>
    <COND (<AND <NOT .ITEM-FOUND> ,PRINT-NONE-WHEN-NO-ITEMS>
        <COND (<NOT ,COMPACT-ROOM-DESC> <TELL CR>)>
        <TELL ,MSG-VISIBLE-ITEMS-HERE ,MSG-WHEN-NO-EXITS-ITEMS CR>
    )>
>

<ROUTINE PRINT-ROOM-EXITS ("AUX" (EXIT-FOUND <>) FIRST-EXIT)
    ;"Show exits"
    <DO (I 1 6) <COND (<G? <GET-ROOM-EXIT ,CURRENT-ROOM .I> 0> <SET EXIT-FOUND T>)>>
    <COND (.EXIT-FOUND
        <COND (<NOT ,COMPACT-ROOM-DESC> <TELL CR>)>
        <TELL ,MSG-OBVIOUS-EXITS>
        <SET FIRST-EXIT T>
        <DO (I 1 6)
            <COND (<G? <GET-ROOM-EXIT ,CURRENT-ROOM .I> 0>
                <COND (<NOT .FIRST-EXIT> <TELL ,CHARS-BETWEEN-EXITS>)>
                <COND (<=? .I 1> <TELL "North">)>
                <COND (<=? .I 2> <TELL "South">)>
                <COND (<=? .I 3> <TELL "East">)>
                <COND (<=? .I 4> <TELL "West">)>
                <COND (<=? .I 5> <TELL "Up">)>
                <COND (<=? .I 6> <TELL "Down">)>
                <SET FIRST-EXIT <>>
            )>
        >
        <TELL "." CR>
    )>
    <COND (<AND <NOT .EXIT-FOUND> ,PRINT-NONE-WHEN-NO-EXITS>
        <COND (<NOT ,COMPACT-ROOM-DESC> <TELL CR>)>
        <TELL ,MSG-OBVIOUS-EXITS ,MSG-WHEN-NO-EXITS-ITEMS CR>
    )>
>

<ROUTINE CHECK-ABBREVIATIONS (POS)
    ;"Abreviation if one word of one character. Put new command in READBUF and reparse."
    <COND (<=? <GETB ,READBUF .POS> !\n> <REPARSE <GET ,ABBREVIATIONS 0>>)>
    <COND (<=? <GETB ,READBUF .POS> !\s> <REPARSE <GET ,ABBREVIATIONS 1>>)>
    <COND (<=? <GETB ,READBUF .POS> !\e> <REPARSE <GET ,ABBREVIATIONS 2>>)>
    <COND (<=? <GETB ,READBUF .POS> !\w> <REPARSE <GET ,ABBREVIATIONS 3>>)>
    <COND (<=? <GETB ,READBUF .POS> !\u> <REPARSE <GET ,ABBREVIATIONS 4>>)>
    <COND (<=? <GETB ,READBUF .POS> !\d> <REPARSE <GET ,ABBREVIATIONS 5>>)>
    <COND (<=? <GETB ,READBUF .POS> !\l> <REPARSE <GET ,ABBREVIATIONS 6>>)>
    <COND (<=? <GETB ,READBUF .POS> !\i> <REPARSE <GET ,ABBREVIATIONS 7>>)>
>

;"=====================================================================================
  Helper routines to GET and SET data in the data tables
  ====================================================================================="
<ROUTINE GET-FLAG (ID) <RETURN <GETB ,SA-FLAGS .ID>>>
<ROUTINE SET-FLAG (ID VALUE) <PUTB ,SA-FLAGS .ID .VALUE>>
<ROUTINE GET-ROOM-DESC (ID) <RETURN <GET <GET ,ROOMS-TABLE .ID> 1>>>
<ROUTINE GET-ROOM-DESC-SUPPRESS (ID) <RETURN <GET <GET ,ROOMS-TABLE .ID> 2>>>
<ROUTINE GET-ROOM-EXIT (ROOM-ID EXIT-ID) <RETURN <GET <GET ,ROOMS-TABLE .ROOM-ID> <+ .EXIT-ID 2>>>>     ;"Return Room# for exit (0=no exit). 1=N, 2=S, 3=E, 4=W, 5=U, 6=D."
<ROUTINE GET-ITEM-LOC (ID) <RETURN <GET <GET ,ITEMS-TABLE .ID> 1>>>
<ROUTINE GET-ITEM-ORIGINAL-LOC (ID) <RETURN <GET <GET ,ITEMS-TABLE .ID> 2>>>
<ROUTINE GET-ITEM-DESC (ID) <RETURN <GET <GET ,ITEMS-TABLE .ID> 3>>>
<ROUTINE GET-ITEM-DESC-LENGTH (ID) <RETURN <GET <GET ,ITEMS-TABLE .ID> 4>>>
<ROUTINE SET-ITEM-LOC (ID LOC) <PUT <GET ,ITEMS-TABLE .ID> 1 .LOC>>
<ROUTINE ITEM-TREASURE? (ID) <RETURN <GET <GET ,ITEMS-TABLE .ID> 6>>>
<ROUTINE GET-ACTION-VERB-ID (ID) <RETURN <GET <GET ,ACTIONS-TABLE .ID> 1>>>
<ROUTINE GET-ACTION-NOUN-ID (ID) <RETURN <GET <GET ,ACTIONS-TABLE .ID> 2>>>
<ROUTINE GET-CONDITION-CODE (ID INDEX) <RETURN <GET <GET ,ACTIONS-TABLE .ID> <+ <* .INDEX 2> 1>>>>
<ROUTINE GET-CONDITION-ARG (ID INDEX) <RETURN <GET <GET ,ACTIONS-TABLE .ID> <+ <* .INDEX 2> 2>>>>
<ROUTINE GET-ACTION-INSTRUCTION (ID INDEX) <RETURN <GET <GET ,ACTIONS-TABLE .ID> <+ .INDEX 12>>>>
<ROUTINE GET-MESSAGE (ID) <RETURN <GET ,MESSAGES-TABLE .ID>>>
<ROUTINE ABORT-WAIT () <RTRUE>>

<ROUTINE ABOUT ()
    <TELL "This game was created with..." CR CR>
    <ABOUT-HEADER>
    <TELL "Release ">
    <PRINTN <BAND <LOWCORE RELEASEID> *3777*>>
    <TELL " / Serial number ">
    <LOWCORE-TABLE SERIAL 6 PRINTC>
    <TELL CR "
|
Scott2Zil is a tool that wraps a data-file (*.sao, *.dat) for|
a game in the Scott Adams-style genre (games that can be|
played with, for example, ScottFree or PerlScott) and|
repackage it inside a ZIL-shell that then can be compiled|
with ZILF.|
|
Thanks to:|
 - Tara McGrew, the creator of ZILF.|
 - pdxiv, the creator of PerlScott for inspiration and code|
   that is much more readable than the original|
   basic interpreter by Scott Adams.|
   (https://github.com/pdxiv/PerlScott)|
 - Mike Taylor, the creator of scottkit. A tool for compile|
   and decompile games in the SA genre.|
   (https://github.com/MikeTaylor/scottkit)|
 - Jason Compton, the author of Ghost King, the game that led|
   me down this path...|
   (https://ifdb.tads.org/viewgame?id=pv6hkqi34nzn1tdy)|
|
2020, Henrik Åsman|">
>

<ROUTINE SHOW-BANNER ()
    <TELL "Built with Scott2Zil, a ZIL-wrapper for Scott Adams adventures." CR>
    <TELL "Release ">
    <PRINTN <BAND <LOWCORE RELEASEID> *3777*>>
    <TELL ". Built on ">
    <LOWCORE-TABLE SERIAL 6 PRINTC>
    <TELL " from a sao source file." CR>
    <TELL "Copyright 2020-2025, Henrik Åsman" CR CR>
>

;"Different versions of routines for ZIP or XZIP"
<VERSION?
    (ZIP
        ;"<INPUT>, <CLEAR>, <SPLIT> is not supported in V3"
        <ROUTINE CHANGE-GAME-MODE () <RETURN>>

        ;"<CLEAR> is not supported in V3"
        <ROUTINE CLEAR-SCREEN () <RETURN>>

        ;"<INPUT> is not supported in V3"
        <ROUTINE DELAY () <RETURN>>

        ;"<INPUT> is not supported in V3"
        <ROUTINE SHOW-INTRO ()
            <SHOW-BANNER>
            <TELL ,MSG-INTRO CR CR>
        >

        ;"<INPUT>, <CLEAR>, <SPLIT> is not supported in V3"
        <ROUTINE SHOW-ROOM-DESC()
            <PRINT-ROOM-DESC>
        >

        ;"<HLIGHT> is not supported in V3"
        <ROUTINE ABOUT-HEADER ()
            <TELL "Scott2Zil - A SA-machine written in zil" CR>
        >
    )
    (ELSE
        <ROUTINE CHANGE-GAME-MODE ()
                    <SETG GAME-CONVERSATIONAL <NOT ,GAME-CONVERSATIONAL>>
                    <COND (,GAME-CONVERSATIONAL
                        <SPLIT 0>
                        <CLEAR 0>
                        <SHOW-ROOM-DESC>
                    )
                    (ELSE
                        <SHOW-ROOM-DESC>
                    )>
        >

        <ROUTINE CLEAR-SCREEN ()
            <COND (<NOT <OR ,GAME-CONVERSATIONAL ,NO-CLS>> <CLEAR 0>)>   ;"Don't clear screen when in conversational mode or clear is turned off."
        >

        <ROUTINE DELAY ()
            <INPUT 1 20 ABORT-WAIT>     ;"Wait for input 2 s (20 x 0.1 s) then call a routine that returns true and aborts the input."
            <RTRUE>
        >

        <ROUTINE SHOW-INTRO ()
            <CLEAR 0>
            <SHOW-BANNER>
            <TELL ,MSG-INTRO>
            <COND (<NOT ,GAME-CONVERSATIONAL> <INPUT 1> <CLEAR 0>)>
        >

        <ROUTINE SHOW-ROOM-DESC("AUX" NEW-ROWPOS)
            <COND (<NOT ,GAME-CONVERSATIONAL>
                <SPLIT ,STARTING-SPLITROW>
                <CLEAR 1>
                <SCREEN 1>
                <CURSET ,STARTING-SPLITROW 1>
                <TELL ,SCREEN-BAR>
                <CURSET 1 1>
            )>

            <PRINT-ROOM-DESC>

            ;"Overflow - Make top screen bigger"
            <COND (<NOT ,GAME-CONVERSATIONAL>
                <SET NEW-ROWPOS <>>
                <CURGET ,CURPOS>
                <COND (<L? <GET ,CURPOS 0> 3>                                           ;"Some interpreters (WinFrotz) wrap around if screen is overflown."
                    <SETG STARTING-SPLITROW <+ <GET ,CURPOS 0> 1 ,STARTING-SPLITROW>>   ;"If row is below 3 this have happend (row never should be lower than 3)."
                    <SET NEW-ROWPOS T>                                                  ;"Enlarge the top screen in this case."
                )>
                <COND (<G=? <GET ,CURPOS 0> ,STARTING-SPLITROW>
                    <SETG STARTING-SPLITROW <+ <GET ,CURPOS 0> 1>>
                    <SET NEW-ROWPOS T>
                )>
                <COND (.NEW-ROWPOS
                    <SPLIT ,STARTING-SPLITROW>
                    <CLEAR 1>
                    <SCREEN 1>
                    <CURSET ,STARTING-SPLITROW 1>
                    <TELL ,SCREEN-BAR>
                    <CURSET 1 1>
                    <PRINT-ROOM-DESC>
                )>
            <SCREEN 0>
            )>
        >

        <ROUTINE ABOUT-HEADER ()
            <HLIGHT 2>
            <TELL "Scott2Zil - A SA-machine written in zil" CR>
            <HLIGHT 0>
        >
    )>
