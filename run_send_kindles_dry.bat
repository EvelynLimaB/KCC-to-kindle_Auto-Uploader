@echo off

echo Loading .env...
for /f "usebackq tokens=*" %%i in (`type .env`) do set %%i

echo Running send_kindles.py...
python send_kindles.py --folder "%CBZ_FOLDER%" --profile "%KCC_PROFILE%" --kcc-cmd "%KCC_CMD%" --kindle-address "%KINDLE_ADDRESS%"

if errorlevel 1 (
    echo Error. Check logs/send_kindles.log
    pause
)