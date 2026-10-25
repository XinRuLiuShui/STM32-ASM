.syntax unified
.cpu cortex-m3
.thumb

.global Reset_Handler
.global Default_Handler
.global EXTI0_IRQHandler
.global _estack

.section .isr_vector, "a", %progbits

.word _estack
.word Reset_Handler

// 异常向量表剩余的系统异常入口
.rept 20
.word Default_Handler
.endr

@ 向量表索引 = 16 + IRQ编号
@ EXTI0的IRQ编号为6
@ 16 + 6 = 22
.word EXTI0_IRQHandler



.section .text

.type Reset_Handler, %function

Reset_Handler:
    bl main

hang:
    b hang

.type Default_Handler,%function

Default_Handler:
    b .

.size Reset_Handler, . - Reset_Handler
