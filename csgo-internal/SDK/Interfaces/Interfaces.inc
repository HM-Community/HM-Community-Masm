InitializeInterfaces proto 
GetClientInterface	 proto szInterfaceName : dword
GetEngineInterface	 proto szInterfaceName : dword
CallVFunc			 proto dwInterfaceAddress : dword, dwFunctionIndex : dword

DbgVFunc			 proto dwInterfaceAddress : dword, dwFunctionIndex : dword