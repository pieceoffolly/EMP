%nolist
include macro.asm
%list
;************************************************************  
;Cтек
;************************************************************ 
sstack segment stack
 db 128 dup(?)         					; Стек
sstack ends
;************************************************************  
;Cегмент данных
;************************************************************ 
data segment para use16
msgname 		db 'Музыкальный Проигрыватель$'   ; Заголовок программы
lnt=$-msgname 									  ;длина заголовка
shortdescribing db '  Руководство по использованию Музыкального Проигрывателя',13,10
				db '  Для перемещения по пунктам меню используйте стрелки ',1bh,' и ',1ah,', для выбора пункта',13,10
				db '  меню нажмите enter. Для запуска проигрывания мелодии выберите пункт меню ',13,10
				db '  "загрузить", введите имя файла, в котором хранится мелодия, и выберите пункт ',13,10
				db '  меню "воспроизвести". Для остановки проигрывания нажмите ctrl+enter. ',13,10
				db 13,10,'  Музыкальный проигрыватель предназначен для проигрывания мелодий из файлов ',13,10
				db '  текстового формата. Мелодии имеют формат записи #2a:8, где символ # - обозна-',13,10
				db '  чает диез (его отсутвие означает, что нота чистая), цифра  2  означает номер ',13,10
				db '  октавы(от 2 до 4), буква а - латинская запись ноты ми(ноты от a до f), ',13,10
				db '  : - разделитель, 8 - длительность ноты(1 - целая, 2 - половина, 4-четвертая,',13,10
				db '  8 - восьмая,9 - шестнадцатая).',13,10
				db '  Музыкальный Проигрыватель разработан студентом группы ЭВМб 12-1 ',13,10
				db '  Преснецовым Станиславом.$',13,10
;пункты главного меню
msghello		db 'Вас приветствует музыкальный проигрыватель!$'
msgload			db 'Загрузить$'
msgplay 		db 'Воспроизвести$'
msgstop 		db 'Остановить   $'
msgclear		db 'Сброс$'
msgabout 		db 'О программе$'
msgexit 		db 'Выход$'	
msgnull			db '$'
;кнопка страницы ABOUT
msgback 		db 'Вернуться$'
flagretabout	dw 0
;переменные для загрузки
loadstring 		db 128,?,128 dup (?) ;имя загружаемого файла
msginput 		db 'Введите имя файла: $'
msgerror		db 'Ошибка! Такого файла не существует!$'
msg_format_error db 'Ошибка! Неподдерживаемый формат файла! Только .txt!$'
msgsuccess		db 'Загружена мелодия: $'
melodyname		db '$'
format 			db '$'
;дескриптор файла
handle 			dw 0
;содержимое файла
buffer			db 255,?,4096 dup (?);буфер для хранения загруженной мелодии
;частоты нот
notes_frequency2 dw 9120,8126,7236,6836,6084,5412,4828 ;частоты нот второй октавы
notes_frequency3 dw	4560,4063,3618,3418,3042,2706,2414 ;частоты нот третьей октавы	
notes_frequency4 dw	2280,2031,1809,1709,1521,1353,1207 ;частоты нот четвертой октавы	
		
sharp_notes_frequency2 dw 8608,7670,6836,6448,5746,5120,4560 ;частоты диез-нот второй октавы
sharp_notes_frequency3 dw 4304,3835,3418,3224,2873,2560,2280 ;частоты диез-нот третьей октавы
sharp_notes_frequency4 dw 2152,1917,1709,1672,1436,1280,1140 ;частоты диез-нот четвертой октавы

