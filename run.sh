#!/bin/ksh
# Определяем название SD-карточки
sdcard=`ls /mnt|grep sdcard.*t`

# Полный путь к SD-карте
SDPath=/mnt/$sdcard

# Получаем полный доступ к SD-карте
mount -u $SDPath

# Вывод картинки старта скрипта
$SDPath/utils/showScreen $SDPath/screens/scriptStart.png

# Удаляем файл .done (если вдруг остался на карточке с прошлого раза)
rm -f  $SDPath/.done

# Создаем файл .started (флаг, что скрипт запущен)
echo started > $SDPath/.started

# Получаем полный доступ к EFS
mount -uw /mnt/efs-persist

#Копируем на карточку имеющиеся файлы базы данных 
cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/old/
cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/old/
cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/old/

#Удаляем имеющуюся запись
$SDPath/utils/sqlite3 /mnt/efs-persist/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"
$SDPath/utils/sqlite3 /HBpersistence/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"
$SDPath/utils/sqlite3 /mnt/hmisql/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"

#Копируем на карточку измененный файл базы данных 
cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/process/
cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/process/
cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/process/

#Добавляем новые записи. Если текст "(4,4100,1)" заменить на "(4,4100,0)", то запуск скрипта отключит доступность инженерного меню
$SDPath/utils/sqlite3 /mnt/efs-persist/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"
$SDPath/utils/sqlite3 /HBpersistence/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"
$SDPath/utils/sqlite3 /mnt/hmisql/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"

#Копируем на карточку измененный файл базы данных 
cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/new/
cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/new/
cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/new/

# Вывод картинки окончания работы скрипта
$SDPath/utils/showScreen $SDPath/screens/scriptDone.png

# Создаем файл .done (флаг, что скрипт отработал)
echo done > $SDPath/.done

# Удаляем файл .started (скрипт отработал до конца)
rm -f  $SDPath/.started