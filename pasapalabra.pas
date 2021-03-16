program Pasapalabra;

const   POS_JUGADOR_1   = 1;
        POS_JUGADOR_2   = 2;
        DATOS_JUGADORES = '/ip2/Zalla-Rocio-jugadores.dat';
        DATOS_PALABRAS  = '/ip2/palabras.dat';
        ERROR_CARGA     = 'Ocurrio un error al cargar datos de inicializacion';
        ERROR_INGRESO_JUGADOR = 'Alguno de los jugadores ingresados no es valido';
        ERROR_AGREGADO_JUGADOR = 'El jugador ingresado ya existe';
        ERROR_MENU = 'La opcion ingresada no es valida, intente nuevamente';
        
type    regJugadores = record
            nombre: string;
            partidasGanadas: integer;
        end;
        
        archivoJugadores = file of regJugadores;

        arbol = ^nodoArbol;
        nodoArbol = record 
            nombre: string;
            partidasGanadas: integer;
            izquierda: arbol;
            derecha: arbol;
        end;
        
        listaCircular = ^nodoListaCircular;
        nodoListaCircular = record
            letra: char; 
            palabra: string;
            consigna: string;
            respuesta: (pendiente, acertada, errada);
            siguiente: listaCircular;
        end;
        
        regPartida = record
            nombre: string;
            puntLetra: listaCircular;
        end;
        
        arreglo = array [POS_JUGADOR_1..POS_JUGADOR_2] of regPartida;
        
        regPalabra = record
        	nroSet: integer;
        	letra: char;
        	palabra: string;
        	consigna: string;
        end;
        
        archivoPalabras = file of regPalabra;

{INGRESAR JUGADORES}

{Genera el nodo del jugador en el arbol "jugadores"}
procedure generarJugador(var jugador: arbol; nombre: string; partidasGanadas: integer);
begin
    new(jugador);
    jugador^.nombre := nombre;
    jugador^.partidasGanadas := partidasGanadas;
    jugador^.izquierda := nil;
    jugador^.derecha := nil;
end;

{Carga el nodo del jugador en el arbol "jugadores", ordenado por nombre}
procedure cargarJugador(var jugadores: arbol; nuevoJugador: arbol);
begin
    if (jugadores = nil) then
        jugadores:= nuevoJugador
    else 
        if (jugadores^.nombre < nuevoJugador^.nombre) then 
            cargarJugador(jugadores^.derecha, nuevoJugador)
        else 
            cargarJugador(jugadores^.izquierda, nuevoJugador);
end;

{A partir de los datos del archivo "datosJugadores" (nombres y partidas ganadas por 
cada jugador), crea el árbol "jugadores"}
procedure cargarJugadores(var jugadores: arbol; var datosJugadores: archivoJugadores);
var registroJugador: regJugadores;
    jugador: arbol;
begin
    while (not eof(datosJugadores)) do begin
        read(datosJugadores, registroJugador);
        generarJugador(jugador, registroJugador.nombre, registroJugador.partidasGanadas);  
        cargarJugador(jugadores, jugador);      
    end;
end;

{MENU}

{JUGAR}

{A partir del nombre de un jugador, recorre el arbol "jugadores" y retorna un 
puntero al nodo del jugador buscado}
function jugadorBuscado(jugadores: arbol; nombreJugador: string): arbol; 
begin
    if (jugadores = nil) then 
        jugadorBuscado:= nil
    else 
        if (jugadores^.nombre = nombreJugador) then
            jugadorBuscado:= jugadores
        else 
            if (jugadores^.nombre < nombreJugador) then
                jugadorBuscado := jugadorBuscado(jugadores^.derecha, nombreJugador)
            else
                jugadorBuscado := jugadorBuscado(jugadores^.izquierda, nombreJugador);
end;

{Compara dos jugadores. Si estan en el árbol y son distintos, son validos}
function sonValidos(jugadores: arbol; nombreJugador1, nombreJugador2: string): boolean;
begin
    sonValidos := false;
    if (nombreJugador1 <> nombreJugador2) and (jugadorBuscado(jugadores, nombreJugador1) <> nil) and (jugadorBuscado(jugadores, nombreJugador2) <> nil) then
        sonValidos := true;
end;

{A partir del nombre y la posicion del jugador en el arreglo, genera la partida
con el puntero a la letra en nil}
procedure generarPartida(var partida: arreglo; nombre: string; posicion: integer);
var partidaJugador: regPartida; 
begin
    partidaJugador.nombre := nombre;
    partidaJugador.puntLetra := nil;
    partida[posicion] := partidaJugador;
end;

