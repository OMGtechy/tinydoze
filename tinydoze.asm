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

    lea ebx, clientRect
    invoke GetClientRect,
        hWindow,
        ebx

    invoke DrawText,
        hDeviceContext,
        offset c_AppName,
        -1,
        ebx,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE

    lea eax, paintStructure
    invoke EndPaint,
        hWindow,
        eax

    jmp ReturnFromMessageHandler

DestroyMessageHandler:

    invoke PostQuitMessage,
        0

ReturnFromMessageHandler:

    xor eax, eax
    ret

WndProc endp

_WinMainCRTStartup:

WinMain proc hInstance:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL windowClass : WNDCLASSEX
    LOCAL message : MSG

    xor ebx, ebx

	invoke GetModuleHandle,
        ebx

	mov	g_hInstance, eax

    mov windowClass.cbSize, sizeof windowClass
    mov windowClass.style, CS_HREDRAW or CS_VREDRAW
    mov windowClass.lpfnWndProc, offset WndProc
    mov windowClass.cbClsExtra, ebx
    mov windowClass.cbWndExtra, ebx
    mov windowClass.hInstance, eax
    mov windowClass.hbrBackground, COLOR_3DSHADOW + 1
    mov windowClass.lpszMenuName, ebx
    mov windowClass.lpszClassName, offset c_WindowClassName

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

    invoke CreateWindowEx, 
        ebx,
        offset c_WindowClassName,
        offset c_AppName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        800,
        600,
        ebx,
        ebx,
        g_hInstance,
        ebx

    invoke UpdateWindow,
        eax

MessageLoop:

    lea ebx, message
    invoke GetMessage,
        ebx,
        0,
        0,
        0

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
