%nolist
include macro.asm
%list
;************************************************************  
;C⥪
;************************************************************ 
sstack segment stack
 db 128 dup(?)         					; �⥪
sstack ends
;************************************************************  
;C������ ������
;************************************************************ 
data segment para use16
msgname 		db '��몠��� �ந��뢠⥫�$'   ; ��������� �ணࠬ��
lnt=$-msgname 									  ;����� ���������
shortdescribing db '  �㪮����⢮ �� �ᯮ�짮����� ��몠�쭮�� �ந��뢠⥫�',13,10
				db '  ��� ��६�饭�� �� �㭪⠬ ���� �ᯮ���� ��५�� ',1bh,' � ',1ah,', ��� �롮� �㭪�',13,10
				db '  ���� ������ enter. ��� ����᪠ �ந��뢠��� ������� �롥�� �㭪� ���� ',13,10
				db '  "����㧨��", ������ ��� 䠩��, � ���஬ �࠭���� �������, � �롥�� �㭪� ',13,10
				db '  ���� "���ந�����". ��� ��⠭���� �ந��뢠��� ������ ctrl+enter. ',13,10
				db 13,10,'  ��몠��� �ந��뢠⥫� �।�����祭 ��� �ந��뢠��� ������� �� 䠩��� ',13,10
				db '  ⥪�⮢��� �ଠ�. ������� ����� �ଠ� ����� #2a:8, ��� ᨬ��� # - ������-',13,10
				db '  砥� ���� (��� ����⢨� ����砥�, �� ��� ����), ���  2  ����砥� ����� ',13,10
				db '  ��⠢�(�� 2 �� 4), �㪢� � - ��⨭᪠� ������ ���� ��(���� �� a �� f), ',13,10
				db '  : - ࠧ����⥫�, 8 - ���⥫쭮��� ����(1 - 楫��, 2 - ��������, 4-�⢥���,',13,10
				db '  8 - ���쬠�,9 - ��⭠����).',13,10
				db '  ��몠��� �ந��뢠⥫� ࠧࠡ�⠭ ��㤥�⮬ ��㯯� ���� 12-1 ',13,10
				db '  ��᭥殢� �⠭�᫠���.$',13,10
;�㭪�� �������� ����
msghello		db '��� �ਢ������ ��몠��� �ந��뢠⥫�!$'
msgload			db '����㧨��$'
msgplay 		db '���ந�����$'
msgstop 		db '��⠭�����   $'
msgclear		db '����$'
msgabout 		db '� �ணࠬ��$'
msgexit 		db '��室$'	
msgnull			db '$'
;������ ��࠭��� ABOUT
msgback 		db '��������$'
flagretabout	dw 0
;��६���� ��� ����㧪�
loadstring 		db 128,?,128 dup (?) ;��� ����㦠����� 䠩��
msginput 		db '������ ��� 䠩��: $'
msgerror		db '�訡��! ������ 䠩�� �� �������!$'
msg_format_error db '�訡��! �������ন����� �ଠ� 䠩��! ���쪮 .txt!$'
msgsuccess		db '����㦥�� �������: $'
melodyname		db '$'
format 			db '$'
;���ਯ�� 䠩��
handle 			dw 0
;ᮤ�ন��� 䠩��
buffer			db 255,?,4096 dup (?);���� ��� �࠭���� ����㦥���� �������
;����� ���
notes_frequency2 dw 9120,8126,7236,6836,6084,5412,4828 ;����� ��� ��ன ��⠢�
notes_frequency3 dw	4560,4063,3618,3418,3042,2706,2414 ;����� ��� ���쥩 ��⠢�	
notes_frequency4 dw	2280,2031,1809,1709,1521,1353,1207 ;����� ��� �⢥�⮩ ��⠢�	
		
sharp_notes_frequency2 dw 8608,7670,6836,6448,5746,5120,4560 ;����� ����-��� ��ன ��⠢�
sharp_notes_frequency3 dw 4304,3835,3418,3224,2873,2560,2280 ;����� ����-��� ���쥩 ��⠢�
sharp_notes_frequency4 dw 2152,1917,1709,1672,1436,1280,1140 ;����� ����-��� �⢥�⮩ ��⠢�

