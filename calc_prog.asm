.data
menu:    .asciiz "\nCALCULADORA PROGRAMADOR DIDÁTICA\n1) DEC -> BIN/OCT/HEX/BCD\n2) DEC -> COMPLEMENTO A 2 (16 bits)\n3) REAL -> FLOAT/DOUBLE (IEEE-754)\n0) SAIR\nEscolha: "
nl:      .asciiz "\n"
sep:     .asciiz "----------------------------------------\n"
bye:     .asciiz "Encerrando programa...\n"

lbl_inteiro: .asciiz "Entre com um número inteiro em base 10: "
lbl_base:    .asciiz "Escolha a base destino (2,8,16): "
lbl_passos:  .asciiz "Passos da conversão (divisões sucessivas):\n"
lbl_result:  .asciiz "Resultado final: "
lbl_div:     .asciiz "  "
lbl_div_a:   .asciiz " / "
lbl_div_b:   .asciiz " = "
lbl_div_r:   .asciiz " resto "
lbl_invalid: .asciiz "Base inválida.\n"

lbl_bcd:     .asciiz "Passos para conversão em BCD:\n"
lbl_byte:    .asciiz "Byte BCD: 0x"

lbl_c2_a: .asciiz "Valor absoluto: "
lbl_c2_b: .asciiz "Binário antes da inversão (16 bits): "
lbl_c2_c: .asciiz "Bits invertidos: "
lbl_c2_d: .asciiz "Somando 1: "
lbl_c2_r: .asciiz "Resultado final (16 bits): "

lbl_real:    .asciiz "Digite um número real: "
lbl_float:   .asciiz "FLOAT (32 bits):\n"
lbl_double:  .asciiz "DOUBLE (64 bits):\n"
lbl_sign:    .asciiz "Sinal: "
lbl_exp:     .asciiz "Expoente bruto: "
lbl_bias:    .asciiz "Expoente com viés: "
lbl_unbias:  .asciiz "Expoente sem viés: "
lbl_frac:    .asciiz "Mantissa: "
lbl_bits:    .asciiz "Bits: "

stack: .space 4096
top:   .word 0
tmp:   .word 0
tmpH:  .word 0
tmpL:  .word 0

.text
.globl main

print_nl:
    li $v0,4
    la $a0,nl
    syscall
    jr $ra

print_str:
    li $v0,4
    syscall
    jr $ra

print_int:
    li $v0,1
    syscall
    jr $ra

print_char:
    li $v0,11
    syscall
    jr $ra

reset_stack:
    la $t0,top
    sw $zero,0($t0)
    jr $ra

push_digit:
    la $t0,top
    lw $t1,0($t0)
    la $t2,stack
    addu $t3,$t2,$t1
    sb $a0,0($t3)
    addiu $t1,$t1,1
    sw $t1,0($t0)
    jr $ra

pop_digit:
    la $t0,top
    lw $t1,0($t0)
    beq $t1,$zero,empty
    addiu $t1,$t1,-1
    sw $t1,0($t0)
    la $t2,stack
    addu $t3,$t2,$t1
    lb $v0,0($t3)
    li $v1,1
    jr $ra
empty:
    move $v1,$zero
    jr $ra

print_digit:
    move $t0,$a0
    li $t1,10
    blt $t0,$t1,num
    addiu $t0,$t0,-10
    li $t2,'A'
    addu $t0,$t0,$t2
    move $a0,$t0
    jal print_char
    jr $ra
num:
    li $t2,'0'
    addu $t0,$t0,$t2
    move $a0,$t0
    jal print_char
    jr $ra

print_bits16:
    li $t0,15
L16:
    bltz $t0,END16
    move $t1,$a0
    srlv $t1,$t1,$t0
    andi $t1,$t1,1
    li $t2,'0'
    bne $t1,$zero,ONE16
    j OUT16
ONE16:
    li $t2,'1'
OUT16:
    move $a0,$t2
    jal print_char
    addiu $t0,$t0,-1
    j L16
END16:
    jr $ra

print_bits32:
    li $t0,31
L32:
    bltz $t0,END32
    move $t1,$a0
    srlv $t1,$t1,$t0
    andi $t1,$t1,1
    li $t2,'0'
    bne $t1,$zero,ONE32
    j OUT32
ONE32:
    li $t2,'1'
OUT32:
    move $a0,$t2
    jal print_char
    addiu $t0,$t0,-1
    j L32
END32:
    jr $ra

dec_to_base:
    move $t0,$a0
    move $t1,$a1
    beq $t0,$zero,ZB
    la $a0,lbl_passos
    jal print_str
    jal reset_stack
LB:
    div $t0,$t1
    mflo $t2
    mfhi $t3
    la $a0,lbl_div
    jal print_str
    move $a0,$t0
    jal print_int
    la $a0,lbl_div_a
    jal print_str
    move $a0,$t1
    jal print_int
    la $a0,lbl_div_b
    jal print_str
    move $a0,$t2
    jal print_int
    la $a0,lbl_div_r
    jal print_str
    move $a0,$t3
    jal print_int
    jal print_nl
    move $a0,$t3
    jal push_digit
    move $t0,$t2
    bne $t0,$zero,LB
    la $a0,lbl_result
    jal print_str
LPR:
    jal pop_digit
    beq $v1,$zero,EDB
    move $a0,$v0
    jal print_digit
    j LPR
EDB:
    jal print_nl
    jr $ra
ZB:
    la $a0,lbl_result
    jal print_str
    li $a0,'0'
    jal print_char
    jal print_nl
    jr $ra

dec_to_bcd:
    move $t0,$a0
    la $a0,lbl_bcd
    jal print_str
    jal reset_stack
