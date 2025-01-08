	.text
	.file	"call.ll"
	.globl	_sum                            # -- Begin function _sum
	.p2align	4, 0x90
	.type	_sum,@function
_sum:                                   # @_sum
	.cfi_startproc
# %bb.0:
                                        # kill: def $esi killed $esi def $rsi
                                        # kill: def $edi killed $edi def $rdi
	leal	(%rdi,%rsi), %eax
	retq
.Lfunc_end0:
	.size	_sum, .Lfunc_end0-_sum
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$3, %edi
	movl	$4, %esi
	callq	_sum@PLT
	movl	%eax, %edi
	callq	_write@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
