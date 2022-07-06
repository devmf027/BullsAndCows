; MULTI-SEGMENT EXECUTABLE FILE TEMPLATE.

DATA SEGMENT   
    N EQU 4  
    COUNTER DB 1
    SECRET_NUM DB N DUP(?)
    GUESSED_NUM DB N+1,N+2 DUP(?)
    COUNTER_STR DB 0,0,'$'  
    BULLS DB 0
    HITS DB 0  
    WELCOME_MSG DB 10,13,"WELCOME TO HITS & BULLS GAME!",10,"$"
    PRESS_START DB 10, 13, "PRESS ENTER TO START OR ANY OTHER KEY TO EXIT $"
    GEN_NUM_MSG DB 10,10,13,"GENERATING RANDOM NUMBER...",10,13,"$" 
    FORMAT_MSG DB 10,13,"ENTER A NUMBER IN THE FORMAT #ABCD ; A!=0 && A!=B!=C!=D",10,13,"$"  
    ERR_MSG DB "WRONG INPUT ! PLEASE TRY AGAIN",10,13,"$"
    WIN_MSG DB 10,13,"CONGRATULATIONS YOU HAVE WON, YOUR TRY COUNT IS: $"
    LOOSE_MSG DB 10,13,"GAME OVER ! YOU PASSED 12 TRIES",10,13,"$" 
    PLAY_AGAIN_MSG DB 10,10,13,"WOULD YOU LIKE TO PLAY AGAIN? PRESS 'Y' TO PLAY OR ANY KEY TO EXIT.$"
    THE_NUM_MSG DB 10,13,"THE NUMBER WAS: $" 
    YOU_HAVE_MSG DB "YOU HAVE: $" 
    BULL_MSG DB " BULL(S) & $"
    HIT_MSG DB " HIT(S)$"
    TRIES_LEFT_MSG DB " TRIES LEFT: $"
    N_LINE DB 10,13,"$"
    EXIT_MSG DB 10,13,"BYE..  :)$"
                 
                  
ENDS   

STACK SEGMENT
    DW   128  DUP(0)
ENDS

CODE SEGMENT
START:


    MOV  AX, DATA
    MOV  DS, AX
    MOV  ES, AX   
    
    PROGRAM_START:          ; BEGINNING OF THE PROGRAM
    MOV COUNTER, 1          ; STARTS THE COUNTER TO 1 
    CALL CLEAR_GUESSED      ; CLEARS LAST GAME GUESSED_NUM
    CALL WELCOME            ; DISPLAYS WELCOME MESSAGE  
    CALL PRESS_ENTER        ; DISPLAYS PRESS ENTER MESSAGE AND USER INPUT
    CALL GEN_WAIT           ; DISPLAYS GENERATING NUMBER MESSAGE
    
RAND_REPEAT:                ; BUILDS RANDOM NUMBER AGAIN
                             
    MOV CX, N               ; FOUR DIGIT COUNTER CX
    MOV DI, 0               ; CLEAR DI
    
MAIN:
    
    PUSH CX                 ; SAVE ACTUAL COUNTER CX
    CALL RAND_GEN           ; GO TO NUMBER GENERATOR
    POP CX                  ; GET COUNTER
    LOOP MAIN               ; NEXT REPETITION  
    JMP CHECK               ; CHECK NUMBER VALIDITY 
    VALIDITY_MSG:           ; DISPLAY VALID NUMBER FORMAT
        JMP FORMAT          ; GO TO DISPLAY INTERRUPT
    GET_INPUT:              ; GET USER NUMBER 
        CALL CLEAR_GUESSED  ; SET EVERY GUESSED_NUM DIGIT TO NULL 
        JMP USER_INPUT      ; GO TO STRING INPUT INTERRUPT  
        MOV DI, 2           ; PREPARE INDEX DI TO CHECK USER NUMBER
        JMP CHECK           ; CHECK NUMBER VALIDITY
    GUESSED_OK:
        CALL BULLS_HITS     ; CALLS FUNCTION THAT CHECKS BULLS AND HITS
        CMP BULLS, N        ; CHECKS WINNING CONDITION
        JE WIN              ; TRUE: GO TO WIN MESSAGE
        CMP COUNTER, 12     ; CHECKS LOOSE CONDITION
        JE LOOSE            ; TRUE: GO TO LOOSE MESSAGE
        CALL BULLS_HITS_OUT ; DISPLAYS NUMBER OF BULLS, HITS AND TRIES LEFT
        INC COUNTER         ; ADD 1 TO THE COUNTES
        JMP VALIDITY_MSG    ; GOES TO FORMAT MESSAGE AND GETS INPUT AGAIN 
        
            
