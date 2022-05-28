@echo OFF

if exist evo.exe del evo.exe

evo-luvi . -o evo.exe

IF %ERRORLEVEL% NEQ 0 EXIT /B 1