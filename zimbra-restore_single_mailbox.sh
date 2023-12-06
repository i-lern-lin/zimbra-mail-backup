#!/bin/bash
# Автор https://jakondo.ru/rezervnoe-kopirovanie-i-vosstanovlenie-pochtovyh-yashhikov-v-zimbra-collaboration-8-6/
#####################
# Настройки скрипта #
#####################
# Путь где хранятся бекапы
Path="/home/jakonda/bkzm"
# Название домена
Domain="jakondo.ru"
echo "#########################################"
echo "# Восстановление почтового ящика Zimbra #"
echo "#########################################"
echo ""
# Запрос даты, за какое число нужно восстановить бекап
read -p "Введите дату за какое число восстановить из бекапа (прим. 01-01-1985): " Date
# Проверим наличия бекапов за указанную дату
if ! [ -d $Path/$Date ]; then
echo 'Нет бекапов на указанную дату... Завершаем работу скрипта.'
exit
fi
# Лог-файл
Log=$Path"/"$Date"/log_single_restore"
# Запрос имени почтового ящика, который нужно восстановить
read -p "Введите имя почтового ящика (без указания домена): " MailBox
# Проверяем есть ли бекап почтового ящика с указанным именем
MailBox=$MailBox"@"$Domain
if ! [ -f $Path/$Date/$MailBox.tgz ]; then
echo 'Нет бекапа указанного почтового ящика... Завершаем работу скрипта.'
exit
fi
echo "Время начала восстановление почтового ящика ($MailBox) - $(date +%T)"
# Запоминаем время начала восстановления
Begin_time=$(date +%s)
echo "" >> $Log
echo "Начало процесса восстановления - $(date +%T)" >> $Log
echo ""
# Проверяем существует ли восстонавливаемый почтовый ящик
echo "Проверяем существует ли почтовый ящик $MailBox в Zimbra"
Result=$(/opt/zimbra/bin/zmprov getMailboxInfo $MailBox)
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6) [OK]"
echo "Почтовый ящик $MailBox существует, восстанавливаем его..." >> $Log
echo
echo "Почтовый ящик $MailBox существует, восстанавливаем его..."
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6) [FAIL]"
echo "Почтовый ящик $MailBox не существует, создаем его..." >> $Log
echo
echo "Почтовый ящик $MailBox не существует, создаем его..."
echo
# Запрос имени почтового ящика, который нужно восстановить
read -p "Введите ФИО владельца почтового ящика $MailBox (Иванов Иван Иванович): " FIO
Result=$(/opt/zimbra/bin/zmprov ca $MailBox Aa1234567 displayName "$FIO")
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6) [OK]"
echo "Почтовый ящик $MailBox успешно создан, продолжаем восстановление его..." >> $Log
echo
echo "Почтовый ящик $MailBox успешно создан, продолжаем восстановление его..."
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6) [FAIL]"
echo "Почтовый ящик $MailBox не удалось создать, завершаем работу скрипта." >> $Log
echo
echo "Почтовый ящик $MailBox не удалось создать, завершаем работу скрипта."
echo
exit
fi
fi
# Выполняем восстановление указанного почтового ящика
echo "Восстановление почтового ящика $MailBox"
Result=$(/opt/zimbra/bin/zmmailbox -z -m $MailBox -t 0 postRestURL «//?fmt=tgz&resolve=replace» $Path/$Date/$MailBox.tgz)
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Восстановление почтового ящика $MailBox успешено" >> $Log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[FAIL]"
echo "Восстановление почтового ящика $MailBox не удачно" >> $Log
echo
fi
# Вычисление времени работы бекапа почтовых ящиков
End_time=$(date +%s)
echo "Конец восстановления - $(date +%T)" >> $Log
Elapsed_time=$(expr $End_time - $Begin_time)
Hours=$(($Elapsed_time / 3600))
Elapsed_time=$(($Elapsed_time - $Hours * 3600))
Minutes=$(($Elapsed_time / 60))
Seconds=$(($Elapsed_time - $Minutes * 60))
echo "Затрачено времени на восстановление : $Hours час $Minutes минут $Seconds секунд"
echo "Затрачено времени на восстановление : $Hours час $Minutes минут $Seconds секунд" >> $Log