;/////RANDOM DIGIT GENERATOR/////            
RAND_GEN:   
    
    MOV AH, 0               ; INTERRUPTS TO GET SYSTEM TIME        
    INT 1AH                 ; CX:DX NOW HOLD NUMBER OF CLOCK TICKS SINCE MIDNIGHT      
    MOV  AX, DX             ; PREPARE DIVIDEND REGISTER AX
    MOV  CX, 10             ; PREPARE DIVISOR REGISTER CX
    XOR  DX, DX             ; CLEAR RESULT REGISTER DX
    DIV  CX                 ; HERE DX CONTAINS THE REMAINDER OF THE DIVISION - FROM 0 TO 9    
    ADD  DL, '0'            ; TO ASCII FROM '0' TO '9' 
    MOV SECRET_NUM[DI], DL  ; ASSIGN DIGIT TO SECRET_NUM[DI] 
    INC DI                  ; INDEX DI+1
    RET   
   
;/////CHECK NUMBER VALIDITY/////    
CHECK:
 
    CMP SECRET_NUM, '0'         ; IF FIRST SECRET NUMBER ELEMENT EQUAL '0' (ASCII VALUE)
    JE RAND_REPEAT              ; TRUE: BUILD RANDOM NUMBER AGAIN
    CMP GUESSED_NUM[2], '0'     ; ELSE IF: CHECK FIRST GUESSED NUMBER ELEMENT EQUAL '0' (ASCII VALUE)
    JE ERR                      ; TRUE: GET USER INPUT AGAIN
    MOV CX, 3                   ; I=3
                                       
;   FOR(I=3; I > 0; I--) 
    FOR_I: 
                                   
        PUSH CX                 ; SAVE I VALUE   
        MOV SI, CX              ; USE I AS INDEX SI (STARTS FROM LAST ARRAY ELEMENT)
        MOV BX, CX              ; USE BX AS INDEX
        INC CX                  ; USE CX AS COUNTER
        DEC BX                  ; BX = I-1 (ARRAY ELEMENT - 1)    
        
;       FOR(J=I-1; J>0; J--)     
        FOR_J:
        
            CMP GUESSED_NUM[2], 0   ; IF SECRET_NUM IS EMPTY
            JNE GUESSED_CHECK       ; FALSE: CHECK USER INPUT VALIDITY
            MOV AL, SECRET_NUM[SI]  ; SAVE SECRET_NUM[I] VALUE IN AL
            MOV AH, SECRET_NUM[BX]  ; IF SECRET_NUM[I] == SECRET_NUM[J]
            CMP AL,AH 
            JE RAND_REPEAT          ; TRUE: BUILD RANDOM NUMBER AGAIN
            GUESSED_DIGIT_OK:       ; THIS DIGIT IS NOT REPEATED
            DEC BX                  ; BX--                      
            LOOP FOR_J              ; FOR_J END
        POP CX                      ; GET FOR_I COUNTER INTO CX
        LOOP FOR_I                  ; FOR_I END
        MOV SI, 0                   ; CLEAR SI FOR FURTHER USE

    CMP GUESSED_NUM[2], 0           ; IF USER INPUT == NULL
    JNE GUESSED_OK                  ; FALSE: INPUT NUMBER IS VALID CONTINUE TO MAIN
    JMP VALIDITY_MSG                ; ELSE: DISPLAY ERROR AND GET INPUT NUMBER
        
    GUESSED_CHECK:
        INC BX                      ; BX++ IN OREDER TO REACH THE LAST ELEMENT
        CMP GUESSED_NUM[BX]+2, '0'  ; CHECKS IF GUESSED DIGIT ASCII VALUE IS BELOW '0' ASCII VALUE
        JB ERR                      ; GOES TO ERROR MESSAGE AND ASKS FOR INPUT AGAIN
        CMP GUESSED_NUM[BX]+2, '9'  ; CHECKS IF GUESSED DIGIT ASCII VALUE IS OVER '9' ASCII VALUE
        JA ERR                      ; GOES TO ERROR MESSAGE AND ASKS FOR INPUT AGAIN   
        DEC BX                      ; BX-- RESET TO THE ORIGINAL VALUE
        MOV AL, GUESSED_NUM[SI+2]   ; SAVES GUESSED_NUM[I] ELEMENT VALUE IN AL
        CMP AL, GUESSED_NUM[BX+2]   ; IF GUESSED_NUM[I] == GUESSED_NUM[I-1]
        JE ERR                      ; TRUE: DISPLAY ERROR AND GET INPUT NUMBER
        JMP GUESSED_DIGIT_OK        ; ELSE: THIS DIGIT IS NOT REPEATED. CONTINUE TO FOR_J

