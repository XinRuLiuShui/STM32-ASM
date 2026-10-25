.syntax unified
.cpu cortex-m3
.thumb

.global main
.global EXTI0_IRQHandler

.section .text
.type main, %function

main:

    @ 开启 AFIO、GPIOA、GPIOC 和 USART1 时钟
    @ 0x40021018 是 RCC 的 APB2 外设时钟使能寄存器。
    @ 0x4015 对应开启：
    @ bit 0：AFIO
    @ bit 2：GPIOA
    @ bit 4：GPIOC
    @ bit 14：USART1
    ldr r0, =0x40021018
    ldr r1, [r0]
    ldr r2, =0x00004015
    orr r1, r1, r2
    str r1, [r0]

    @ 配置 PA0 为输入上拉
    @ 0x40010800 是 GPIOA 的 CRL 寄存器，负责配置 PA0～PA7
    @ PA0 对应最低的 4 个 bit，也就是 bit3:0
    @ 先清零，再设为设成 1000，STM32F1 中，CNF=10、MODE=00 表示输入上拉/下拉模式
    ldr r0, =0x40010800
    ldr r1, [r0]
    bic r1, r1, #0xF
    orr r1, r1, #0x8
    str r1, [r0]
    
    @ 将 GPIOA 的 ODR bit0 置 1，就选择了上拉
    ldr r0, =0x4001080C
    ldr r1, [r0]
    orr r1, r1, #1
    str r1, [r0]

    @ 将 EXTI0 映射到 PA0
    @ AFIO_EXTICR1
    ldr r0, =0x40010008
    ldr r1, [r0]
    bic r1, r1, #0xF
    str r1, [r0]
    
    @ 允许 EXTI0 中断
    @ EXTI_IMR
    ldr r0, =0x40010400
    ldr r1, [r0]
    orr r1, r1, #1
    str r1, [r0]
    
    @ 关闭上升沿触发
    @ EXTI_RTSR
    ldr r0, =0x40010408
    ldr r1, [r0]
    bic r1, r1, #1
    str r1, [r0]
    
    @ 开启下降沿触发
    @ EXTI_FTSR
    ldr r0, =0x4001040C
    ldr r1, [r0]
    orr r1, r1, #1
    str r1, [r0]
    
    @ 清除之前可能存在的中断挂起标志
    @ EXTI_PR
    ldr r0, =0x40010414
    movs r1, #1
    str r1, [r0]
    
    @ 在 NVIC 中使能 EXTI0，IRQ6
    @ ARM Cortex-M3 内核组件 NVIC_ISER0
    ldr r0, =0xE000E100
    movs r1, #1
    lsls r1, r1, #6
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

    @ 启动时先发送一条测试消息
    @ ldr r0, =message
    @ bl usart_send_string


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

.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:
    // 清除 EXTI0 挂起标志
    ldr r0, =0x40010414
    movs r1, #1
    str r1, [r0]

    // 通知主循环发送字符串
    ldr r0, =send_flag
    movs r1, #1
    str r1, [r0]

    bx lr

.size EXTI0_IRQHandler, . - EXTI0_IRQHandler

.section .bss
.align 2
send_flag:
    .space 4

.section .rodata
.align 2
message:
    .asciz "EXTI0 interrupt!\r\n"
