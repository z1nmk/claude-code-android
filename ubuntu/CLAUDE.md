# Управление телефоном (claude-code-android)

Ты работаешь в Ubuntu (proot-distro) внутри Termux на Android-телефоне пользователя. Proot не может запускать
бинарники из /system/bin, поэтому команды Android выполняются через **rish** (Shizuku) по мосту socat
(Termux, 127.0.0.1:7777). Права — как у `adb shell` (uid 2000).

## Команды
- `rish -c '<команда>'` — выполнить команду Android: `input tap X Y`, `input swipe ...`, `input text '...'`,
  `input keyevent KEYCODE_HOME|BACK|WAKEUP`, `am start -n pkg/.Activity`, `am start -a android.intent.action.VIEW -d URL`,
  `monkey -p <пакет> 1` (запустить приложение), `pm list packages`, `pm install -r -g /data/local/tmp/x.apk`,
  `settings get/put`, `dumpsys ...`, `cmd ...`, `uiautomator dump /sdcard/.ui.xml` (дерево элементов экрана).
- `shot OUT.png` — скриншот основного экрана (потом посмотри его через Read).
- `tap-text "Текст" [display]` — тап по элементу с таким текстом (через uiautomator). Дешевле, чем искать координаты по скриншоту.
- `vdisplay start [WxH/DPI]` (запускать фоновой задачей) / `vdisplay stop` / `vdisplay status` — скрытый виртуальный
  экран: приложения работают на нём, не мешая пользователю. Номер экрана N — из `vdisplay status`;
  запуск приложения на нём: `rish -c 'am start --display N -f 0x18000000 -n pkg/.Activity'`; ввод: `input -d N tap X Y`.
- `vshot OUT.png` — скриншот скрытого экрана.

## Правила и подсказки
- Если `rish` ничего не возвращает — мост не запущен или Shizuku остановлен. Попроси пользователя нажать кнопку
  «Claude» (или выполнить `~/claude-start.sh` в Termux) и проверить, что Shizuku запущен. Не предлагай adb по сети.
- `pm install` не читает /sdcard напрямую: сначала `cp /sdcard/Download/x.apk /data/local/tmp/`.
- Когда телефон спит, тапы на скрытом экране теряются: сначала `rish -c 'input keyevent KEYCODE_WAKEUP'`.
- Экономь токены: для поиска элементов используй `uiautomator dump` + grep или `tap-text`, а скриншоты — только когда
  нужно увидеть картинку. Для повторяющихся действий (автокликер и т.п.) пиши скрипт, который работает сам,
  а не цикл «скриншот → клик» через себя.
- Перед необратимыми действиями (удаление, покупки, отправка сообщений, смена системных настроек) спрашивай пользователя.
