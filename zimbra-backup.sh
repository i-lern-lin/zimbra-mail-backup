#!/bin/bash
# https://jakondo.ru/rezervnoe-kopirovanie-i-vosstanovlenie-pochtovyh-yashhikov-v-zimbra-collaboration-8-6/

#####################
# Настройки скрипта #
#####################
# Путь к месту бекапа
Path_backup="/mnt/outback/"
# Временный файл для работы
Source_list="/mnt/outback/"
# Название домена
Domain="mail.net"
# Значение текущей даты
Current_date=$(date +%d-%m-%Y)
# Лог-файл
Log=$Path_backup"/"$Current_date"/log"
echo "#####################################################"
echo "# Резервное копирование всех почтовых ящиков Zimbra #"
echo "#####################################################"
echo ""
echo "Время начала бекапа всех почтовых ящиков - $(date +%T)"
echo "Начало бекапа - $(date +%T)" > $Log
# Запоминаем время начала бекапа
Begin_time=$(date +%s)
echo ""
# Определяем список всех имеющихся почтовых ящиков
echo "Формируем список всех почтовых ящиков для бекапа..."
/opt/zimbra/bin/zmprov -l gaa $Domain > $Source_list
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Формирование списка почтовых ящиков успешно выполнено." >> $Log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[FAIL]"
echo "Формирование списка почтовых ящиков не удалось выполнить. Завершение работы (Неудача)." >> $Log
exit
echo
fi
# Проходимся по всем ящикам в полученном списке и делаем бекап каждого
echo "Выполняем резервное копирование всех почтовых ящиков"
echo "----------------------------------------------------"
mkdir -p $Path_backup/$Current_date/
echo "Создание каталога $Current_date для размешения бекапа." >> $Log
for mailbox in $( cat $Source_list); do
echo "Резервирование почтового ящика - $mailbox"
/opt/zimbra/bin/zmmailbox -z -m $mailbox getRestUrl "//?fmt=tgz" > $Path_backup/$Current_date/$mailbox.tgz
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Бекап почтового ящика $mailbox успешен" >> $Log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[FAIL]"
echo "Бекап почтового ящика $mailbox не удачно" >> $Log
echo
fi
done

# Вычисление времени работы бекапа почтовых ящиков
End_time=$(date +%s)
Elapsed_time=$(expr $End_time - $Begin_time)
Hours=$(($Elapsed_time / 3600))
Elapsed_time=$(($Elapsed_time - $Hours * 3600))
Minutes=$(($Elapsed_time / 60))
Seconds=$(($Elapsed_time - $Minutes * 60))
echo "Затрачено времени на резервное копирование : $Hours час $Minutes минут $Seconds секунд"
echo "Затрачено времени на резервное копирование : $Hours час $Minutes минут $Seconds секунд" >> $Log