r 	db -1
data ends	
.386	
;************************************************************  
;������� ����
;************************************************************ 
assume CS:code,DS:data,SS:sstack
code segment para use16
org 100h	
;************************************************************  
;��楤�� ����㧪�
;************************************************************ 
LOAD 	proc
;���⪠ �࠭� ��� �����
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
print13 5,1,msginput,19,00000111b	;�ਣ��襭�� �����
move_pointer 5,20
xor  	bx,bx
mov 	ah,10
mov 	dx,offset loadstring		;���� ��ப� �������� 䠩��
int		21h
;���������� ��� � ����� ����� 䠩��	
mov 	cl,[loadstring+1]			;����塞 ����� 䠩��
adc		ch,0
mov 	si,cx
mov		loadstring[si+2],0			;����ᨬ � ����� 0
;�஢��塞, �� �� 䠩� � �㦭�� �ଠ�
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
mov 	dx,offset loadstring+2  	;������ ᬥ饭�� ��ப�
mov 	ah,3dh						;���뢠�� 䠩�
mov 	al,0						;⮫쪮 ��� �⥭��		
int 	21h
jnc 	continue
print13 6,1,msgerror,35,00000111b
jmp 	exit_load
continue:
mov 	bx,ax 					
mov 	[handle],ax					;��࠭塞 ���ਯ�� 䠩��

mov		ah,3fh						;�⥭�� 䠩��
mov		bx,[handle]					;�����塞 ���ਯ�� � bx
mov 	dx,offset buffer+2			;ᬥ饭�� ���� ������
mov 	cx,4096						;ࠧ���
int 	21h