r 	db -1
data ends	
.386	
;************************************************************  
;Сегмент кода
;************************************************************ 
assume CS:code,DS:data,SS:sstack
code segment para use16
org 100h	
;************************************************************  
;Процедура загрузки
;************************************************************ 
LOAD 	proc
;очистка экрана для ввода
mov 	dh,4
mov		bx,0
next_load_row:
inc		dh
cmp 	dh,7
je		stop_clear_load
mov 	dl,1
next_load_col:
mov     ah,02
int     10h
push 	dx
mov		dl,' '
mov		ah,02h
int 	21h
pop 	dx
inc 	dl
cmp		dl,78
je		next_load_row
jmp		next_load_col
stop_clear_load:
print13 5,1,msginput,19,00000111b	;приглашение ввода
move_pointer 5,20
xor  	bx,bx
mov 	ah,10
mov 	dx,offset loadstring		;ввод строки названия файла
int		21h
;добавление нуля в конец имени файла	
mov 	cl,[loadstring+1]			;вычисляем длину файла
adc		ch,0
mov 	si,cx
mov		loadstring[si+2],0			;заносим в конец 0
;проверяем, что это файл в нужном формате
cmp 	loadstring[si+1],'t'
jne 	format_error
cmp 	loadstring[si],'x'
jne 	format_error
cmp 	loadstring[si-1],'t'
jne 	format_error
cmp 	loadstring[si-2],'.'
jne 	format_error
jmp 	open_file
format_error:
print13 6,1,msg_format_error,51,00000111b
jmp 	exit_load
open_file:
mov 	dx,offset loadstring+2  	;задаем смещение строки
mov 	ah,3dh						;открываем файл
mov 	al,0						;только для чтение		
int 	21h
jnc 	continue
print13 6,1,msgerror,35,00000111b
jmp 	exit_load
continue:
mov 	bx,ax 					
mov 	[handle],ax					;сохраняем дескриптор файла

mov		ah,3fh						;чтение файла
mov		bx,[handle]					;помещяем дескриптор в bx
mov 	dx,offset buffer+2			;смещение буфера данных
mov 	cx,4096						;размер
int 	21h

