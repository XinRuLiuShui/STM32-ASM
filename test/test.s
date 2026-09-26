.syntax unified
.cpu cortex-m3
.thumb

.global main

main:
    mov r0, #10
    mov r1, #20
    add r2, r0, r1

loop:
    b loop
