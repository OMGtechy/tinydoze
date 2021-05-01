.386
.model flat, stdcall
option casemap : none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib

.data

c_AppName byte "Josh's Tiny App", 0

.code
WndProc proc hWindow:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL paintStructure : PAINTSTRUCT
    LOCAL clientRect : RECT

    cmp uMsg, WM_DESTROY
    je DestroyMessageHandler

    cmp uMsg, WM_PAINT
    je PaintMessageHandler

    invoke DefWindowProc,
        hWindow,
        uMsg,
        wParam,
        lParam
    ret

PaintMessageHandler:

    lea ebx, clientRect
    invoke GetClientRect,
        hWindow,
        ebx

    lea eax, paintStructure
    push eax
    invoke BeginPaint,
        hWindow,
        eax

    push DT_CENTER or DT_VCENTER or DT_SINGLELINE
    push ebx

    xchg ebx, eax

    invoke SetBkMode,
        ebx,
        TRANSPARENT

    push -1
    push offset c_AppName
    push ebx
    call DrawText

    push hWindow
    call EndPaint

    jmp ReturnFromMessageHandler

DestroyMessageHandler:

    invoke PostQuitMessage,
        0

ReturnFromMessageHandler:

    xor eax, eax
    ret

WndProc endp

_WinMainCRTStartup:

WinMain proc _unused:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL windowClass : WNDCLASSEX
    LOCAL message : MSG

    xor ebx, ebx

	invoke GetModuleHandle,
        ebx

    push ebx
	push eax

    mov windowClass.cbSize, sizeof windowClass
    mov windowClass.style, CS_HREDRAW or CS_VREDRAW
    mov windowClass.lpfnWndProc, offset WndProc
    mov windowClass.cbClsExtra, ebx
    mov windowClass.cbWndExtra, ebx
    mov windowClass.hInstance, eax
    mov windowClass.hbrBackground, COLOR_3DSHADOW + 1
    mov windowClass.lpszMenuName, ebx
    mov windowClass.lpszClassName, offset c_AppName

    invoke LoadIconA,
        ebx,
        IDI_APPLICATION

    mov windowClass.hIcon, eax
    mov windowClass.hIconSm, eax

    invoke LoadCursorA,
        ebx,
        IDC_ARROW

    mov windowClass.hCursor, eax

    lea eax, windowClass
    invoke RegisterClassEx,
        eax

    push ebx
    push ebx
    push 480 ; you could write an 8 bit value here to use a smaller op code and save space
    push 600 ; but I didn't count that as "functionally equivalent"
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW or WS_VISIBLE
    push offset c_AppName
    push eax
    push ebx
    call CreateWindowEx

MessageLoop:

    xor eax, eax

    lea ebx, message
    invoke GetMessage,
        ebx,
        eax,
        eax,
        eax

    test eax, eax
    je NoMoreMessages

    invoke TranslateMessage,
        ebx

    invoke DispatchMessage,
        ebx

    jmp MessageLoop

NoMoreMessages:
    mov eax, message.wParam
    ret

WinMain endp

end _WinMainCRTStartup
