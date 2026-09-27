.syntax unified
.cpu cortex-m3
.thumb

.global Reset_Handler
.global _estack

.section .isr_vector, "a", %progbits

.word _estack
.word Reset_Handler

.section .text.Reset_Handler, "ax", %progbits
.type Reset_Handler, %function

Reset_Handler:
    bl main

hang:
    b hang

.size Reset_Handler, . - Reset_Handler
