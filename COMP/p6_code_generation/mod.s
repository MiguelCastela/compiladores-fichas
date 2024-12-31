	.text
	.file	"mod.ll"
	.globl	_mod                            # -- Begin function _mod
	.p2align	4, 0x90
	.type	_mod,@function
_mod:                                   # @_mod
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	cltd
	idivl	%esi
	imull	%esi, %eax
	subl	%eax, %edi
	movl	%edi, %eax
	retq
.Lfunc_end0:
	.size	_mod, .Lfunc_end0-_mod
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
	callq	_mod@PLT
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
