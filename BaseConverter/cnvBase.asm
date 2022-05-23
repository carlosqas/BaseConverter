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
    
    call convertNumber
    print bufferResultConversion
    print bufferResult
    breakline
    breakline
    
    jmp requestBase
    
    ret

; Funcao que recebe e trata o valor digitado da base
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
    jb BaseInvalidNumberMessage ; Caracter digitado menor do que 30h
    cmp AL, 39h
    ja BaseInvalidNumberMessage ; Caracter digitado maior do que 39h
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
    jb BaseInvalidBaseMessage
    cmp AL, 10h
    ja BaseInvalidBaseMessage 
    
    ; Finaliza a funcao e retorna ao programa principal
    EndBaseFunction:
    pop DX
    pop CX
    pop BX
    pop AX
    breakline
    ret
    
    ; Loop auxiliar para a conversao para valor numerico
    BaseMultiplyAL:
    add AX, CX
    mul BL
    mov CX, AX
    inc SI
    dec [601h]
    jmp BaseConvertLoop
    
    ; Informa ao usuario que digite um numero valido, sem letras
    BaseInvalidNumberMessage:
    breakLine
    print bufferInvalidNumber
    mov [602h], 0
    jmp EndBaseFunction
    
    ; Informa ao usuario que digite um numero no intervalo estabelecido
    BaseInvalidBaseMessage:
    breakLine
    print bufferInvalidBase
    mov [602h], 0
    jmp EndBaseFunction 
    

; Funcao que recebe e trata o valor a ser convertido
receiveNumber:
    push AX
    push BX
    push CX
    push DX
    
    ; Inicializacao da memoria para a regra de negocio
    mov SI, bufferValue
    mov BX, 0Ah
    mov [602h], 1 ; Caso o funcao detecte erro, ira retornar o booleano aqui
    mov [610h], 0 ; Endereco de memoria que ficara armazenado o valor a ser convertido 
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
    jb ValueInvalidNumberMessage ; Caracter digitado menor do que 30h
    cmp AL, 39h
    ja ValueInvalidNumberMessage ; Caracter digitado maior do que 39h
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
    jc ValueInvalidValueMessage 
    mov [610h], CX
    
    ; Finaliza a funcao e retorna ao programa principal
    EndReceiveValueFunction:
    pop DX
    pop CX
    pop BX
    pop AX
    breakline
    ret
    
    ; Loop auxiliar para a conversao para valor numerico
    multiplyAL:
    add AX, CX
    jc ValueInvalidValueMessage
    mul BX
    jc ValueInvalidValueMessage
    mov CX, AX
    inc SI
    dec [612h]
    jmp convertLoop
    
    ; Informa ao usuario que digite um numero valido, sem letras
    ValueInvalidNumberMessage:
    breakLine
    print bufferInvalidNumber
    mov [602h], 0
    jmp EndReceiveValueFunction
    
    ; Informa ao usuario que digite um numero no intervalo estabelecido
    ValueInvalidValueMessage:
    breakLine
    print bufferInvalidValue
    mov [602h], 0
    jmp EndReceiveValueFunction
    
    

; Funcao que converte o numero de uma base para outra
convertNumber:
    push AX
    push BX
    push CX
    push DX
    
    mov AX, [610h] ; AX e o numero digitado pelo usuario.
    mov BX, [600h] ; BX e a base de destino
    mov SI, 620h ; Posicao de memoria onde sera armazenado o numero convertido.
    mov CX, 0 ; Contador para indicar qual a ultima posicao de memoria do numero convertido.
    
    ; Divisoes sucessivas para converter o numero
    NumberConvertLoop:    
    div BX
    cmp DL, 0Ah
    jb addNumberLoop
    jae addLetterLoop
    resumeConvertLoop:
    mov [SI], DL
    inc CL
    inc SI
    mov DX, 0
    cmp AL, BL
    jae NumberConvertLoop
    
    cmp AL, 0Ah
    jb addNumber
    jae addLetter
    endConvertLoop:
    mov [SI], AL
    
    ; Desinvertendo o numero convertido para o buffer de resultado
    mov SI, bufferResult
    mov BX, CX
    add BX, 620h
    mov AL, [BX]
    
    InvertLoop:
    mov [SI], AL
    dec BX
    mov AL, [BX]
    inc SI
    cmp BX, 620h
    jae InvertLoop 
    mov [SI], '$'
    
    pop DX
    pop CX
    pop BX
    pop AX
    
    ret
    
    addNumberLoop:
        add DL, 30h
        jmp resumeConvertLoop 
        
    addNumber:
        add AL, 30h
        jmp endConvertLoop
    
    addLetterLoop:
        add DL, 37h
        jmp resumeConvertLoop
        
    addLetter:
        add AL, 37h
        jmp endConvertLoop
    
    
    
; Buffers
bufferReqDestBase: db "Digite a base de destino (2 a 16): $"
bufferReqValue: db "Digite o numero em base decimal (0 a 65535): $"
bufferInvalidNumber: db "Numero digitado invalido!$"
bufferInvalidBase: db "Digite uma base entre 2 e 16!$"
bufferInvalidValue: db "Digite um numero entre 0 e 65535!$"
bufferResultConversion: db "O numero convertido e: $"
bufferLfcr: db 13, 10, '$'
bufferBase: db 3, 0, 3 dup('$')
bufferValue: db 6, 0, 6 dup('$')
bufferResult: db 17, 0, 17 dup('0')