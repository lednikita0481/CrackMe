.code
;------------------------------------------------
; Puts to bx adress ov videomem where to print
;------------------------------------------------
; Entry:	CL - x
;           CH - y
; Exit: 	BX - adress of videomem
; Expects:  None
; Destroys:	
;------------------------------------------------
GetCoord    macro
            nop
            push cx
            push ax

            mov al, ch
            mov bh, 80d
            mul bh ; y*80 in ax
            mov ch, 0
            add ax, cx ; y*80 + x in ax
            shl ax, 1
            
            mov bx, ax

            pop ax
            pop cx
            nop
            endm
;------------------------------------------------

;------------------------------------------------
; begin cell in bx, width in al and heighth in cx
;------------------------------------------------
; Entry:	SI - param list beginning
; Exit: 	BX - start cell
;           Al - width
;           CX - heighth
; Expects:	None
; Destroys:	AH
;------------------------------------------------
PRPARAMS    macro
            nop
            mov cl, [si]
            mov ch, [si+1]                      ; mov coordinats to cx reg to call macro
            GetCoord                            ; cell to start in bx
            xor cx, cx

            mov cl, [si]
            mov ch, [si+1]
            mov al, 80
            sub al, cl
            sub al, cl
            add al, 0                           ; width to al

            mov cl, 25
            sub cl, ch
            sub cl, ch
            add cl, 0
            xor ch, ch                          ; heighth to cx
            nop
            endm
;------------------------------------------------ 


;------------------------------------------------
; Prints a frame
;------------------------------------------------
; Entry:	SI - frame params massive beginning
; Exit: 	None
; Expects:	ES = B800h
; Destroys:	
;------------------------------------------------
PrFrame     proc
    
            push ax
            push bx
            push cx
            
            PRPARAMS
            sub cx, 2

            push ax cx dx
            xor ah, ah
            mov al, [si+2]
            sub al, 1
            ;cmp al, 2
            ;ja ??base0
            mov cl, 11d 
            mul cl
            mov si, offset base1
            add si, ax
            ;jmp end_base
            
            
;??base0:    mov si, offset base0
end_base:   pop dx cx ax

            mov dl, [si]
            mov dh, [si+1]                      ; colors to register
            add si, 2
            mov ah, dh                          ; to print same color in 1st and last strings
            mov dh, dl
            call PrString

            mov dh, ah
            add si, 3
CStrPr:     call PrString
            loop CStrPr

            mov dh, dl
            add si, 3
            call PrString

            
            pop cx
            pop bx
            pop ax
            ret
            endp
;------------------------------------------------

;------------------------------------------------
; Prints a string of frame
;------------------------------------------------
; Entry:	SI - frame symbols massive beginning
;           BX - cell to start
;           AL - width
;           DL - frame color
;           DH - outer color
; Exit: 	None
; Expects:	ES = B800h
; Destroys:	AX
;           BX - add amount of used bytes
;------------------------------------------------
PrString    proc

            push cx
            push di
            push ax

            xor ch, ch      
            mov cl, al
            sub cx, 2                       ; to make counter

            mov di, bx                      ; to use str functions

            mov ah, dl                      ; frame color to reg
            mov al, [si]                    ; symbol to reg
            stosw                           ; write first elem

            mov ah, dh                      ; use inner color
            mov al, [si+1]                  ; use inner symbol
            rep stosw                       ; write inner symbols

            mov ah, dl                      ; use edge color
            mov al, [si+2]                  ; use edge symbol
            stosw                           ; write edge symbol

            add bx, 160
            pop ax
            pop di
            pop cx
            ret
            endp
;---------------------------------------------
RealPass        db 'aboba'
;------------------------------------------------
; Prints a text
;------------------------------------------------
; Entry:	SI - frame params massive beginning
;           [mess_begin] - 
; Exit: 	None
; Expects:	ES = B800h
; Destroys:	
;------------------------------------------------
PrText      proc
            push ax
            push bx
            push cx
            push dx
            push di


            PRPARAMS
            mov ch, al
            cmp cl, 4
            jae da_kak_zhe_nazvat_etu_metku_bliat
            jmp aboba
