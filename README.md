Парсит лог, созданный com-портом OpenAccess, заносит все записи в базу и обнуляет лог.
Конфигурация в файле config.pl<br>
<br>
<br>
Установка<br>
<br>
1) Отредактируйте config.pl в соответствие со своими настройками (nano config.pl). Параметр log - относительный папки проекта путь к файлу с cron логами, по умолчанию - parse_log.txt<br>
2) Запустите setup.sh<br>
<br>
<br>

Установка вручную<br>
<br>
Что создать текстовый файл-лог для OpenAccess запустите minicom в новом скрине<br>
<br>
screen -dmS [name of screen] minicom -C [path to created log file]<br>
<br>
например<br>
<br>
screen -dmS OA_MINICOM minicom -C /home/access/scripts/access_log.txt<br>
<br>
