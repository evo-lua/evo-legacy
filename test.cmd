@echo OFF

evo Tests/run-all-tests.lua

IF %ERRORLEVEL% NEQ 0 EXIT /B 1