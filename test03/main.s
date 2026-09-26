.syntax unified
.cpu cortex-m3
.thumb

.global main

.section .text
.type main, %function

main:

    /*--------------------------------
     * 1. 开启 GPIOC 时钟
     *
     * RCC_APB2ENR = 0x40021018
     * GPIOCEN = bit4
     *--------------------------------*/

    ldr r0, =0x40021018
    ldr r1, [r0]

    orr r1, r1, #(1 << 4)

    str r1, [r0]


    /*--------------------------------
     * 2. 配置 PC13
     *
     * GPIOC_CRH = 0x40011004
     * PC13 = 4'b0001
     *--------------------------------*/

    ldr r0, =0x40011004
    ldr r1, =0x00100000

    str r1, [r0]


    /*--------------------------------
     * 3. PC13 输出低电平
     *
     * GPIOC_BRR = 0x40011014
     * bit13 = 1
     *--------------------------------*/




loop:
    ldr r0, =0x4001100C
    mov r1, #(1 << 13)

    str r1, [r0]
    bl delay

    ldr r0, =0x4001100C
    mov r1, #(0 << 13)

    str r1, [r0]
    bl delay

    b loop

.type delay, %function

delay:

    ldr r0, =0x003FFFFF

delay_loop:

    subs r0, r0, #1
    bne delay_loop

    bx lr

.size delay, . - delay
        
.size main, . - main
