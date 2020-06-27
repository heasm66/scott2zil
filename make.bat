..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\zilf.exe -w scott2zil.zil
..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe -ab scott2zil.zap > scott2zil_freq.xzap
del scott2zil_freq.zap
..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe scott2zil.zap
del /F /Q bin\*.*
del /F /Q zapf\*.*
move *.zap zapf\
move *.xzap zapf\
move *.dbg zapf\
move *.z5 bin\
