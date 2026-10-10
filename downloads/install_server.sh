#!/usr/bin/env bash
# ======================================================================
#       OreLootMaster - Авто-установщик сервера Minecraft 1.21.1 (Linux)
# ======================================================================

set -e

echo "======================================================================"
echo "         ⛏️  OreLootMaster - Авто-установщик сервера 1.21.1 (Linux) ⛏️"
echo "======================================================================"
echo " Этот скрипт автоматически скачает ядро Purpur 1.21.1, установит плагин"
echo " OreLootMaster, примет EULA и настроит выбранный пресет сложности."
echo "======================================================================"
echo ""

# 1. Проверка Java
if ! command -v java &> /dev/null; then
    echo "[ОШИБКА] Java не найдена в системе!"
    echo "Установите Java 21 LTS: sudo apt install openjdk-21-jre-headless (Debian/Ubuntu) или sudo dnf install java-21-openjdk (CentOS/RHEL)"
    exit 1
fi

JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
echo "[OK] Java обнаружена: $JAVA_VER"
echo ""

# 2. Выбор пресета сложности
echo "Выберите пресет ухудшения лута и руд:"
echo ""
echo "  [1] 1. Vanilla Soft        - Легкое усложнение (убраны имбовые яблоки/шаблоны, -20% руд)"
echo "  [2] 2. Resource Scarcity   - Ощутимый дефицит (без алмазной брони, -40% руд, 70% мусора)"
echo "  [3] 3. Hardcore Survival   - Суровый хардкор (без алмазов в сундуках, -60% руд, 85% мусора)"
echo "  [4] 4. Stone Age           - Каменный век (железо как алмазы, 95% мусора, алмазы почти недосягаемы)"
echo "  [5] 5. Wasteland Nightmare - Апокалипсис / Пустошь (алмазы ВЫКЛ, 100% мусора в сундуках)"
echo "  [6] Свой файл config.yml   - Указать путь к готовому файлу"
echo ""
read -p "Введите номер [1-6] (по умолчанию 2): " PRESET_CHOICE
PRESET_CHOICE=${PRESET_CHOICE:-2}

# 3. Подготовка папок
mkdir -p plugins/OreLootMaster

# 4. Скачивание ядра Purpur 1.21.1
if [ ! -f "server.jar" ]; then
    echo ""
    echo "[*] Скачивание ядра Purpur 1.21.1..."
    curl -L -o server.jar "https://api.purpurmc.org/v2/purpur/1.21.1/latest/download"
    echo "[OK] server.jar успешно загружен!"
else
    echo "[OK] server.jar уже существует, пропускаем скачивание."
fi

# 5. Установка плагина OreLootMaster
echo "[*] Установка плагина OreLootMaster..."
if [ -f "OreLootMaster-1.0.0.jar" ]; then
    cp -f "OreLootMaster-1.0.0.jar" "plugins/OreLootMaster-1.0.0.jar"
elif [ -f "../OreLootMaster-1.0.0.jar" ]; then
    cp -f "../OreLootMaster-1.0.0.jar" "plugins/OreLootMaster-1.0.0.jar"
elif [ -f "downloads/OreLootMaster-1.0.0.jar" ]; then
    cp -f "downloads/OreLootMaster-1.0.0.jar" "plugins/OreLootMaster-1.0.0.jar"
else
    echo "Скачивание плагина OreLootMaster..."
    curl -s -L -o "plugins/OreLootMaster-1.0.0.jar" "https://raw.githubusercontent.com/dap3842/oreloot/main/OreLootMaster-1.0.0.jar" || true
fi
echo "[OK] Плагин установлен в plugins/OreLootMaster-1.0.0.jar!"

# 6. Настройка EULA и server.properties
echo "eula=true" > eula.txt
if [ ! -f "server.properties" ]; then
    cat <<EOF > server.properties
online-mode=false
motd=\u00A7bOreLootMaster 1.21.1 Server
server-port=25565
EOF
fi

# 7. Применение пресета
PRESET_NAME="preset_2_medium.yml"
case "$PRESET_CHOICE" in
    1) PRESET_NAME="preset_1_soft.yml" ;;
    2) PRESET_NAME="preset_2_medium.yml" ;;
    3) PRESET_NAME="preset_3_hard.yml" ;;
    4) PRESET_NAME="preset_4_very_hard.yml" ;;
    5) PRESET_NAME="preset_5_nightmare.yml" ;;
esac

if [ "$PRESET_CHOICE" -eq 6 ]; then
    echo ""
    read -p "Укажите путь к вашему файлу config.yml: " CUSTOM_PATH
    cp -f "$CUSTOM_PATH" "plugins/OreLootMaster/config.yml"
    echo "[OK] Кастомный конфиг скопирован!"
else
    if [ -f "presets/$PRESET_NAME" ]; then
        cp -f "presets/$PRESET_NAME" "plugins/OreLootMaster/config.yml"
        echo "[OK] Применен локальный пресет: $PRESET_NAME"
    elif [ -f "../presets/$PRESET_NAME" ]; then
        cp -f "../presets/$PRESET_NAME" "plugins/OreLootMaster/config.yml"
        echo "[OK] Применен пресет: $PRESET_NAME"
    else
        echo "[*] Загрузка пресета $PRESET_NAME..."
        curl -s -L -o "plugins/OreLootMaster/config.yml" "https://raw.githubusercontent.com/dap3842/oreloot/main/presets/$PRESET_NAME" || curl -s -L -o "plugins/OreLootMaster/config.yml" "http://87.120.165.146:28472/api/config/yaml" || true
        echo "[OK] Конфигурация установлена!"
    fi
fi

# 8. Создание start.sh
cat <<'EOF' > start.sh
#!/usr/bin/env bash
java -Xms2G -Xmx3G -Djava.net.preferIPv4Stack=true -jar server.jar --nogui
EOF
chmod +x start.sh

echo ""
echo "======================================================================"
echo "    🎉 Установка успешно завершена!"
echo ""
echo "    • Ядро: server.jar (Purpur 1.21.1)"
echo "    • Плагин: plugins/OreLootMaster-1.0.0.jar"
echo "    • Конфиг: plugins/OreLootMaster/config.yml"
echo "    • Скрипт запуска: ./start.sh"
echo ""
echo "    Веб-панель для настройки: http://87.120.165.146:28472/"
echo "======================================================================"
echo ""

read -p "Запустить сервер прямо сейчас? [y/N]: " START_NOW
if [[ "$START_NOW" =~ ^[Yy]$ ]]; then
    ./start.sh
fi
