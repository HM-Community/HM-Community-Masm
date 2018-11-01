.686p
.xmm
.model flat, stdcall
option casemap:none

include C:\masm32_x86\include\masm32rt.inc


.code

GetImageBase proc szImageName : dword

	invoke GetModuleHandleA, szImageName

	ret 4

GetImageBase endp


GetImageSize proc szImageName : dword

	local mInfo : MODULEINFO
	
	push ebx ; Handle to own process
	push edx ; dwImageBase

	invoke GetCurrentProcess

	mov ebx, eax

	invoke GetModuleHandleA, szImageName

	cmp eax, 0

	jz ErrorAndExit

	mov edx, eax

	push ecx ; &mInfo
	lea ecx, [ mInfo ]

	;BOOL GetModuleInformation( HANDLE hProcess, HMODULE hModule, LPMODULEINFO lpmodinfo, DWORD cb );
	invoke GetModuleInformation, ebx, edx, ecx, sizeof MODULEINFO

	pop ecx

	.if eax == 0
		jmp ErrorAndExit
	.else
		mov eax, mInfo.SizeOfImage
		pop edx
		pop ebx

		ret 4

	.endif

ErrorAndExit:
	mov eax, 0

	pop edx
	pop ebx

	ret 4

GetImageSize endp

end