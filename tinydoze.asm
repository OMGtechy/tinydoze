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

c_WindowClassName = 16

.data

c_AppName byte "Josh's Tiny App", 0

.data?

g_hInstance HINSTANCE ?

.code
WndProc proc hWindow:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL paintStructure : PAINTSTRUCT
    LOCAL hDeviceContext : HDC
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

    lea eax, paintStructure
    invoke BeginPaint,
        hWindow,
        eax

    mov hDeviceContext, eax

    invoke SetBkMode,
        hDeviceContext,
        TRANSPARENT

    lea eax, clientRect
    invoke GetClientRect,
        hWindow,
        eax

    lea eax, clientRect
    invoke DrawText,
        hDeviceContext,
        offset c_AppName,
        -1,
        eax,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE

    lea eax, paintStructure
    invoke EndPaint,
        hWindow,
        eax

    xor eax, eax
    ret

DestroyMessageHandler:

    invoke PostQuitMessage,
        0

    xor eax, eax
    ret

WndProc endp

_WinMainCRTStartup:

WinMain proc hInstance:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL windowClass : WNDCLASSEX
    LOCAL message : MSG

	invoke 	GetModuleHandle,
        0

	mov	g_hInstance, eax

    mov windowClass.cbSize, sizeof windowClass
    mov windowClass.style, CS_HREDRAW or CS_VREDRAW
    mov windowClass.lpfnWndProc, offset WndProc
    mov windowClass.cbClsExtra, 0
    mov windowClass.cbWndExtra, 0
    mov windowClass.hInstance, eax
    mov windowClass.hbrBackground, COLOR_3DSHADOW + 1
    mov windowClass.lpszMenuName, 0
    mov windowClass.lpszClassName, offset c_WindowClassName

    invoke LoadIconA,
        0,
        IDI_APPLICATION

    mov windowClass.hIcon, eax
    mov windowClass.hIconSm, eax

    mov eax, g_hInstance

    invoke LoadCursorA,
        0,
        IDC_ARROW

    mov windowClass.hCursor, eax

    lea eax, windowClass
    invoke RegisterClassEx,
        eax

    invoke CreateWindowEx, 
        0,
        offset c_WindowClassName,
        offset c_AppName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        800,
        600,
        0,
        0,
        g_hInstance,
        0

    invoke UpdateWindow,
        eax

MessageLoop:

    lea eax, message
    invoke GetMessage,
        eax,
        0,
        0,
        0

    cmp eax, 0
    je NoMoreMessages

    lea eax, message
    invoke TranslateMessage,
        eax

    lea eax, message
    invoke DispatchMessage,
        eax

    jmp MessageLoop

NoMoreMessages:
    mov eax, message.wParam
    ret

WinMain endp

end _WinMainCRTStartup
