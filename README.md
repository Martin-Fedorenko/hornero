# utn-game-jam-2026

Prilares principales del videojuego:

Jugabilidad del hornero:
Escenario procedural y elementos
Obstaculos y enemigos

Flujo principal:

La ubicación es aleatoria como la generación del mapa.

Game Loop:
El hornero empieza en la ubicación de donde va a estar la casa.
Empieza a volar.
Desciende al piso o a alguna superficie.
Busca en un arbusto o algo el objeto.
Se eleva con el objeto.
Vuelve a la casa.
Repite.

Jugabilidad del hornero:
Camina por el eje horizontal
Aletea para ganar altitud
Planea
Picotea para buscar 
Construye la casa con "minijuego de baile"
Barra de vida
Estamina
Estados del hornero:
    IDLE
    Caminando
    Aletear
    Volar
    Caer (este solo afecta si el jugador es golpeado en el aire por un enemigo)

Naturaleza del hornero:
Tiene peso y fisicas


Mecanicas de contruccion:
Las mecanicas de construccion se basan en una secuencia de botones que el jugador debe presionar correctamente para terminar la misam finalizar

Requisitos de construccion:
El jugador debe poseer al menos un material necesarios para la construccion (definir materiales)
EL jugador NO debe estar en peligro o siendo atacado durante la busqueda de materiales o construccion del hogar

Consisten de 3 factores:

Construccion Exitosa:Al llegar al hogar, el jugador debe iniciar manualmente la construccion del nido, para ello presiona "X" boton para interactuar con la casa y comienza la secuencia de construccion, basada en piano tiles, consiste en una seerie de flecha que bajan desde laparte superior de la pantalla y el jugador debe coincidir apretar dicha tecla con un indicador visual en la pantalla, si esto coincide, la construccion es exitosa. Esto sucede arriba del personaje principal 

Construccion Fallida: Las mecanicas de construccion no favorables consisten de la misma manerea que la exitosa, la diferencia es que al no coinicidir las teclas oprimidas dentro del circulo, el jugador sale del evento y debera volver a iniciarlo nuevamente, con los rieesgos(enemgios) que eso consiste.

Interrupcion manual: Durante el evento, si el jugador considera algun peligro para el o su hogar, puede cancelar este evento de manera manual para no perjudicar los elementos de construccion o la salud del jugador


Mecanica de Recoleccion:
Al igual que la mecanica de construccion, la misma se basa en los mismos principios que "PianoTiles" siendo el jugador quien deba inicar el evento y presionar de manera correcta el quickTimeEvent. Los escenarios de busqueda son los mismos que la construccion: Exitosa, Fallida y interrupcion manual.

BARRO = El jugador debe ir a estanques de barro para poder recolectar el material de construccion para su nido



ENEMIGOS:
SEEK & DESTROY = El/los enemigos que cumplen esta condicion estan obligados a perseguir al jugador hasta alcanzarlo, el objetivo es que pierda estamina o los materiales(ver casos). En el caso de que el enemigo logre acertar el ataque, el jugador, dependiendo del nivel de estamina, cae al piso y debera recuperarla en caso de ser necesario para volver a tomar vuelo. Siempre que el/los enemigos golpeen al jugador y este tenga objetos encima, los pierde. Si el jugador pierde el objeto en el aire, este puede ser obtenido nuevamente calculando su trayectoria hacia el material antes de alcanzar el suelo.

PAJARO CARPITERO/CHIMANGO = Mientras el jugador no este en el nido/hogar, el pajaro carpintero/chimango puede destruir el nido, esto se vera reflejado con un warning en pantalla, tiempo y un barra de progreso de destruccion de nido, en el cual el jugador debera ir hasta el nido y espantar al enemigo para no perder su avannce  


FELINO: El enemigo se encuentra en el suelo y puede atacar desde el al jugador, tambien tiene la posibilidad de saltar.



