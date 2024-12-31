	.text
	.file	"identifier.ll"
	.globl	_identity                       # -- Begin function _identity
	.p2align	4, 0x90
	.type	_identity,@function
_identity:                              # @_identity
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	retq
.Lfunc_end0:
	.size	_identity, .Lfunc_end0-_identity
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
	xorl	%edi, %edi
	callq	_read@PLT
	movl	%eax, %edi
	callq	_identity@PLT
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