mov     cx, 30						;���뢠�� �������� 䠩��
mov     bx, dx
xor		si,si
m:     
mov     al, [bx]
mov		melodyname[si],al			;����ᨬ �������� 䠩�� � ��६�����
inc     bx
inc 	si
loop    m 	
mov     ah, 3Eh						;�����⨥ 䠩��
mov     bx, [handle]				;�����塞 ���ਯ�� � bx
int     21h
print13 6,1,msgsuccess,19,00000111b	;�뢮� ᮮ�饭�� � ����㧪�
print13 6,20,melodyname,30,00000111b;�뢮� �������� �������
exit_load:
move_pointer 3,5
ret
LOAD	endp
;************************************************************  
;��楤�� �ந��뢠��� �������
;************************************************************  
PLAY	proc near
STOP	3								
mov  	si,0           					;���樠�����㥬 㪠��⥫�
mov  	al,01001110b    				;��⠭���� ��� ࠡ��� � ������� 2
out  	43h,al 							;���뫠�� � �������� ॣ����
;ᬮ�ਬ ����, ����砥� �� ����� � ����頥� � ����� 2
NEXT_NOTE:
in   	al,61h     						;����砥� ⥪�騩 �����
or   	al,00000011b   					;ࠧ�蠥� ������� � ⠩���
out  	61h,al   						;�����塞 ����
lea  	bx,buffer+2      				;��६ ᬥ饭�� ��� �������
mov  	al,[bx][si]    					;��६ ��� si-⮩ ���� ��ப�
cmp 	al,'2'							;����砥� ����� ��⠢�
je  	clear_note1						;� ���室�� �� �ந��뢠��� ����
cmp 	al,'3'
je  	clear_note2
cmp 	al,'4'
je  	clear_note3
cmp  	al,023h 						;ᨬ��� # - ����, ���室 �� �ந��뢠��� ����-����
jne   	not_sharp						
mov  	al,[bx][si+1]					;�ய�� ����� # � ���室 �� ���� �� ���
inc  	si
cmp 	al,'2'							;����砥� ����� ��⠢�
je  	sharp_note1						;� ���室�� �� �ந��뢠��� ����
cmp 	al,'3'
je  	sharp_note2
cmp 	al,'4'
je  	sharp_note3
not_sharp:
cmp  	al,40h        					;�᫨ @, � ��㧠
je   	to_pause_play   	
cmp  	al,7ch 							;ᨬ��� | - ࠧ����⥫� ���
je   	shift1
cmp  	al,0ah        					;��७�� �ய�᪠����
je   	shift1       
cmp  	al,24h        					;$ - �ਧ��� ���� �������
je   	to_end_play       				;�᫨ ���⨣��� �����
shift1:
inc  	si								;��������� �訡�� - ���室�� �� ᫥���騩 ᨬ���
jmp  	NEXT_NOTE
;����祭�� ����� ��⮩ ���� 2-� ��⠢�
clear_note1:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET notes_frequency2      ;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
;����祭�� ����� ��⮩ ���� 3-� ��⠢�
clear_note2:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET notes_frequency3      ;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
;����祭�� ����� ��⮩ ���� 4-� ��⠢�
clear_note3:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET notes_frequency4      ;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
;����祭�� ����� ���� � ������
sharp_note1:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET sharp_notes_frequency2;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
sharp_note2:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET sharp_notes_frequency3;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
sharp_note3:
mov  	al,[bx][si+1]					;�ய�� ����� ��⠢�
inc  	si
call 	FAR PTR REPLACE_AL
cbw                 					;��ॢ���� � ᫮��
mov  	bx,OFFSET sharp_notes_frequency4;ᬥ饭�� ⠡���� ����
jmp  	find_frequency
to_pause_play:
jmp 	pause_play
;������ ����� ����
find_frequency:
dec  	ax             					;㬥��蠥� ᮤ�ন��� ax �� 1
shl  	ax,1           					;ᤢ����� ����� ᮤ�ন��� ��(㬭������ �� 2), �.�. ᫮��
mov  	di,ax          					;����㥬 �१ di
mov  	dx,[bx][di]    					;����砥� ����� �� ⠡����
;��稭��� �ᯮ������ ����
mov  	al,dl          					;����頥� � al ����訩 ���� �����
out  	42h,al      					;���뫠�� ��� 
mov  	al,dh          					;����頥� � al ���訩 ���� �����
out  	42h,al      					;���뫠�� ���
jmp  	delay
to_end_play:
jmp  	end_play
to_next_note:
jmp  	NEXT_NOTE
;��㧠, �᫨ @
pause_play:
in   	al,61h      					;����砥� ����� ���� B
and  	al,11111100b        			;�몫�砥� ������� �� �६� ����
out  	61h,al         
;ᮧ����� 横�� ����প�
delay:
mov  	ah,0           					;�㭪�� �⥭�� ���稪� 
int  	1ah            					;����砥� ���祭�� ���稪�(�뢮� � cx/dx ���稪 ⨪�� � ������ ���)
mov  	bx,OFFSET buffer+2  			;ᬥ饭�� �������
mov  	cl,[bx][si+2]    				;��६ ����� ����
mov  	bx,dx          					;��६ ����襥 ᫮�� ���稪�
call 	FAR PTR REPLACE_CL				;�����塞 ���� � ����砥� ���⥫쭮���
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
jmp  	shift       					;�訡�� � ��㧥 -> ��� �� �ந��뢠����
semibreve:
mov  	cx,28							;������ ����� 楫��
add  	bx,cx          					;��।��塞 ������ ����砭��
jmp  	still_play
half:      
mov  	cx,14  							;������ ����� ��������
add  	bx,cx          
jmp  	still_play
fourth: 	
mov  	cx,7 							;������ ����� �⢥��
add  	bx,cx          
jmp  	still_play
eigth:     	
mov  	cx,3							;������ ����� ���쬮�
add  	bx,cx 
jmp  	still_play  
sixteen:   
mov  	cx,1							;������ ����� ��⭠��⮩
add  	bx,cx    
jmp  	still_play

