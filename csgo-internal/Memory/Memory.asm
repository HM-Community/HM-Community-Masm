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

GetAddressOfExportedFunction proc szImageName : DWORD, szFunctionName : DWORD

	mov eax, szImageName ; EAX = *(byte*)szImageName

	push eax
	call GetModuleHandleA

	cmp eax, 0

	jz Exit

	push ebx
	mov ebx, eax ; ebx = ImageBase from szImageName

	;FARPROC GetProcAddress( HMODULE hModule, LPCSTR  lpProcName )
	mov eax, szFunctionName

	push eax
	push ebx
	call GetProcAddress

	; No need to check here because even if the function fails
	; the return value will be 0 in eax and we will return anyways

	pop ebx

	ret 8

Exit:
	printf("%s\n", "Could not get module handle!")
	ret 8

GetAddressOfExportedFunction endp
end