{Retorna un numero random del 1 al 5, distinto al asignado al jugador anterior}
function numeroSet(var palabras: archivoPalabras; setJugadorAnterior: integer): integer;
begin
    if (setJugadorAnterior = -1) then begin
        randomize; 
        numeroSet := random(5) + 1;
    end else
        numeroSet := ((setJugadorAnterior + 1) mod 5) + 1; {retorno el siguiente al del jugador anterior}
end;

{Retorna el registro inicial a partir del numero de set asignado en el archivo "palabras"}
function inicioSet(var palabras: archivoPalabras; numeroSet: integer): regPalabra;
var inicioSetEncontrado: boolean;
    registroInicioSet, registroPalabra: regPalabra;
begin
    inicioSetEncontrado := false;

    while (not eof(palabras)) and (not inicioSetEncontrado) do begin
        read(palabras, registroPalabra);
        
        if (registroPalabra.nroSet = numeroSet) then begin
            registroInicioSet := registroPalabra;
            inicioSetEncontrado := true;
        end;
    end;

    inicioSet := registroInicioSet;
end;

{Genera el nodo "pregunta" en la lista circular a partir de los datos del registro}
procedure generarPregunta(var pregunta: listaCircular; registro: regPalabra); 
begin
    new(pregunta);
    pregunta^.letra := registro.letra;
    pregunta^.palabra := registro.palabra;
    pregunta^.consigna := registro.consigna;
    pregunta^.respuesta := pendiente;
    pregunta^.siguiente := nil;
end;

{Llama a generarPregunta e inserta los nodos en la lista circular "rosco"}
procedure insertarEnRosco(var rosco: listaCircular; registro: regPalabra);
var cursor, pregunta: listaCircular;
begin
    generarPregunta(pregunta, registro); 

    if (rosco = nil) then begin
        rosco := pregunta;
        rosco^.siguiente := rosco;
    end else begin
        cursor := rosco;
        while (cursor^.siguiente <> rosco) do
            cursor := cursor^.siguiente;
            
        pregunta^.siguiente := cursor^.siguiente; {el primero es cursor^.ste}
        cursor^.siguiente := pregunta; {se agrega al final nuevoNodo}
    end;
end;

{Carga todas las preguntas del set asignado al jugador en su rosco}
procedure cargarRosco(var rosco: listaCircular; numeroSet: integer; var palabras: archivoPalabras);
var primerPreguntaSet, actual: regPalabra;
begin
    reset(palabras);

    primerPreguntaSet := inicioSet(palabras, numeroSet);
    insertarEnRosco(rosco, primerPreguntaSet);
    
    actual := primerPreguntaSet;
    
    while (not eof(palabras)) and (primerPreguntaSet.nroSet = actual.nroSet) do begin
        read(palabras, actual);
        insertarEnRosco(rosco, actual);
    end;

    close(palabras);
end;

{Carga las preguntas que se obtienen del archivo "palabras", todas marcadas 
como [Pendiente] en dos listas circulares apuntadas por el arreglo "partida"}
procedure cargarPreguntas(var partida: arreglo; var palabras: archivoPalabras);
var rosco1, rosco2: listaCircular;
    setJugador1, setJugador2: integer;
begin
    rosco1 := nil;
    rosco2 := nil;
    
    setJugador1 := numeroSet(palabras, -1); {-1 porque no hay un jugador anterior con set asignado}
    setJugador2 := numeroSet(palabras, setJugador1); {numeroSet debe devolver un set distinto al de setJugador1}

    cargarRosco(rosco1, setJugador1, palabras);
    cargarRosco(rosco2, setJugador2, palabras);

    partida[POS_JUGADOR_1].puntLetra := rosco1;
    partida[POS_JUGADOR_2].puntLetra := rosco2;
end;

{Recorre la lista circular "rosco" y retorna TRUE si no quedan preguntas pendientes}
function roscoCompleto(letraActual, rosco: listaCircular): boolean;
begin
    roscoCompleto := true;
    
    while (letraActual^.siguiente <> rosco) and (roscoCompleto) do begin 
        if (letraActual^.respuesta = pendiente) then 
            roscoCompleto := false;

        letraActual := letraActual^.siguiente;
    end;
end;

{Mientras el rosco no este completo, es decir, mientras no haya preguntas pendientes,
avanza hasta la primer palabra sin contestar. Muestra la letra y la consigna y se queda 
esperando el ingreso de la respuesta del jugador.
Si el texto es “pp” quedará la palabra como [Pendiente]. Si no corresponde a la 
palabra se marca [Errada]. En ambos casos, se avanza el puntero a la siguiente 
palabra y se pasa al otro jugador. Si no, se marca [Acertada] y se avanza el 
puntero a la siguiente palabra.}
procedure jugarTurno(var letraActual: listaCircular; rosco: listaCircular; nombreJugador: string);
var respuesta: string;
    puedeSeguir: boolean;