da_kak_zhe_nazvat_etu_metku_bliat: sub ch, 4
            sub cl, 4
            xor ax, ax                      ;ch - width
                                            ;cl - heighth
                                            ;bx - 1st cell of frame
                                            ;ah - used strings
                                            ;al - counted symbols

            mov si, [mess_begin]            ;si - message

zaloopa:    cmp byte ptr [si], '$'
            je end_zaloop
            inc al
            cmp al, ch
            jae next_str
            cmp byte ptr [si], 20h
            jne ret_zaloop
            mov di, si                      ; save last space
            jmp ret_zaloop

next_str:   inc ah
            mov si, di
            xor al, al

ret_zaloop: inc si
            jmp zaloopa
                                ; in ah - amount of needed strings
end_zaloop: inc ah
            cmp ah, cl
            jb notaboba
            jmp aboba


notaboba:   mov al, cl
            add al, 4
            sub al, ah
            xor ah, ah
            xor dx, dx
            mov dl, 2
            div dl
            xor dx, dx               
            xor ah, ah          ; in al - string to start from

            mov dx, cx
            xor cx, cx
            mov cl, al
addd:       add bx, 160
            loop addd
            mov cx, dx
            xor dx, dx          ;reach needed string in bx

            mov si, [mess_begin]
            xor ax, ax
            xor dx, dx
            xor di, di                      ;ch - width
                                            ;cl - heighth
                                            ;bx - 1st cell of needed string
                                            ;al - counted symbols

str1:       inc al
            cmp byte ptr [si], '$'
            je last_str
            cmp al, ch
            jae prstrrr
            cmp byte ptr [si], space
            jne skip_space
            mov di, si                      ; save last space
            mov ah, al                      ; save amount of symbols

skip_space: inc si
            jmp str1

last_str:   mov ah, al
            mov di, si

prstrrr:    mov si, di          ; ret to last space
            mov al, ah          ; ret to symbs amount
            xor ah, ah
            sub si, ax          ; ret to the beginning of the string
            inc si
            mov ah, ch
            push cx             ; save to use as loop counter
            xor cx, cx
            mov cl, al          ; make counter
            add ah, 4
            sub ah, al
            xchg ah, al
            xor ah, ah

            push ax
            push dx
            mov dl, 2
            div dl
            cmp ah, 0
            je skip_add
            pop dx
            pop ax
            add ax, 1
            jmp metka_huetka
skip_add:   pop dx
            pop ax              ; %2 problem solving

metka_huetka: mov di, bx          ; save cell of the str beginning
            add bx, ax          ; reach needed 
            xor ax, ax
ppp:        mov al, [si]
            mov byte ptr es:[bx], al
            inc si
            cmp byte ptr [si], '$'
            je huetka_metka
            add bx, 2
            loop ppp
huetka_metka: pop cx
            mov bx, di
            add bx, 160             ; next str
            xor ax, ax
            cmp byte ptr [si], '$'
            jne str1


aboba:      pop di
            pop dx
            pop cx
            pop bx
            pop ax
            ret
            endp
;------------------------------------------------

.data
FrameParam db 10, 5, 1
;------------------------------------------------
; Frame param: 
; input:
; 1 - x left up conner
; 1 - y left conner
; 3 - base
;
; base:
; 1, 2 - colors
; 3 - 11 - symbols
;------------------------------------------------
base1 db 0ch, 34h,   0dah, 0c4h, 0bfh,   0c3h, 20h, 0b4h,   0c0h, 0c4h, 0d9h
base2 db 47h, 47h,   0c9h, 0cdh, 0bbh,   0cch, 20h, 0b9h,   0c8h, 0cdh, 0bch

OkText db 'Access has granted!$'
BadText db 'Access has denied!$'
mess_begin dw 0