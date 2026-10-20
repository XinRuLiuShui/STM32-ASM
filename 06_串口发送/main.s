.syntax unified
.cpu cortex-m3
.thumb

.global main
.global TIM2_IRQHandler

.section .text
.type main, %function

main:

    @ 开启 GPIOA、GPIOC 和 USART1 时钟
    ldr r0, =0x40021018
    ldr r1, [r0]
    ldr r2, =0x00004014
    orr r1, r1, r2
    str r1, [r0]

    @ 开启 TIM2 时钟
    ldr r0, =0x4002101C
    ldr r1, [r0]
    orr r1, r1, #1
    str r1, [r0]

    @ 配置 PC13 为推挽输出
    ldr r0, =0x40011004
    ldr r1, =0x00100000
    str r1, [r0]

    @ 配置 PA9 为复用推挽输出，50MHz
    @ PA9 对应 GPIOA_CRH 的 bit7:4
    ldr r0, =0x40010804
    ldr r1, [r0]
    bic r1, r1, #0xF0
    orr r1, r1, #0xB0
    str r1, [r0]

    @ 配置 USART1 波特率为 9600
    @ 假设 PCLK2 = 8MHz，BRR = 0x0341
    ldr r0, =0x40013808
    ldr r1, =0x0341
    str r1, [r0]

    @ 使能 USART1 和发送功能
    @ CR1: UE = bit13，TE = bit3
    ldr r0, =0x4001380C
    ldr r1, =0x2008
    str r1, [r0]

    @ 初始化发送标志
    ldr r0, =send_flag
    mov r1, #0
    str r1, [r0]

    @ 设置 TIM2 PSC=7999
    ldr r0, =0x40000028
    ldr r1, =7999
    str r1, [r0]

    @ 设置 TIM2 ARR=999
    ldr r0, =0x4000002C
    ldr r1, =999
    str r1, [r0]

    @ 清零 CNT
    ldr r0, =0x40000024
    mov r1, #0
    str r1, [r0]

    @ 清除更新标志
    ldr r0, =0x40000010
    mov r1, #0
    str r1, [r0]

    @ 使能 TIM2 更新中断
    ldr r0, =0x4000000C
    mov r1, #1
    str r1, [r0]

    @ 在 NVIC 中使能 TIM2 IRQ28
    ldr r0, =0xE000E100
    ldr r1, =(1 << 28)
    str r1, [r0]

    @ 启动 TIM2
    ldr r0, =0x40000000
    mov r1, #1
    str r1, [r0]

main_loop:
    @ 检查发送标志
    ldr r0, =send_flag
    ldr r1, [r0]
    cmp r1, #0
    beq main_loop

    @ 清除标志
    mov r1, #0
    str r1, [r0]

    @ 发送字符 A
    bl usart_send_a

    @ 继续等待下一次中断
    b main_loop

@ 发送 A、CR、LF
.type usart_send_a, %function

usart_send_a:
    @ 发送 A
    ldr r0, =0x40013800
wait_a:
    ldr r1, [r0]
    tst r1, #0x80
    beq wait_a

    ldr r0, =0x40013804
    mov r1, #0x41
    str r1, [r0]

    @ 发送 CR
    ldr r0, =0x40013800
wait_cr:
    ldr r1, [r0]
    tst r1, #0x80
    beq wait_cr

    ldr r0, =0x40013804
    mov r1, #0x0D
    str r1, [r0]

    @ 发送 LF
    ldr r0, =0x40013800
wait_lf:
    ldr r1, [r0]
    tst r1, #0x80
    beq wait_lf

    ldr r0, =0x40013804
    mov r1, #0x0A
    str r1, [r0]

    bx lr


@ TIM2 中断服务程序
.type TIM2_IRQHandler, %function

TIM2_IRQHandler:
    @ 清除 TIM2 更新标志
    ldr r0, =0x40000010
    mov r1, #0
    str r1, [r0]

    @ 翻转 PC13
    ldr r0, =0x4001100C
    ldr r1, [r0]
    eor r1, r1, #0x2000
    str r1, [r0]

    @ 设置发送标志
    ldr r0, =send_flag
    mov r1, #1
    str r1, [r0]

    bx lr

.size TIM2_IRQHandler, . - TIM2_IRQHandler


.section .bss
.align 2
send_flag:
    .space 4