mov     cx, 30						;считываем название файла
mov     bx, dx
xor		si,si
m:     
mov     al, [bx]
mov		melodyname[si],al			;заносим название файла в переменную
inc     bx
inc 	si
loop    m 	
mov     ah, 3Eh						;закрытие файла
mov     bx, [handle]				;помещяем дескриптор в bx
int     21h
print13 6,1,msgsuccess,19,00000111b	;вывод сообщение о загрузке
print13 6,20,melodyname,30,00000111b;вывод названия мелодии
exit_load:
move_pointer 3,5
ret
LOAD	endp
;************************************************************  
;Процедура проигрывания мелодии
;************************************************************  
PLAY	proc near
STOP	3								
mov  	si,0           					;инициализируем указатель
mov  	al,01001110b    				;установка для работы с каналом 2
out  	43h,al 							;посылаем в командный регистр
;смотрим ноту, получаем ее частоту и помещаем в канал 2
NEXT_NOTE:
in   	al,61h     						;получаем текущий статус
or   	al,00000011b   					;разрешаем динамик и таймер
out  	61h,al   						;заменяем байт
lea  	bx,buffer+2      				;берем смещение для мелодии
mov  	al,[bx][si]    					;берем код si-той ноты строки
cmp 	al,'2'							;получаем номер октавы
je  	clear_note1						;и переходим на проигрывание ноты
cmp 	al,'3'
je  	clear_note2
cmp 	al,'4'
je  	clear_note3
cmp  	al,023h 						;символ # - диез, переход на проигрывание диез-ноты
jne   	not_sharp						
mov  	al,[bx][si+1]					;пропуск знака # и переход на ноту за ним
inc  	si
cmp 	al,'2'							;получаем номер октавы
je  	sharp_note1						;и переходим на проигрывание ноты
cmp 	al,'3'
je  	sharp_note2
cmp 	al,'4'
je  	sharp_note3
not_sharp:
cmp  	al,40h        					;если @, то пауза
je   	to_pause_play   	
cmp  	al,7ch 							;символ | - разделитель нот
je   	shift1
cmp  	al,0ah        					;перенос пропускается
je   	shift1       
cmp  	al,24h        					;$ - признак конца мелодии
je   	to_end_play       				;если достигнут конец
shift1:
inc  	si								;возможная ошибка - переходим на следующий символ
jmp  	NEXT_NOTE
;получение частоты чистой ноты 2-й октавы
clear_note1:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET notes_frequency2      ;смещение таблицы частот
jmp  	find_frequency
;получение частоты чистой ноты 3-й октавы
clear_note2:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET notes_frequency3      ;смещение таблицы частот
jmp  	find_frequency
;получение частоты чистой ноты 4-й октавы
clear_note3:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET notes_frequency4      ;смещение таблицы частот
jmp  	find_frequency
;получение частоты ноты с диезом
sharp_note1:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET sharp_notes_frequency2;смещение таблицы частот
jmp  	find_frequency
sharp_note2:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET sharp_notes_frequency3;смещение таблицы частот
jmp  	find_frequency
sharp_note3:
mov  	al,[bx][si+1]					;пропуск номера октавы
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;переводим в слово
mov  	bx,OFFSET sharp_notes_frequency4;смещение таблицы частот
jmp  	find_frequency
to_pause_play:
jmp 	pause_play
;задаем частоту ноты
find_frequency:
dec  	ax             					;уменьшаем содержимое ax на 1
shl  	ax,1           					;сдвигаем влево содержимое ах(умножение на 2), т.к. слова
mov  	di,ax          					;адресуем через di
mov  	dx,[bx][di]    					;получаем частоту из таблицы
;начинаем исполнение ноты
mov  	al,dl          					;помещаем в al младший байт частоты
out  	42h,al      					;посылаем его 
mov  	al,dh          					;помещаем в al старший байт частоты
out  	42h,al      					;посылаем его
jmp  	delay
to_end_play:
jmp  	end_play
to_next_note:
jmp  	NEXT_NOTE
;пауза, если @
pause_play:
in   	al,61h      					;получаем статус порта B
and  	al,11111100b        			;выключаем динамик на время паузы
out  	61h,al         
;создание цикла задержки
delay:
mov  	ah,0           					;функция чтения счетчика 
int  	1ah            					;получаем значение счетчика(вывод в cx/dx счетчик тиков с момента сброса)
mov  	bx,OFFSET buffer+2  			;смещение мелодии
mov  	cl,[bx][si+2]    				;берем длину паузы
mov  	bx,dx          					;берем младшее слово счетчика
call 	FAR PTR REPLACE_CL				;заменяем коды и получаем длительность
mov  	ch,0           
cmp  	cx,1
je   	semibreve
cmp  	cx,2
je   	half
cmp  	cx,4
je   	fourth
cmp  	cx,8
je   	eigth
cmp  	cx,9
je   	sixteen
jmp  	shift       					;ошибка в паузе -> нота не проигрывается
semibreve:
mov  	cx,28							;задаем длину целой
add  	bx,cx          					;определяем момент окончания
jmp  	still_play
half:      
mov  	cx,14  							;задаем длину половины
add  	bx,cx          
jmp  	still_play
fourth: 	
mov  	cx,7 							;задаем длину четверти
add  	bx,cx          
jmp  	still_play
eigth:     	
mov  	cx,3							;задаем длину восьмой
add  	bx,cx 
jmp  	still_play  
sixteen:   
mov  	cx,1							;задаем длину шестнадцатой
add  	bx,cx    
jmp  	still_play

