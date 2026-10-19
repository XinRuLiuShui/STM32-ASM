.syntax unified
.cpu cortex-m3
.thumb

.global main

.section .text
.type main, %function

main:

    @ 1. 开启 GPIOA 和 USART1 时钟
    ldr r0, =0x40021018
    ldr r1, [r0]
    ldr r2, =0x00004004
    orr r1, r1, r2
    str r1, [r0]

    @ 2. 配置 PA9 为复用推挽输出，50MHz
    @ PA9 对应 GPIOA_CRH 的 bit7:4
    ldr r0, =0x40010804
    ldr r1, [r0]
    bic r1, r1, #0xF0
    orr r1, r1, #0xB0
    str r1, [r0]

    @ 3. 配置 USART1 波特率为 9600
    @ 假设 PCLK2 = 8MHz，BRR = 0x0341
    ldr r0, =0x40013808
    ldr r1, =0x0341
    str r1, [r0]

    @ 4. 使能 USART1 和发送功能
    @ CR1: UE = bit13，TE = bit3
    ldr r0, =0x4001380C
    ldr r1, =0x2008
    str r1, [r0]

send_loop:
    @ 5. 等待 TXE = 1，表示发送数据寄存器为空
wait_txe:
    ldr r0, =0x40013800
    ldr r1, [r0]
    tst r1, #0x80
    beq wait_txe

    @ 6. 写入字符 A（ASCII = 0x41）
    ldr r0, =0x40013804
    mov r1, #0x41
    str r1, [r0]

    @ 7. 持续发送
    b send_loop

.size main, . - main

