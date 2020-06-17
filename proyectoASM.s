.text
.align 2
.global miMain
.type miMain, %function
.extern printf
//.extern convertida

miMain: // X0 pixels	
		mov	x14,#0
		mov 	x16,#0
		mov	x13,#0		//bandera bala
		mov 	x6,#0
		mov	x5,#0		//x5 contador de columnas
		mov	x4,#0		//x4 contador de fila
		mov	x10, x0	     	//  BackUp pixels address
		mov	x15, x1	     	//  BackUp config

      	        mov x11, 0x07f 		//la columna en la que empiezo por defecto
       		//mov x12, 0xfff		
	
		mov x8,#120		// la fila en la que empiezo por defecto
		mov x9,#1		//COLOCO EL CONTADOR DEL MARCO
	loop2:	
		//  Pinto pantalla de color
		mov     x0, x10
		adrp	x1, Contorno	        //Variable megaman
		add	x1, x1, :lo12:Contorno
      		bl      pintar_pantalla_color


		// Parametros:(x0-> ptr ventana,x1->ptr sprite,x2->direccion de ventana donde se dibuja mi spite, x3->eq x2 pero con columna
		//		x4->inicio de ancho, x5->contador de marco, x6-> contador de imagenes
		mov     x0, x10      	       		// Direccion del arreglo de la ventana 320x240
        	adrp	x1, last	        	//Variable megaman
		add	x1, x1, :lo12:last
		mov     x3, x11		       		//x3=0xfff (columna fff)
		mov 	x2,x8	      	      		//inicia a dibujar en la fila x2

		subs  	xzr,x16,#0			//si x16 es diferente de cero implica que alguien apreto un boton
		bne	botones

		cmp	x5,#9
		b.le	aparicion
		mov	x5,#0				//si le coloco 9 implica que voy a tener esprando el cuadro 9
		b	aparicion
		botones:

		subs	xzr,x16,#10
		bne	volver_fila
		mov	x16,#0
		volver_fila:
		mov	x5,x16				//numero de imagen	
		aparicion:


		subs	xzr,x13,#1
		bne	copiar_primera_vez		
		sub	x27,x3,#48		//copia un ancho menos para dibujar mi bala
		mov	x26,x2			//copio la fila de mi columna
		copiar_primera_vez:

		bl	draw_image
		add	x5,x5,#1		//avanzo hacia la siguiente imagen de  la misma filas

		
		mov     x0, x10	
		bl	draw_villano
		
		subs	xzr,x13,#0
		beq	no_disparo
		adrp	x1, bala	        //Variable megaman
		add	x1, x1, :lo12:bala
		mov     x0, x10			//restauro el puntero de mi arreglo de pixeles de mi pantalla
		mov	x3,x27			//columna nueva de la bala
		mov	x2,x26			//fila de bala

		add	x13,x13,#1		//(POR AHORA ESTA AL VICIO)		
		bl	dibujar_bala
		
		sub	x27,x27,#16		//se desplaza de a 12 columnas de pixels hacia la izq
		
		no_disparo:


		
				
		
		//me muevo hacia la izquierda
		ldrb	w7, [x15, #0] // w7=1 implica que pulso la tecla de flecha para la izquierda
		subs	wzr, w7, #1   // verifico si la pulso
       	 	b.ne	ver_der		
		sub     x11, x11 ,#16
		mov	x4,#4		//hago que me busque la fila #5
		add	x16,x16,#1
		b       wait
	
		ver_der:
        	ldrb	w7, [x15, #1] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	ver_arriba		
		add     x11,x11,#16
		mov	x4,#3		//hago que me busque la fila #3
		add	x16,x16,#1
		b       wait

		ver_arriba://salta hacia la derecha
		ldrb	w7, [x15, #2] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	ver_abajo
		sub 	x8,x8,#4
		mov	x4,#6		//hago que me busque la fila #3
		add	x16,x16,#1		
		sub     x2,x2,x8
		b       wait

		ver_abajo://dispara hacia la derecha
		ldrb	w7, [x15, #3] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		//b.ne	dormir
		b.ne	barra_espacio	
		add 	x8,x8,#4
		mov	x4,#7		//hago que me busque la fila #3
		add	x16,x16,#1
		add     x2,x2,x8
		b	wait


		barra_espacio:
		ldrb	w7, [x15, #7] //w7=1 implica que pulso la tecla de la flecha para la derecha
		subs	wzr, w7, #1
       		b.ne	dormir
		mov	x4,#4		//Faltaria hacer una imagen donde este parado y disparando
		add	x6,x16,#1	//no falta aumentar el x11 ya que no me desplazo en la pantalla

		mov 	x13,#1
		

		
		
		dormir://sino apreta ninguna tecla entonces esta durmiendo
		mov	x16,#0
		cmp	x5,#9
		b.lt	wait
		mov	x4,#2
		
		wait: 	// wait for frame

   	        ldrb	w7, [x15, #8]
		subs	wzr, w7, #1
                b.ne	wait

		mov     w7, #0
		strb	w7,[x15, #8]
		b	loop2
	


	draw_villano:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x2,[sp, 24]
		str     x3,[sp, 16]
		str     x4,[sp, 8]
		str     x5,[sp, 0]
	

		//dibujar villano
		
		mov     x3,#3		       		//x3=0x000 (columna 0)
		mov 	x2,#169
		mov	x4,#8	
		mov	x5,x14
			
		subs	xzr,x5,#10
		bne	volver_fila_villano
		mov	x5,#0
		volver_fila_villano:
		bl	draw_image
		add	x5,x5,#1
		mov	x14,x5

		ldr     x5,[sp, 0]
        	ldr     x4,[sp, 8]
        	ldr     x3,[sp, 16]
        	ldr     x2,[sp, 24]
        	ldr     x30,[sp, 32]
        	ldr     x29,[sp, 40]
       		add     sp, sp ,48
		ret


	
		
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

		add	x3, x0, x2      //x3=posicion en el arreglo de la pantalla expresada en byte
		add	x25,x1,x2
		ldr	w5,[x25,#0]	//AGREGADO
		str	w5,[x3,#0]	//AGREGADO
		add	x2,x2,#4        // le sumo 4 para ir al siguiente pixel
		movz	x4,0xB000       // 0x4b000 es el final de la posicion del vector de pixels de mi ventana
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

		// Parametros:(x0-> ptr ventana,x1->ptr sprite,x2->contador de filas a multipicar, x3->eq x2 pero con columna
		//		x4->inicio de ancho, x5->contador de marco, x6-> contador de imagenes

	draw_image:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x4,[sp, 24]
		str     x5,[sp, 16]
		str     x6,[sp, 8]
		str     x7,[sp, 0]
		//guardar x18,x25
		//se que tengo 1152000 pixels en una fila de 10 imagenes
		// x5=contador_colum,x4=contador_fila 
		
		mov 	x21,#192	
		mov	x17,#225			//LO TENGO QUE CAMBIAR YA QUE 
		mov	x18,#9
		lsl	x17,x17,x18	
		mul	x17,x17,x4	//obtengo la fila de mi imagen
		mul     x21,x21,x5	//obtengo mi nuevo ancho
		add	x21,x21,x17	//(ancho*contador_columna+filas_de_col*contador_filas)

		//verificar que no me paso de arriba
		cmp	x2,#0		
		b.gt	no_pasar_de_abajo
		add	x2,x2,#4
		add 	x8,x8,#4
		b	ver_costados
		
		no_pasar_de_abajo:
		
		cmp	x2,#170
		b.lt	ver_costados
		sub	x2,x2,#4
		sub 	x8,x8,#4

		
		//verifico que no me paso de las columnas limitrofes
		//de derecha a izquierda
		
		//ALTERNATIVA
		//udiv	x4, x3, x13		//x4=x3/272 -> TENGO QUE HACER X13=271
		//msub	x24, x4, x13, x3	//x24=x3%272
		//subs	xzr,x24,#0
		//bne	no_pasar_por_izq
		

		ver_costados:
		cmp	x3,#271
		b.lt	no_pasar_por_izq

		sub	x11,x11,#16
		sub	x3,x3,#16 			//AGREGADDOOOOOOOOOO
		
		b	no_pasar
		
		no_pasar_por_izq:

		cmp	x3,#1
		b.gt	no_pasar
		
		add	x11,x11,#16
		add	x3,x3,#16 			//AGREGADDOOOOOOOOOO
		
		
		no_pasar:

		//actualizar el puntero de mi ventana
		movz    x4, #1280	// 320 x 4= obtengo los bytes de una fila
		mul     x2, x2, x4  	//x2=10*(1280) = me posiciono en la fila que coloco la imagen
		add	x0, x0, x2	//me posiciono en la fila de abajo
		lsl     x3, x3, #2  	// x3=oxfff0 
		add     x0, x0, x3  	// x0=me posicion en la columna y fila de la pantalla a donde voy a dibujar (add x0, x2, lsl x3,x3,#2)


		//udiv	x4, x3, x13		//x4=x3/272
		//msub	x24, x4, x13, x3	//x24=x3%272
		
		ldr     x2, [x1, #0]    // x2 Ancho de mi imagen ->x2=300, no me sirve mucho el ancho
		ldr     x3, [x1, #8]    // x3 Alto de mi imagen
		mov	x3,#60		//TENGO QUE ARRGLAR MI ANCHO
		
		mov	x24,#48		//HASTA LA COLUMNA 48
		add     x1, x1, #16	//actualizo mi puntareo de arreglo de mi imagen ya que ya no necesito obtener el ancho y el alto
		
		mov 	x22,x0
		mov	x20,x1		//lo guardo para conservar la inicio del arreglo de mi imagen
		add	x1,x1,x21	// me posiciono en los pixel del marco al cual voy(agregue)
		mov	x25,x1		//HICE UNA COPIA DE LA DIRECCION INICIAL DE DONDE INICIO A PINTAR
		
		mov	x4, #0		// Cont Filas de imagen
		mov	x5, #0		// Cont Columnas de imagen

	 draw_image_loop:

		//dibujo la columnas primero
		
		ldr     w6, [x1,#0]		// cargo los 4 bytes directamente
		lsr     w7, w6, #24       	// 0xff aabbcc
        	cmp     w7, 0xff          	//  ( Red * A + Pix *(256-A) ) / 256
        	b.lt    no_dibujar
		str	w6, [x0, #0]		// dibujo el pixeles de mi imagen en la ventana
		no_dibujar:

			
		add     x0, x0, #4      	// Muevo direccion del pixel de pantalla
		add     x1, x1, #4      	// Muevo direccion del pixel de imagen
		add     x5, x5, #1      	// Incremento en uno la columna
		
		cmp	x5,x24
		b.lt    draw_image_loop  	// me aseguro de no desbordar y pasar a la fila de abajo de mi pantalla a donde dibujo
		
		mov	x5, #0		// setear contador columna 
		
		add     x0, x0, #1280	// Paso al pinxers que tengo que pintar(osea me desplazo una fila hacia abajo)
		lsl     x6, x24, #2	//x6= obtengo el ancho del marco mio de mi imagen en byte
		sub     x0, x0, x6	// ancho de pantalla -ancho de mi imagen= 1 columna de la fila de abajo

		add	x25,x25,#1920	//avanzo en filas de mi puntero de mi imagen-> solo funciona para imagenes de 306
		mov	x1,x25		//actualizo el punto de mi imagen
		
		add     x4, x4, #1	// Aumento mi contador de fila
		cmp     x4, x3 		// verifico si me mi contador de fila es igual al tamaño de la fila de mi imagen
		b.lt    draw_image_loop   // dibujo la fila en la que estoy 

		mov	x1,x20
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


//falta cambiar todas las etiquetas


		dibujar_bala:
		sub     sp, sp ,48
		str     x29,[sp, 40]
		str     x30,[sp, 32]
		str     x4,[sp, 24]
		str     x5,[sp, 16]
		str     x6,[sp, 8]
		str     x7,[sp, 0]
		//guardar x18,x25
		//se que tengo 1152000 pixels en una fila de 10 imagenes
		// x5=contador_colum,x4=contador_fila 
		
		

		//para no pasarme de derecha a izquierda
		//cmp	x3,#271
		//b.lt	no_pasar_por_izq

		//sub	x11,x11,#16
		//sub	x3,x3,#16 			//AGREGADDOOOOOOOOOO
		
		//b	no_pasar
		
		//no_pasar_por_izq:



		//no pasarme de izq a derecha

		cmp	x3,#1
		b.gt	no_pasar_para_bala
		
		add	x27,x27,#16
		add	x3,x3,#16 			//AGREGADDOOOOOOOOOO
		mov	x13,#0				//lo seteo en cero
		no_pasar_para_bala:

		//actualizar el puntero de mi ventana

		movz    x4, #1280	// 320 x 4= obtengo los bytes de una fila
		mul     x2, x2, x4  	//x2=10*(1280) = me posiciono en la fila que coloco la imagen
		add	x0, x0, x2	//me posiciono en la fila de abajo
		lsl     x3, x3, #2  	// x3=oxfff0 
		add     x0, x0, x3  	// x0=me posicion en la columna y fila de la pantalla a donde voy a dibujar (add x0, x2, lsl x3,x3,#2)


		
		ldr     x2, [x1, #0]    // x2 Ancho de mi imagen ->x2=48
		ldr     x3, [x1, #8]    // x3 Alto de mi imagen	 ->x3=60

		
		//mov	x24,#48		//HASTA LA COLUMNA 48
		add     x1, x1, #16	//actualizo mi puntareo de arreglo de mi imagen ya que ya no necesito obtener el ancho y el alto
		
		mov 	x22,x0
		mov	x20,x1		//lo guardo para conservar la inicio del arreglo de mi imagen
		
		mov	x4, #0		// Cont Filas de imagen
		mov	x5, #0		// Cont Columnas de imagen

	 ciclo_draw_bala:

		//dibujo la columnas primero
		
		ldr     w6, [x1,#0]		// cargo los 4 bytes directamente
		lsr     w7, w6, #24       	// 0xff aabbcc
        	cmp     w7, 0xff          	//  ( Red * A + Pix *(256-A) ) / 256
        	b.lt    no_dibujar_bala
		str	w6, [x0, #0]		// dibujo el pixeles de mi imagen en la ventana
		no_dibujar_bala:

			
		add     x0, x0, #4      	// Muevo direccion del pixel de pantalla
		add     x1, x1, #4      	// Muevo direccion del pixel de imagen
		add     x5, x5, #1      	// Incremento en uno la columna
		
		cmp	x5,x2
		b.lt    ciclo_draw_bala  	// me aseguro de no desbordar y pasar a la fila de abajo de mi pantalla a donde dibujo
		
		mov	x5, #0		// setear contador columna 
		
		add     x0, x0, #1280	// Paso al pinxers que tengo que pintar(osea me desplazo una fila hacia abajo)
		lsl     x6, x2, #2	//x6= obtengo el ancho del marco mio de mi imagen en byte
		sub     x0, x0, x6	// ancho de pantalla -ancho de mi imagen= 1 columna de la fila de abajo

		
		
		add     x4, x4, #1	// Aumento mi contador de fila
		cmp     x4, x3 		// verifico si me mi contador de fila es igual al tamaño de la fila de mi imagen
		b.lt    ciclo_draw_bala   // dibujo la fila en la que estoy 

		mov	x1,x20
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

/*
		// Mover puntero de pantalla al primer pixel donde debe ir la imagen.(lo puedo optimizar)
		adrp	x14, memoria_aux	        //USO VARIABLE AUX
		add	x14, x14, :lo12:memoria_aux     //USO VARIABLE AUX
		*/
		





		

