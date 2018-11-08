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
	
	push dwIndex ; Entity Index

	push 3 ; VFunc Index for GetClientEntity
	push IClientEntityList
	call DbgVFunc

	ret 4

GetClientEntity endp

end