begin
    writeln('Turno del jugador ', nombreJugador);
    writeln('============================================');
    puedeSeguir := true;

    while (puedeSeguir) and (not roscoCompleto(letraActual, rosco)) do begin
        while (letraActual^.respuesta <> pendiente) do
            letraActual := letraActual^.siguiente;
        
        writeln(letraActual^.letra);
        writeln(letraActual^.consigna);
        readln(respuesta);
        
        if (respuesta = letraActual^.palabra) then
            letraActual^.respuesta := acertada
        else if (respuesta = 'pp') then begin
            letraActual := letraActual^.siguiente;
            puedeSeguir := false;
        end else begin
            letraActual^.respuesta := errada;
            letraActual := letraActual^.siguiente;
            puedeSeguir := false;
        end;
    end;
end;

{Recorre la lista circular "rosco" y retorna la cantidad de respuestas acertadas 
de un jugador}
function respuestasAcertadas(rosco: listaCircular): integer;
var respuestaActual: listaCircular;
    contador: integer;
begin
    contador := 0;
    respuestaActual := rosco;
    
    while (respuestaActual^.siguiente <> rosco) do begin 
        if (respuestaActual^.respuesta = acertada) then 
            contador := contador + 1;
            
        respuestaActual := respuestaActual^.siguiente;
    end;
    
    respuestasAcertadas := contador;
end;

{Compara las respuestas acertadas de cada jugador y retorna el nombre del ganador.
Si empatan, se considera que ninguno gano.}
function jugadorGanador(jugador1, jugador2: string; rosco1, rosco2: listaCircular): string;
var aciertosJugador1, aciertosJugador2: integer;
begin
    aciertosJugador1 := respuestasAcertadas(rosco1);
    aciertosJugador2 := respuestasAcertadas(rosco2);
    
    if (aciertosJugador1 > aciertosJugador2) then
        jugadorGanador := jugador1
    else if (aciertosJugador1 < aciertosJugador2) then
        jugadorGanador := jugador2
    else
        jugadorGanador := 'ninguno';
end;

{A partir del nombre de un jugador, recorre el archivo "datosJugadores" y busca
su posicion y registro (al necesitar ambos datos, se utilizo un procedimiento
y no una funcion)}
procedure buscarJugadorEnPersistencia(
    var datosJugadores: archivoJugadores;
    nombreBuscado: string;
    var posicionEncontrado: integer;
    var registroJugadorEncontrado: regJugadores);
begin
    posicionEncontrado := 0;

    read(datosJugadores, registroJugadorEncontrado);

    while not eof(datosJugadores) and (registroJugadorEncontrado.nombre <> nombreBuscado) do begin
        read(datosJugadores, registroJugadorEncontrado);
        posicionEncontrado := posicionEncontrado + 1;
    end;
end;

{Llama a buscarJugadorEnPersistencia y actualiza sus partidas ganadas en el archivo
"datosJugadores", sumando 1. Asumo que el jugador que se actualiza ya existe}
procedure actualizarDatosJugadores(var datosJugadores: archivoJugadores; nombre: string);
var jugador: regJugadores;
    posicion: integer;
begin
    reset(datosJugadores);
    
    buscarJugadorEnPersistencia(
        datosJugadores, nombre, posicion, jugador);
    
    jugador.partidasGanadas := jugador.partidasGanadas + 1;
    
    seek(datosJugadores, posicion);
    write(datosJugadores, jugador);
    
    close(datosJugadores);
end;

{Llama a jugadorBuscado y actualiza sus partidas ganadas en el arbol "jugadores",
sumando 1}
procedure actualizarJugadores(var jugadores: arbol; nombreJugador: string);
var jugadorAActualizar: arbol;
begin
    jugadorAActualizar := jugadorBuscado(jugadores, nombreJugador);
    jugadorAActualizar^.partidasGanadas := jugadorAActualizar^.partidasGanadas + 1;
end;

{Llama a jugadorGanador y, si hubo uno, imprime por pantalla su nombre y actualiza 
sus victorias tanto en el archivo "datosJugadores" como en el arbol "jugadores".
Si no, imprime que ha habido un empate.}
procedure procesarGanador(
    var datosJugadores: archivoJugadores; 
    var jugadores: arbol;
    jugador1, jugador2: regPartida;
    rosco1, rosco2: listaCircular);
