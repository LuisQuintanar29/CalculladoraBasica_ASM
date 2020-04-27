;Proyecto Calculadora Basica en Ensamblador 8086
;Autores:
;			Quintanar Ramírez Luis Enrique
;			                  Eduardo Tonathiu
;
title "Calculadora Basica"
	.model small
	.386
	.stack 64
	.data
;======================= VARIABLES ===============================
msg  db 13,10," ( 1 )  SUMA                A + B "
	 db 13,10," ( 2 )  RESTA               A - B " 
	 db 13,10," ( 3 )  MULTIPLICACION      A * B " 
	 db 13,10," ( 4 )  DIVISION            A / B ","$"
msg1 db 13,10,13,10,"INGRESA EL PRIMER NUMERO:   ","$"
msg2 db 13,10,13,10,"INGRESA EL SEGUNDO NUMERO:  ","$"
msg3 db 13,10,13,10,"EL RESULTADO DE LA SUMA ES:   ","$"
msg4 db 13,10,13,10,"EL RESULTADO DE LA RESTA ES:  ","$"
msg5 db 13,10,13,10,"EL RESULTADO DE LA MULTIPICACION ES:  ","$"
msg6 db 13,10,13,10,"EL COCIENTE DE LA DIVISION ES:  ","$"
msg7 db 13,10,13,10,"EL RESIDUO DE LA DIVISION ES:  ","$"
msg8 db "NUMERO NEGATIVO","$"
msg9 db "DIVISION ENTRE CERO","$"
msg10 db 13,10,13,10,"DESEAS CONTINUAR [ Y / N ] ","$"
msg11 db 13,10,13,10,"EL RESULTADO DE LA DIVISION ES:  ","$"

max_digit equ 4
conta_digit db 0
digitos dw 0
mcm dd 100000000
mdm dd 10000000
mm dd 1000000
cm dd 100000
dm dw 10000
mil dw 1000
cien dw 100
diez dw 10

n1 db 0
num1 dw 0
num2 dw 0
residuo dw 0
re dd 0
;=================================================================
;========================= MACROS ================================
clear macro
	mov ah,00h
	mov al,03h
	int 10h
endm
print macro msg
	lea dx,[msg]
	mov ah,09h
	int 21h
endm
printChar macro caracter
	mov ah,02h
	mov dl,caracter
	int 21h
endm
leer_nums macro
	print msg1
	call leer_numero
	mov [num1],bx
	print msg2
	call leer_numero
	mov [num2],bx
endm
;=================================================================
	.code
;===================== PROCEDIMIENTOS ============================
leer_numero proc 
	mov conta_digit,0
leeNum:
	mov ah,08h
	int 21h

	cmp al,0Dh
	je pressEnter

	cmp al,30h
	jl leeNum
	cmp al,39h
	jg leeNum

	mov bl,max_digit
	cmp [conta_digit],bl
	jge leeNum

	mov ah,02h
	mov dl,al
	int 21h
	mov n1,al
	xor ax,ax
	mov al,n1
	sub ax,30h
	push ax

	inc [conta_digit]
	jmp leeNum
pressEnter:
	;Ver si hay algo
	cmp [conta_digit],0
	je leeNum
	;Si hay, guardar el numero
	mov digitos,0
unDigito:
	pop bx
	mov ax,bx
	add digitos,ax
	cmp [conta_digit],2
	jae dosDigitos
	jmp listo
dosDigitos:
	pop bx
	mov ax,bx
	mul [diez]
	add digitos,ax
	cmp [conta_digit],3
	jae tresDigitos
	jmp listo
tresDigitos:
	pop bx
	mov ax,bx
	mul [cien]
	add digitos,ax
	cmp [conta_digit],4
	jae cuatroDigitos
	jmp listo
cuatroDigitos:
	pop bx
	mov ax,bx
	mul [mil]
	add digitos,ax
listo:
	mov bx,digitos
	;call printResult
	ret
endp

printResult proc
	;El resultado debe estar en el registro BX
	;Convierte para imprimir
	mov eax,ebx
	xor edx,edx
	div [mcm]
	mov ecx,edx
	add al,30h
	printChar al

	mov eax,ecx
	xor edx,edx
	div [mdm]
	mov ecx,edx
	add al,30h
	printChar al

	mov eax,ecx
	xor edx,edx
	div [mm]
	mov ecx,edx
	add al,30h
	printChar al

	mov eax,ecx
	xor edx,edx
	div [cm]
	mov ecx,edx
	add al,30h
	printChar al

	mov ax,cx
	xor dx,dx
	div [dm]
	mov cx,dx
	add al,30h
	printChar al

	mov ax,cx
	xor dx,dx
	div [mil]
	mov cx,dx
	add al,30h
	printChar al

	mov ax,cx
	xor dx,dx
	div [cien]
	mov cx,dx
	add al,30h
	printChar al

	mov ax,cx
	xor dx,dx
	div[diez]
	mov cx,dx
	add al,30h
	printChar al

	mov ax,cx
	add al,30h
	printChar al

	ret
endp

SUMA proc
	print msg3
	xor ebx,ebx
	mov bx,[num1]
	add bx,[num2]
	call printResult
	ret
endp

RESTA proc
	print msg4
	xor bx,bx
	mov bx,[num1]
	cmp bx,[num2]	;comparamos si sale como resultado un numero negativo
	jge doResta
	print msg8
	ret
doResta:
	xor bx,bx
	add bx,num1
	sub bx,num2
	call printResult 
	ret
endp
 
MULTI proc
	print msg5
	xor ebx,ebx
	xor eax,eax
	xor edx,edx			;limpiamos los registros
	mov ax,[num1]
	mov bx,[num2]
	mul bx 				;multiplicamos
	mov [residuo],ax	;guardamos la parte baja, ocupamos esta variable por no usar más memoria
	xor ebx,ebx
	shl edx,16			;Hacemos un recorrido para la parte alta
	mov [re],edx
	xor ebx,ebx
	mov bx,[residuo]
	add [re],ebx		;agregamos la parte baja
	mov ebx,[re]
	call printResult
	ret
endp

DIVS proc
	mov bx,[num2]
	cmp bx,0
	jne doDivs
	print msg11
	print msg9
	ret
doDivs:
	print msg6
	xor ebx,ebx
	xor eax,eax
	mov dx,0
	mov ax,[num1]
	div [num2]
	mov [residuo],dx
	mov bx,ax
	call printResult
	print msg7
	mov bx,[residuo]
	call printResult
	ret
endp
;=================================================================
inicio:
	mov ax,@data
	mov ds,ax
;Programa
	clear
	print msg
	leer_nums
	call SUMA
	call RESTA
	call MULTI
	call DIVS
	print msg10
leerOpc:
	mov ah,08h
	int 21h
Yes:
	cmp al,89
	jne y
	jmp inicio
y:
	cmp al,121
	jne No
	jmp inicio
No:
	cmp al,78
	jne n
	jmp salir
n:
	cmp al,110
	jne leerOpc
	jmp salir
salir:
	mov ah,4Ch
	mov al,0
	int 21h
	end inicio