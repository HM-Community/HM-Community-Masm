.686p
.xmm
.model flat, stdcall
option casemap:none

include SDK\Interfaces\Interfaces.inc

include C:\masm32_x86\include\masm32rt.inc

.data

; === Interfaces.asm ===
; The address of the interface
extern IClientEntityList : dword

.code

GetClientEntity proc dwIndex : dword

	local dwECX : dword

	invoke GetVfunc, IClientEntityList, 3

	.if eax == 0
		ret 4
	.endif

	mov dwECX, ecx

	mov ecx, IClientEntityList

	push dwIndex
	call eax

	mov ecx, dwECX

	ret 4				

GetClientEntity endp

GetClientEntityFromHandle proc hEntity : dword

	local dwECX : dword

	invoke GetVfunc, IClientEntityList, 4

	.if eax == 0
		ret 4
	.endif

	mov dwECX, ecx

	mov ecx, IClientEntityList

	push hEntity
	call eax

	mov ecx, dwECX

	ret 4

GetClientEntityFromHandle endp


GetNumberOfEntities	proc bIncludeNonNetworkable : byte 

	local dwECX : dword

	invoke GetVfunc, IClientEntityList, 5

	.if eax == 0
		ret 4
	.endif

	mov dwECX, ecx

	mov ecx, IClientEntityList

	push dword ptr bIncludeNonNetworkable ; Need to sign/zero extend here the byte value for the push.
	call eax

	mov ecx, dwECX

	ret 4 ; 4 bytes because masm aligns every parameter from a function to 4 bytes. 

GetNumberOfEntities endp


GetHighestEntityIndex proc

	local dwECX : dword

	invoke GetVfunc, IClientEntityList, 6

	.if eax == 0
		ret 4
	.endif

	mov dwECX, ecx

	mov ecx, IClientEntityList

	call eax

	mov ecx, dwECX

	ret

GetHighestEntityIndex endp

end