.text
.align 2
.global miMain
.type miMain, %function
.extern printf
.extern nave




miMain: // X0 pixels
		mov		x10, X0			//  BackUp pixels address (xo tiene la direccion de memoria del arreglo de pixeles)
		mov		x15, X1			//  BackUp config

		mov		x11,	#0			//	Start counter in 0
		
		movz	w2, 0x0aa0			// Muevo la parte alta  de la direccion a_w2
		movk	w2, 0xffff, lsl 16	// X2 = color
		// w2 = 0xffff0aa0

loop2:
		add		w2, w2, #1

		lsl		X1, X11, #2		// *4 pixels

		mov		X0, X10			// X0 = pixels
		add		X0, X0, X1
		str		W2, [x0, #0]

		add		X11, X11, #1
		movz	X3,	0x2C00
		movk	X3, 0x1, lsl 16
		cmp		X11, X3
		b.lt	loop2
		mov		x11,	#0

wait: 	//wait for frame

        ldrb	w7, [x15, #8]
		ands	w7,w7,#1
        b.ne	wait
		mov		w7, #0
		strb	w7,[x15, #8]
		b		loop2
