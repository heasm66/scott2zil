# scott2zil
Tool for creating converting a SA-game dat-file to ZIL that compiles with ZILF. 

Scott2Zil is a tool that takes a data-file for a game in the Scott Adams-style genre (games that can be played with for example ScottFree or PerlScott) and repackage it inside a ZIL-shell that can be compiled with ZILF to and independed z5-game.

## Thanks to:
* Tara McGrew, the creator of ZILF. (https://foss.heptapod.net/zilf/zilf)
* pdxiv, the creator of PerlScott for inspiration and code that is much more readable than the original basic interpreter by Scott Adams. (https://github.com/pdxiv/PerlScott)
* Mike Taylor, the creator of scottkit. A tool for compile and decompile games in the SA genre. (https://github.com/MikeTaylor/scottkit)
* Jason Compton, the author of Ghost King, the game that led me down this path... (https://ifdb.tads.org/viewgame?id=pv6hkqi34nzn1tdy)

## scott2zil is tested with the following games:
 - 01  Adventureland
 - 02  Pirate Adventure
 - 03  Mission Impossible
 - 04  Voodoo Castle
 - 12  The Golden Voyage
 - 14b Buckaroo Banzai
 - Ghost King

# Manual
* Take the data from the *.sao or *.dat you created with scottkit or obtained by other means and paste it in the table game-dat. Currently there is adventure 1 - Adventureland, just replace it.
* If you want you can change some of the game constants that controls for example the standard messages and if the gameflow is with split screen or conversational.
* Compile the game with ZILF and play in a Z-machine of your choice (I use Windows Frotz 1.21 myself). There is a make-file with the syntax for ZILF and ZAPF but you probably need to change the paths.

Plase report any issues you find!

You can redistribute and/or modify this file under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This file is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this file. If not, see <https://www.gnu.org/licenses/>.
