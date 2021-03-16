# Pasapalabra

Pasapalabra es una implementación, totalmente operacional, del juego Pasapalabra o Rosco. El juego permite agregar un jugador, ver lista de jugadores, jugar y salir.

Archivos utilizados: jugadores.dat (cada registro tiene el nombre del jugador y la cantidad de partidas ganadas), palabras.dat (5 Sets o juegos distintos de palabras).

Estructuras dinámicas en memoria: jugadores (árbol con nombre y cantidad de partidas ganadas, ordenado por nombre), partida (arreglo de dos elementos con nombre del jugador y  puntero a lista circular [rosco]), rosco (lista circular con el estado de las respuestas de un jugador).
