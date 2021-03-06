format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
;??????? 4. ?????? B, ??? B[i] = 1, ???? A[i] >0, = -1, ???? A[i] <0, = 0,????  A[i]=0
section '.data' data readable writable

        strVecSize     db 'size of vector: ', 0
        strIncorSize   db 'Incorrect size of vector = %d', 10, 0
        strVecElemI    db '[%d]? ', 0
        strScanInt     db '%d', 0
        strBVec        db '---B---', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0

        i            dd ?
        tmp          dd ?
        tmp_b          dd ?
        tmpStack     dd ?
        vec          rd 100
        vecB          rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput

; 2) out of B Vector
        push strBVec
        call [printf]

; 3) test vector out
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:

        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; fail size
        push vec_size
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
; else continue...
getVector:

        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov eax, vecB           ; eax = &vecB
        mov [tmp_b], eax

getVecLoop:

        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]

        mov eax, 0
        cmp [ebx], eax
        jg  greaterThanOne
        je equalOne
        jl lessThanOne

middleOfLoop:

        add ebx, 4
        jmp getVecLoop

endInputVector:

        mov ebx, vec
        xor ecx, ecx
        ret

greaterThanOne:
         mov eax, [tmp_b]
         mov [eax], dword 1
         jmp backToLoop

lessThanOne:
        mov eax, [tmp_b]
        mov [eax], dword -1
        jmp backToLoop

equalOne:
         mov eax, [tmp_b]
         mov [eax], dword 0
         jmp backToLoop

backToLoop:
        mov eax,[tmp_b]
        add eax, 4
        mov [tmp_b],eax
        jmp middleOfLoop


;--------------------------------------------------------------------------
VectorOut:

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB           ; ebx = &vecB

putVecLoop:

        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop

endOutputVector:

        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'