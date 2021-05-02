tinydoze is an attempt to make the smallest possible executable that meets a few requirements.

See this YouTube link for details: https://www.youtube.com/watch?v=b0zxIfJJLAY

Things I thought of and didn't do for some reason / yet:
- Realigning the windows libraries so I can /align:1. This should save up to 3 bytes?
- Removing the optional PE header.
- Finding a way to remove the DLL and/or function names.
- Failing that, remove SetBkMode and therefore gdi32.dll dependency by setting the background colour of the text to match.
- Removing / shrinking the name of the executable embedded inside the executable.
- Find a way to remove some more of the padding.
- Find a way to remove / shrink the "Rich" header? If possible at all.
- Manually set the return address of TranslateMessage to DispatchMessage with the stack set correctly. 
