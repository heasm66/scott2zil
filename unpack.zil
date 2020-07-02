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

;"Unpack the game.dat"
;"Definition of DAT-file from Mike Taylors ScottKit https://github.com/MikeTaylor/scottkit"
;"
A game consists of a header of 12 values each apparently 16 bit

0	Unknown*
1	Number of items
2	Number of actions
3	Number of Nouns and Verbs (one list is padded)
4	Number of rooms
5	Maximum a player can carry
6	Starting Room
7	Total Treasures (*)
8	Word Length (only seen 3,4 or 5)
9	Time light source lasts. This counts down every time item 9 is
	in game. Brian Howarths games allow -1 for never run down. When
	it runs out the light item (9) is dumped in room 0 and a look
	done. Messages vary between interpreters and include things
	like 'Your light is flickering and dying' as well as 
	'Light runs out in %d turns'.
10	Number of Messages
11	Room you must put treasure in to score points. Not all games use
	the treasure system for scoring

All the number of something values are the last item to be read counting
from 0. Thus 3 messages, means messages 0, 1, 2 and 3.

(*) This can be calculated in game. What happens if the number is wrong
I don't know. I've found no games that it occurs in.

A game has 16 (maybe more) binary flags, and 8 (maybe more counters). A few
later games seem to have 2 (maybe more) values to store location numbers in
temporarily - eg Yoho spell in Claymorgue.  Flag 15 indicates whether
it is dark, and flag 16 seems to get set when the lamp runs out.  No
other flag has an intrinsic meaning.

Following the header is a list of game actions. Each is of the form

150*verb+noun
5 repeats of condition+20*value
150*action1+action2
150*action3+action4

Conditions

0	<arg> is a parameter to one of the following actions
1	Item <arg> carried
2	Item <arg> in room with player
3	Item <arg> carried or in room with player
4	In room <arg>
5	Item <arg> not in room with player
6	Item <arg> not carried
7	Not in room <arg>
8	BitFlag <arg> is set. 
9	BitFlag <arg> is cleared
10	Something carried	(arg unused)
11	Nothing carried		(arg unused)
12	Item <arg> not carried nor in room with player
13	Item <arg> is in game		[not in room 0]
14	Item <arg> is not in game	[in room 0]
15	CurrentCounter <= <arg>
16	CurrentCounter > <arg>
17	Object still in initial room (arg unused)
18	Object not in initial room (arg unused)
19	CurrentCounter = <arg>

Actions.  <arg>s are taken from the values provided by
pseudo-conditionals with op-code 0 in the same action.

0	Does nothing
1-51	Print message 1-51. Some drivers add a space some add a newline.
        It does not seem to be possible to print message 0
52	Get item <arg>. Checks if you can carry it first
53	Drops item <arg>
54	Moves to room <arg>
55	Item <arg> is removed from the game (put in room 0)
56	The darkness flag is set
57	The darkness flag is cleared
58	Bitflag <arg> is set
59	The same as 55 (it seems - I'm cautious about this)
60	BitFlag <arg> is cleared
61	Death. Dark flag cleared, player moved to last room
62	Item <arg1> put in room <arg2>
63	Game over. 
64	Describe room
65	Score
66	Inventory
67	BitFlag 0 is set	
68	BitFlag 0 is cleared
69	Refill lamp (reset its time to live) and put it in player's inventory
70	Screen is cleared. This varies by driver from no effect upwards
71	Saves the game. Choices of filename etc depend on the driver alone.
72	Swap item <arg1> and item <arg2> locations
73	Continue: when finished with the current action, proceed to
	attempt all subsequent actions that have both noun and verb
	equal to 0 (subject to their conditions being satisfied).
74	Take item <arg> - no check is done too see if it can be carried.
75	Put item <arg1> with item <arg2> - Not certain seems to do this
	from examination of Claymorgue
76	Look (same as 64 ?? - check)
77	Decrement current counter. Will not go below 0
78	Print current counter value. Some drivers only cope with 0-99
	apparently
79	Set current counter value to <arg>
80	Swap location with current location-swap flag
81	Select a counter. Current counter is swapped with backup counter
	<arg>
82	Add <arg> to current counter
83	Subtract <arg> from current counter
84	Echo noun player typed without CR
85	Echo the noun the player typed
86	CR
87	Swap current location value with backup location-swap value <arg>
88	Wait 2 seconds
89      SAGA - draw picture <n> (actually <n+number of rooms>, as each
	Look() draws picture <room number> automatically)
	Older spectrum driver - crashes
	Spectrum Seas of Blood - seems to start Fighting Fantasy combat mode
90-101  Unused
102+	Print message 52-99


This is followed by the words with verbs and nouns interleaved. A word with
a * at the beginning is a synonym for the word above.
Verb 1 is GO, verb 10 is GET, verb 18 is DROP (always).
Nouns 1-6 are directions.

This is followed by the rooms. Each room is 6 exits (north south east west
up down) followed by a text string.

Then come the messages, stored as a list of strings.

Next come the items in the format item text then location. Item text may
end with /TEXT/. This text is not printed but means that an automatic
get/drop will be done for 'GET/DROP TEXT' on this item. Item names beginning
with '*' are treasures. The '*' is printed. If you put all treasures in the
treasure room (in the header) and 'SCORE' the game finishes with a well done
message. Item location -1 is the inventory (255 on C64 and Spectrum tape
games) and 0 means not in play in every game I've looked at. The lamp (always
object 9) behaviour supports this belief.

