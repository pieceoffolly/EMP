;************************************************************
;Макрос выхода в ОС
;************************************************************
EXIT macro
    mov 	ah,4Ch
    int 	21h
endm
;************************************************************
;Макрос вывода названий пунктов меню
;************************************************************
MENU macro coord_dh
push 	ax
push 	cx
push 	dx
push 	bp
;пункт меню LOAD
print13 coord_dh,1,msgload,9,00001111b
;пункт меню PLAY
print13 coord_dh,11,msgplay,13,00001111b
;пункт меню CLEAR
print13 coord_dh,25,msgclear,5,00001111b
;пункт меню ABOUT
print13 coord_dh,31,msgabout,11,00001111b
;пункт меню EXIT
print13 coord_dh,43,msgexit,5,00001111b
pop 	bp
pop 	dx
pop		cx
pop 	ax
endm
;************************************************************
;макрос замены слова "воспроизвести" словом "стоп"
;************************************************************
STOP macro coord_dh
;пункт меню STOP
print13 coord_dh,11,msgstop,13,00001111b
move_pointer coord_dh,17
endm
;************************************************************
;Макрос очистки экрана путем установки второго видео режима	
;************************************************************
CLRSCR 	macro
mov  ah,0        ;номер функции установки режима дисплея
mov  al,02h      ;код режима 80x25 черно-белого
int  10h         ;очистка экрана
endm	
;************************************************************
;Макрос перемещения указателя на координаты coord_dh,coord_dl
;************************************************************
move_pointer macro coord_dh,coord_dl
mov 	dh,coord_dh
mov 	dl,coord_dl 
mov     ah,02h
int     10h
endm
;************************************************************
;Макрос перемещения указателя на координаты coord_dh,coord_dl 
;и печати символа char цветом color
;************************************************************
print_at_pointer macro coord_dh,coord_dl,color,char
push 	ax
push 	bx
push 	cx
push 	dx
mov 	dh,coord_dh
mov 	dl,coord_dl
mov     bl,color  
mov     ah,02h
int     10h
mov     al,char
mov     cx,1
mov     ah,09h
int     10h
pop 	dx
pop 	cx
pop 	bx
pop 	ax
endm
;************************************************************
;макрос для вывода на экран строки через прерывание 21h
;************************************************************
print21 macro
mov 	ah,09h  
int 	21h 
endm
;************************************************************
;макрос для вывода на экран строки через функцию 13h прерывания 10h
;координаты печати coord_dh,coord_dl 
;адрес строки string, размер строки string_size, цвет colorb
;************************************************************
print13 macro coord_dh,coord_dl,string,string_size,colorb
push cx
mov dh,coord_dh
mov dl,coord_dl
mov al,0
mov bh,0
mov bl,colorb
push ds
pop es
lea bp,string
mov cx,string_size
mov ah,13h
int 10h
pop cx
endm
;************************************************************
;макрос для вывода на экран символа char через прерывание 10h
;************************************************************
print10 macro char
mov     al,char
mov     cx,1
mov     ah,09h
int     10h
endm
;************************************************************
;макрос для подготовки к вызову draw_lines процедурам
;************************************************************
set_line_param macro coord_dh,coord_dl,color,linelength,symbol
xor 	bx,bx
move_pointer coord_dh,coord_dl ;начальная координата
mov 	bl,color			   ;цвет
mov 	si,linelength		   ;длина
mov 	al,symbol			   ;рисуемый символ
endm
;************************************************************
;макрос отрисовки логотипа МП 
;************************************************************
PRINT_LOGO_MACRO macro top_begin,left_begin
;M
print13 top_begin,left_begin,msgnull,1,10101010b
print13 top_begin,left_begin+1,msgnull,1,10101010b
print13 top_begin+1,left_begin,msgnull,1,10101010b
print13 top_begin+1,left_begin+1,msgnull,1,10101010b
print13 top_begin+2,left_begin,msgnull,1,10101010b
print13 top_begin+2,left_begin+1,msgnull,1,10101010b
print13 top_begin+3,left_begin,msgnull,1,10101010b
print13 top_begin+3,left_begin+1,msgnull,1,10101010b
print13 top_begin+4,left_begin,msgnull,1,10101010b
print13 top_begin+4,left_begin+1,msgnull,1,10101010b
print13 top_begin+5,left_begin,msgnull,1,10101010b
print13 top_begin+5,left_begin+1,msgnull,1,10101010b
print13 top_begin+6,left_begin,msgnull,1,10101010b
print13 top_begin+6,left_begin+1,msgnull,1,10101010b
print13 top_begin+7,left_begin,msgnull,1,10101010b
print13 top_begin+7,left_begin+1,msgnull,1,10101010b
print13 top_begin+8,left_begin,msgnull,1,10101010b
print13 top_begin+8,left_begin+1,msgnull,1,10101010b