still_play: 
int  	1ah            					;��६ ���祭�� ���稪�
cmp  	dx,bx          					;�ࠢ������ � ����砭���
jne  	still_play     					;�᫨ �� ࠢ��, �த������ ���
shift:
;����⨥ ctrl+enter -> ��室
mov 	ah,0bh
int 	21h
cmp 	al, 0
jnz 	end_play						
;���室�� � ᫥���饩 ���
inc  	si             					
inc  	si
inc  	si
jmp  	to_next_note   
;����� �ந��뢠���
end_play:    
in   	al,61h      					;����砥� ����� ���� B
and  	al,11111100b        			;�몫�砥� �������
out  	61h,al         					;�����塞 ����
ret
PLAY endp
;************************************************************ 
;��楤�� ������ ����� ��� ��室��� ��ப�
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
;��楤�� ������ ����� ����থ� ��室��� ��ப�
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
;��楤�� ���ᮢ�� ��ਧ��⠫쭮� �����
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
;��楤�� ���ᮢ�� ��ਧ��⠫쭮� �����
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
;��楤�� �뢮�� ������� � �ணࠬ��
;************************************************************ 
ABOUT 	proc NEAR
call 	FAR PTR CLEAR_CENTER
;ᮤ�ন���: ⥪�� � ���ᠭ��� �ணࠬ��
print13	3,11,shortdescribing,895,00001111b
print13	21,35,msgback,9,00001111b
;move_pointer 21,35  
call 	FAR PTR PRINT_TITLE
move_pointer 21,39  
ret
ABOUT 	endp	
;************************************************************  
;�㭪�� ���⪨ 業�ࠫ쭮�� ����
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
;��楤�� �뢮�� �������� � ���ᮢ�� ��ଫ���� �ணࠬ��
;************************************************************ 
PRINT_TITLE proc FAR
;�뢮� �������� �ணࠬ�� 
mov 	dh,1    	;��⠭�������� ����� �� 1,28           
mov     dl,28  
mov     bl,9    	;��稭��� � ᨭ��� 梥�
mov 	si,0		;㪠��⥫� �� ����� �㪢�
next_char:
mov     ah,02h
int     10h
print10 msgname[si]	
inc 	si			
inc     bl      	;��������� 梥�
cmp 	bl,16
jne		skip
mov 	bl,9
skip:
inc     dl			;���室 � ᫥���饬� ᨬ���� ��ப�
cmp     si, lnt-1	
je      stop_print_title
jmp     next_char
stop_print_title:
;㣫� ����让 ࠬ��
print_at_pointer 02,00,15,201  			;���孨� ���� 㣮�
print_at_pointer 02,79,15,187  			;���孨� �ࠢ� 㣮�
print_at_pointer 24,00,15,200			;������ ���� 㣮�
print_at_pointer 24,79,15,188			;������ �ࠢ�

;����� ࠬ�� 
set_line_param 02,01,15,78,205			;������ ����
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 24,01,15,78,205			;������ ���� ����
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 03,0,15,21,186			;���⨪��쭠� ����� �����
call 	FAR PTR DRAW_VERTICAL_LINE
set_line_param 03,79,15,21,186			;���⨪��쭠� �ࠢ�� �����
call 	FAR PTR DRAW_VERTICAL_LINE

;ࠬ�� ����� ��������
print_at_pointer 00,27,15,201  			;����� ����
print_at_pointer 01,27,15,186
print_at_pointer 02,27,15,202
print_at_pointer 00,53,15,187  			;�ࠢ�� ����
print_at_pointer 01,53,15,186
print_at_pointer 02,53,15,202
set_line_param 00,28,15,25,205			;������ ����
call 	FAR PTR DRAW_HORIZONTAL_LINE
set_line_param 02,28,15,25,205			;������ ����
call 	FAR PTR DRAW_HORIZONTAL_LINE
xor 	si,si
ret
PRINT_TITLE	endp
;************************************************************  
;�㭪�� ���ᮢ�� ࠬ�� �㭪⮢ ����
;************************************************************ 
PRINT_GRAPHIC_MENU proc
set_line_param 04,01,15,47,205			;������ ���� ����
call 	FAR PTR DRAW_HORIZONTAL_LINE
;ࠬ�� load
print_at_pointer 03,00,15,186
print_at_pointer 04,00,15,204
print_at_pointer 02,10,15,203
print_at_pointer 03,10,15,186
print_at_pointer 04,10,15,202
;ࠬ�� play
print_at_pointer 02,24,15,203
print_at_pointer 03,24,15,186
print_at_pointer 04,24,15,202
;ࠬ�� clear
print_at_pointer 02,30,15,203
print_at_pointer 03,30,15,186
print_at_pointer 04,30,15,202
;ࠬ�� about
print_at_pointer 02,42,15,203
print_at_pointer 03,42,15,186
print_at_pointer 04,42,15,202
;ࠬ�� exit
print_at_pointer 02,48,15,203
print_at_pointer 03,48,15,186
print_at_pointer 04,48,15,188
ret
PRINT_GRAPHIC_MENU endp
;************************************************************  
;�㭪�� �뢮�� ⥪�� ����
;************************************************************ 
PRINT_TEXT_MENU proc
MENU 3
ret
PRINT_TEXT_MENU endp
;************************************************************  
;�㭪�� ���ᮢ�� ����
;************************************************************ 
PRINT_LOGO proc 
PRINT_LOGO_MACRO 10,25
ret
PRINT_LOGO endp
;************************************************************  
;������ ����� �ணࠬ��
;************************************************************ 
MAIN proc
mov 	ax,data   			;����ன�� DS
mov 	ds,ax    			;�� ᥣ���� ������

