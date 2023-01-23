;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Cum Mar 11 2016
; Processor: 8086
; Compiler:  MASM32
;
; Before starting simulation set Internal Memory Size 
; in the 8086 model properties to 0x10000
;====================================================================
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'  
MASTER_KEY DB 01101011B,01011011B ,00111011B,01101101B ; 9876   
KULLANICI_SIFRE DB 0,0,0,0

DATA ENDS
CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
	
START: 

        MOV AX, DATA
	MOV DS, AX 
	MOV AL, 10000001B; CW
	OUT 0AEH, AL 
OPEN: 
      MOV AL,11000001B 
      OUT 0A8H,AL	
TEKRAR_AL:
	XOR SI,SI
	MOV CX,4 
DONGU:
	CALL GIRDIAL
	IN AL,0ACH 
	MOV KULLANICI_SIFRE[SI],AL 
	INC SI  
	CALL BEKLE
	LOOP DONGU   
	CALL GIRDIAL 
	IN AL,0ACH 
	CMP AL,01100111B 
	JNE TEKRAR_AL
LOCKED:  
	MOV AL,11000111B 
	OUT 0A8H,AL 
	CALL BEKLE
	CALL GIRDIAL
DENEME: 
	 
TEKRAR_AL2: 
	 XOR DX,DX 
	 XOR BX,BX
	 XOR SI,SI
	 MOV CX,4 
DONGU2:
	CALL GIRDIAL
	IN AL,0ACH 
	CMP KULLANICI_SIFRE[SI],AL   
	JNE ATLA
	INC DX  
	
ATLA:	CMP MASTER_KEY[SI],AL 
	JNE ATLA2 
	INC BX
ATLA2:	INC SI   
	CALL BEKLE
	LOOP DONGU2   
	CMP BX,4 
	JE OPEN
	CMP DX,4 
	JE OPEN  
	JMP TEKRAR_AL2
BEKLE  PROC NEAR 
SONSUZ: 
      IN AL,0ACH 
      AND AL,00001111B 
      CMP AL,00001111B 
      JNE SONSUZ
      RET 
BEKLE ENDP 

GIRDIAL PROC FAR 
SONSUZ:
	 MOV AL,011B  
	 OUT 0AAH,AL 
	 IN AL,0ACH 
	 AND AL,00001111B 
	 CMP AL,00001111B 
	 JNE BASILDI
	 MOV AL,110B 
	 OUT 0AAH,AL 
	 IN AL,0ACH 
	 AND AL,00001111B 
	 CMP AL,00001111B
	 JNE BASILDI
	 MOV AL,101B
	 OUT 0AAH,AL 
	 IN AL,0ACH 
	 AND AL,00001111B 
	 CMP AL,00001111B
	 JNE BASILDI

	 JMP SONSUZ   
BASILDI:
	 RET
GIRDIAL ENDP	

ENDLESS:
	
	
	JMP ENDLESS
CODE    ENDS 
        END START