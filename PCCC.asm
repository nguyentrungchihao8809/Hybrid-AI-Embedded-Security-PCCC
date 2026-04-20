$INCLUDE (REG51.INC)

; --- DINH NGHIA CHAN LCD ---
RS          BIT P2.0
EN          BIT P2.1
LCD_DATA    EQU P0

; --- DINH NGHIA CHAN HE THONG ---
LED         BIT P3.4
BUZZER      BIT P3.5
BUTTON      BIT P3.6  

ADC_IN      EQU P1
CS          BIT P3.0
RD_         BIT P3.1
WR_         BIT P3.2
INTR        BIT P3.3

; --- BIEN HE THONG ---
TIMEOUT     EQU 30H
TEMP_VAL    EQU 31H
LAST_CHAR   EQU 32H
SYSTEM_ON   BIT 00H     ; Bit trang thai: 1 là ON, 0 là OFF

ORG 0000H
    LJMP MAIN

ORG 000BH               ; Ngat Timer 0
    LJMP T0_ISR

ORG 0023H               ; Ngat UART
    LJMP UART_ISR

ORG 0100H
MAIN:
    MOV SP, #60H
    ; --- Khoi tao UART ---
    MOV TMOD, #21H      ; Timer 1: Mode 2, Timer 0: Mode 1
    MOV TH1, #0FDH      ; 9600 Baud
    MOV SCON, #50H
    SETB TR1

    ; --- Khoi tao Timer 0 ---
    MOV TH0, #3CH       ; 50ms
    MOV TL0, #0B0H
    SETB ET0
    SETB TR0

    ; --- Cho phep ngat ---
    SETB ES
    SETB EA

    ; --- Trang thai ban dau ---
    SETB SYSTEM_ON      ; Mac dinh he thong bat khi khoi dong
    MOV TIMEOUT, #0
    MOV LAST_CHAR, #0
    MOV TEMP_VAL, #0
    CLR LED
    CLR BUZZER
    SETB BUTTON         ; Dat chan P3.6 lam Input

    ; --- Khoi tao LCD ---
    ACALL LCD_INIT
    ACALL LCD_GREETING  

LOOP_MAIN:
    ACALL CHECK_BUTTON      ; Kiem tra nut nhan de bat/tat he thong
    ACALL READ_ADC
    ACALL PROCESS_LOGIC
    ACALL DISPLAY_TEMP_LCD
    SJMP LOOP_MAIN

; --- KIEM TRA NUT NHAN (P3.6) ---
CHECK_BUTTON:
    JB BUTTON, EXIT_BTN     ; Neu BUTTON = 1 (khong nhan) thi thoat
    ACALL DELAY_LCD         ; Chong nhieu (tan dung ham delay co san)
    JB BUTTON, EXIT_BTN     ; Kiem tra lai chac chan dang nhan
    
    CPL SYSTEM_ON           ; Dao trang thai he thong (Bat <-> Tat)
    
WAIT_RELEASE:               ; Cho nguoi dung nha nut ra
    JNB BUTTON, WAIT_RELEASE
EXIT_BTN:
    RET

; --- DOC ADC 0804 ---
READ_ADC:
    CLR CS          
    CLR WR_         
    NOP
    SETB WR_        
WAIT_ADC:
    JB INTR, WAIT_ADC 
    CLR RD_         
    NOP
    MOV A, ADC_IN   
    MOV TEMP_VAL, A
    SETB RD_
    SETB CS         
    RET

; --- LOGIC XU LY CHINH ---
PROCESS_LOGIC:
    ; --- BUOC QUAN TRONG: Kiem tra he thong co dang bat khong ---
    JNB SYSTEM_ON, SYS_OFF  ; Neu SYSTEM_ON = 0 thi nhay den tat het

    MOV A, LAST_CHAR
    
    ; Kiem tra neu la 'A'
    CJNE A, #'A', CHECK_F
    SETB LED
    CLR BUZZER
    RET

CHECK_F:
    ; Kiem tra neu la 'F'
    CJNE A, #'F', EXIT_PL
    
    ; Logic so sanh nhiet do (TEMP_VAL >= 50)
    MOV A, TEMP_VAL
    CLR C
    SUBB A, #50
    JC LOW_TEMP
    
    SETB LED
    SETB BUZZER
    RET

LOW_TEMP:
    CLR LED
    CLR BUZZER
    RET

SYS_OFF:
    CLR LED                 ; Cuong buc tat bao dong khi he thong bi tat
    CLR BUZZER
EXIT_PL:
    RET

; --- DIEU KHIEN LCD ---
LCD_INIT:
    MOV A, #38H
    ACALL SEND_CMD
    MOV A, #0CH
    ACALL SEND_CMD
    MOV A, #01H
    ACALL SEND_CMD
    RET

LCD_GREETING:
    MOV A, #80H
    ACALL SEND_CMD
    MOV DPTR, #STR_TEMP
    ACALL LCD_PRINT_STR
    RET

DISPLAY_TEMP_LCD:
    MOV A, #86H
    ACALL SEND_CMD
    MOV A, TEMP_VAL
    MOV B, #10
    DIV AB
    
    ADD A, #30H
    ACALL SEND_CHAR
    MOV A, B
    ADD A, #30H
    ACALL SEND_CHAR
    
    MOV A, #0DFH
    ACALL SEND_CHAR
    MOV A, #'C'
    ACALL SEND_CHAR
    
    ; --- Hien thi trang thai ON/OFF len LCD (Tuy chon) ---
    MOV A, #8CH             ; Di chuyen den cuoi dong 1
    ACALL SEND_CMD
    JB SYSTEM_ON, DISP_ON
    MOV A, #' '
    ACALL SEND_CHAR
    MOV A, #'X'             ; Hien chu X neu dang OFF
    ACALL SEND_CHAR
    RET
DISP_ON:
    MOV A, #' '
    ACALL SEND_CHAR
    MOV A, #'V'             ; Hien chu V neu dang ON
    ACALL SEND_CHAR
    RET

SEND_CMD:
    MOV LCD_DATA, A
    CLR RS
    SETB EN
    ACALL DELAY_LCD
    CLR EN
    RET

SEND_CHAR:
    MOV LCD_DATA, A
    SETB RS
    SETB EN
    ACALL DELAY_LCD
    CLR EN
    RET

LCD_PRINT_STR:
    CLR A
    MOVC A, @A+DPTR
    JZ END_STR
    ACALL SEND_CHAR
    INC DPTR
    SJMP LCD_PRINT_STR
END_STR:
    RET

DELAY_LCD:
    MOV R7, #10
DL1: MOV R6, #50
    DJNZ R6, $
    DJNZ R7, DL1
    RET

; --- NGAT UART ---
UART_ISR:
    PUSH ACC
    JNB RI, EXIT_U
    MOV A, SBUF
    MOV LAST_CHAR, A
    MOV TIMEOUT, #40
    CLR RI
EXIT_U: 
    POP ACC
    RETI

; --- NGAT TIMER 0 ---
T0_ISR:
    PUSH ACC
    MOV TH0, #3CH
    MOV TL0, #0B0H
    
    MOV A, TIMEOUT
    JZ EXIT_T
    DEC TIMEOUT
    
    MOV A, TIMEOUT
    JNZ EXIT_T
    
    MOV LAST_CHAR, #0
    ; Chi xoa LED/BUZZER neu he thong dang ON (de tranh xung dot lenh)
    JNB SYSTEM_ON, EXIT_T
    CLR LED
    CLR BUZZER
EXIT_T: 
    POP ACC
    RETI

STR_TEMP: DB "Temp: ", 0
END