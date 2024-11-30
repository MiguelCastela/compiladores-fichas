	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0
	.globl	__factorial                     ## -- Begin function _factorial
	.p2align	4, 0x90
__factorial:                            ## @_factorial
	.cfi_startproc
## %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	testl	%edi, %edi
	je	LBB0_2
## %bb.1:                               ## %L1then
	movl	%edi, %ebx
	leal	-1(%rbx), %edi
	callq	__factorial
	imull	%ebx, %eax
	movl	%eax, 12(%rsp)
	jmp	LBB0_3
LBB0_2:                                 ## %L1else
	movl	$1, 12(%rsp)
LBB0_3:                                 ## %L1end
	movl	12(%rsp), %eax
	addq	$16, %rsp
	popq	%rbx
	retq
	.cfi_endproc
                                        ## -- End function
.subsections_via_symbols
