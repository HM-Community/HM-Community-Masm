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