var ganador: string;
begin
    ganador := jugadorGanador(jugador1.nombre, jugador2.nombre, rosco1, rosco2); 
    
    if (ganador <> 'ninguno') then begin
        writeln('El ganador del rosco es ', ganador);
        actualizarDatosJugadores(datosJugadores, ganador);
        actualizarJugadores(jugadores, ganador);
    end else
        writeln('Ha habido un empate');
end;

{Comienza el juego. Se verifica que aún tiene palabras sin contestar, si no termina 
la partida. Juega el primer jugador. Si, cuando termina, no completo el rosco, 
juega el segundo jugador y visceversa. Cuando se sale del ciclo se terminó la 
partida y se llama a procesarGanador.}
procedure comenzarJuego(var partida: arreglo; var jugadores: arbol; var datosJugadores: archivoJugadores);
var juegoFinalizado: boolean;
    jugador1, jugador2: regPartida;
    rosco1, rosco2, cursorRosco1, cursorRosco2: listaCircular;
begin
    juegoFinalizado := false;

    jugador1 := partida[POS_JUGADOR_1];
    jugador2 := partida[POS_JUGADOR_2];

    rosco1 := jugador1.puntLetra;
    rosco2 := jugador2.puntLetra;
    
    cursorRosco1 := rosco1; 
    cursorRosco2 := rosco2;
    
    while (not juegoFinalizado) do begin
        jugarTurno(cursorRosco1, rosco1, jugador1.nombre); {jugador 1} 
        juegoFinalizado := roscoCompleto(cursorRosco1, rosco1);
        
        if (not juegoFinalizado) then begin
            jugarTurno(cursorRosco2, rosco2, jugador2.nombre); {jugador 2}
            juegoFinalizado := roscoCompleto(cursorRosco2, rosco2);
        end;
    end;
    
    procesarGanador(datosJugadores, jugadores, jugador1, jugador2, rosco1, rosco2);
end;


{Pide el nombre de dos jugadores. Si son validos, llama a generarPartida, cargarPreguntas
y comenzarJuego. Si no, imprime que alguno de los jugadores no es valido.}
procedure jugar(var jugadores: arbol; var datosJugadores: archivoJugadores; var palabras: archivoPalabras; var partida: arreglo);
var nombreJugador1, nombreJugador2: string;
begin
    writeln('Ingrese el nombre del/de la participante numero 1:');
    readln(nombreJugador1);
    writeln('Ingrese el nombre del/de la participante numero 2:');
    readln(nombreJugador2);

    if (sonValidos(jugadores, nombreJugador1, nombreJugador2)) then begin
        generarPartida(partida, nombreJugador1, POS_JUGADOR_1); 
        generarPartida(partida, nombreJugador2, POS_JUGADOR_2);
        cargarPreguntas(partida, palabras);
        comenzarJuego(partida, jugadores, datosJugadores);
    end else
        writeln(ERROR_INGRESO_JUGADOR);
end;

{VER LISTA JUGADORES}

{A partir del recorrido in-order del árbol "jugadores", muestra todos los existentes 
con la cantidad de partidas ganadas por cada uno.}
procedure verListaJugadores(jugadores: arbol);
begin
    if (jugadores <> nil) then begin
        verListaJugadores(jugadores^.izquierda); 
        writeln('  - Jugador: ', jugadores^.nombre);
        writeln('  - Partidas ganadas: ', jugadores^.partidasGanadas); 
        writeln('  ____________________________________');
        verListaJugadores(jugadores^.derecha);
    end;
end;

{AGREGAR JUGADOR}

{A partir del nombre de un jugador, llama a generarJugador y cargarJugador,
agregandolo ordenado al arbol "jugadores". En principio, sus partidas ganadas son 0}
procedure agregarAJugadores(var jugadores: arbol; nombreJugador: string);
var jugador: arbol;
begin
    generarJugador(jugador, nombreJugador, 0);
    cargarJugador(jugadores, jugador);
end;

{A partir del nombre de un jugador, lo agrega al final del archivo "datosJugadores".
En principio, sus partidas ganadas son 0}
procedure agregarADatosJugadores(var datosJugadores: archivoJugadores; nombreJugador: string);
var registroJugador: regJugadores;
begin
    reset(datosJugadores);

    seek(datosJugadores, fileSize(datosJugadores));
    
    registroJugador.nombre := nombreJugador;
    registroJugador.partidasGanadas := 0;
    write(datosJugadores, registroJugador);

    close(datosJugadores);
end;

