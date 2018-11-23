.686p
.xmm
.model flat, stdcall
option casemap:none

include SDK\Interfaces\Interfaces.inc

.data

; === Interfaces.asm ===
; The address of the interface
extern IClientEntityList : dword

.code

GetClientEntity proc dwIndex : dword

	push 3 ; VFunc Index for GetClientEntity
	push IClientEntityList	
	call CalcVfunc	

	.if eax == 0
		ret 4
	.endif

	mov ecx, IClientEntityList	; Store this pointer in ecx because of the thiscall calling convention
	mov ecx, [ ecx ]			; Dereference it, so it points to the vtable

	push dwIndex
	call eax

	ret 4	; TODO: Fix crash here

GetClientEntity endp

end