;/////BULLS & HITS GAME MOTOR/////
BULLS_HITS:
    MOV CX, N                       ; K = 4
    MOV BULLS, 0                    ; CLEARS VARIABLE BULLS
    MOV HITS, 0                     ; CLEARS VARIABLE HITS
    FOR_K:
        PUSH CX                     ; SAVES K VALUE
        DEC CX                      ; TO USE CX AS INDEX
        MOV SI, CX                  ; USES K AS INDEX SI (STARTS FROM LAST ARRAY ELEMENT) 
        MOV DI, 3                   ; USES DI AS INDEX 
        MOV CX, 4                   ; L = 4
        FOR_L:
            CMP SI, DI              ; IF IS THE SAME POSITION (INDEX)
            JE CHECK_BULL           ; TRUE: CHECKS IF IS BULL
            JNE CHECK_HIT           ; FALSE: CHECKS IF IS HIT
            CHECK_END:
            DEC DI                  ; L--
            LOOP FOR_L   
        NEXT_K:                     
        POP CX                      ; RETRIEVES K VALUE
        LOOP FOR_K
        MOV SI, 0                   ; CLEARS SI
        MOV DI, 0                   ; CLEARS DI
        RET            
    
    CHECK_BULL:
        MOV AH, SECRET_NUM[DI]      ; MOVES SECRET_NUM[L] VALUE TO AH
        MOV AL, GUESSED_NUM[SI]+2   ; MOVES SECRET NUM[K] VALUE TO AL
        CMP AH, AL                  ; IF NOT EQUAL
        JNE IS_NOT_BULL             ; TRUE: SKIPS BULLS++
        INC BULLS                   ; BULLS++
        JMP NEXT_K                  ; MOVES TO THE NEXT INDEX K
        IS_NOT_BULL:
            JMP CHECK_END 
            
    CHECK_HIT:
        MOV AH, GUESSED_NUM[DI]+2   ; MOVES SECRET_NUM[L] VALUE TO AH
        MOV AL, SECRET_NUM[SI]      ; MOVES SECRET NUM[K] VALUE TO AL
        CMP AH, AL                  ; IF NOT EQUAL
        JNE IS_NOT_HIT              ; TRUE: SKIPS HITS++
        INC HITS                    ; HITS++
        JMP NEXT_K                  ; MOVES TO THE NEXT K INDEX
        IS_NOT_HIT:
            JMP CHECK_END 
            
;/////COUNTDOWN COUNTER/////
REV_COUNTER:
MOV AX, 12                          ; MOVE 12 TO AX
SUB AL, COUNTER                     ; SUBTRACTS TO OBTAIN THE
JMP REVERSED                        ; SKIPS PART OF THE NORMAL COUNTER CODE

;/////CONVERT COUNTER VALUE TO ASCII/////                     
COUNTER_TO_STRING: 
    MOV AH, 0                       ; CLEARS AH
    MOV AL, COUNTER                 ; SAVES COUNTER'S VALUE IN AL
    REVERSED:
    CMP AL, 9                       ; CHECKS IF IT IS ONE DIGIT NUMBER
    JA TWO_DIGITS                   ; FALSE: GOES TO THE TWO DIGIT PART OF THE CODE
    MOV COUNTER_STR, '0'            ; TRUE: MOVE '0' TO THE TENTHS DIGIT OF COUNTER STR
    ADD AL, '0'                     ; ADD '0' ASCII VALUE TO AL
    MOV COUNTER_STR[1], AL          ; MOVES AL VALUE TO THE ONES DIGIT OF COUNTER_STR
    
    RET    
    
    TWO_DIGITS:
        MOV CX, 10                  ; PREPARE DIVISOR REGISTER CX              
        XOR DX, DX  ;               ; CLEAR RESULT REGISTER DX
        DIV CX                      ; DIVIDE AX/CX
        ADD DL, '0'                 ; ADD '0' ASCII VALUE TO MODULO RESULT
        ADD AL, '0'                 ; ADD '0' ASCII VALUE TO DIVISION RESULT
        MOV COUNTER_STR, AL         ; MOVES THE RESULT OF THE DIVISION TO COUNTER_STR TENTHS DIGIT
        MOV COUNTER_STR[1], DL      ; MOVES THE REULT OF THE MODULO TO COUNTER_STR ONES DIGIT
        
        RET 