A set of strings follow this. In order they match to each line of verb/noun
actions, and are comments. The Spectrum and C64 tape system where the
database is compiled into the program has no comments.

Finally three values follow which are version, adventure number and an
unknown magic number*.

* First unknown is size of game (number of bytes) and second unknown is
  a checksum number (see documentation for Adventure System for TRS-80
  how it's calculated).
"

;"Unpack header"
<CONSTANT GAME-BYTES <ZGET ,GAME-DAT 0>>
<CONSTANT NUMBER-ITEMS <ZGET ,GAME-DAT 1>>
<CONSTANT NUMBER-ACTIONS <ZGET ,GAME-DAT 2>>
<CONSTANT NUMBER-VOCABULARY <ZGET ,GAME-DAT 3>>
<CONSTANT NUMBER-ROOMS <ZGET ,GAME-DAT 4>>
<CONSTANT MAX-ITEMS-CARRY <ZGET ,GAME-DAT 5>>
<CONSTANT STARTING-ROOM <ZGET ,GAME-DAT 6>>
<CONSTANT TOTAL-TREASURES <ZGET ,GAME-DAT 7>>
<CONSTANT WORD-LENGTH <ZGET ,GAME-DAT 8>>
<CONSTANT TIME-LIGHT-SOURCE-LASTS <ZGET ,GAME-DAT 9>>
<CONSTANT NUMBER-MESSAGES <ZGET ,GAME-DAT 10>>
<CONSTANT TREASURE-ROOM <ZGET ,GAME-DAT 11>>
<CONSTANT START-INDEX-ACTIONS 12>
<CONSTANT START-INDEX-VOCABULARY <+ ,START-INDEX-ACTIONS <* <+ ,NUMBER-ACTIONS 1> 8>>>
<CONSTANT START-INDEX-ROOMS <+ ,START-INDEX-VOCABULARY <* <+ ,NUMBER-VOCABULARY 1> 2>>>
<CONSTANT START-INDEX-MESSAGES <+ ,START-INDEX-ROOMS <* <+ ,NUMBER-ROOMS 1> 7>>>
<CONSTANT START-INDEX-ITEMS <+ ,START-INDEX-MESSAGES ,NUMBER-MESSAGES 1>>

;"Unpack actions

150*verb+noun
5 repeats of condition+20*value
150*action1+action2
150*action3+action4

     0   Action #
     1   Verb
     2   Noun
     3   Condition 1
     4   Arg 1
     5   Condition 2
     6   Arg 2
     7   Condition 3
     8   Arg 3
     9   Condition 4
    10   Arg 4
    11   Condition 5
    12   Arg 5
    13   Action 1
    14   Action 2
    15   Action 3
    16   Action 4
"
<DEFINE UNPACK-ACTIONS ("AUX" ACTIONS) 
    <SET ACTIONS <ITABLE <+ ,NUMBER-ACTIONS 1>>>
    <REPEAT (ACTION (N 0))
        <SET ACTION <ITABLE 17>>
        <ZPUT .ACTION 0 .N>
        <ZPUT .ACTION 1 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 0>> 150>>
        <ZPUT .ACTION 2 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 0>> 150>>
        <ZPUT .ACTION 3 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 1>> 20>>
        <ZPUT .ACTION 4 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 1>> 20>>
        <ZPUT .ACTION 5 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 2>> 20>>
        <ZPUT .ACTION 6 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 2>> 20>>
        <ZPUT .ACTION 7 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 3>> 20>>
        <ZPUT .ACTION 8 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 3>> 20>>
        <ZPUT .ACTION 9 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 4>> 20>>
        <ZPUT .ACTION 10 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 4>> 20>>
        <ZPUT .ACTION 11 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 5>> 20>>
        <ZPUT .ACTION 12 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 5>> 20>>
        <ZPUT .ACTION 13 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 6>> 150>>
        <ZPUT .ACTION 14 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 6>> 150>>
        <ZPUT .ACTION 15 </ <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 7>> 150>>
        <ZPUT .ACTION 16 <MOD <ZGET ,GAME-DAT <+ ,START-INDEX-ACTIONS <* .N 8> 7>> 150>>
        <ZPUT .ACTIONS .N .ACTION>
        <SET N <+ .N 1>>
 		<COND (<G? .N ,NUMBER-ACTIONS> <RETURN .ACTIONS>)>
    >
>

<GLOBAL ACTIONS-TABLE <UNPACK-ACTIONS>>

;"Unpack vocabulary"

;"Conversion table between ISO-8859-1 and ZASCII C1. It also converts all uppcase characters to lowercase."
<CONSTANT UNICODE-TO-ZASCII-C1 <TABLE (BYTE) 
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
64 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 91 92 93 94 95
96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
128 129 130 131 132 133 134 135 136 137 138 139 220 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 220 157 158 159
160 222 162 219 164 165 166 167 168 169 170 163 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 162 188 189 190 223
181 169 191 205 155 201 211 213 182 170 192 164 183 171 193 165 218 206 184 172 194 207 156 215 203 185 173 195 157 174 215 161
181 169 191 205 155 201 211 213 182 170 192 164 183 171 193 165 216 206 184 172 194 207 156 247 203 185 173 195 157 174 215 166 
>>

<DEFINE STRING-TO-TABLE (TEXT "OPT" (LEN 0) "AUX" TBL)
	<COND (<0? .LEN> <SET LEN <LENGTH .TEXT>>)>
    <SET TBL <ITABLE NONE <+ .LEN 1> (BYTE)>>
    <REPEAT ((N 0) C)
        <SET N <+ .N 1>>
        <SET C 0>
        <COND (<L=? .N <LENGTH .TEXT>> <SET C <NTH .TEXT .N>>)>
        <SET C <GETB ,UNICODE-TO-ZASCII-C1 <CHTYPE .C FIX>>>          ;"Convert to ZASCII_C1 and lowercase"
		<PUTB .TBL <- .N 1> .C>
        <COND (<=? .N .LEN> 
			<PUTB .TBL .N 0>		;"Terminate with 0"
			<RETURN .TBL>
		)>
    >
>

<DEFINE UNPACK-VOCABULARY ("AUX" VOCABULARY) 
    <SET VOCABULARY <ITABLE <+ ,NUMBER-VOCABULARY 1>>>
    <REPEAT (VERB-NOUN (N 0) VERB NOUN)
        <SET VERB-NOUN <ITABLE 3>>
        <SET VERB <STRING-TO-TABLE <ZGET ,GAME-DAT <+ ,START-INDEX-VOCABULARY <* .N 2> 0>> <+ ,WORD-LENGTH 2>>>
        <SET NOUN <STRING-TO-TABLE <ZGET ,GAME-DAT <+ ,START-INDEX-VOCABULARY <* .N 2> 1>> <+ ,WORD-LENGTH 2>>>
        <ZPUT .VERB-NOUN 0 .N>
        <ZPUT .VERB-NOUN 1 .VERB>
        <ZPUT .VERB-NOUN 2 .NOUN>
        <ZPUT .VOCABULARY .N .VERB-NOUN>
        <SET N <+ .N 1>>
 		<COND (<G? .N ,NUMBER-VOCABULARY> <RETURN .VOCABULARY>)>
    >
>

<GLOBAL VOCABULARY-TABLE <UNPACK-VOCABULARY>>

;"Unpack rooms
    0 Room #
    1 description
    2 Suppress 'I'm in a' (true/false). * in first pos means to suppress
    3 North
    4 South
    5 East
    6 West
    7 Up
    8 Down
    9 Touchbit
"
<DEFINE UNPACK-ROOMS ("AUX" ROOMS) 
    <SET ROOMS <ITABLE <+ ,NUMBER-ROOMS 1>>>
    <REPEAT (ROOM (N 0) TEXT LOC DESC)
        <SET ROOM <ITABLE 9>>
        <SET DESC <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 6>>>
        <SET DESC <REPLACE-CRLF-AND-96 .DESC>>
        <ZPUT .ROOM 2 <>>
        <COND (<G? <LENGTH .DESC> 0>
            <COND (<=? <NTH .DESC 1> !\*> 
                <ZPUT .ROOM 2 T>
                <SET DESC <REST .DESC>>
            )>
        )>
        <ZPUT .ROOM 0 .N>
        <ZPUT .ROOM 1 .DESC>
        <ZPUT .ROOM 3 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 0>>>
        <ZPUT .ROOM 4 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 1>>>
        <ZPUT .ROOM 5 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 2>>>
        <ZPUT .ROOM 6 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 3>>>
        <ZPUT .ROOM 7 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 4>>>
        <ZPUT .ROOM 8 <ZGET ,GAME-DAT <+ ,START-INDEX-ROOMS <* .N 7> 5>>>
        <ZPUT .ROOMS .N .ROOM>
        <SET N <+ .N 1>>
 		<COND (<G? .N ,NUMBER-ROOMS> <RETURN .ROOMS>)>
    >
>

<DEFINE REPLACE-CRLF-AND-96 (TEXT)
    <REPEAT ((N 0))
        <COND (<=? .TEXT ""> <RETURN .TEXT>)>
        <SET N <+ .N 1>>
        <COND (<=? <ASCII <NTH .TEXT .N>> 13> <PUT .TEXT .N !\ >)>
        <COND (<=? <ASCII <NTH .TEXT .N>> 10> <PUT .TEXT .N !\|>)>
        <COND (<=? <ASCII <NTH .TEXT .N>> 96> <PUT .TEXT .N <ASCII 34>>)>
        <COND (<=? .N <LENGTH .TEXT>> <RETURN .TEXT>)>
    >
>

<GLOBAL ROOMS-TABLE <UNPACK-ROOMS>>

;"Unpack messages"
<DEFINE UNPACK-MESSAGES ("AUX" MESSAGES) 
    <SET MESSAGES <ITABLE <+ ,NUMBER-MESSAGES 1>>>
    <REPEAT ((N 0) TEXT)
        <SET TEXT <ZGET ,GAME-DAT <+ ,START-INDEX-MESSAGES .N>>>
        <SET TEXT <REPLACE-CRLF-AND-96 .TEXT>>
        <ZPUT .MESSAGES .N .TEXT>
        <SET N <+ .N 1>>
 		<COND (<G? .N ,NUMBER-MESSAGES> <RETURN .MESSAGES>)>
    >
>

<GLOBAL MESSAGES-TABLE <UNPACK-MESSAGES>>

;"Unpack items
    0 Item#
    1 Location
    2 Original location
    3 Description
    4 Length of description
    5 noun (lowercase)
    6 Treasure (true/false)
"
<DEFINE UNPACK-ITEMS ("AUX" ITEMS) 
    <SET ITEMS <ITABLE <+ ,NUMBER-ITEMS 1>>>
    <REPEAT (ITEM (N 0) TEXT LOC DESC)
        <SET LOC <ZGET ,GAME-DAT <+ ,START-INDEX-ITEMS <* .N 2> 1>>>
        <SET TEXT <ZGET ,GAME-DAT <+ ,START-INDEX-ITEMS <* .N 2>>>>
        <SET DESC <UNPACK-GET-ITEM-DESC .TEXT>>
        <SET DESC <REPLACE-CRLF-AND-96 .DESC>>
        <SET ITEM <ITABLE 7>>
        <ZPUT .ITEM 0 .N>
        <ZPUT .ITEM 1 .LOC>
        <ZPUT .ITEM 2 .LOC>
        <ZPUT .ITEM 3 .DESC>
        <ZPUT .ITEM 4 <LENGTH .DESC>>
        <ZPUT .ITEM 5 <STRING-TO-TABLE <UNPACK-GET-ITEM-NOUN .TEXT> <+ ,WORD-LENGTH 2>>>
        <ZPUT .ITEM 6 <>>
        <COND (<G? <LENGTH .DESC> 0>
            <COND (<=? <NTH .DESC 1> !\*> 
                <ZPUT .ITEM 6 T>
            )>
        )>
        <ZPUT .ITEMS .N .ITEM>
        <SET N <+ .N 1>>
 		<COND (<G? .N ,NUMBER-ITEMS> <RETURN .ITEMS>)>
    >
>

<DEFINE UNPACK-GET-ITEM-DESC (TEXT)
    <REPEAT ((N 0))
        <COND (<=? .TEXT ""> <RETURN .TEXT>)>
        <SET N <+ .N 1>>
        <COND (<=? .N <LENGTH .TEXT>> <RETURN .TEXT>)>
        <COND (<=? <NTH .TEXT .N> !\/> <RETURN <SUBSTRUC .TEXT 0 <- .N 1>>>)>
    >
>

<DEFINE UNPACK-GET-ITEM-NOUN (TEXT)
    <REPEAT ((N 0) (POS-START 0) (POS-END 0))
        <COND (<=? .TEXT ""> <RETURN .TEXT>)>
        <SET N <+ .N 1>>
        <COND (<G? .N <LENGTH .TEXT>> <RETURN "">)>
        <COND (<=? <NTH .TEXT .N> !\/>
            <COND (<NOT <=? .POS-START 0>>
                <SET POS-END .N>
                <COND (<=? <- .POS-END .POS-START> 1> <RETURN "">)>
                <RETURN <SUBSTRUC .TEXT .POS-START <- .POS-END .POS-START 1>>>
            )> 
            <COND (<=? .POS-START 0>
                <SET POS-START .N>
            )> 
        )>
    >
>

<GLOBAL ITEMS-TABLE <UNPACK-ITEMS>>
