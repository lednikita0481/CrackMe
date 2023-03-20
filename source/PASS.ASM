.286
.model tiny
.code
locals @@
org 100h


;------------------------------------------------
; Exits to DOS
;------------------------------------------------
; Entry:	None
; Exit: 	(non defined)
; Expects:	None
; Destroys:	.... (registers list)
;------------------------------------------------
EXIT		macro
		    nop		;to see in debugger
		    mov ax, 4c00h
		    int 21h
            nop
		    endm
;------------------------------------------------


Start:          in ax, 40h
                mov dx, 0EDAh
                add dx, ax
                nop
                xchg al, ah
                mov di, offset EnteredPass
                call InPass
                mov byte ptr [seed], dh

                cli 
                mov si, offset EnteredPass
                mov di, offset RealPass
                call PassCheck

                mov bx, 0b800h
                mov es, bx
                mov si, offset FRAMEPARAM
                cmp ax, 0
                je loose
                mov [mess_begin], offset OKTEXT
                jmp print
loose:          mov byte ptr [si+2], 2
                mov [mess_begin], offset badtext
print:          call PrFrame
                mov si, offset FRAMEPARAM
                call PrText
                sti
                EXIT


;------------------------------------------------
; Password input
;------------------------------------------------
; Entry:	DI - beginning of user password enter array
; Exit: 	
; Expects:	
; Destroys:	
;------------------------------------------------
InPass          proc 
                push ax

                mov ah, 01h
rep_enter:      int 21h
                cmp al, carr_ret
                je ret_mom
                mov byte ptr [di], al
                inc di
                jmp rep_enter
                
ret_mom:        pop ax
                ret

                endp
;------------------------------------------------


;------------------------------------------------
; password comparison 
;------------------------------------------------
; Entry:	SI - beginning of user password enter array
;           DI - beginning of real password enter array
; Exit: 	AX: 1 if equal, 0 if not equal
; Expects:	
; Destroys:	
;------------------------------------------------
PassCheck       proc


                push cx bx dx

                mov cx, 2           ; 2 passwords - entered and real
another_hash:   push cx
                mov cx, Pass_Length
                xor dx, dx
                xor bx, bx          ; hash is here
Next_Check:     mov al, [si]
                mul byte ptr [seed]
                add bx, ax
                inc si
                loop Next_Check

                pop cx
                cmp cx, 1
                je The_End

                mov [hash_entered], bx
                mov si, di
                loop another_hash

The_End:        dec cx
                mov [hash_real], bx
                jmp skip

                db 15 dup(0)
EnteredPass     db 20 dup(0)

skip:           mov bx, [hash_real]
                cmp bx, [hash_entered]
                jne bad_pass
                mov ax, 1
                jmp @@ret_mom
bad_pass:       mov ax, 0

@@ret_mom:      pop dx bx cx
                ret
                endp
;------------------------------------------------

include FRAME.ASM


.data 
Pass_Length = 5
carr_ret = 013d
space = 20h
seed db ?
Reg_Enter dw 0
hash_real dw 1
hash_entered dw 2
end             Start