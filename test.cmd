@echo OFF

evo unit-tests.lua
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

evo test.lua
IF %ERRORLEVEL% NEQ 0 EXIT /B 1