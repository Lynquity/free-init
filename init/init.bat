@echo off

if "%1"=="express" (
    powershell -ExecutionPolicy Bypass -File "./../program/init.ps1 -File ./../../templates/express.yaml"
)