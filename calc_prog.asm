.data
menu:    .asciiz "\nCALCULADORA PROGRAMADOR DIDÁTICA\n1) DEC -> BIN/OCT/HEX/BCD\n2) DEC -> COMPLEMENTO A 2 (16 bits)\n3) REAL -> FLOAT/DOUBLE (bits IEEE-754)\n0) SAIR\nEscolha: "
nl:      .asciiz "\n"
sep:     .asciiz "----------------------------------------\n"
opt1:    .asciiz "Você escolheu: DEC -> BIN/OCT/HEX/BCD\n"
opt2:    .asciiz "Você escolheu: COMPLEMENTO A 2 (16 bits)\n"
opt3:    .asciiz "Você escolheu: REAL -> FLOAT/DOUBLE (bits IEEE-754)\n"
bye:     .asciiz "Encerrando programa...\n"

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
    la $a0, opt1
    jal print_str
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