;/////PLAY AGAIN FUNCTION/////        
PLAY_AGAIN: 
    CALL PLAY_AGAIN_OUT             ; DISPLAY PLAY AGAIN MESSAGE
    MOV AH, 01H                     ; CHAR INPUT INTERRUPT
    INT 21H 
    CALL NEW_LINE
    CMP AL, 'Y'                     ; IF INPUT == 'Y' OR 'y'
    JE PROGRAM_START
    CMP AL, 'y'                     ; TRUE: START GAME AGAIN
    JE PROGRAM_START                        ; FALSE: EXIT
    JMP EXIT_OUT

;/////CLEAR GUESSED NUMBER/////
CLEAR_GUESSED:
        MOV CX, N+1                 ; USE CX AS LOOP COUNTER. CX = 5
        MOV BX, N                   ; USE BX AS INDEX. BX = 4 
        RESET_GUESSED:  
            MOV GUESSED_NUM[BX]+2, 0; SET EVERY DIGIT TO NULL BY INDEX
            DEC BX                  ; BX--
            LOOP RESET_GUESSED      ; CX--. NEXT ITERATION
            
        RET  
       
;/////GET USER INPUT INTERRUPT/////
USER_INPUT:
     LEA DX, GUESSED_NUM            ;PUTS USER NUMBER INTO GUESSED_NUM
     MOV AH, 0AH
     INT 21H
     CALL NEW_LINE
     JMP CHECK        

;/////DISPLAY MESSAGE/////
WELCOME:
    MOV AH,09
    LEA DX, WELCOME_MSG
    INT 21H
    RET

PRESS_ENTER:
    MOV AH,09
    LEA DX, PRESS_START
    INT 21H
    MOV AH, 01H                     
    INT 21H
    CMP AL, 13
    JNE EXIT_OUT
    RET   

GEN_WAIT:                
    MOV AH, 09H
    LEA DX, GEN_NUM_MSG 
    INT 21H
    RET

FORMAT:
    LEA DX, FORMAT_MSG 
    MOV AH, 09H 
    INT 21H
    JMP GET_INPUT

ERR:
    LEA DX, ERR_MSG 
    MOV AH, 09H 
    INT 21H
    JMP FORMAT
    
WIN:
    CALL COUNTER_TO_STRING
    LEA DX, WIN_MSG 
    MOV AH, 09H 
    INT 21H
    LEA DX, COUNTER_STR 
    MOV AH, 09H 
    INT 21H
    JMP PLAY_AGAIN

LOOSE:
    LEA DX, LOOSE_MSG 
    MOV AH, 09H 
    INT 21H 
    LEA DX, THE_NUM_MSG 
    MOV AH, 09H 
    INT 21H
    LEA DX, SECRET_NUM
    MOV SECRET_NUM[N], '$'
    MOV AH, 09H 
    INT 21H
    JMP PLAY_AGAIN    

BULLS_HITS_OUT:
    MOV AH, 09H
    LEA DX, YOU_HAVE_MSG   
    INT 21H 
    
    MOV AH, 2
    MOV DL, BULLS
    ADD DL, '0'
    INT 21H
     
    MOV AH, 09H
    LEA DX, BULL_MSG  
    INT 21H
     
    MOV AH, 2
    MOV DL, HITS
    ADD DL, '0'
    INT 21H
       
    MOV AH, 09H 
    LEA DX, HIT_MSG 
    INT 21H
    
    CALL COUNTER_TO_STRING
    LEA DX, TRIES_LEFT_MSG 
    MOV AH, 09H
    INT 21H
      
    CALL REV_COUNTER
    MOV AH, 09H
    LEA DX, COUNTER_STR
    INT 21H 
    
    CALL NEW_LINE
    
    RET      

PLAY_AGAIN_OUT:
    MOV AH, 09H 
    LEA DX, PLAY_AGAIN_MSG                
    INT 21H 
    
    RET 
                
NEW_LINE:    
    PUSH AX
    MOV AH, 09H 
    LEA DX, N_LINE                
    INT 21H 
    POP AX 
    
    RET    

EXIT_OUT:
    MOV AH, 09H 
    LEA DX, EXIT_MSG                
    INT 21H 
    
EXIT:
    
ENDS

END START ; SET ENTRY POINT AND STOP THE ASSEMBLER.