B1:
    beq $t0,$zero,B2
    li $t1,10
    div $t0,$t1
    mflo $t2
    mfhi $t3
    move $a0,$t3
    jal push_digit
    move $t0,$t2
    j B1
B2:
print_bcd:
    jal pop_digit
    beq $v1,$zero,END_B
    move $t4,$v0
    jal pop_digit
    beq $v1,ONE_B
    move $t5,$v0
    sll $t5,$t5,4
    or $t6,$t5,$t4
    la $a0,lbl_byte
    jal print_str
    li $v0,34
    move $a0,$t6
    syscall
    jal print_nl
    j print_bcd
ONE_B:
    move $t6,$t4
    la $a0,lbl_byte
    jal print_str
    li $v0,34
    move $a0,$t6
    syscall
    jal print_nl
    j print_bcd
END_B:
    jr $ra

dec_to_c2:
    move $t0,$a0
    la $a0,lbl_c2_a
    jal print_str
    bltz $t0,NEG
    move $a0,$t0
    jal print_int
    jal print_nl
    move $t2,$t0
    j PRE
NEG:
    subu $t2,$zero,$t0
    move $a0,$t2
    jal print_int
    jal print_nl
PRE:
    la $a0,lbl_c2_b
    jal print_str
    move $a0,$t2
    jal print_bits16
    jal print_nl
    bgez $t0,POS
    la $a0,lbl_c2_c
    jal print_str
    nor $t3,$t2,$zero
    and $t3,$t3,0xFFFF
    move $a0,$t3
    jal print_bits16
    jal print_nl
    la $a0,lbl_c2_d
    jal print_str
    addiu $t4,$t3,1
    and $t4,$t4,0xFFFF
    move $a0,$t4
    jal print_bits16
    jal print_nl
    la $a0,lbl_c2_r
    jal print_str
    move $a0,$t4
    jal print_bits16
    jal print_nl
    jr $ra
POS:
    la $a0,lbl_c2_r
    jal print_str
    move $a0,$t2
    jal print_bits16
    jal print_nl
    jr $ra

real_float:
    la $a0,lbl_float
    jal print_str
    li $v0,6
    syscall
    mfc1 $t0,$f0
    la $a0,lbl_sign
    jal print_str
    srl $t1,$t0,31
    andi $t1,$t1,1
    move $a0,$t1
    jal print_int
    jal print_nl
    la $a0,lbl_exp
    jal print_str
    srl $t2,$t0,23
    andi $t2,$t2,0xFF
    move $a0,$t2
    jal print_int
    jal print_nl
    la $a0,lbl_bias
    jal print_str
    move $a0,$t2
    jal print_int
    jal print_nl
    la $a0,lbl_unbias
    jal print_str
    addiu $t3,$t2,-127
    move $a0,$t3
    jal print_int
    jal print_nl
    la $a0,lbl_frac
    jal print_str
    andi $t4,$t0,0x7FFFFF
    move $a0,$t4
    jal print_int
    jal print_nl
    la $a0,lbl_bits
    jal print_str
    move $a0,$t0
    jal print_bits32
    jal print_nl
    jr $ra

real_double:
    la $a0,lbl_double
    jal print_str
    li $v0,7
    syscall
    addiu $sp,$sp,-8
    sdc1 $f0,0($sp)
    lw $t1,4($sp)
    lw $t0,0($sp)
    addiu $sp,$sp,8
    la $a0,lbl_sign
    jal print_str
    srl $t2,$t1,31
    andi $t2,$t2,1
    move $a0,$t2
    jal print_int
    jal print_nl
    la $a0,lbl_exp
    jal print_str
    srl $t3,$t1,20
    andi $t3,$t3,0x7FF
    move $a0,$t3
    jal print_int
    jal print_nl
    la $a0,lbl_bias
    jal print_str
    move $a0,$t3
    jal print_int
    jal print_nl
    la $a0,lbl_unbias
    jal print_str
    li $t4,1023
    subu $t5,$t3,$t4
    move $a0,$t5
    jal print_int
    jal print_nl
    la $a0,lbl_frac
    jal print_str
    jal print_nl
    la $a0,lbl_bits
    jal print_str
    move $a0,$t1
    jal print_bits32
    move $a0,$t0
    jal print_bits32
    jal print_nl
    jr $ra

main:
menu_loop:
    la $a0,sep
    jal print_str
    la $a0,menu
    jal print_str
    li $v0,5
    syscall
    move $t0,$v0
    beq $t0,$zero,exit
    li $t1,1
    beq $t0,$t1,op1
    li $t1,2
    beq $t0,$t1,op2
    li $t1,3
    beq $t0,$t1,op3
    j menu_loop

op1:
    la $a0,lbl_inteiro
    jal print_str
    li $v0,5
    syscall
    move $s0,$v0
    la $a0,lbl_base
    jal print_str
    li $v0,5
    syscall
    move $s1,$v0
    li $t2,2
    beq $s1,$t2,OK
    li $t2,8
    beq $s1,$t2,OK
    li $t2,16
    beq $s1,$t2,OK
    la $a0,lbl_invalid
    jal print_str
    j menu_loop
OK:
    move $a0,$s0
    move $a1,$s1
    jal dec_to_base
    move $a0,$s0
    jal dec_to_bcd
    j menu_loop

op2:
    la $a0,lbl_inteiro
    jal print_str
    li $v0,5
    syscall
    move $a0,$v0
    jal dec_to_c2
    j menu_loop

op3:
    la $a0,lbl_real
    jal print_str
    jal real_float
    la $a0,lbl_real
    jal print_str
    jal real_double
    j menu_loop

exit:
    la $a0,bye
    jal print_str
    jr $ra