still_play: 
int  	1ah            					;берем значение счетчика
cmp  	dx,bx          					;сравниваем с окончанием
jne  	still_play     					;если не равны, продолжаем звук
shift:
;нажатие ctrl+enter -> выход
mov 	ah,0bh
int 	21h
cmp 	al, 0
jnz 	end_play						
;переходим к следующей ноте
inc  	si             					
inc  	si
inc  	si
jmp  	to_next_note   
;конец проигрывания
end_play:    
in   	al,61h      					;получаем статус порта B
and  	al,11111100b        			;выключаем динамик
out  	61h,al         					;заменяем байт
ret
PLAY endp
;************************************************************ 
;процедура замены кодов нот исходной строки
;************************************************************ 
REPLACE_AL proc FAR
cmp 	al,61h
je  al_6
cmp 	al,62h
je  al_7
cmp 	al,63h
je  al_1
cmp 	al,64h
je  al_2
cmp 	al,65h
je  al_3
cmp 	al,66h
je  al_4
cmp 	al,67h
je  al_5
jmp end_replace_al
al_1: 
mov 	al,01h
jmp end_replace_al
al_2: 
mov 	al,02h
jmp end_replace_al
al_3: 
mov 	al,03h
jmp end_replace_al
al_4: 
mov 	al,04h
jmp end_replace_al
al_5: 
mov 	al,05h
jmp end_replace_al
al_6: 
mov 	al,06h
jmp end_replace_al
al_7: 
mov 	al,07h
end_replace_al:
ret
REPLACE_AL endp
;************************************************************ 
;процедура замены кодов задержек исходной строки
;************************************************************ 
REPLACE_CL proc FAR
push 	ax
mov 	al,cl
sub 	al,30h
mov 	cl,al
pop 	ax
ret
REPLACE_CL endp
;************************************************************  
;Процедура отрисовки горизонтальной линии
;************************************************************  
DRAW_HORIZONTAL_LINE	proc FAR
hm:
mov     ah,02h
int     10h
mov     cx,1
mov     ah,09h
int     10h
inc 	dl
dec		si
cmp 	si,0
jne		hm
xor  	si,si
ret
DRAW_HORIZONTAL_LINE	endp
;************************************************************  
;Процедура отрисовки горизонтальной линии
;************************************************************  
DRAW_VERTICAL_LINE	proc FAR
vm:
mov     ah,02h
int     10h
mov     cx,1
mov     ah,09h
int     10h
inc 	dh
dec		si
cmp 	si,0
jne		vm
xor  	si,si
ret
DRAW_VERTICAL_LINE	endp
;************************************************************  
;Процедура вывода вкладки о программе
;************************************************************ 
ABOUT 	proc NEAR
call 	FAR PTR CLEAR_CENTER
;содержимое: текст с описанием программы
print13	3,11,shortdescribing,895,00001111b
print13	21,35,msgback,9,00001111b
;move_pointer 21,35  
call 	FAR PTR PRINT_TITLE
move_pointer 21,39  
ret
ABOUT 	endp	
;************************************************************  
;Функция очистки центрального поля
;************************************************************ 
CLEAR_CENTER proc FAR
push	ax
mov 	dh,2 
mov		bx,0
next_row:
inc		dh
cmp 	dh,23
je		stop_clear
mov 	dl,1
next_col:
mov     ah,02
int     10h
mov		al,' '
mov		ah,09h
int 	10h
inc 	dl
cmp		dl,78
je		next_row
jmp		next_col
stop_clear:
pop		ax
ret
CLEAR_CENTER endp
;************************************************************  
;Процедура вывода названия и отрисовки оформления программы
;************************************************************ 
PRINT_TITLE proc FAR
;вывод названия программы 
mov 	dh,1    	;устанавливаем курсор на 1,28           
mov     dl,28  
mov     bl,9    	;начинаем с синего цвета
mov 	si,0		;указатель на первую букву
next_char:
mov     ah,02h
int     10h
print10 msgname[si]	
inc 	si			
inc     bl      	;изменение цвета
cmp 	bl,16
jne		skip
mov 	bl,9
skip:
inc     dl			;переход к следующему символу строки
cmp     si, lnt-1	
je      stop_print_title
jmp     next_char
stop_print_title:
;углы большой рамки
print_at_pointer 02,00,15,201  			;верхний левый угол
print_at_pointer 02,79,15,187  			;верхний правый угол
print_at_pointer 24,00,15,200			;нижний левый угол
print_at_pointer 24,79,15,188			;нижний правый

