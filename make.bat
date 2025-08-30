echo off
rem Copyright (C) 2020 heasm66
rem You can redistribute and/or modify this file under the terms of the
rem GNU General Public License as published by the Free Software
rem Foundation, either version 3 of the License, or (at your option) any
rem later version.
rem This file is distributed in the hope that it will be useful, but
rem WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
rem General Public License for more details.
rem You should have received a copy of the GNU General Public License
rem along with this file. If not, see <https://www.gnu.org/licenses/>."
echo on
zilf.exe -w scott2zil.zil
Zapf.exe -ab scott2zil.zap > scott2zil_freq.xzap
del scott2zil_freq.zap
Zapf.exe scott2zil.zap
del /F /Q bin\*.*
del /F /Q zapf\*.*
move *.zap zapf\
move *.xzap zapf\
move *.dbg zapf\
move *.z? bin\
pause
