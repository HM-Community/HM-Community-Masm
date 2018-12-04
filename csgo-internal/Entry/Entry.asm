.686p
.xmm
.model flat, stdcall
option casemap:none

include C:\masm32_x86\include\masm32rt.inc

include Memory\Memory.inc

include Utils\Includes.inc

include SDK\Interfaces\Interfaces.inc

include SDK\Interfaces\IClientEntityList\IClientEntityList.inc


.data

szCaption db 'HM-Community', 0
szMessage db 'www.high-minded.net', 13, 10, 0

szFilename db 'CONOUT$', 0
szMode db 'w', 0

szClientDllName db 'client_panorama.dll', 0
szTierZero db 'tier0.dll', 0

;szCreateInterface db 'CreateInterface', 0
szMsg db 'Msg', 0

.code

InitializeConsole proc
	
	local hOutput : HANDLE

	invoke AllocConsole

	invoke crt_freopen, offset szFilename, offset szMode, stdout()

	invoke SetConsoleTitleA, offset szMessage

	ret

InitializeConsole endp

;
; BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
; 
Entrypoint proc hModule : HMODULE, ul_reason_for_call : dword , lpReserved : LPVOID

	local dwBase : dword
	local dwSize : dword
	local dwFunctionAddress : dword

	Switch ul_reason_for_call

	case DLL_PROCESS_ATTACH

		call InitializeConsole

		printf("\n%s\n", "This is a internal CS:GO Cheat developed by the community of HighMinded!")
		
		invoke GetImageBase, 0
		mov dwBase, eax

		printf("\n%s%s\n", "Image Base: 0x", uhex$( dwBase ) ) ; Watch out the printf macro change some register!

		invoke GetImageSize, 0
		mov dwSize, eax
		
		printf("\n%s%s\n", "Image Size:", str$( dwSize ) )

		invoke GetAddressOfExportedFunction, offset szTierZero, offset szMsg

		cmp eax, 0

		jz ErrorRetrievingAddress

		mov dword ptr [ dwFunctionAddress ], eax
		printf("%s%s\n", "tier0.dll =- Msg: 0x", uhex$( dwFunctionAddress ) )

		mov eax, dword ptr [ dwFunctionAddress ] ; printf macro fucks with gprs

		; eax contains the address to the exported function: Msg
		; Function prototype: __int64 __cdecl Msg(int a1, char a2)
		push 0
		push offset szMessage
		call eax
		add esp, 8

		printf("%s\n", "You may want to open the console..")

		call InitializeInterfaces

		push 1
		call GetClientEntity
		pushad
		printf("%s%s\n", "GetClientEntity(1): 0x", uhex$( eax ) )
		popad
		
		push eax
		call GetClientEntityFromHandle

		pushad
		printf("%s%s\n", "GetClientEntityFromHandle(eax): 0x", uhex$( eax ) )
		popad

		push 0
		call GetNumberOfEntities

		pushad
		printf("%s%s\n", "GetNumberOfEntities(0): 0x", uhex$( eax ) )
		popad

		call GetHighestEntityIndex

		pushad
		printf("%s%s\n", "GetHighestEntityIndex(): 0x", uhex$( eax ) )
		popad


		invoke Sleep, 10000 ; Just for debug

		jmp Exit

	case DLL_THREAD_ATTACH
		; Do some stuff
	
	case DLL_THREAD_DETACH
		; Do some stuff

	case DLL_PROCESS_DETACH
		mov eax, hModule
		invoke FreeLibraryAndExitThread, eax, 1

	Endsw

ErrorRetrievingAddress:

		printf("%s\n", "Could not retrieve the address of ConMsg in tier0.dll!")

		jmp Exit

Exit:

	invoke FreeConsole

	mov eax, hModule
	invoke FreeLibraryAndExitThread, eax, 1
		
Entrypoint endp

end Entrypoint