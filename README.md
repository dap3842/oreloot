# ⛏️ OreLootMaster (Minecraft 1.21.1 / Paper & Purpur)

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live%20Guide-2563eb?style=for-the-badge&logo=github)](https://dap3842.github.io/oreloot/)
[![Web Configurator](https://img.shields.io/badge/Web%20Configurator-87.120.165.146%3A28472-10b981?style=for-the-badge)](http://87.120.165.146:28472/)
[![Minecraft Version](https://img.shields.io/badge/Minecraft-1.21.1-orange?style=for-the-badge&logo=minecraft)](https://papermc.io/)

Комплексная система управления генерацией руд и ухудшением лута в сундуках данжей для серверов **Minecraft 1.21.1** (Paper / Purpur API).

---

## 🌐 Полезные ссылки

* **Онлайн Веб-конфигуратор:** [http://87.120.165.146:28472/](http://87.120.165.146:28472/)
* **Интерактивный сайт-руководство (GitHub Pages):** [https://dap3842.github.io/oreloot/](https://dap3842.github.io/oreloot/)
* **Скачать плагин:** [OreLootMaster-1.0.0.jar](downloads/OreLootMaster-1.0.0.jar)
* **Авто-установщик для Windows:** [install_server.bat](downloads/install_server.bat)
* **Авто-установщик для Linux:** [install_server.sh](downloads/install_server.sh)

---

## 🚀 Быстрый запуск

### Вариант 1: Автоматическая установка через скрипт (1 минута)
1. Скачайте `install_server.bat` (для Windows) или `install_server.sh` (для Linux VPS).
2. Запустите скрипт:
   * Выберите желаемый пресет сложности [1-5] или укажите свой `config.yml`.
   * Скрипт сам скачает ядро Purpur 1.21.1, подключит плагин, создаст `eula.txt` и запустит готовый сервер!

### Вариант 2: Ручная установка
1. Поместите файл `OreLootMaster-1.0.0.jar` в папку `plugins/` вашего сервера (Paper / Purpur 1.21.1, Java 21).
2. Запустите сервер:
   ```bat
   java -Xms2G -Xmx3G -Djava.net.preferIPv4Stack=true -jar server.jar --nogui
   ```
3. Редактируйте настройки через онлайн-панель [http://87.120.165.146:28472/](http://87.120.165.146:28472/).
4. В игре выполните:
   * `/oreloot reload` — мгновенное обновление лута без выключения сервера (за 2 миллисекунды!).
   * `/restart` — перезапуск для применения новых руд в неисследованных чанках.

---

## 🔥 5 Готовых пресетов сложности

| Пресет | Множитель руд | Черный список (что удалено) | Шанс мусора | Контроль чар на книгах | Файл конфигурации |
|---|:---:|---|:---:|---|:---:|
| **1. Vanilla Soft** | **0.8x** (80%) | Зачарованные яблоки, незеритовые шаблоны | **50%** | Мягкая замена топовых чар (Починка, Прочность III) | [`presets/preset_1_soft.yml`](presets/preset_1_soft.yml) |
| **2. Resource Scarcity** | **0.6x** (60%) | Золотые яблоки, алмазная броня и оружие | **70%** | Замена боевых чар (Острота, Защита IV) | [`presets/preset_2_medium.yml`](presets/preset_2_medium.yml) |
| **3. Hardcore Survival** | **0.4x** (40%) | ВСЕ алмазы, яблоки, трезубцы, ядро, седла | **85%** | Замена чар на пул мусора (Шипы, Медлительность) | [`presets/preset_3_hard.yml`](presets/preset_3_hard.yml) |
| **4. Stone Age** | **0.3x** (30%) | Алмазы, незерит, изумруды, жемчуг, тотемы, слитки | **95%** | Жесткий вайтлист только базовых утилитных чар | [`presets/preset_4_very_hard.yml`](presets/preset_4_very_hard.yml) |
| **5. Wasteland Nightmare** | **0.2x** (Алмазы: ВЫКЛ!) | ВСЕ руды, броня, слитки, книги, оружие, ценности | **100%** | **Чары на книгах полностью отключены** (обычные книги) | [`presets/preset_5_nightmare.yml`](presets/preset_5_nightmare.yml) |

---

## ✨ Контроль чар на зачарованных книгах (Enchanted Books)
В плагин и веб-панель встроена гибкая система контроля зачарований на книгах (`Material.ENCHANTED_BOOK`) в сундуках данжей:
1. **Белый список (Whitelist):** Разрешает генерацию только одобренных чар из 42 доступных в Minecraft 1.21.1.
2. **Точечная замена 1-в-1 (Specific replacement):** Заменяет имбовые чары (например, Починку или Шелк) на конкретные аналоги (например, Прочность I или Эффективность II) с настраиваемым шансом.
3. **Замена в пул мусора (Pool replacement):** Заменяет нежелательные чары на случайное зачарование из пула слабого/мусорного зачарования с весами.
4. **Полное отключение чар на книгах:** Превращает любые зачарованные книги в сундуках в обычные книги (`Material.BOOK`).

---

## 🏛️ Технические особенности
* **0% лагов в мире:** Генерация руд контролируется нативным ванильным датапаком `OreLootMaster_Worldgen`, который генерируется автоматически без тяжелых слушателей чанков.
* **Поддержка Minecraft 1.21:** Полноценный перехват сундуков, вагонеток, бочек, а также хранилищ **Vault / Ominous Vault** и **Trial Spawner** в Trial Chambers.
* **Быстродействие $O(1)$:** Фильтрация по битовым маскам `EnumSet<Material>` и кэшированным `NamespacedKey` за доли миллисекунды.