;линии рамки 
set_line_param 02,01,15,78,205			;верхняя часть
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 24,01,15,78,205			;нижняя часть окна
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 03,0,15,21,186			;вертикальная левая линия
call 	FAR PTR DRAW_VERTICAL_LINE
set_line_param 03,79,15,21,186			;вертикальная правая линия
call 	FAR PTR DRAW_VERTICAL_LINE

;рамка вокруг названия
print_at_pointer 00,27,15,201  			;левая часть
print_at_pointer 01,27,15,186
print_at_pointer 02,27,15,202
print_at_pointer 00,53,15,187  			;правая часть
print_at_pointer 01,53,15,186
print_at_pointer 02,53,15,202
set_line_param 00,28,15,25,205			;верхняя часть
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 02,28,15,25,205			;нижная часть
call 	FAR PTR DRAW_HORIZONTAL_LINE
xor 	si,si
ret
PRINT_TITLE	endp
;************************************************************  
;Функция отрисовки рамок пунктов меню
;************************************************************ 
PRINT_GRAPHIC_MENU proc
set_line_param 04,01,15,47,205			;нижняя часть меню
call 	FAR PTR DRAW_HORIZONTAL_LINE
;рамка load
print_at_pointer 03,00,15,186
print_at_pointer 04,00,15,204
print_at_pointer 02,10,15,203
print_at_pointer 03,10,15,186
print_at_pointer 04,10,15,202
;рамка play
print_at_pointer 02,24,15,203
print_at_pointer 03,24,15,186
print_at_pointer 04,24,15,202
;рамка clear
print_at_pointer 02,30,15,203
print_at_pointer 03,30,15,186
print_at_pointer 04,30,15,202
;рамка about
print_at_pointer 02,42,15,203
print_at_pointer 03,42,15,186
print_at_pointer 04,42,15,202
;рамка exit
print_at_pointer 02,48,15,203
print_at_pointer 03,48,15,186
print_at_pointer 04,48,15,188
ret
PRINT_GRAPHIC_MENU endp
;************************************************************  
;Функция вывода текста меню
;************************************************************ 
PRINT_TEXT_MENU proc
MENU 3
ret
PRINT_TEXT_MENU endp
;************************************************************  
;Функция отрисовки лого
;************************************************************ 
PRINT_LOGO proc 
PRINT_LOGO_MACRO 10,25
ret
PRINT_LOGO endp
;************************************************************  
;Главный модуль программы
;************************************************************ 
MAIN proc
mov 	ax,data   			;настройка DS
mov 	ds,ax    			;на сегмент данных

mainmenu:
mov     ah,0	
mov 	al,03h 				;код режима 80x25, 320x200 пикселей, 256 цветов
int     10h

mov     ax, 1003h
mov     bx, 0       		;отключение мерцания
int     10h

call 	PRINT_TITLE			;вывод названия
call    PRINT_TEXT_MENU  	;вывод пунктов меню
call	PRINT_GRAPHIC_MENU	;вывод рамки меню
call    PRINT_LOGO

;клавиатура  
print13 3,1,msgload,9,11110000b ;устанавливаем активным пункт меню Загрузить
move_pointer 3,5	
mov		ax,flagretabout			;проверка возврата со страницы О программе
cmp 	ax,1
jne		notabout		
call    PRINT_TEXT_MENU 		;если был возврат со страницы О программе
print13 3,31,msgabout,11,11110000b
move_pointer 3,36
notabout:
mov		ax,0
mov		flagretabout,ax	
xor		ax,ax	
keyloop:
mov 	cx, 2h				;отображение курсора
mov 	ah, 7h				;нефильтрующий консольный ввод без эха
int 	21h

