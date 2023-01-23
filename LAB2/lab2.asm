STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
BARIS 	DB	42H, 41H, 52H, 49H, 53H, 20H, 42H, 41H, 4BH, 49H, 4DH, 13 ; B, A, R, I, S,  , B, A, K, I, M, \n
DATA    ENDS

CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
START:
        MOV AX, DATA
	MOV DS, AX
	
				; MOD YAZMACINA ERISIM
	MOV DX, 0302h		; mod yazmacinin adresi DX'e alinir
	MOV AL, 01001101B	; son iki bitinin 00'dan farkli olmasi gerekir
				; 00 olursa baud rate factor senkron haberlesme modu oluyor. Biz asenkron kullaniyoruz
				; sync1 ve sync2 bekliyor 00 senkron yaparsak. Diger degerler su an önemli degil.
	OUT DX, AL		; mod yazmacinin adresine (DX) 01001101 degeri (AL) yüklenir.
	
				; KONTROL YAZMACINA ERISIM
	MOV AL, 40H		; ikinci out islemi kontrol yazmacina gidilir (01000000) 1: internal reset
	OUT DX, AL		; 8251 resetlenir
	
				; MOD YAZMACINA ERISIM
	MOV AL, 01001101B	;asenkron haberlesme ve faktör degeri: (d1d0) 01: rxc (9600hz) ve txc (9600hz) degerleri bire bölünür
				; -> 9600 baud'luk haberlesme degerlerini elde etmis olduk. (virtual terminalin de baud degeri 9600, karsilikli örtüsür)
	OUT DX, AL		; (d7d6) 01: stop bit sayim (1) /// (d3d2) 11: 8 bit ile haberlesecegiz (ascii chars) /// (d5d4) partiy yok
	
				; KONTROL YAZMACINA ERISIM
	MOV AL, 00010101B	; daha önceden kalan herhangi bir hata biti varsa temizlenir (d4: 1)
				; receive enable ve transmit enable (d2:1, d0:1 ) -> veri gönderilir ve alinir
	OUT DX, AL		; kontrol yazmaci yüklenir
	

ENDLESS:			; program kapatilana kadar okuma ve yazma yapilir
				; kontrol ve status yazmaçlarinin oldugu adres -> 0302H
	MOV DX, 0302H		; WR -> kontrol yazmacina yazar /// RD -> status yazmacini okur
TEKRAR:				; burada bir sayi giriyoruz
AGAIN:				; girilen deger bir rakam degilse tekrar girilmesi beklenir
	IN AL, DX		; dx içerisindeki deger al ye alinir
	AND AL, 02H		; maskele, status yazmacinin en düsük anlamli 2. bitinde RxRDY ucu var. 1 ise tamamlanmistir
	JZ TEKRAR		; 1 olana kadar devam edilir
				; Geçerli bir input degeri beklenir
	MOV DX, 0300H		; input bu adreste
	IN AL, DX		; al ye girilen deger alinir
	SHR AL, 1		; stop biti için gerekli	
	CMP AL, 30H		; girilen ascii degeri 0 karakterinden küçük bir degerle saklanmissa
	JBE AGAIN		; tekrar girilmesi beklenir
	CMP AL, 39H		; girilen ascii degeri 9 karakterinden büyük bir degerle saklanmissa
	JA AGAIN		; tekrar girilmesi beklenir
	
	SUB AX, 030H		; girilen degerin ascii kodundan 0 karakteri çikarilir
	XOR AH, AH		; ah in degeri sifirlanir
	MOV CX, AX		; ismin kaç kere bastirilacagini saklamak üzere elde edilen deger cx e yazilir
	
	MOV DX, 0302H		; kontrol ve status yazmaçlarinin oldugu adres
	
OUTER:	PUSH CX			; Iç içe iki döngü oldugu için CX stack'e push'lanir
	MOV CX, 0CH		; Ismin bastirilmasi için CX'e 10 degeri atanir
INNER:				; Ismin bastirildigi döngü
TEKRAR2:MOV DX, 0302H		; Bastirma islemi için beklenir
	IN AL, DX
	AND AL, 01H		; maskele, status yazmacinin en düsük anlamli 1. bitinde TxRDY ucu var. 1 ise tamamlandi
	JZ TEKRAR2

	MOV BX, 0CH		; BX yazmaci ismin harflerine erismek için kullanilir. Ismim 10 harfli oldugu için BX e 10 degeri atanir
	SUB BX, CX		; Teker teker harfleri bastirmak için BX degeri ayarlanir.
	MOV DX, 0300H		; Out islemi için gerekli
	MOV AL, BARIS[BX]	; Ismin ilgili harfi yazdirilir
	OUT DX, AL		; Bastirma islemi yapilir
	LOOP INNER		; Isim bir kez yazdirilana kadar tüm gözler gezilir
	POP CX			; Stack'e attilan döngü sayisi geri alinir
	LOOP OUTER		; Istenilen rakam kadar döngü devam eder

        JMP ENDLESS
CODE    ENDS
        END START