.syntax unified
.cpu cortex-m3
.thumb

.global Reset_Handler
.global Default_Handler
.global TIM2_IRQHandler
.global _estack

.section .isr_vector, "a", %progbits

.word _estack
.word Reset_Handler


// 异常向量表剩余的系统异常入口
.rept 14
.word Default_Handler
.endr

// IRQ0 到 IRQ27
.rept 28
.word Default_Handler
.endr

// IRQ28：TIM2
.word TIM2_IRQHandler


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