cmp 	al, 1Bh 			;выход по нажатию ESC
je 		exitp
cmp 	al, 75
je 		LEFT				;перемещение влево по нажатию <-
cmp 	al, 77				
je 		RIGHT				;перемещение влево по нажатию ->
cmp 	al, 0Dh				;действие по нажатию enter
je 		ENTERPRESS
loop 	keyloop  			;если нажата непредусмотренная клавиша

jmptomain:
jmp 	mainmenu

moveIT:
mov 	ah, 2h
int 	10h
loop 	keyloop
;передвижение влево по центрам пунктов меню
LEFT:   
cmp 	dh,3
jne		keyloop
cmp		dl,45
je		move_l1
cmp		dl,36
je		move_l2
cmp		dl,27
je		move_l3
cmp		dl,17
je		move_l4
cmp		dl,7
jb		keyloop
move_l1:
call 	PRINT_TEXT_MENU
print13 3,31,msgabout,11,11110000b
mov		dl,36
jmp 	moveIT
move_l2:
call 	PRINT_TEXT_MENU
print13 3,25,msgclear,5,11110000b
mov		dl,27
jmp 	moveIT
move_l3:
call 	PRINT_TEXT_MENU
print13 3,11,msgplay,13,11110000b
mov		dl,17
jmp 	moveIT
move_l4:
call 	PRINT_TEXT_MENU
print13 3,1,msgload,9,11110000b
mov		dl,5
jmp 	moveIT
;передвижение вправо по центрам пунктов меню
RIGHT:  
cmp 	dh,3
jne		keyloop
cmp		dl,5
je		move_r1
cmp		dl,17
je		move_r2
cmp		dl,27
je		move_r3
cmp		dl,36
je		move_r4
cmp		dl,43
ja		keyloop
move_r1:
call 	PRINT_TEXT_MENU
print13 3,11,msgplay,13,11110000b
mov		dl,17
jmp 	moveIT
move_r2:
call 	PRINT_TEXT_MENU
print13 3,25,msgclear,5,11110000b
mov		dl,27
jmp 	moveIT
move_r3:
call 	PRINT_TEXT_MENU
print13 3,31,msgabout,11,11110000b
mov		dl,36
jmp 	moveIT
move_r4:
call 	PRINT_TEXT_MENU
print13 3,43,msgexit,5,11110000b
mov		dl,45
jmp 	moveIT
;Нажатие enter
ENTERPRESS:
;проверка нахождения в области 21,?
cmp 	dh,21
je 		retabout
cmp 	dh,3
jne 	keyloop 		;если указатель не на строке меню,возврат
;пункт меню LOAD
cmp 	dl,9
jae 	key3
cmp		dl,1
jbe		keyloop
call 	LOAD			;действие для LOAD
key3:
;пункт меню PLAY
cmp 	dl,23
jae 	key4
cmp		dl,11
jbe		keyloop
;действие для PLAY
call	PLAY
print13 3,11,msgplay,13,11110000b
mov		dl,17
jmp 	keyloop
key4:
;пункт меню CLEAR
cmp 	dl,29
jae 	key5
cmp		dl,25
jbe		keyloop
;действие для CLEAR
jmp 	jmptomain
key5:
;пункт меню ABOUT
cmp 	dl,41
jae 	key6
cmp		dl,31
jbe		keyloop
call	ABOUT			;действие для ABOUT
jmp 	keyloop
key6:
;пункт меню EXIT
cmp 	dl,47
jae     keyloop
cmp 	dl,43
jbe		keyloop
;действие для EXIT
jmp 	exitp 
retabout:
;возврат в главное меню из меню ABOUT
cmp 	dl,40
jae 	keyloop
cmp		dl,36
jbe		keyloop
mov		ax,1
mov		flagretabout,ax
jmp 	jmptomain  		
exitp:
CLRSCR
EXIT 

code ends
end MAIN
