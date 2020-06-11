.text
.align 2
.global miMain
.type miMain, %function
.extern printf
//.extern convertida

miMain: // X0 pixels
		mov	x10, x0	     	//  BackUp pixels address
		mov	x15, x1	     	//  BackUp config

      	        mov x11, 0x07f		//la columna en la que empiezo por defecto
       		mov x12, 0xfff		
	
		mov x8, 120		// la fila en la que empiezo por defecto
		mov x9,#1		//COLOCO EL CONTADOR DEL MARCO
	loop2:	
		//  Pinto pantalla de color
		mov     x0, x10
		movz    w1,0xffff
		movk	w1, 0xffff, lsl 16	// w1 = color = 0xff000000
      		bl      pintar_pantalla_color


		// Dibujo Imagen x2->fila, x3->columna
		mov     x0, x10      	       // Direccion del arreglo de la ventana 320x240
        	adrp	x1, aparision	       //Variable megaman
		add	x1, x1, :lo12:aparision
		mov     x3, x11		       //x3=0xfff (columna fff)
		mov 	x2,x8	      	       //inicia a dibujar en la fila x2, (me sobre el x4 para pasar)
		bl	draw_image_aparicion
		
		/*subs	xzr,x9,#1
		bne	draw_static
		bl	draw_image_aparicion
		
		draw_static:
		bl      draw_image	       //aca le pase desde que posicion del arregl quiero que inicio a dibujar mi megaman
		*/
		
		ldrb	w7, [x15, #0] // w7=1 implica que pulso la tecla de flecha para la izquierda
		subs	wzr, w7, #1   // verifico si la pulso
       	 	b.ne	ver_der		
		sub     x11, x11 ,#16
		b        wait
	
		ver_der:
        	ldrb	w7, [x15, #1] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	ver_arriba		
		add     x11,x11,#16

		ver_arriba:
		ldrb	w7, [x15, #2] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	ver_abajo
		sub 	x8,x8,#4		
		sub     x2,x2,x8

		ver_abajo:
		ldrb	w7, [x15, #3] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	wait	
		add 	x8,x8,#4
		add     x2,x2,x8



		wait: 	// wait for frame

   	        ldrb	w7, [x15, #8]
		subs	wzr, w7, #1
                b.ne	wait

		mov     w7, #0
		strb	w7,[x15, #8]
		add	x9,x9,#1		//seteo para que me aparezca una sola vez
		b	loop2
		
		
	pintar_pantalla_color:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x2,[sp, 24]
		str     x3,[sp, 16]
		str     x4,[sp, 8]
		str     x5,[sp, 0]
		
		mov	x2,#0    //Start counter in 0

		pintar_pantalla_color_loop:

		add	x3, x0, x2     //x3=posicion en el arreglo de la pantalla expresada en byte
		str	w1, [x3, #0]   // guardo el color en la posicion del arreglo de x3(regordemos que guardo de a word(4 byte))
		add	x2, x2, #4     // le sumo 4 para ir al siguiente pixel
		movz	x4,0xB000      // 0x4b000 es el final de la posicion del vector de pixels de mi ventana
		movk	x4, 0x4, lsl 16
		cmp	x2, x4
		b.lt	pintar_pantalla_color_loop
		
       		ldr     x5,[sp, 0]
        	ldr     x4,[sp, 8]
        	ldr     x3,[sp, 16]
        	ldr     x2,[sp, 24]
        	ldr     x30,[sp, 32]
        	ldr     x29,[sp, 40]
       		add     sp, sp ,48
		ret

	draw_image_aparicion:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x4,[sp, 24]
		str     x5,[sp, 16]
		str     x6,[sp, 8]
		str     x7,[sp, 0]
		//guardar x24,x25

		/*
		// Mover puntero de pantalla al primer pixel donde debe ir la imagen.(lo puedo optimizar)
		adrp	x14, memoria_aux	        //USO VARIABLE AUX
		add	x14, x14, :lo12:memoria_aux     //USO VARIABLE AUX
		*/
		
		//actualizar el puntero de mi ventana
		movz    x4, #1280	// 320 x 4= obtengo los bytes de una fila
		mul     x2, x2, x4  	//x2=10*(1280) = me posiciono en la fila que coloco la imagen
		add	x0, x0, x2	//me posiciono en la fila de abajo
		lsl     x3, x3, #2  	// x3=oxfff0 
		add     x0, x0, x3  	// x0=me posicion en la columna y fila de la pantalla a donde voy a dibujar (add x0, x2, lsl x3,x3,#2)
				    	
		
		ldr     x2, [x1, #0]    // x2 Ancho de mi imagen ->x2=300, no me sirve mucho el ancho
		ldr     x3, [x1, #8]    // x3 Alto de mi imagen
		mov	x24,#50		//HASTA LA COLUMNA 50
		add     x1, x1, #16	//actualizo mi puntareo de arreglo de mi imagen ya que ya no necesito obtener el ancho y el alto
		

		
		
		//desde aca agregue
		mov	x21,xzr	//mi imagen inicial
		mov	x23,#6

		repetir:
		//desde aca agregue
		mov 	x22,x0
		mov	x20,x1		//lo guardo para conservar la inicio del arreglo de mi imagen
		add	x1,x1,x21	// me posiciono en los pixel del marco al cual voy(agregue)
		mov	x25,x1		//HICE UNA COPIA DE LA DIRECCION INICIAL DE DONDE INICIO A PINTAR
		
			
		mov	x4, #0		// Cont Filas de imagen
		mov	x5, #0		// Cont Columnas de imagen

	 draw_image_loop:
		//dibujo la columnas primero
		
		ldr     w6, [x1,#0]		// cargo los 4 bytes direcctamente
		str	w6, [x0, #0]		// dibujo el pixeles de mi imagen en la ventana
		add     x0, x0, #4      	// Muevo direccion del pixel de pantalla
		add     x1, x1, #4      	// Muevo direccion del pixel de imagen
		add     x5, x5, #1      	// Incremento en uno la columna
		
		cmp	x5,x24
		b.lt    draw_image_loop  	// me aseguro de no desbordar y pasar a la fila de abajo de mi pantalla a donde dibujo
		
		
		mov	x5, #0		// setear contador columna 
		
		add     x0, x0, #1280	// Paso al pinxers que tengo que pintar(osea me desplazo una fila hacia abajo)
		lsl     x6, x24, #2	//x6= obtengo el ancho del marco mio de mi imagen en byte
		sub     x0, x0, x6	// ancho de pantalla -ancho de mi imagen= 1 columna de la fila de abajo

		add	x25,x25,#1220	//avanzo en filas de mi puntero de mi imagen-> solo funciona para imagenes de 306
		mov	x1,x25		//actualizo el punto de mi imagen
		
		add     x4, x4, #1	// Aumento mi contador de fila
		cmp     x4, x3 		// verifico si me mi contador de fila es igual al tamaño de la fila de mi imagen
		b.lt    draw_image_loop   // dibujo la fila en la que estoy 

		mov     x19,#0
		add	x19,x19,#2000
		lsl	x19,x19,#12
		add	x19,x19,x19

		delay:
		subs	x19,x19,#1
		bne	delay

		mov	x1,x20		//(agregado)
		add	x21,x21,#200

		mov	x0,x22
		subs	x23,x23,#1	//(agregado)
		bne	repetir		//(agregado)
		
		//ACA TENGO QUE GUARDAR EN memoria_aux el desde y hasta de lo que pinte ahora

		ldr     x7,[sp, 0]
		ldr     x6,[sp, 8]
		ldr     x5,[sp, 16]
		ldr     x4,[sp, 24]
		ldr     x30,[sp, 32]
		ldr     x29,[sp, 40]
		add     sp, sp ,48
		ret
		
	draw_image:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x4,[sp, 24]
		str     x5,[sp, 16]
		str     x6,[sp, 8]
		str     x7,[sp, 0]
		
		
		//actualizar el puntero de mi ventana
		movz    x4, #1280	// 320 x 4= obtengo los bytes de una fila
		mul     x2, x2, x4  	//x2=10*(1280) = me posiciono en la fila que coloco la imagen
		add	x0, x0, x2	//me posiciono en la fila de abajo
		lsl     x3, x3, #2  	// x3=oxfff0 
		add     x0, x0, x3  	// x0=me posicion en la columna y fila de la pantalla a donde voy a dibujar (add x0, x2, lsl x3,x3,#2)
				    	
		
		ldr     x2, [x1, #0]    // x2 Ancho de mi imagen ->x2=300, no me sirve mucho el ancho
		ldr     x3, [x1, #8]    // x3 Alto de mi imagen
		mov	x24,#50		//HASTA LA COLUMNA 50
		add     x1, x1, #16	//actualizo mi puntareo de arreglo de mi imagen ya que ya no necesito obtener el ancho y el alto
		

		
		
		//desde aca agregue
		mov	x21,#1000	//mi imagen inicial
		mov	x23,#6

		
		//desde aca agregue
		mov 	x22,x0
		mov	x20,x1		//lo guardo para conservar la inicio del arreglo de mi imagen
		add	x1,x1,x21	// me posiciono en los pixel del marco al cual voy(agregue)
		mov	x25,x1		//HICE UNA COPIA DE LA DIRECCION INICIAL DE DONDE INICIO A PINTAR
		
			
		mov	x4, #0		// Cont Filas de imagen
		mov	x5, #0		// Cont Columnas de imagen

	 draw_image_loop_static:
		//dibujo la columnas primero
		
		ldr     w6, [x1,#0]		// cargo los 4 bytes direcctamente
		str	w6, [x0, #0]		// dibujo el pixeles de mi imagen en la ventana
		add     x0, x0, #4      	// Muevo direccion del pixel de pantalla
		add     x1, x1, #4      	// Muevo direccion del pixel de imagen
		add     x5, x5, #1      	// Incremento en uno la columna
		
		cmp	x5,x24
		b.lt    draw_image_loop_static  	// me aseguro de no desbordar y pasar a la fila de abajo de mi pantalla a donde dibujo
		
		
		mov	x5, #0		// setear contador columna 
		
		add     x0, x0, #1280	// Paso al pinxers que tengo que pintar(osea me desplazo una fila hacia abajo)
		lsl     x6, x24, #2	//x6= obtengo el ancho del marco mio de mi imagen en byte
		sub     x0, x0, x6	// ancho de pantalla -ancho de mi imagen= 1 columna de la fila de abajo

		add	x25,x25,#1220	//avanzo en filas de mi puntero de mi imagen-> solo funciona para imagenes de 306
		mov	x1,x25		//actualizo el punto de mi imagen
		
		add     x4, x4, #1	// Aumento mi contador de fila
		cmp     x4, x3 		// verifico si me mi contador de fila es igual al tamaño de la fila de mi imagen
		b.lt    draw_image_loop_static   // dibujo la fila en la que estoy 

		

		

		mov	x1,x20		//(agregado)
		mov	x0,x22
		
		
		//ACA TENGO QUE GUARDAR EN memoria_aux el desde y hasta de lo que pinte ahora

		ldr     x7,[sp, 0]
		ldr     x6,[sp, 8]
		ldr     x5,[sp, 16]
		ldr     x4,[sp, 24]
		ldr     x30,[sp, 32]
		ldr     x29,[sp, 40]
		add     sp, sp ,48
		ret

memoria_aux:
    .xword   0  // desde_ancho 
    .xword   20  // hasta_ancho





		

