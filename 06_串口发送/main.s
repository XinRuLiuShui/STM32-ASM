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

    @ 发送字符串
    ldr r0, =message
    bl usart_send_string

    @ 继续等待下一次中断
    b main_loop


@ 发送以 \0 结尾的字符串
@ 输入：r0 = 字符串首地址
.type usart_send_string, %function

usart_send_string:
    push {r4, lr}

    @ r4 保存当前字符的地址
    mov r4, r0

send_string_loop:
    @ 读取当前字符
    ldrb r1, [r4]

    @ 如果字符为 0，说明字符串结束
    cmp r1, #0
    beq send_string_done

    @ 等待 USART1 的 TXE 置位
    ldr r0, =0x40013800

wait_txe:
    ldr r2, [r0]
    tst r2, #0x80
    beq wait_txe

    @ 将字符写入 USART1_DR
    ldr r0, =0x40013804
    str r1, [r0]

    @ 指向下一个字符
    adds r4, r4, #1
    b send_string_loop

send_string_done:
    pop {r4, pc}


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

.section .rodata
.align 2
message:
    .asciz "TIM2 interrupt!\r\n"
