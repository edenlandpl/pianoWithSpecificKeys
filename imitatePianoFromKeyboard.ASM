format MZ
stack stk:256
entry text:main

macro delay time
{
local ext, iter
	push cx
	mov cx,time
ext:
	push cx
	mov cx,0FFFFh
iter:
	loop iter
	pop cx
	loop ext
	pop cx
}

segment data_16 use16
wl	 db 'asdfghjkl!'
w	dw 41h,53h,44h,46h,47h,48h,4ah,4bh,4ch
przesuniecie dw 0
_stare08 dw ?
	dw ?
_stare09 dw ?
	dw ?
	
mark_08 dw 0
mark_09 dw 0	; przesuniecie wyswietlania  wzgledem poczatku ekranu
atryb db 71h
time_08 db 0
znak dw 0
adres dw 0
flaga2	dw  0
klawiszEscpape dw 01h
segment text use16
moje08:
	push ax
	push bx
	push es
	test [time_08],03
	jnz skip
	mov ax,0B800h
	mov es,ax
	;mov al,21h
	mov ax, [adres]
	mov ah,71h
	mov bx,[mark_08]
	mov [es:bx],ax
	;add [mark_08],2
skip:
	inc [time_08]
	pop es
	pop bx
	pop ax
	jmp dword [ds:_stare08]
	
moje09:
	push ax;odkładamy na stos aby nie zmieniać wartości
	push bx
	push dx
	xor eax,eax
	xor bx, bx
	mov ah,5
	int 16h        ; odczytaj kod klawisz abezposrednio z bufora
	mov bl, cl
	mov [znak],bx
	in ax,60h;scan kod klawisza, skankod puszczonego klawisza jest o 128 większy
	;;sprawdzenie czy al jest równe 1 czyli ESC
	sub ax,[klawiszEscpape]
	jnz dalej02
	mov [ds:flaga2] ,1

dalej02: cmp al,1ch		   ;26         jesli wieksze niz 26, nie interesuje nas
	jna dalej1
	cmp al,26h;               ;1e        jesli mniejsze niz 1e, nie interesuje nas
	ja dalej1
	sub al,1dh		; odejmij od numeru znaku, 1e, aby miec offset litery
       ; mov al, [ds:ax]
       ; mov [adres],0
	;add [przesuniecie],ax
	;mov bx,[przesuniecie+w]
	;mov bx,[eax+w]

	;add bx,w
	;add bx,ax
	;mov w,bx
	;mov bx,[w]

	;mov dl, [przesuniecie+eax]
	;add dl,w
	;add bx,1e
	;;;;;;;;;;;;;;;;;;;;;;;;
	mov bl ,wl
	add bl, al
	mov  al, [bx]

	mov ah,[atryb]
	mov bx, [mark_09]
	push ax
	mov ax,0B800h
	mov es,ax
	pop ax
	mov [es:bx],ax
	add [mark_09],2
	jmp dalej
	;;;;;;;;;;;;;;;;;;;;;;;;;


	mov [adres],bx
	add [mark_08],2 		; przesuniecie offsetu wyswietlania nastepnego znaku


;uruchomienie licznika kanału
	mov al,0B6h
	out 43h,al

;ustalenie wysokości dźwięku
	mov ax,2000
	out 42h,al
	mov al,ah
	out 42h,al
;włączeie dzwieku
	in al,61h
	or al,3
	out 61h,al
	
	jmp dalej
	
dalej1: ;dzwięk wyłączony
	in al,61h
	and al,0FCh
	out	61h,al
	
dalej:
	in al,61h;port klawiatury używany też do głośniczka
	or al,80h;ustawia na najstarszym bicie 1
	out 61h,al;wysyłamy wszystko
	and al,7Fh;mignięcie jedynką oznacza że zostało użyte przerwanie
	out 61h,al
	
	mov al,20h
	out 20h,al
	pop dx
	pop bx
	pop ax
	
	iret;koniec przerwania
	;ret ściąga

main:
	mov	ax,data_16
	mov	ds,ax
	mov ax,stk
	mov ss,ax
	mov sp,256
	
	cli;blokada przerwania
	xor ax,ax
	mov es,ax;tutaj jest 0
	les bx,[es:(8 shl 2)];es ma przyisaną jakąś wartość
	mov [_stare08+2],es
	mov [_stare08],bx
	mov es, ax;zerujemy es
	mov word [es:(8 shl 2)], moje08;offset zapis słowa offsetu moje08
	mov word [es:(8 shl 2)+2], text;segment text
	
	;przerwanie klawiatury następny wektor przerwań
	;przerwanie to działanie procesu w tle
	mov es,ax
	les bx,[es:(9 shl 2)]
	mov [_stare09+2],es
	mov [_stare09],bx
	mov es,ax
	mov word [es:(9 shl 2)],moje09
	mov word [es:(9 shl 2)+2],text
	
	sti	;odblokowanie obsługi przerwania
;loop   
	 delay 20000
	 cmp [flaga2], 1	 ; sprawdz czy w flaga jest 1 - tzn poszukiwany klawisz(tutaj escape)
	 je endzior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dodane do sprawdzenia
	    ; xor   bx, bx
	    ; xor dx, dx
	    ; mov dx, [iteracja]              ;przeniesienie wartosci iteracji do rejestru
	    ; add bx, [tonelow+edx]           ; dodajemy do adresu tablicy iteracje, kolejna wartosc z tabeli [edx to wieksza czesc dl ]
	    ; mov [temp], bx

	push dx
	;push bx
	;xor ah, ah
	;xor dx, dx
	;xor ch, ch
	;mov dl, al

	;add ax,dx
	;add al,w
	;mov [adres], ax

       ; mov ah,9
       ; mov dx,[przesuniecie]
       ; int 21h
	; mov ah,9
       ; mov dx,w
       ; int 21h
       ; mov ah,2
	;mov dx,[znak]
       ; int 21h
       ; mov ah,2
       ; mov dl,[w+przesuniecie]
	;int 21h
       ; pop bx
	pop dx

       ; mov bx,data_16
       ; mov ds,bx
       ; mov ah,9h
       ; mov dx,[adres]
	;int 21h
       ; mov ah,0fh
       ; mov bx,[mark_08]
       ; mov [es:bx],ax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;dzwiek wyłaczony
	in al,61h
	and al,0FCh
	out 61h,al
	
	cli ;blokujemy przerwanie sprzętowa maskowalne
	;wstawiamy w miejsce zmiennych oryginalne wartości przerwania
	xor ax, ax
	les cx, dword[ds:_stare08];dword 16 bitów 2 bajty; segment do es a offset do cx
	mov ds, ax
	mov [ds:(8 shl 2)], cx;wędruje pod wskazany adres 32
	mov [ds:(8 shl 2)+2], es;8*4+2=34
	
	mov ax, data_16
	mov ds,ax
	
	les cx,dword [ds:_stare09]
	xor ax,ax;zerowanie ax
	mov ds,ax;ds jest 0
	mov [ds : (9 shl 2)],cx
	mov [ds : (9 shl 2)+2],es
	
	mov ax, data_16;aby ds wskazywał na nasz obszar pamięci
	mov ds,ax
	
	sti	;odblokowywujemy przerwania
	
endzior:	mov ah,1
	int 21h
	mov	ax,4c00h
	int	21h
	ret
	
segment stk use16
	db 256 dup (?)