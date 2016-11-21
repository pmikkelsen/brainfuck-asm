section .text
global _start

_start:
	mov r13, [rsp + 16]	; program text (1st command line arg)
	mov r14, 0		; stack offset
	mov r15, -1		; program offset
	
	xor rax, rax
initStack:
	push byte 0
	inc rax
	cmp rax, 30000
	jne initStack
	mov rbp, rsp		; pointer to brainfuck stack

exec:
	inc r15			; increment program pointer offset
	mov al, [r13 + r15]	; save current command in al
	cmp al, 0
	je exit
	cmp al, '>'
	je incrementPtr
	cmp al, '<'
	je decrementPtr
	cmp al, '+'
	je incrementData
	cmp al, '-'
	je decrementData
	cmp al, '.'
	je output
	cmp al, ','
	je input
	cmp al, '['
	je loopStart
	cmp al, ']'
	je loopEnd
	jmp exec

incrementPtr:
	inc r14
	jmp exec

decrementPtr:
	dec r14
	jmp exec

incrementData:
	inc byte [rbp + r14]
	jmp exec

decrementData:
	dec byte [rbp + r14]
	jmp exec

output:
	mov rax, 1
	mov rdi, 1
	mov rsi, rbp
	add rsi, r14
	mov rdx, 1
	syscall
	jmp exec

input:
	mov rax, 0
	mov rdi, 0
	mov rsi, rbp
	add rsi, r14
	mov rdx, 1
	syscall
	jmp exec

loopStart:
	push r15
	cmp byte [rbp + r14], 0
	je skipInstructions
	jmp exec

skipInstructions:
	inc r15
	cmp byte [r13 + r15], ']'
	jne skipInstructions
	jmp exec

loopEnd:
	pop rax
	cmp byte [rbp + r14], 0
	je exec
	mov r15, rax
	dec r15
	jmp exec			

exit:
	mov rax, 60
	mov rdi, 0
	syscall
