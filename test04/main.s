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


    /*
     * 开 TIM2 时钟
     *
     * RCC_APB1ENR
     * 0x4002101C
     *
     * TIM2EN bit0
     */


    ldr r0, =0x4002101C

    ldr r1,[r0]

    orr r1,r1,#1

    str r1,[r0]

    /*
     * TIM2 PSC
     */

    ldr r0, =0x40000028

    ldr r1, =7999

    str r1,[r0]

    /*
     * TIM2 ARR
     */

    ldr r0, =0x4000002C

    ldr r1, =499

    str r1,[r0]

    /*
     * 启动 TIM2
     *
     * CR1 CEN=1
     */

    ldr r0, =0x40000000

    mov r1,#1

    str r1,[r0]


loop:
    /*
     * 等待 UIF
     *
     * TIM2_SR
     */

wait:


    ldr r0, =0x40000010

    ldr r1,[r0]


    tst r1,#1


    beq wait



    /*
     * 清 UIF
     */

    ldr r0, =0x40000010

    mov r1,#0

    str r1,[r0]



    /*
     * LED翻转
     *
     * 先简单使用 ODR
     *
     * GPIOC_ODR
     * 0x4001100C
     */


    ldr r0, =0x4001100C

    ldr r1,[r0]


    eor r1,r1,#0x2000


    str r1,[r0]

    b loop

.size main, . - main
