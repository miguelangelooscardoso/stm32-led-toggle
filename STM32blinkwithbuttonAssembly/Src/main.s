.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

@ Definições de registradores
.equ RCC_AHB1ENR,     0x40023830 @ Clock enable register
.equ RCC_APB2ENR,     0x40023844 @ APB2 peripheral clock enable register
.equ GPIOA_MODER,     0x40020000 @ GPIOA mode register
.equ GPIOA_ODR,       0x40020014 @ GPIOA output data register
.equ GPIOC_MODER,     0x40020800 @ GPIOC mode register
.equ GPIOC_IDR,       0x40020810 @ GPIOC input data register

@ Variáveis para debounce
.section .data
debounce_count: .word 0
last_state:     .word 0
DEBOUNCE_THRESHOLD: .word 50 @ Ajustável conforme necessário

.section .text
.global main

main:
    @ Habilita clock para GPIOA, GPIOC
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 0)  @ GPIOA
    ORR R1, R1, #(1 << 2)  @ GPIOC
    STR R1, [R0]

    LDR R0, =RCC_APB2ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 14) @ SYSCFG
    STR R1, [R0]

    @ Configura PA0, PA1, PA4, PA5, PA6, PA7 como saída (LEDs)
    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    BIC R1, R1, #0x0000FF00  @ Limpa os bits que não queremos mexer
    ORR R1, R1, #0x00005500  @ Configura PA0, PA1, PA4, PA5, PA6, PA7 como saída
    STR R1, [R0]

    @ Inicializa LEDs desligados
    LDR R0, =GPIOA_ODR
    MOV R1, #0
    STR R1, [R0]

    @ Configura PC13 como entrada (botão)
    LDR R0, =GPIOC_MODER
    LDR R1, [R0]
    BIC R1, R1, #(3 << (13 * 2))  @ Limpa bits de PC13
    STR R1, [R0]

    @ Loop principal
loop:
    @ Debounce
    LDR R4, =debounce_count
    LDR R5, [R4]

    @ Lê estado atual do botão
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    TST R1, #(1 << 13)  @ Verifica se o botão está pressionado
    BNE reset_debounce  @ Se não pressionado, resetar o debounce

    @ Incrementa contador de debounce
    ADD R5, R5, #1
    STR R5, [R4]

    @ Verifica threshold de debounce
    LDR R0, =DEBOUNCE_THRESHOLD
    LDR R0, [R0]
    CMP R5, R0
    BLT continue_loop

    @ Toggle LEDs
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    EOR R1, R1, #0xF3  @ Alterna os LEDs
    STR R1, [R0]

    @ Reseta contador
reset_debounce:
    MOV R5, #0
    STR R5, [R4]

continue_loop:
    B loop
.end
