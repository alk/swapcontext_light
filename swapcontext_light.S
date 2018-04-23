
// those are offsets into ucontext_t's uc_mcontext.gregs[reg]
.set oR12, 72
.set oR13, 80
.set oR14, 88
.set oR15, 96
.set oRBP, 120
.set oRBX, 128
.set oRIP, 168
.set oRSP, 160

.text
.globl swapcontext
.type swapcontext, @function
swapcontext:
        .cfi_startproc
        // we first save our registers. Only callee saved registers.
        // and we don't bother with signal mask or FPU state
	movq     %rbx, oRBX(%rdi)
	movq     %rbp, oRBP(%rdi)
	movq     %r12, oR12(%rdi)
	movq     %r13, oR13(%rdi)
	movq     %r14, oR14(%rdi)
	movq     %r15, oR15(%rdi)
        // rip is taken from top of stack. Our return address
	movq     (%rsp), %rcx
	movq     %rcx, oRIP(%rdi)
        // saved stack is adjusted with return address 'popped'
	leaq     8(%rsp), %rcx
	movq     %rcx, oRSP(%rdi)

	// to have decent and still simple unwind info we first 'push'
	// all registers into target stack, then switch stack, then
	// pop everything
	movq     oRSP(%rsi), %rdx
	subq     $56, %rdx
	movq     oRIP(%rsi), %rcx
	movq     %rcx, 48(%rdx)
	movq     oRBP(%rsi), %rcx
	movq     %rcx, 40(%rdx)
	movq     oRBX(%rsi), %rcx
	movq     %rcx, 32(%rdx)
	movq     oR12(%rsi), %rcx
	movq     %rcx, 24(%rdx)
	movq     oR13(%rsi), %rcx
	movq     %rcx, 16(%rdx)
	movq     oR14(%rsi), %rcx
	movq     %rcx, 8(%rdx)
	movq     oR15(%rsi), %rcx
	movq     %rcx, 0(%rdx)

        // and here as we switch the stack, we're carefully updating
	// stack unwinding info
	movq     %rdx, %rsp
        // first is indicate that rsp+56 is where 'function' frame
	//starts
	.cfi_def_cfa_offset 56
        // then indicate where other registers sit
	.cfi_offset 15, -56
	.cfi_offset 14, -48
	.cfi_offset 13, -40
	.cfi_offset 12, -32
	.cfi_offset 3, -24
	.cfi_offset 6, -16
	popq %r15
        // and as we pop them we're updating rsp-to-frame-address
	// offset
	.cfi_def_cfa_offset 48
	popq %r14
	.cfi_def_cfa_offset 40
	popq %r13
	.cfi_def_cfa_offset 32
	popq %r12
	.cfi_def_cfa_offset 24
	popq %rbx
	.cfi_def_cfa_offset 16
	popq %rbp
	.cfi_def_cfa_offset 8
	xorl %eax, %eax
	ret
        .cfi_endproc
.size swapcontext, .-swapcontext