{Pide el nombre del jugador y verifica que el nombre no exista en el árbol "jugadores". 
Si existe, avisa y no permite su agregado. Si no existe, lo agrega en el árbol 
"jugadores" y al final del archivo "datosJugadores"}
procedure agregarJugador(var jugadores: arbol; var datosJugadores: archivoJugadores);
var nuevoJugador: string;
    jugador: arbol;
begin
    writeln('Ingrese su nombre: ');
    readln(nuevoJugador);
    jugador := jugadorBuscado(jugadores, nuevoJugador);

    if (jugador = nil) then begin
        agregarAJugadores(jugadores, nuevoJugador);
        agregarADatosJugadores(datosJugadores, nuevoJugador);
    end else 
        writeln(ERROR_AGREGADO_JUGADOR);
end;

{Mientras el usuario no decida salir del juego, muestra el menu, espera que ingrese 
una opcion y llama al modulo correspondiente. Si la opcion no es valida, imprime 
un error}
procedure menu(var datosJugadores: archivoJugadores; var palabras: archivoPalabras; var jugadores: arbol; var partida: arreglo);
var opcion: char;
    finalizado: boolean;
    titulo: string;
begin
    titulo := 'PALAPASABRA';
    finalizado := false;
    
    writeln(titulo);

    while not finalizado do begin
        writeln('1. Agregar jugador');
        writeln('2. Ver lista de jugadores');
        writeln('3. Jugar');
        writeln('4. Salir');
        
        finalizado := false;
        
        readln(opcion);
        
        case opcion of
            '1': agregarJugador(jugadores, datosJugadores);
            '2': verListaJugadores(jugadores);
            '3': jugar(jugadores, datosJugadores, palabras, partida);
            '4': begin
                    finalizado := true;
                    write('El juego ha finalizado');
                end
            else writeln(ERROR_MENU);
        end;
    end;
end;

{INICIALIZAR JUEGO}

{Verifica que "datosJugadores" se abra correctamente, es decir, que exista el archivo}
procedure abrirDatosJugadores(var datosJugadores: archivoJugadores; var cargaCorrecta: boolean);
begin
	cargaCorrecta := true;
	assign(datosJugadores, DATOS_JUGADORES);
	{$I-} {Desactiva la verificación de errores de entrada/salida (en tiempo de ejecución)}
		reset(datosJugadores); {Se intentar abrir el archivo "datosJugadores"}
	{$I+} {Se activa la verificación de errores}
	if (ioResult <> 0) then {ioResult devuelve 0 si la operacion tuvo exito y <> 0 si hubo algún error}
		cargaCorrecta := false;
end;

{Verifica que "datasetPalabras" se abra correctamente, es decir, que exista el archivo}
procedure abrirDatasetPalabras(var datasetPalabras: archivoPalabras; var cargaCorrecta: boolean);
begin
	cargaCorrecta := true;
	assign(datasetPalabras, DATOS_PALABRAS);
	{$I-}
		reset(datasetPalabras);
	{$I+}	
	if (ioResult <> 0) then
		cargaCorrecta := false;
end;

{Llama a abrirDatosJugadores y abrirDatasetPAlabras para chequear que los archivos existan. 
Si la carga de datosJugadores es correcta, llama a cargarJugadores, que 
cargará los jugadores del archivo en el arbol "jugadores". 
Si ambas son correctas, cargaCorrecta es TRUE}
procedure inicializarJuego(
    var datosJugadores: archivoJugadores;
    var palabras: archivoPalabras;
    var jugadores: arbol;
    var cargaCorrecta: boolean);
var cargaDatosJugadoresCorrecta, cargaDatasetPalabrasCorrecta: boolean;
begin
    abrirDatosJugadores(datosJugadores, cargaDatosJugadoresCorrecta);
    abrirDatasetPalabras(palabras, cargaDatasetPalabrasCorrecta);

    if (cargaDatosJugadoresCorrecta) then
        cargarJugadores(jugadores, datosJugadores); 
        
    close(palabras);
    close(datosJugadores);

    cargaCorrecta := cargaDatosJugadoresCorrecta and cargaDatasetPalabrasCorrecta;
end;

var datosJugadores: archivoJugadores;
    jugadores: arbol;
    palabras: archivoPalabras;
    partida: arreglo;
    cargaCorrecta: boolean;
    
begin
    inicializarJuego(datosJugadores, palabras, jugadores, cargaCorrecta); 

    {Si la carga de los archivos es correcta, muestra el menu e inicia el juego}
    if (cargaCorrecta) then 
        menu(datosJugadores, palabras, jugadores, partida)
    else
        writeLn(ERROR_CARGA);
end.
