.686p
.xmm
.model flat, stdcall
option casemap:none

include Memory\Memory.inc

include C:\masm32_x86\include\masm32rt.inc

.data?

dwClientCreateInterface dd ?
dwEngineCreateInterface dd ?

public IClient
public ICHLClient
public IClientPrediction
public IClientEntityList

IClient dd ? ; TODO: rename to the correct interface name
ICHLClient dd ? ; https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/client/cdll_client_int.cpp
IClientPrediction dd ?
IClientEntityList dd ?

.data

szClientName db 'client_panorama.dll', 0
szEngineName db 'engine.dll', 0

szCreateInterface db 'CreateInterface', 0

; === client_panorama.dll interfaces ===
szInterfaceClient db 'VClient018', 0 
szInterfaceClientEntityList db 'VClientEntityList003', 0
szInterfaceClientPrediction db 'VClientPrediction001', 0
; ======================================

; === engine.dll interfaces ====
szInterfaceEngineClient db 'VEngineClient014', 0
;===============================


.code

InitializeInterfaces proc

	push offset szCreateInterface
	push offset szClientName
	call GetAddressOfExportedFunction

	cmp eax, 0

	jz ErrorClientInterface

	mov dwClientCreateInterface, eax

	push offset szCreateInterface
	push offset szEngineName
	call GetAddressOfExportedFunction

	cmp eax, 0

	jz ErrorEngineInterface

	mov dwEngineCreateInterface, eax

	push offset szInterfaceClient
	call GetClientInterface

	cmp eax, 0
	jz ErrorRetrievingInterface

	mov dword ptr [ IClient ], eax

	printf("%s%s\n", "IClient =- 0x", uhex$( eax ) )

	push offset szInterfaceClientEntityList
	call GetClientInterface

	cmp eax, 0
	jz ErrorRetrievingInterface

	mov dword ptr [ IClientEntityList ], eax

	printf("%s%s\n", "IClientEntityList =- 0x", uhex$( eax ) )

	push offset szInterfaceClientPrediction
	call GetClientInterface

	cmp eax, 0
	jz ErrorRetrievingInterface

	mov dword ptr [ IClientPrediction ], eax

	printf("%s%s\n", "IClientPrediction =- 0x", uhex$( eax ) )

	push offset szInterfaceEngineClient
	call GetEngineInterface

	cmp eax, 0
	jz ErrorRetrievingInterface

	mov dword ptr [ ICHLClient ], eax

	printf("%s%s\n", "ICHLClient =- 0x", uhex$( eax ) )

	mov eax, 1

	ret

ErrorRetrievingInterface:
	
	printf("%s\n", "Could not get interface address!")

	mov eax, 0

	ret

ErrorEngineInterface:

	printf("%s\n", "Could not get address of CreateInterface from engine.dll!")

	ret

ErrorClientInterface:

	printf("%s\n", "Could not get address of CreateInterface from client_panorama.dll")

	ret 

InitializeInterfaces endp

GetClientInterface proc szInterfaceName : dword
	
	; int __cdecl CreateInterface(int interface_name, dword* result_pointer) 

	mov eax, dword ptr [ dwClientCreateInterface ]

	push 0
	push szInterfaceName
	call eax
	add esp, 8

	ret 4

GetClientInterface endp

GetEngineInterface proc szInterfaceName : dword
	
	; int __cdecl CreateInterface(int interface_name, dword* result_pointer) 

	mov eax, dword ptr [ dwEngineCreateInterface ]

	push 0
	push szInterfaceName
	call eax
	add esp, 8

	ret 4

GetEngineInterface endp

CalcVfunc proc dwInterfaceAddress : dword, dwFunctionIndex : dword

	push ebx 
	mov ebx, dwInterfaceAddress		; Put the interface address in ebx
	mov ebx, dword ptr [ ebx ]		; Dereference it, so it points to the vtable

	push ecx
	mov ecx, dwFunctionIndex		

	lea ebx, [ ebx + ecx * 4 ]		; Calculate the vfunc address - absolute
	
	mov eax, ebx					; Save it in eax

	pop ecx
	pop ebx

	ret 8

CalcVfunc endp

end