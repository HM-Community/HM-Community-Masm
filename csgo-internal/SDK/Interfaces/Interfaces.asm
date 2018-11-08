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

; Need to push the arguments for the vfunc before the call to this function
; Also make sure all parameter are 4 bytes aligned!! If not stack can be fucked up
CallVFunc proc dwInterfaceAddress : dword, dwFunctionIndex : dword

	ret 8

CallVFunc endp

DbgVFunc proc dwInterfaceAddress : dword, dwFunctionIndex : dword
	
	; == Stack ==
	; [ VFuncParam] + 0x10 + 4 * x, x = count of vfunc params
	; [ Param2 ]	+ 0xC
	; [ Param1 ]	+ 0x8
	; [ RetAddr ]	+ 0x4
	; [ ------- ]	+ 0x0
	; [ dwParam1 ]	- 0x4
	; [ dwParam2 ]	- 0x8
	; [ dwRetAddr ] - 0xC

	local dwParam1 : dword
	local dwParam2 : dword
	local dwReturnAddress : dword

	local dwECX : dword

	push eax								; save eax value

	mov eax, dword ptr [ ebp + 4 ]			; save the return address 
	mov dwReturnAddress, eax				; to the local variable for later use

	mov eax, dwInterfaceAddress				; save the interface address
	mov dwParam1, eax						; to the local variable for later use
	
	mov eax, dwFunctionIndex				; save the function index
	mov dwParam2, eax						; to the local variable for later use

	mov dwECX, ecx							; Save ecx because of the thispointer
	
	pop eax									; Restore eax value

	add esp, 4 * 3							; Increase stack pointer
											; so it points to the first vfunc parameter
											; Data from ebp 0x0 - 0xC may be corrupted
											; so we saved it to local variables

	mov eax, dwParam1						; eax = dwInterfaceAddress
	mov eax, dword ptr [ eax ]				; Dereference eax so it points to the vtable
	
	mov ecx, dwParam2						; Move dwFunctionIndex in ecx for addressing

	mov eax, dword ptr [ eax + ecx * 4 ]	; Dereference correct vtable function address
											; vtable + function_index * function_size

	mov ecx, dwParam1						; Move the thispointer in ecx
											; because of the thiscall calling convention

	call eax								; call the vtable function

	sub esp, 4 * 3							; Restore stack pointer to it's old value

	mov ecx, dwECX							; Restore ecx to it's old value

	push dwReturnAddress					; Push the saved return address

	ret										; Return here without pop'ing the 8 bytes
											; for the parameters because they got pop'ed
											; when we increased the stackframe pointer

DbgVFunc endp

end