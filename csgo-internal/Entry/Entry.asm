.686p
.xmm
.model flat, stdcall
option casemap:none

include C:\masm32\include\masm32rt.inc

include Memory\Memory.inc

_iobuf STRUCT
    _ptr        DWORD ?
    _cnt        DWORD ?
    _base       DWORD ?
    _flag       DWORD ?
    _file       DWORD ?
    _charbuf    DWORD ?
    _bufsiz     DWORD ?
    _tmpfname   DWORD ?
_iobuf ENDS

stdout MACRO
    call crt___p__iob
    add eax, SIZEOF _iobuf
    EXITM <eax>
ENDM

.data

szCaption db 'HM-Community', 0
szMessage db 'www.high-minded.net', 0

szFilename db 'CONOUT$', 0
szMode db 'w', 0

.code

InitializeConsole proc
	
	local hOutput : HANDLE

	invoke AllocConsole

	push eax
;invoke GetStdHandle, STD_OUTPUT_HANDLE

	mov dword ptr [ hOutput ], eax

	;TODO: Fix access violation here
	invoke crt_freopen, offset szFilename, offset szMode, stdout()

	invoke SetConsoleTitleA, offset szMessage

	pop eax

	ret

InitializeConsole endp

;
; BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
; 
Entrypoint proc hModule : HMODULE, ul_reason_for_call : dword , lpReserved : LPVOID

	local dwBase : dword
	local dwSize : dword

	Switch ul_reason_for_call

	case DLL_PROCESS_ATTACH
		
		call InitializeConsole

		printf("%s\n", "Hello and welcome to the world of masm!")
		
		invoke GetImageBase, 0
		mov dwBase, eax

		printf("\n%s%s\n", "Image Base:", uhex$( dwBase ) ) ; Watch out the printf macro change some register!

		invoke GetImageSize, 0
		mov dwSize, eax
		
		printf("\n%s%s\n", "Image Size:", str$( dwSize ) )

		jmp Exit

	case DLL_THREAD_ATTACH
		; Do some stuff
	
	case DLL_THREAD_DETACH
		; Do some stuff

	case DLL_PROCESS_DETACH
		mov eax, hModule
		invoke FreeLibraryAndExitThread, eax, 1

	Endsw

Exit:

	mov eax, 1 

	ret 12
		
Entrypoint endp

end Entrypoint