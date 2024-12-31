	.text
	.file	"multiplication.ll"
	.globl	_multiply                       # -- Begin function _multiply
	.p2align	4, 0x90
	.type	_multiply,@function
_multiply:                              # @_multiply
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	imull	%esi, %eax
	retq
.Lfunc_end0:
	.size	_multiply, .Lfunc_end0-_multiply
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	xorl	%edi, %edi
	callq	_read@PLT
	movl	%eax, %ebx
	xorl	%edi, %edi
	callq	_read@PLT
	movl	%ebx, %edi
	movl	%eax, %esi
	callq	_multiply@PLT
	movl	%eax, %edi
	callq	_write@PLT
	xorl	%eax, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
