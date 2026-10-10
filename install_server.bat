@echo off
chcp 65001 >nul
title OreLootMaster - Авто-установщик сервера Minecraft 1.21.1
color 0B

echo ======================================================================
echo          ⛏️  OreLootMaster - Авто-установщик сервера 1.21.1  ⛏️
echo ======================================================================
echo  Этот скрипт автоматически скачает ядро Purpur 1.21.1, установит плагин
echo  OreLootMaster, примет EULA и настроит выбранный пресет сложности.
echo ======================================================================
echo.

:: 1. Проверка Java
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] Java не найдена в системе!
    echo Установите Java 21 LTS: https://adoptium.net/temurin/releases/?version=21
    echo.
    pause
    exit /b 1
)

echo [OK] Java обнаружена.
echo.

:: 2. Выбор пресета сложности
echo Выберите пресет ухудшения лута и руд:
echo.
echo   [1] 1. Vanilla Soft        - Легкое усложнение (убраны имбовые яблоки/шаблоны, -20%% руд)
echo   [2] 2. Resource Scarcity   - Ощутимый дефицит (без алмазной брони, -40%% руд, 70%% мусора)
echo   [3] 3. Hardcore Survival   - Суровый хардкор (без алмазов в сундуках, -60%% руд, 85%% мусора)
echo   [4] 4. Stone Age           - Каменный век (железо как алмазы, 95%% мусора, алмазы почти недосягаемы)
echo   [5] 5. Wasteland Nightmare - Апокалипсис / Пустошь (алмазы ВЫКЛ, 100%% мусора в сундуках)
echo   [6] Свой файл config.yml   - Указать путь к готовому файлу
echo.
set /p PRESET_CHOICE="Введите номер [1-6] (по умолчанию 2): "
if "%PRESET_CHOICE%"=="" set PRESET_CHOICE=2

:: 3. Подготовка папок
if not exist "plugins" mkdir plugins
if not exist "plugins\OreLootMaster" mkdir plugins\OreLootMaster

:: 4. Скачивание ядра Purpur 1.21.1
if not exist "server.jar" (
    echo.
    echo [*] Скачивание ядра Purpur 1.21.1...
    curl -L -o server.jar "https://api.purpurmc.org/v2/purpur/1.21.1/latest/download"
    if not exist "server.jar" (
        echo [!] Ошибка скачивания через curl, попытка через PowerShell...
        powershell -Command "Invoke-WebRequest -Uri 'https://api.purpurmc.org/v2/purpur/1.21.1/latest/download' -OutFile 'server.jar'"
    )
    echo [OK] server.jar успешно загружен!
) else (
    echo [OK] server.jar уже существует, пропускаем скачивание.
)

:: 5. Установка плагина OreLootMaster
echo [*] Установка плагина OreLootMaster...
if exist "OreLootMaster-1.0.0.jar" (
    copy /Y "OreLootMaster-1.0.0.jar" "plugins\OreLootMaster-1.0.0.jar" >nul
) else if exist "..\OreLootMaster-1.0.0.jar" (
    copy /Y "..\OreLootMaster-1.0.0.jar" "plugins\OreLootMaster-1.0.0.jar" >nul
) else (
    echo Скачивание плагина OreLootMaster...
    curl -L -o "plugins\OreLootMaster-1.0.0.jar" "https://raw.githubusercontent.com/dap3842/oreloot/main/OreLootMaster-1.0.0.jar" 2>nul
)
echo [OK] Плагин установлен в plugins/OreLootMaster-1.0.0.jar!

:: 6. Настройка EULA и server.properties
echo eula=true> eula.txt
if not exist "server.properties" (
    echo online-mode=false> server.properties
    echo motd=§bOreLootMaster 1.21.1 Server>> server.properties
)

:: 7. Применение пресета
set PRESET_NAME=preset_2_medium.yml
if "%PRESET_CHOICE%"=="1" set PRESET_NAME=preset_1_soft.yml
if "%PRESET_CHOICE%"=="2" set PRESET_NAME=preset_2_medium.yml
if "%PRESET_CHOICE%"=="3" set PRESET_NAME=preset_3_hard.yml
if "%PRESET_CHOICE%"=="4" set PRESET_NAME=preset_4_very_hard.yml
if "%PRESET_CHOICE%"=="5" set PRESET_NAME=preset_5_nightmare.yml

if "%PRESET_CHOICE%"=="6" (
    echo.
    set /p CUSTOM_PATH="Укажите путь к вашему config.yml: "
    copy /Y "%CUSTOM_PATH%" "plugins\OreLootMaster\config.yml" >nul
    echo [OK] Кастомный конфиг скопирован!
) else (
    if exist "presets\%PRESET_NAME%" (
        copy /Y "presets\%PRESET_NAME%" "plugins\OreLootMaster\config.yml" >nul
        echo [OK] Применен пресет: %PRESET_NAME%
    ) else if exist "..\presets\%PRESET_NAME%" (
        copy /Y "..\presets\%PRESET_NAME%" "plugins\OreLootMaster\config.yml" >nul
        echo [OK] Применен пресет: %PRESET_NAME%
    ) else (
        echo [*] Загрузка пресета %PRESET_NAME%...
        curl -s -L -o "plugins\OreLootMaster\config.yml" "https://raw.githubusercontent.com/dap3842/oreloot/main/presets/%PRESET_NAME%" 2>nul
        if not exist "plugins\OreLootMaster\config.yml" (
            curl -s -L -o "plugins\OreLootMaster\config.yml" "http://87.120.165.146:28472/api/config/yaml" 2>nul
        )
        echo [OK] Конфигурация установлена!
    )
)

:: 8. Создание start.bat
echo @echo off > start.bat
echo title Minecraft 1.21.1 - OreLootMaster >> start.bat
echo java -Xms2G -Xmx3G -Djava.net.preferIPv4Stack=true -jar server.jar --nogui >> start.bat
echo pause >> start.bat

echo.
echo ======================================================================
echo    🎉 Установка успешно завершена!
echo.
echo    • Ядро: server.jar (Purpur 1.21.1)
echo    • Плагин: plugins/OreLootMaster-1.0.0.jar
echo    • Конфиг: plugins/OreLootMaster/config.yml
echo    • Скрипт запуска: start.bat
echo.
echo    Веб-панель для настройки: http://87.120.165.146:28472/
echo ======================================================================
echo.

set /p START_NOW="Запустить сервер прямо сейчас? [Y/n]: "
if /i "%START_NOW%"=="n" goto end
call start.bat

:end