print13 top_begin+1,left_begin+2,msgnull,1,10101010b
print13 top_begin+1,left_begin+3,msgnull,1,10101010b
print13 top_begin+2,left_begin+4,msgnull,1,10101010b
print13 top_begin+2,left_begin+5,msgnull,1,10101010b
print13 top_begin+3,left_begin+6,msgnull,1,10101010b
print13 top_begin+3,left_begin+7,msgnull,1,10101010b
print13 top_begin+2,left_begin+8,msgnull,1,10101010b
print13 top_begin+2,left_begin+9,msgnull,1,10101010b
print13 top_begin+1,left_begin+10,msgnull,1,10101010b
print13 top_begin+1,left_begin+11,msgnull,1,10101010b

print13 top_begin,left_begin+12,msgnull,1,10101010b
print13 top_begin,left_begin+13,msgnull,1,10101010b
print13 top_begin+1,left_begin+12,msgnull,1,10101010b
print13 top_begin+1,left_begin+13,msgnull,1,10101010b
print13 top_begin+2,left_begin+12,msgnull,1,10101010b
print13 top_begin+2,left_begin+13,msgnull,1,10101010b
print13 top_begin+3,left_begin+12,msgnull,1,10101010b
print13 top_begin+3,left_begin+13,msgnull,1,10101010b
print13 top_begin+4,left_begin+12,msgnull,1,10101010b
print13 top_begin+4,left_begin+13,msgnull,1,10101010b
print13 top_begin+5,left_begin+12,msgnull,1,10101010b
print13 top_begin+5,left_begin+13,msgnull,1,10101010b
print13 top_begin+6,left_begin+12,msgnull,1,10101010b
print13 top_begin+6,left_begin+13,msgnull,1,10101010b
print13 top_begin+7,left_begin+12,msgnull,1,10101010b
print13 top_begin+7,left_begin+13,msgnull,1,10101010b
print13 top_begin+8,left_begin+12,msgnull,1,10101010b
print13 top_begin+8,left_begin+13,msgnull,1,10101010b
;П
print13 top_begin,left_begin+18,msgnull,1,10101010b
print13 top_begin,left_begin+19,msgnull,1,10101010b
print13 top_begin+1,left_begin+18,msgnull,1,10101010b
print13 top_begin+1,left_begin+19,msgnull,1,10101010b
print13 top_begin+2,left_begin+18,msgnull,1,10101010b
print13 top_begin+2,left_begin+19,msgnull,1,10101010b
print13 top_begin+3,left_begin+18,msgnull,1,10101010b
print13 top_begin+3,left_begin+19,msgnull,1,10101010b
print13 top_begin+4,left_begin+18,msgnull,1,10101010b
print13 top_begin+4,left_begin+19,msgnull,1,10101010b
print13 top_begin+5,left_begin+18,msgnull,1,10101010b
print13 top_begin+5,left_begin+19,msgnull,1,10101010b
print13 top_begin+6,left_begin+18,msgnull,1,10101010b
print13 top_begin+6,left_begin+19,msgnull,1,10101010b
print13 top_begin+7,left_begin+18,msgnull,1,10101010b
print13 top_begin+7,left_begin+19,msgnull,1,10101010b
print13 top_begin+8,left_begin+18,msgnull,1,10101010b
print13 top_begin+8,left_begin+19,msgnull,1,10101010b

print13 top_begin,left_begin+20,msgnull,1,10101010b
print13 top_begin,left_begin+21,msgnull,1,10101010b
print13 top_begin,left_begin+22,msgnull,1,10101010b
print13 top_begin,left_begin+23,msgnull,1,10101010b
print13 top_begin,left_begin+24,msgnull,1,10101010b
print13 top_begin,left_begin+25,msgnull,1,10101010b
print13 top_begin,left_begin+26,msgnull,1,10101010b
print13 top_begin,left_begin+27,msgnull,1,10101010b

print13 top_begin,left_begin+28,msgnull,1,10101010b
print13 top_begin,left_begin+29,msgnull,1,10101010b
print13 top_begin+1,left_begin+28,msgnull,1,10101010b
print13 top_begin+1,left_begin+29,msgnull,1,10101010b
print13 top_begin+2,left_begin+28,msgnull,1,10101010b
print13 top_begin+2,left_begin+29,msgnull,1,10101010b
print13 top_begin+3,left_begin+28,msgnull,1,10101010b
print13 top_begin+3,left_begin+29,msgnull,1,10101010b
print13 top_begin+4,left_begin+28,msgnull,1,10101010b
print13 top_begin+4,left_begin+29,msgnull,1,10101010b
print13 top_begin+5,left_begin+28,msgnull,1,10101010b
print13 top_begin+5,left_begin+29,msgnull,1,10101010b
print13 top_begin+6,left_begin+28,msgnull,1,10101010b
print13 top_begin+6,left_begin+29,msgnull,1,10101010b
print13 top_begin+7,left_begin+28,msgnull,1,10101010b
print13 top_begin+7,left_begin+29,msgnull,1,10101010b
print13 top_begin+8,left_begin+28,msgnull,1,10101010b
print13 top_begin+8,left_begin+29,msgnull,1,10101010b
endm