mainmenu:
mov     ah,0	
mov 	al,03h 				;��� ०��� 80x25, 320x200 ���ᥫ��, 256 梥⮢
int     10h

mov     ax, 1003h
mov     bx, 0       		;�⪫�祭�� ���栭��
int     10h

call 	PRINT_TITLE			;�뢮� ��������
call    PRINT_TEXT_MENU  	;�뢮� �㭪⮢ ����
call	PRINT_GRAPHIC_MENU	;�뢮� ࠬ�� ����
call    PRINT_LOGO

;���������  
print13 3,1,msgload,9,11110000b ;��⠭�������� ��⨢�� �㭪� ���� ����㧨��
move_pointer 3,5	
mov		ax,flagretabout			;�஢�ઠ ������ � ��࠭��� � �ணࠬ��
cmp 	ax,1
jne		notabout		
call    PRINT_TEXT_MENU 		;�᫨ �� ������ � ��࠭��� � �ணࠬ��
print13 3,31,msgabout,11,11110000b
move_pointer 3,36
notabout:
mov		ax,0
mov		flagretabout,ax	
xor		ax,ax	
keyloop:
mov 	cx, 2h				;�⮡ࠦ���� �����
mov 	ah, 7h				;��䨫�����騩 ���᮫�� ���� ��� ��
int 	21h

cmp 	al, 1Bh 			;��室 �� ������ ESC
je 		exitp
cmp 	al, 75
je 		LEFT				;��६�饭�� ����� �� ������ <-
cmp 	al, 77				
je 		RIGHT				;��६�饭�� ����� �� ������ ->
cmp 	al, 0Dh				;����⢨� �� ������ enter
je 		ENTERPRESS
loop 	keyloop  			;�᫨ ����� ���।�ᬮ�७��� ������

jmptomain:
jmp 	mainmenu

moveIT:
mov 	ah, 2h
int 	10h
loop 	keyloop
;��।������� ����� �� 業�ࠬ �㭪⮢ ����
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
;��।������� ��ࠢ� �� 業�ࠬ �㭪⮢ ����
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
;����⨥ enter
ENTERPRESS:
;�஢�ઠ ��宦����� � ������ 21,?
cmp 	dh,21
je 		retabout
cmp 	dh,3
jne 	keyloop 		;�᫨ 㪠��⥫� �� �� ��ப� ����,������
;�㭪� ���� LOAD
cmp 	dl,9
jae 	key3
cmp		dl,1
jbe		keyloop
call 	LOAD			;����⢨� ��� LOAD
key3:
;�㭪� ���� PLAY
cmp 	dl,23
jae 	key4
cmp		dl,11
jbe		keyloop
;����⢨� ��� PLAY
call	PLAY
print13 3,11,msgplay,13,11110000b
mov		dl,17
jmp 	keyloop
key4:
;�㭪� ���� CLEAR
cmp 	dl,29
jae 	key5
cmp		dl,25
jbe		keyloop
;����⢨� ��� CLEAR
jmp 	jmptomain
key5:
;�㭪� ���� ABOUT
cmp 	dl,41
jae 	key6
cmp		dl,31
jbe		keyloop
call	ABOUT			;����⢨� ��� ABOUT
jmp 	keyloop
key6:
;�㭪� ���� EXIT
cmp 	dl,47
jae     keyloop
cmp 	dl,43
jbe		keyloop
;����⢨� ��� EXIT
jmp 	exitp 
retabout:
;������ � ������� ���� �� ���� ABOUT
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
