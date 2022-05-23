; Macro que realiza o print de uma string comum.
macro print address
    push AX
    push DX
    
    mov AH, 09h
    mov DX, address
    int 21h
    
    pop DX
    pop AX
endm

; Macro que recebe o input do usuario.
macro input address
    push AX
    push DX
    
    mov AH, 0Ah
    mov DX, address
    int 21h    
    
    pop DX
    pop AX
endm

; Macro que pula linha.
macro breakLine
    push AX
    push DX
    
    mov AH, 09h
    mov DX, bufferLfcr
    int 21h
    
    pop DX
    pop AX
endm

; Programa principal
    org 100h
    
requestBase:
    print bufferReqDestBase     
    call receiveBase
    mov AL, [602h]
    cmp AL, 0
    je requestBase 
    
requestNumber:
    print bufferReqValue
    call receiveNumber
    mov AL, [602h]
    cmp AL, 0
    je requestNumber
    
    ; Fazer funcao que converte da base decimal para a base solicitada
    
    ret

; Funcoes
receiveBase:
    push AX
    push BX
    push CX
    push DX
    
    ; Inicializacao da memoria para a regra de negocio
    mov SI, bufferBase
    mov BL, 0Ah   ; 0h30 = '0'
    mov [600h], 0 ; Endereco de memoria que ficara armazenado o valor da base
    mov [601h], 0 ; Endereco de memoria que ficara armazenado o tamanho da string
    mov [602h], 1 ; Caso o funcao detecte erro, ira retornar o booleano aqui
    
    ; Pegar o valor do usuario.
    input bufferBase
    
    ; Obtem o tamanho da string digitada pelo usuario
    BaseStringSizeLoop:
    mov AL, [SI+2]
    inc [601h]
    inc SI
    cmp AL, 0Dh
    jne BaseStringSizeLoop
    dec [601h]
    
    ; Verificar se e um numero de fato.
    mov SI, bufferBase
    mov DL, [601h]
    
    BaseVerifyLoop:    
    mov AL, [SI+2]
    cmp AL, 30h
    jb invalidNumberMessage ; Caracter digitado menor do que 30h
    cmp AL, 39h
    ja invalidNumberMessage ; Caracter digitado maior do que 39h
    dec DL
    inc SI
    cmp DL, 0
    ja BaseVerifyLoop  
    
    ; Converte para um numero
    mov SI, bufferBase
    mov AX, 0
    mov CX, 0
    
    BaseConvertLoop:
    mov AL, [SI+2]
    sub AL, 30h
    cmp [601h], 1
    ja BaseMultiplyAL
    add CX, AX
    mov [600h], CX
    
    ; Verificar se esta entre 2 e 16.
    mov AX, 0
    mov AL, [600h]
    cmp AL, 02h
    jb invalidNumberMessage
    cmp AL, 10h
    ja invalidNumberMessage 
    
    EndBaseFunction:
    pop DX
    pop CX
    pop BX
    pop AX
    breakline
    ret
    
    BaseMultiplyAL:
    add AX, CX
    mul BL
    mov CX, AX
    inc SI
    dec [601h]
    jmp BaseConvertLoop
    
    

receiveNumber:
    push AX
    push BX
    push CX
    push DX
    
    ; Inicializacao da memoria para a regra de negocio
    mov SI, bufferValue
    mov BX, 0Ah
    mov [602h], 1 ; Caso o funcao detecte erro, ira retornar o booleano aqui
    mov [610h], 0 ; Endereco de memoria que ficara armazenado o valor da base 
    mov [612h], 0 ; Endereco de memoria que ficara armazenado o tamanho da string
    
    ; Pegar o valor do usuario.
    input bufferValue
    
    ; Obtem o tamanho da string digitada pelo usuario
    stringSizeLoop:
    mov AL, [SI+2]
    inc [612h]
    inc SI
    cmp AL, 0Dh
    jne stringSizeLoop
    dec [612h]
    
    ; Verificar se e um numero de fato.
    mov SI, bufferValue
    mov DL, [612h]
    
    verifyLoop:    
    mov AL, [SI+2]
    cmp AL, 30h
    jb invalidNumberMessage ; Caracter digitado menor do que 30h
    cmp AL, 39h
    ja invalidNumberMessage ; Caracter digitado maior do que 39h
    dec DL
    inc SI
    cmp DL, 0
    ja verifyLoop  
    
    ; Converte para um numero
    mov SI, bufferValue
    mov CX, 0
    
    convertLoop:
    mov AX, 0
    mov AL, [SI+2]
    sub AL, 30h
    cmp [612h], 1
    ja multiplyAL
    add CX, AX
    mov [610h], CX
    
    continue:
    pop DX
    pop CX
    pop BX
    pop AX
    breakline
    ret
    
    multiplyAL:
    add AX, CX
    mul BX
    mov CX, AX
    inc SI
    dec [612h]
    jmp convertLoop
    
    invalidNumberMessage:
    breakLine
    print bufferInvalidNumber
    mov [602h], 0
    jmp continue

; Buffers
bufferReqDestBase: db "Digite a base de destino (2 a 16): $"
bufferReqValue: db "Digite o numero em base decimal (0 a 65535): $"
bufferInvalidNumber: db "Numero digitado invalido!$"
bufferLfcr: db 13, 10, '$'
bufferBase: db 3, 0, 3 dup('$')
bufferValue: db 6, 0, 6 dup('$') 