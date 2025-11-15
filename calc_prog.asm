.data
menu:    .asciiz "\nCALCULADORA PROGRAMADOR DIDÁTICA\n1) DEC -> BIN/OCT/HEX/BCD\n2) DEC -> COMPLEMENTO A 2 (16 bits)\n3) REAL -> FLOAT/DOUBLE (bits IEEE-754)\n0) SAIR\nEscolha: "
nl:      .asciiz "\n"
sep:     .asciiz "----------------------------------------\n"
opt2:    .asciiz "Você escolheu: COMPLEMENTO A 2 (16 bits)\n"
opt3:    .asciiz "Você escolheu: REAL -> FLOAT/DOUBLE (bits IEEE-754)\n"
bye:     .asciiz "Encerrando programa...\n"
lbl_inteiro: .asciiz "Entre com um número inteiro em base 10: "
lbl_base:    .asciiz "Escolha a base destino (2, 8 ou 16): "
lbl_passos:  .asciiz "Passos da conversão (divisões sucessivas):\n"
lbl_result:  .asciiz "Resultado final: "
lbl_div:     .asciiz "  "
lbl_div_a:   .asciiz " / "
lbl_div_b:   .asciiz " = "
lbl_div_r:   .asciiz " resto "
lbl_invalid: .asciiz "Base inválida.\n"
lbl_bcd:     .asciiz "Passos para conversão em BCD:\n"
lbl_byte:    .asciiz "Byte BCD: 0x"

stack: .space 1024
top:   .word 0

.text
.globl main

print_nl:
    li $v0, 4
    la $a0, nl
    syscall
    jr $ra

print_str:
    li $v0, 4
    syscall
    jr $ra

print_int:
    li $v0, 1
    syscall
    jr $ra

print_char:
    li $v0, 11
    syscall
    jr $ra

reset_stack:
    la $t0, top
    sw $zero, 0($t0)
    jr $ra

push_digit:
    la $t0, top
    lw $t1, 0($t0)
    la $t2, stack
    addu $t3, $t2, $t1
    sb $a0, 0($t3)
    addiu $t1, $t1, 1
    sw $t1, 0($t0)
    jr $ra

pop_digit:
    la $t0, top
    lw $t1, 0($t0)
    beq $t1, $zero, empty
    addiu $t1, $t1, -1
    sw $t1, 0($t0)
    la $t2, stack
    addu $t3, $t2, $t1
    lb $v0, 0($t3)
    li $v1, 1
    jr $ra
empty:
    move $v1, $zero
    jr $ra

print_digit:
    move $t0, $a0
    li $t1, 10
    blt $t0, $t1, num
    addiu $t0, $t0, -10
    li $t2, 'A'
    addu $t0, $t0, $t2
    move $a0, $t0
    jal print_char
    jr $ra
num:
    li $t2, '0'
    addu $t0, $t0, $t2
    move $a0, $t0
    jal print_char
    jr $ra

dec_to_base:
    move $t0, $a0
    move $t1, $a1
    beq $t0, $zero, zero_case
    la $a0, lbl_passos
    jal print_str
    jal reset_stack
loop:
    div $t0, $t1
    mflo $t2
    mfhi $t3
    la $a0, lbl_div
    jal print_str
    move $a0, $t0
    jal print_int
    la $a0, lbl_div_a
    jal print_str
    move $a0, $t1
    jal print_int
    la $a0, lbl_div_b
    jal print_str
    move $a0, $t2
    jal print_int
    la $a0, lbl_div_r
    jal print_str
    move $a0, $t3
    jal print_int
    jal print_nl
    move $a0, $t3
    jal push_digit
    move $t0, $t2
    bne $t0, $zero, loop
    la $a0, lbl_result
    jal print_str
print_loop:
    jal pop_digit
    beq $v1, $zero, done
    move $a0, $v0
    jal print_digit
    j print_loop
done:
    jal print_nl
    jr $ra
zero_case:
    la $a0, lbl_result
    jal print_str
    li $a0, '0'
    jal print_char
    jal print_nl
    jr $ra

dec_to_bcd:
    move $t0, $a0
    la $a0, lbl_bcd
    jal print_str
    jal reset_stack
bcd_loop:
    beq $t0, $zero, pack
    li $t1, 10
    div $t0, $t1
    mflo $t2
    mfhi $t3
    move $a0, $t3
    jal push_digit
    move $t0, $t2
    j bcd_loop
pack:
    jal print_nl
    la $a0, lbl_byte
    jal print_str
print_bcd_bytes:
    jal pop_digit
    beq $v1, $zero, end_bcd
    move $t4, $v0
    jal pop_digit
    beq $v1, one_left
    move $t5, $v0
    sll $t5, $t5, 4
    or $t6, $t5, $t4
    li $v0, 34
    move $a0, $t6
    syscall
    jal print_nl
    la $a0, lbl_byte
    jal print_str
    j print_bcd_bytes
one_left:
    move $t6, $t4
    li $v0, 34
    move $a0, $t6
    syscall
    jal print_nl
end_bcd:
    jr $ra

main:
menu_loop:
    la $a0, sep
    jal print_str
    la $a0, menu
    jal print_str
    li $v0, 5
    syscall
    move $t0, $v0
    beq $t0, $zero, exit
    li $t1, 1
    beq $t0, $t1, opcao1
    li $t1, 2
    beq $t0, $t1, opcao2
    li $t1, 3
    beq $t0, $t1, opcao3
    j menu_loop
opcao1:
    la $a0, lbl_inteiro
    jal print_str
    li $v0, 5
    syscall
    move $s0, $v0
    la $a0, lbl_base
    jal print_str
    li $v0, 5
    syscall
    move $s1, $v0
    li $t2, 2
    beq $s1, $t2, ok
    li $t2, 8
    beq $s1, $t2, ok
    li $t2, 16
    beq $s1, $t2, ok
    la $a0, lbl_invalid
    jal print_str
    j menu_loop
ok:
    move $a0, $s0
    move $a1, $s1
    jal dec_to_base
    move $a0, $s0
    jal dec_to_bcd
    j menu_loop
opcao2:
    la $a0, opt2
    jal print_str
    j menu_loop
opcao3:
    la $a0, opt3
    jal print_str
    j menu_loop
exit:
    la $a0, bye
    jal print_str
    jr $ra