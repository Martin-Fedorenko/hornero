extends RefCounted
## Todos los textos que se ven en el juego, en español (Argentina) y en inglés
## (Estados Unidos). El autoload "Idioma" (scripts/idioma.gd) arma con esto las
## traducciones de Godot.
##
## Para agregar o cambiar un texto: se edita acá y en el código se usa la
## clave. Un Label, Button o RichTextLabel cuyo `text` sea una clave se
## traduce solo y se actualiza al cambiar de idioma; para textos armados en
## código (con %s, por ejemplo) se usa Idioma.t("CLAVE") o tr("CLAVE").
##
## Los textos con %s / %d se completan desde el código. Los {ENTRE_LLAVES} de
## AYUDA los completa texto_ayuda() en menu_inicio.gd según el dispositivo
## (teclado o pantalla táctil) y el timón elegido.

const TEXTOS := {
	# --- Menú principal ------------------------------------------------------
	"MENU_JUGAR": {"es": "JUGAR", "en": "PLAY"},
	"MENU_COMO_JUGAR": {"es": "CÓMO JUGAR", "en": "HOW TO PLAY"},
	"MENU_HISTORIA": {"es": "HISTORIA", "en": "STORY"},
	"MENU_ESTADISTICAS": {"es": "ESTADÍSTICAS", "en": "STATS"},
	"MENU_CONFIGURACION": {"es": "CONFIGURACIÓN", "en": "SETTINGS"},
	"MENU_CREDITOS": {"es": "CRÉDITOS", "en": "CREDITS"},
	"MENU_SALIR": {"es": "SALIR", "en": "QUIT"},
	"MENU_VOLVER": {"es": "Volver", "en": "Back"},
	"TOOLTIP_SILENCIAR": {"es": "Silenciar / activar el sonido", "en": "Mute / unmute sound"},
	"TOOLTIP_IDIOMA": {"es": "Cambiar idioma (español / inglés)", "en": "Change language (Spanish / English)"},
	"ERROR_INICIAR_TITULO": {"es": "No se pudo iniciar", "en": "Couldn't start the game"},
	"ERROR_INICIAR_TEXTO": {"es": "La escena de juego todavía no está disponible.", "en": "The game scene isn't available yet."},

	# --- Títulos de las ventanas del menú ------------------------------------
	"TITULO_COMO_JUGAR": {"es": "Cómo jugar", "en": "How to Play"},
	"TITULO_HISTORIA": {"es": "Historia", "en": "Story"},
	"TITULO_FAUNA": {"es": "Fauna", "en": "Wildlife"},
	"TITULO_ESTADISTICAS": {"es": "Estadísticas", "en": "Stats"},
	"TITULO_CONFIGURACION": {"es": "Configuración", "en": "Settings"},
	"TITULO_CREDITOS": {"es": "Créditos", "en": "Credits"},

	# --- Botones comunes -----------------------------------------------------
	"CERRAR": {"es": "Cerrar", "en": "Close"},
	"ACEPTAR": {"es": "Aceptar", "en": "Accept"},
	"CANCELAR": {"es": "Cancelar", "en": "Cancel"},

	# --- Créditos ------------------------------------------------------------
	"CREDITOS": {
		"es": """
[b][color=#f8dc9c]DIRECCIÓN DE IMAGEN, SONIDO, AMBIENTE Y DESARROLLO[/color][/b]
Ingeniero Fedorenko Martin · Villadeza Eric · Brian Moulia

[b][color=#f8dc9c]MOTOR[/color][/b]
Godot Engine

[b][color=#f8dc9c]AGRADECIMIENTOS[/color][/b]
A nuestras novias: la Magíster Cyntia V, la Ingeniera Abril C y la Ingeniera Arabella B.

Al maestro Gustavo Santaolalla, por crear una obra maestra como "De Ushuaia a La Quiaca". Y perdón por tomarnos el atrevimiento de sumarle el noble cantar del hornero a su pieza.

A la Universidad Tecnológica Nacional, Facultad Regional Buenos Aires, por formarnos como profesionales.

Y sin dudas, a nuestros padres y familia.

No queremos dejar de agradecer al noble Hornero, nuestra fuente de inspiración.""",
		"en": """
[b][color=#f8dc9c]ART, SOUND, ENVIRONMENT AND DEVELOPMENT[/color][/b]
Engineer Fedorenko Martin · Villadeza Eric · Brian Moulia

[b][color=#f8dc9c]ENGINE[/color][/b]
Godot Engine

[b][color=#f8dc9c]ACKNOWLEDGMENTS[/color][/b]
To our girlfriends: Cyntia V (MSc), Engineer Abril C and Engineer Arabella B.

To maestro Gustavo Santaolalla, for creating a masterpiece like "De Ushuaia a La Quiaca". And our apologies for taking the liberty of adding the noble song of the hornero to his piece.

To the Universidad Tecnológica Nacional, Facultad Regional Buenos Aires, for shaping us as professionals.

And of course, to our parents and families.

We can't leave out the noble Hornero, our source of inspiration.""",
	},

	# --- Cómo jugar ----------------------------------------------------------
	"AYUDA": {
		"es": """[b][color=#f8dc9c]OBJETIVO[/color][/b]
Juntá paja, ramitas, piedras y barro y llevalos a tu nido: cada material le suma una etapa. Cuando esté terminado, entrá con {NIDO} para ganar. Si el nido queda fuera de pantalla, una flecha te marca dónde está.
Arriba a la derecha corre el tiempo de la partida: al ganar te muestra cuánto tardaste.

[b][color=#f8dc9c]DIFICULTAD[/color][/b] (se elige en Configuración)
[b]Fácil[/b]: Perfecto para horneros principiantes.
[b]Difícil[/b]: Solo para veteranos de la Pampa.

[b][color=#f8dc9c]VUELO[/color][/b]
{ALETEAR}: aletear. Cada aletazo te empuja hacia donde apunta el pico (y un poco hacia arriba) y gasta stamina. Desde el piso, despega.
{ARRIBA}: {ACCION_ARRIBA}.   {ABAJO}: {ACCION_ABAJO}. {NOTA_TIMON}
{GIRAR}: darte vuelta en el aire.
Cuando no aleteás, planeás: la gravedad siempre tira para abajo y las alas convierten esa caída en avance.
Picar con el pico hacia abajo te hace ganar velocidad; subir el pico cambia esa velocidad por altura.
Si subís el pico demasiado y vas lento, perdés sustentación: el pico se cae y bajás en picada hasta recuperar velocidad.
Podés dar loops: si quedás panza arriba, el hornero rueda solo para enderezarse.

[b][color=#f8dc9c]EN EL PISO[/color][/b]
{GIRAR}: caminar.   {ALETEAR}: despegar.
En el piso la stamina se recupera rápido; planeando, de a poco.

[b][color=#f8dc9c]{TITULO_PICO}[/color][/b]
Cerca de un material, {PICO} lo levanta con el pico. Con algo en el pico, {PICO} lo suelta.
Para entregarlo, soltalo sobre el nido o pasá volando por encima con él.
Algunos árboles tienen ramitas apoyadas en las ramas: agarralas con {PICO} al pasar volando.
Cada tanto aparecen bichos en las hojas y los troncos de los árboles. Se comen pasando por encima: devuelven vida y stamina.

[b][color=#f8dc9c]{TITULO_NIDO}[/color][/b]
Dentro del círculo del nido, {NIDO} te mete adentro; otra vez {NIDO} te saca.
Adentro recuperás vida y stamina lentamente.
Con el nido techado quedás a salvo: ningún depredador te puede atacar.

[b][color=#f8dc9c]PELIGROS[/color][/b]
[b]Chimango, aguilucho y carancho[/b] atacan desde el aire. Si te agarran, apretá {ALETEAR} varias veces para soltarte; si te sueltan, caés aturdido y perdés vida y stamina.
[b]Gato montés[/b]: acecha en el piso y salta si volás bajo cerca de él.
[b]Cotorra[/b]: pica tu nido y, si la dejás 15 segundos, le rompe una etapa y se va. Acercate para espantarla: si se va antes, no rompe nada.

{PAUSA}""",
		"en": """[b][color=#f8dc9c]GOAL[/color][/b]
Gather straw, twigs, stones and mud and bring them to your nest: each material adds a stage. When it's finished, go inside with {NIDO} to win. If the nest is off-screen, an arrow shows you where it is.
The game timer runs in the top-right corner: when you win, it shows how long you took.

[b][color=#f8dc9c]DIFFICULTY[/color][/b] (chosen in Settings)
[b]Easy[/b]: Perfect for beginner horneros.
[b]Hard[/b]: Only for veterans of the Pampas.

[b][color=#f8dc9c]FLIGHT[/color][/b]
{ALETEAR}: flap. Each flap pushes you where your beak is pointing (and a little upward) and uses stamina. On the ground, it takes off.
{ARRIBA}: {ACCION_ARRIBA}.   {ABAJO}: {ACCION_ABAJO}. {NOTA_TIMON}
{GIRAR}: turn around in the air.
When you're not flapping, you glide: gravity always pulls you down and your wings turn that fall into forward motion.
Diving with your beak down makes you gain speed; raising your beak trades that speed for altitude.
If you raise your beak too much while flying slowly, you stall: your beak drops and you nosedive until you regain speed.
You can do loops: if you end up belly-up, the hornero rolls over on its own to right itself.

[b][color=#f8dc9c]ON THE GROUND[/color][/b]
{GIRAR}: walk.   {ALETEAR}: take off.
On the ground your stamina recovers quickly; while gliding, slowly.

[b][color=#f8dc9c]{TITULO_PICO}[/color][/b]
Near a material, {PICO} picks it up with your beak. With something in your beak, {PICO} drops it.
To deliver it, drop it on the nest or fly over the nest while carrying it.
Some trees have twigs resting on their branches: grab them with {PICO} as you fly by.
Every now and then bugs show up on tree leaves and trunks. Eat them by flying over them: they restore health and stamina.

[b][color=#f8dc9c]{TITULO_NIDO}[/color][/b]
Inside the nest's circle, {NIDO} takes you inside; press {NIDO} again to get out.
Inside, you slowly recover health and stamina.
Once the nest has a roof, you're safe: no predator can attack you.

[b][color=#f8dc9c]DANGERS[/color][/b]
[b]Chimango caracara, variable hawk and crested caracara[/b] attack from the air. If one grabs you, press {ALETEAR} repeatedly to break free; if it drops you, you fall stunned and lose health and stamina.
[b]Geoffroy's cat[/b]: lurks on the ground and pounces if you fly low near it.
[b]Monk parakeet[/b]: pecks at your nest and, if you leave it alone for 15 seconds, it breaks one stage and flies off. Get close to scare it away: if it leaves early, it breaks nothing.

{PAUSA}""",
	},
	"AYUDA_TACTIL_INTRO": {
		"es": """[b][color=#f8dc9c]CONTROLES EN PANTALLA[/color][/b]
Pulgar derecho: la [b]palanca[/b] para caminar y dirigir el vuelo.
Pulgar izquierdo: [b]ALETEAR[/b], [b]PICO[/b] (agarrar y soltar) y [b]NIDO[/b] (entrar y salir).
Podés apretar varios botones a la vez.

""",
		"en": """[b][color=#f8dc9c]ON-SCREEN CONTROLS[/color][/b]
Right thumb: the [b]stick[/b] to walk and steer your flight.
Left thumb: [b]FLAP[/b], [b]BEAK[/b] (pick up and drop) and [b]NEST[/b] (go in and out).
You can press several buttons at once.

""",
	},
	# Lo que completa los {ENTRE_LLAVES} de AYUDA.
	"AYUDA_ALETEAR_TECLA": {"es": "[b]Espacio[/b]", "en": "[b]Space[/b]"},
	"AYUDA_ARRIBA_TACTIL": {"es": "[b]Palanca ↑[/b]", "en": "[b]Stick ↑[/b]"},
	"AYUDA_ABAJO_TACTIL": {"es": "[b]Palanca ↓[/b]", "en": "[b]Stick ↓[/b]"},
	"AYUDA_GIRAR_TECLA": {"es": "[b]A / D[/b] o [b]← / →[/b]", "en": "[b]A / D[/b] or [b]← / →[/b]"},
	"AYUDA_GIRAR_TACTIL": {"es": "[b]Palanca ← / →[/b]", "en": "[b]Stick ← / →[/b]"},
	"AYUDA_BAJAR_PICO": {"es": "bajar el pico", "en": "tilt your beak down"},
	"AYUDA_SUBIR_PICO": {"es": "subir el pico", "en": "tilt your beak up"},
	"AYUDA_NOTA_AVION": {"es": "Funciona como el timón de un avión.", "en": "It works like an airplane's control stick."},
	"AYUDA_NOTA_DIRECTO": {"es": "Timón directo: se cambia en Configuración.", "en": "Direct controls: you can change this in Settings."},
	"AYUDA_PAUSA_TECLA": {"es": "[b]Esc[/b]: pausa.   [b]R[/b]: reiniciar la partida.", "en": "[b]Esc[/b]: pause.   [b]R[/b]: restart the game."},
	"AYUDA_PAUSA_TACTIL": {"es": "[b]Pausa[/b] (arriba, al centro): desde ahí también podés reiniciar la partida.", "en": "[b]Pause[/b] (top center): from there you can also restart the game."},

	# --- Botones en pantalla (celulares) -------------------------------------
	"TACTIL_ALETEAR": {"es": "ALETEAR", "en": "FLAP"},
	"TACTIL_PICO": {"es": "PICO", "en": "BEAK"},
	"TACTIL_NIDO": {"es": "NIDO", "en": "NEST"},
	"GIRAR_TELEFONO": {"es": "Girá el teléfono\npara jugar", "en": "Rotate your phone\nto play"},

	# --- Historia ------------------------------------------------------------
	"HISTORIA": {
		"es": """[b][color=#f8dc9c]EL PRIMER INGENIERO ARGENTINO[/color][/b]

Cuentan los libros que el primer ingeniero argentino fue Luis Huergo, el que se recibió allá por 1870 y soñó puertos, canales y vías de tren.

Pero los libros no lo saben todo.

Mucho antes de que existieran las universidades, los planos y las reglas de cálculo, en la pampa ya trabajaba otro ingeniero. No tenía título ni diploma, pero tenía un pico firme, alas incansables y un saber que pasaba de padres a hijos. Era un hornero, y en el monte todos lo conocían como [b]Huergo[/b].

Huergo sabía cosas que ningún libro le había enseñado: que el barro tiene que estar húmedo pero no aguado, que la paja y las ramitas lo hacen fuerte como el adobe, que las piedras le dan base, y que la puerta del nido tiene que mirar para el lado contrario al viento. Así, pellada a pellada, levantaba casas de barro que aguantaban tormentas, soles y años enteros.

Pero ser ingeniero en la pampa no es fácil. El chimango, el aguilucho y el carancho vigilan desde el cielo; el gato montés acecha entre los pastos; y la cotorra, envidiosa, viene a picotear la obra ajena.

Ahora te toca a vos ayudar a Huergo: juntá los materiales, esquivá a los que quieren arruinarle el día y terminá el nido antes de que sea tarde.

[i]Moraleja: antes de que el hombre aprendiera a construir, el hornero ya era ingeniero. Y lo sigue siendo, en cada poste y en cada árbol de nuestra tierra.[/i]""",
		"en": """[b][color=#f8dc9c]THE FIRST ARGENTINE ENGINEER[/color][/b]

The history books say the first Argentine engineer was Luis Huergo, who graduated back around 1870 and dreamed up ports, canals and railroads.

But books don't know everything.

Long before there were universities, blueprints or slide rules, another engineer was already at work on the Pampas. He had no degree or diploma, but he had a steady beak, tireless wings and know-how passed down from parents to children. He was a hornero, and everyone in the woods knew him as [b]Huergo[/b].

Huergo knew things no book had ever taught him: that mud has to be moist but not runny, that straw and twigs make it as strong as adobe, that stones give it a solid base, and that the nest's door has to face away from the wind. And so, beakful by beakful, he raised mud houses that withstood storms, scorching suns and years on end.

But being an engineer on the Pampas isn't easy. The chimango, the hawk and the caracara keep watch from the sky; the wild cat lurks in the grass; and the envious parakeet comes to peck at other birds' work.

Now it's your turn to help Huergo: gather the materials, dodge those who want to ruin his day, and finish the nest before it's too late.

[i]Moral: before humans learned to build, the hornero was already an engineer. And he still is, on every post and in every tree of our land.[/i]""",
	},

	# --- Estadísticas --------------------------------------------------------
	"PESTANA_PERSONAL": {"es": "Personal", "en": "Personal"},
	"PESTANA_GLOBAL": {"es": "Global", "en": "Global"},
	"PESTANA_RANKING_FACIL": {"es": "Ranking Fácil", "en": "Easy Ranking"},
	"PESTANA_RANKING_DIFICIL": {"es": "Ranking Difícil", "en": "Hard Ranking"},
	"ESTAD_TITULO_PERSONAL": {"es": "Tus partidas", "en": "Your games"},
	"ESTAD_TITULO_GLOBAL": {"es": "Todos los horneros", "en": "All horneros"},
	"ESTAD_TITULO_RANKING_FACIL": {"es": "Ranking Global · Fácil", "en": "Global Leaderboard · Easy"},
	"ESTAD_TITULO_RANKING_DIFICIL": {"es": "Ranking Global · Difícil", "en": "Global Leaderboard · Hard"},
	"ESTAD_CARGANDO": {"es": "Cargando…", "en": "Loading…"},
	"ESTAD_JUGANDO_COMO": {"es": "Jugando como %s", "en": "Playing as %s"},
	"ESTAD_JUGANDO_SIN_CONEXION": {"es": "Jugando como %s · sin conexión, tus partidas no se guardan", "en": "Playing as %s · offline, your games aren't saved"},
	"ESTAD_MODO_INCOGNITO": {"es": "Modo incógnito · tus partidas no se guardan", "en": "Incognito mode · your games aren't saved"},
	"ESTAD_NOMBRE_TEMPORAL": {"es": "Elegiste tu nombre sin conexión: estas partidas no se guardan. La próxima vez que abras el juego vas a poder elegir un nombre de nuevo.", "en": "You chose your name while offline: these games aren't saved. Next time you open the game you'll be able to choose a name again."},
	"ESTAD_INCOGNITO": {"es": "Estás jugando en modo incógnito: tus estadísticas no se guardan.", "en": "You're playing in incognito mode: your stats aren't saved."},
	"ESTAD_SIN_CONEXION": {"es": "No se pudo conectar con el servidor. Probá de nuevo más tarde.", "en": "Couldn't connect to the server. Please try again later."},
	"ESTAD_RANKING_VACIO": {"es": "Todavía nadie terminó un nido en esta dificultad.", "en": "Nobody has finished a nest on this difficulty yet."},
	"ESTAD_NIDOS": {"es": "Nidos construidos", "en": "Nests built"},
	"ESTAD_MUERTES": {"es": "Muertes", "en": "Deaths"},
	"ESTAD_MEJOR_FACIL": {"es": "Mejor tiempo fácil", "en": "Best time (Easy)"},
	"ESTAD_MEJOR_DIFICIL": {"es": "Mejor tiempo difícil", "en": "Best time (Hard)"},
	"RANKING_NOMBRE": {"es": "Nombre", "en": "Name"},
	"RANKING_TIEMPO": {"es": "Tiempo", "en": "Time"},
	"RANKING_VOS": {"es": " (vos)", "en": " (you)"},
	"ESTAD_BORRAR": {"es": "Borrar estadísticas", "en": "Delete stats"},
	"ESTAD_CREAR_NOMBRE": {"es": "Crear nombre", "en": "Create name"},
	"ESTAD_BORRAR_CONFIRMACION": {"es": "Se borran tu nombre, tus nidos construidos, tus muertes y tus tiempos de los rankings. Las estadísticas globales no cambian. No se puede deshacer.", "en": "This deletes your name, your nests built, your deaths and your leaderboard times. Global stats don't change. This can't be undone."},
	"ESTAD_BORRANDO": {"es": "Borrando tus estadísticas…", "en": "Deleting your stats…"},
	"ESTAD_BORRADAS": {"es": "Tus datos se borraron. Ahora estás en modo incógnito.", "en": "Your data was deleted. You're now in incognito mode."},
	"ESTAD_BORRAR_ERROR": {"es": "No fue posible borrar tus estadísticas. Revisá tu conexión a internet.", "en": "Couldn't delete your stats. Check your internet connection."},

	# --- Configuración -------------------------------------------------------
	"CONFIG_PANTALLA": {"es": "Pantalla", "en": "Display"},
	"CONFIG_COMPLETA": {"es": "Completa", "en": "Fullscreen"},
	"CONFIG_VENTANA": {"es": "Ventana", "en": "Windowed"},
	"CONFIG_FPS": {"es": "FPS en la partida", "en": "In-game FPS"},
	"CONFIG_MOSTRAR": {"es": "Mostrar", "en": "Show"},
	"CONFIG_OCULTAR": {"es": "Ocultar", "en": "Hide"},
	"CONFIG_DIFICULTAD": {"es": "Dificultad", "en": "Difficulty"},
	"CONFIG_FACIL": {"es": "Fácil", "en": "Easy"},
	"CONFIG_DIFICIL": {"es": "Difícil", "en": "Hard"},
	"CONFIG_FACIL_DETALLE": {"es": "[b][color=#f8dc9c]Fácil:[/color][/b] Perfecto para horneros principiantes.", "en": "[b][color=#f8dc9c]Easy:[/color][/b] Perfect for beginner horneros."},
	"CONFIG_DIFICIL_DETALLE": {"es": "[b][color=#f8dc9c]Difícil:[/color][/b] Solo para veteranos de la Pampa.", "en": "[b][color=#f8dc9c]Hard:[/color][/b] Only for veterans of the Pampas."},
	"CONFIG_TIMON": {"es": "Timón de vuelo", "en": "Flight controls"},
	"CONFIG_AVION": {"es": "Avión", "en": "Airplane"},
	"CONFIG_DIRECTO": {"es": "Directo", "en": "Direct"},
	"CONFIG_AVION_DETALLE": {"es": "[b][color=#f8dc9c]Avión:[/color][/b] arriba baja el pico y abajo lo sube, como la palanca de un avión.", "en": "[b][color=#f8dc9c]Airplane:[/color][/b] up tilts the beak down and down tilts it up, like an airplane's control stick."},
	"CONFIG_DIRECTO_DETALLE": {"es": "[b][color=#f8dc9c]Directo:[/color][/b] arriba sube el pico y abajo lo baja.", "en": "[b][color=#f8dc9c]Direct:[/color][/b] up tilts the beak up and down tilts it down."},

	# --- Nombre de jugador ---------------------------------------------------
	"NOMBRE_TITULO": {"es": "Nombre de jugador", "en": "Player name"},
	"NOMBRE_DETALLE": {"es": "Así vas a aparecer en los rankings.", "en": "This is how you'll appear on the leaderboards."},
	"NOMBRE_PLACEHOLDER": {"es": "Tu nombre", "en": "Your name"},
	"NOMBRE_RECHAZAR": {"es": "Rechazar", "en": "Decline"},
	"NOMBRE_AVISO": {"es": "Si rechazás, jugás en modo incógnito: no se guardan tus estadísticas, pero podés ver los rankings.", "en": "If you decline, you'll play in incognito mode: your stats won't be saved, but you can still see the leaderboards."},
	"NOMBRE_COMPROBANDO": {"es": "Comprobando...", "en": "Checking..."},
	"NOMBRE_ERROR_VACIO": {"es": "Escribí un nombre.", "en": "Enter a name."},
	"NOMBRE_ERROR_LARGO": {"es": "Máximo %d caracteres.", "en": "%d characters max."},
	"NOMBRE_ERROR_OCUPADO": {"es": "Ese nombre ya está en uso. Elegí otro.", "en": "That name is already taken. Choose another one."},

	# --- Partida -------------------------------------------------------------
	"CARGANDO": {"es": "Cargando...", "en": "Loading..."},
	"AVISO_AGARRAR": {"es": "%s para agarrar", "en": "%s to pick up"},
	"AVISO_ENTRAR_NIDO": {"es": "%s para entrar", "en": "%s to go in"},
	"AVISO_SALIR_NIDO": {"es": "%s para salir", "en": "%s to get out"},
	"JUEGO_PAUSA": {"es": "PAUSA", "en": "PAUSED"},
	"JUEGO_FALLASTE": {"es": "HAS FALLADO", "en": "YOU FAILED"},
	"JUEGO_GANASTE": {"es": "¡HAS GANADO!", "en": "YOU WIN!"},
	"JUEGO_CONTINUAR": {"es": "Continuar", "en": "Resume"},
	"JUEGO_REINICIAR": {"es": "Reiniciar", "en": "Restart"},
	"JUEGO_VOLVER_A_JUGAR": {"es": "Volver a jugar", "en": "Play again"},
	"JUEGO_SALIR_MENU": {"es": "Salir al menú", "en": "Quit to menu"},
	"JUEGO_SALIR_ESCRITORIO": {"es": "Salir al escritorio", "en": "Quit to desktop"},
	"JUEGO_SALIR_JUEGO": {"es": "Salir del juego", "en": "Quit game"},
	"JUEGO_TU_TIEMPO": {"es": "Tu tiempo: %s", "en": "Your time: %s"},
	"JUEGO_SIN_CONEXION": {"es": "Sin conexión: tu resultado se va a subir\ncuando vuelva internet.", "en": "Offline: your result will be uploaded\nwhen you're back online."},

	# --- Fauna: ventana de detalle -------------------------------------------
	"FAUNA_DISTRIBUCION": {"es": "Distribución en Sudamérica", "en": "Range in South America"},
	"FAUNA_NOTA_MAPA": {"es": "Rojo: distribución aproximada. Esquema, no avistamientos puntuales.", "en": "Red: approximate range. A sketch, not specific sightings."},
	"FAUNA_PROXIMAMENTE": {"es": "PRÓXIMAMENTE", "en": "COMING SOON"},
	"FAUNA_PRONTO": {"es": "[i]Todavía no aparece en el juego. Pronto vas a poder encontrarlo en la Pampa.[/i]", "en": "[i]It isn't in the game yet. Soon you'll be able to find it on the Pampas.[/i]"},
	"FAUNA_DONDE_VIVE": {"es": "Dónde vive:", "en": "Where it lives:"},
	"FAUNA_PELIGRO": {"es": "¿Peligro de extinción?", "en": "Endangered?"},
	"FAUNA_PRESIONES": {"es": "Presiones humanas:", "en": "Human pressures:"},
	"FAUNA_COME": {"es": "Qué come:", "en": "What it eats:"},
	"FAUNA_RELACION": {"es": "Relación con el hornero:", "en": "Relationship with the hornero:"},

	# --- Fauna: fichas de cada animal ----------------------------------------
	"FAUNA_HORNERO_NOMBRE": {"es": "Hornero", "en": "Rufous Hornero"},
	"FAUNA_HORNERO_HABITAT": {"es": "Centro y norte de Argentina, Uruguay, Paraguay, Bolivia y sur de Brasil. Vive en campos, pastizales, plazas y ciudades. Es el Ave Nacional de la Argentina.", "en": "Central and northern Argentina, Uruguay, Paraguay, Bolivia and southern Brazil. It lives in fields, grasslands, plazas and cities. It is Argentina's National Bird."},
	"FAUNA_HORNERO_DESCRIPCION": {"es": "Ave caminadora que construye un nido cerrado de barro con una cámara para los huevos.", "en": "A ground-walking bird that builds a closed mud nest with a chamber for its eggs."},
	"FAUNA_HORNERO_PELIGRO": {"es": "No está en peligro de extinción (Preocupación menor).", "en": "Not endangered (Least Concern)."},
	"FAUNA_HORNERO_CAZA": {"es": "Casi no se lo caza: es querido en todo el país. Como toda la fauna silvestre, capturarlo es ilegal.", "en": "It is hardly ever hunted: it is loved throughout the country. Like all wildlife, capturing it is illegal."},
	"FAUNA_HORNERO_COME": {"es": "Insectos, larvas, arañas y lombrices que busca caminando por el suelo.", "en": "Insects, larvae, spiders and earthworms it finds while walking on the ground."},
	"FAUNA_HORNERO_RELACION": {"es": "Es el protagonista: construye y defiende su nido; puede sufrir depredación de huevos o pichones.", "en": "It's the protagonist: it builds and defends its nest, and its eggs or chicks may fall prey to predators."},

	"FAUNA_CHIMANGO_NOMBRE": {"es": "Chimango", "en": "Chimango Caracara"},
	"FAUNA_CHIMANGO_HABITAT": {"es": "Sur de Sudamérica: casi toda la Argentina, Chile, Uruguay y sur de Brasil. Campos abiertos, costas y hasta ciudades.", "en": "Southern South America: almost all of Argentina, Chile, Uruguay and southern Brazil. Open fields, coasts and even cities."},
	"FAUNA_CHIMANGO_DESCRIPCION": {"es": "Rapaz oportunista que suele buscar alimento en el suelo y aprovecha recursos naturales y humanos.", "en": "An opportunistic raptor that usually forages on the ground and takes advantage of both natural and human resources."},
	"FAUNA_CHIMANGO_PELIGRO": {"es": "No está en peligro de extinción (Preocupación menor).", "en": "Not endangered (Least Concern)."},
	"FAUNA_CHIMANGO_CAZA": {"es": "Sí, injustamente: algunos lo tratan como plaga y lo matan, aunque ayuda a limpiar el campo de carroña e insectos.", "en": "Yes, unfairly: some people treat it as a pest and kill it, even though it helps clear the countryside of carrion and insects."},
	"FAUNA_CHIMANGO_COME": {"es": "De todo: carroña, insectos, larvas, lombrices, pequeños animales y huevos. Suele seguir a los arados.", "en": "Everything: carrion, insects, larvae, earthworms, small animals and eggs. It often follows plows."},
	"FAUNA_CHIMANGO_RELACION": {"es": "En el juego es un depredador aéreo. Puede consumir huevos o pichones de aves, pero no se halló aquí un registro directo específico sobre horneros.", "en": "In the game it is an aerial predator. It may eat bird eggs or chicks, but no specific direct record involving horneros was found."},

	"FAUNA_AGUILUCHO_NOMBRE": {"es": "Aguilucho común", "en": "Variable Hawk"},
	"FAUNA_AGUILUCHO_HABITAT": {"es": "Andes y Patagonia, desde Colombia hasta Tierra del Fuego. Estepas, laderas y zonas abiertas.", "en": "The Andes and Patagonia, from Colombia to Tierra del Fuego. Steppes, slopes and open areas."},
	"FAUNA_AGUILUCHO_DESCRIPCION": {"es": "Rapaz de espacios abiertos que planea buscando roedores, reptiles y otras presas pequeñas.", "en": "A raptor of open spaces that soars in search of rodents, reptiles and other small prey."},
	"FAUNA_AGUILUCHO_PELIGRO": {"es": "No está en peligro de extinción (Preocupación menor).", "en": "Not endangered (Least Concern)."},
	"FAUNA_AGUILUCHO_CAZA": {"es": "Sí, injustamente: le disparan creyendo que ataca al ganado. También muere electrocutado en tendidos eléctricos.", "en": "Yes, unfairly: it gets shot by people who believe it attacks livestock. It also dies from electrocution on power lines."},
	"FAUNA_AGUILUCHO_COME": {"es": "Roedores, liebres jóvenes, reptiles, aves e insectos grandes. Controla plagas de roedores.", "en": "Rodents, young hares, reptiles, birds and large insects. It keeps rodent pests in check."},
	"FAUNA_AGUILUCHO_RELACION": {"es": "Puede representar un riesgo oportunista para aves pequeñas, pero no se halló un registro directo específico de depredación de horneros.", "en": "It may pose an opportunistic risk to small birds, but no specific direct record of it preying on horneros was found."},

	"FAUNA_CARANCHO_NOMBRE": {"es": "Carancho", "en": "Southern Crested Caracara"},
	"FAUNA_CARANCHO_HABITAT": {"es": "Casi toda Sudamérica y toda la Argentina. Campos abiertos, bordes de rutas y montes.", "en": "Most of South America and all of Argentina. Open fields, roadsides and woodlands."},
	"FAUNA_CARANCHO_DESCRIPCION": {"es": "Rapaz grande y adaptable; combina la búsqueda de carroña con la captura de presas pequeñas.", "en": "A large, adaptable raptor that combines scavenging for carrion with catching small prey."},
	"FAUNA_CARANCHO_PELIGRO": {"es": "No está en peligro de extinción (Preocupación menor).", "en": "Not endangered (Least Concern)."},
	"FAUNA_CARANCHO_CAZA": {"es": "Sí, injustamente: lo envenenan o le disparan acusándolo de atacar corderos, aunque sobre todo come animales ya muertos.", "en": "Yes, unfairly: it is poisoned or shot on accusations of attacking lambs, even though it mostly eats animals that are already dead."},
	"FAUNA_CARANCHO_COME": {"es": "Carroña, insectos, roedores, reptiles, huevos y pichones.", "en": "Carrion, insects, rodents, reptiles, eggs and chicks."},
	"FAUNA_CARANCHO_RELACION": {"es": "Hay un registro publicado en Uruguay (2026) de un carancho que abrió un nido de hornero y depredó un pichón.", "en": "There is a published record from Uruguay (2026) of a caracara that broke open a hornero nest and preyed on a chick."},

	"FAUNA_GATO_MONTES_NOMBRE": {"es": "Gato montés", "en": "Geoffroy's Cat"},
	"FAUNA_GATO_MONTES_HABITAT": {"es": "Centro y sur de Sudamérica: gran parte de la Argentina, del monte y el espinal a la pampa y la Patagonia.", "en": "Central and southern South America: much of Argentina, from the dry forests and espinal to the Pampas and Patagonia."},
	"FAUNA_GATO_MONTES_DESCRIPCION": {"es": "Felino silvestre pequeño, principalmente nocturno y solitario.", "en": "A small wild cat, mostly nocturnal and solitary."},
	"FAUNA_GATO_MONTES_PELIGRO": {"es": "Hoy no está en peligro de extinción (Preocupación menor), pero la caza para pieles lo diezmó y sigue protegido por CITES.", "en": "Not endangered today (Least Concern), but hunting for its fur decimated it, and it is still protected by CITES."},
	"FAUNA_GATO_MONTES_CAZA": {"es": "Sí, injustamente: durante décadas se exportaron cientos de miles de pieles. Hoy lo matan por atacar gallineros y lo atropellan en las rutas.", "en": "Yes, unfairly: for decades hundreds of thousands of pelts were exported. Today it is killed for raiding henhouses and hit by cars on highways."},
	"FAUNA_GATO_MONTES_COME": {"es": "Roedores, liebres, aves, reptiles y peces.", "en": "Rodents, hares, birds, reptiles and fish."},
	"FAUNA_GATO_MONTES_RELACION": {"es": "En el juego acecha al hornero. En la naturaleza podría capturar aves o saquear nidos al alcance, aunque no se halló un registro directo específico.", "en": "In the game it stalks the hornero. In the wild it could catch birds or raid nests within reach, although no specific direct record was found."},

	"FAUNA_COTORRA_NOMBRE": {"es": "Cotorra", "en": "Monk Parakeet"},
	"FAUNA_COTORRA_HABITAT": {"es": "Centro y norte de Argentina, Uruguay, Paraguay, Bolivia y sur de Brasil. Arma grandes nidos comunitarios de ramitas en árboles y postes.", "en": "Central and northern Argentina, Uruguay, Paraguay, Bolivia and southern Brazil. It builds large communal stick nests in trees and on poles."},
	"FAUNA_COTORRA_DESCRIPCION": {"es": "Loro sociable que forma colonias y construye grandes nidos comunales de ramas.", "en": "A sociable parrot that forms colonies and builds large communal stick nests."},
	"FAUNA_COTORRA_PELIGRO": {"es": "No está en peligro de extinción (Preocupación menor).", "en": "Not endangered (Least Concern)."},
	"FAUNA_COTORRA_CAZA": {"es": "Sí: la declararon plaga agrícola y se la caza y se le destruyen los nidos. También la capturan para venderla como mascota.", "en": "Yes: it was declared an agricultural pest, so it is hunted and its nests are destroyed. It is also captured to be sold as a pet."},
	"FAUNA_COTORRA_COME": {"es": "Semillas, granos, frutos, brotes, flores y algún insecto.", "en": "Seeds, grains, fruit, buds, flowers and the occasional insect."},
	"FAUNA_COTORRA_RELACION": {"es": "El juego le asigna el daño al nido como mecánica; no lo presentamos como una interacción natural comprobada con el hornero.", "en": "The game gives it nest damage as a mechanic; we don't present it as a proven natural interaction with the hornero."},

	"FAUNA_HALCONCITO_NOMBRE": {"es": "Halconcito colorado", "en": "American Kestrel"},
	"FAUNA_HALCONCITO_DESCRIPCION": {"es": "Rapaz pequeña y veloz que caza desde perchas o en vuelo; identificada aquí como el halconcito colorado, especie común en Argentina.", "en": "A small, fast raptor that hunts from perches or on the wing; identified here as the American kestrel, a common species in Argentina."},
	"FAUNA_HALCONCITO_HABITAT": {"es": "Desde Canadá hasta Tierra del Fuego; en Sudamérica ocupa campos, pastizales, sabanas y bordes urbanos.", "en": "From Canada to Tierra del Fuego; in South America it lives in fields, grasslands, savannas and city outskirts."},
	"FAUNA_HALCONCITO_PELIGRO": {"es": "No está globalmente amenazado (Preocupación menor); en Argentina es residente o migratorio según la región.", "en": "Not globally threatened (Least Concern); in Argentina it is a resident or a migrant depending on the region."},
	"FAUNA_HALCONCITO_CAZA": {"es": "Puede sufrir persecución y pérdida de sitios de nidificación; no se lo debe confundir con una amenaza para aves domésticas.", "en": "It may suffer persecution and loss of nesting sites; it should not be mistaken for a threat to poultry."},
	"FAUNA_HALCONCITO_COME": {"es": "Insectos, roedores, lagartijas y aves pequeñas.", "en": "Insects, rodents, lizards and small birds."},
	"FAUNA_HALCONCITO_RELACION": {"es": "Puede capturar aves pequeñas, pero los registros consultados no identifican al hornero como presa de esta especie.", "en": "It can catch small birds, but the records consulted don't identify the hornero as prey of this species."},

	"FAUNA_TAGUATO_NOMBRE": {"es": "Taguató común", "en": "Roadside Hawk"},
	"FAUNA_TAGUATO_DESCRIPCION": {"es": "Rapaz diurna pequeña y adaptable, conocida también como gavilán común en algunas regiones.", "en": "A small, adaptable daytime raptor, also known as the common hawk in some regions."},
	"FAUNA_TAGUATO_HABITAT": {"es": "Desde México y Centroamérica hasta gran parte de Sudamérica; usa montes, bosques abiertos, campos y áreas urbanas.", "en": "From Mexico and Central America to much of South America; it uses woodlands, open forests, fields and urban areas."},
	"FAUNA_TAGUATO_PELIGRO": {"es": "No está globalmente amenazado (Preocupación menor); la evaluación nacional consultada también lo clasifica como no amenazado.", "en": "Not globally threatened (Least Concern); the national assessment consulted also lists it as not threatened."},
	"FAUNA_TAGUATO_CAZA": {"es": "Puede morir por persecución, pérdida de árboles para nidificar y colisiones; no se considera una amenaza para el ganado.", "en": "It may die from persecution, loss of nesting trees and collisions; it is not considered a threat to livestock."},
	"FAUNA_TAGUATO_COME": {"es": "Insectos, pequeños reptiles, roedores y aves; caza desde perchas y también caminando en el suelo.", "en": "Insects, small reptiles, rodents and birds; it hunts from perches and also while walking on the ground."},
	"FAUNA_TAGUATO_RELACION": {"es": "Hay un registro publicado en Córdoba de un taguató común que depredó un volantón de hornero; es evidencia directa, no significa que sea su presa habitual.", "en": "There is a published record from Córdoba of a roadside hawk preying on a hornero fledgling; it is direct evidence, but it doesn't mean horneros are its usual prey."},

	"FAUNA_AVES_NOCTURNAS_NOMBRE": {"es": "Aves nocturnas", "en": "Night birds"},

	"FAUNA_LECHUZA_NOMBRE": {"es": "Lechuza de campanario", "en": "American Barn Owl"},
	"FAUNA_LECHUZA_DESCRIPCION": {"es": "Lechuza nocturna de vuelo silencioso y oído muy desarrollado; suele anidar en cavidades y edificios.", "en": "A nocturnal owl with silent flight and keen hearing; it usually nests in cavities and buildings."},
	"FAUNA_LECHUZA_HABITAT": {"es": "Gran parte de América; ocupa ambientes abiertos, campos y ciudades, y se refugia en huecos y construcciones.", "en": "Much of the Americas; it lives in open habitats, fields and cities, and roosts in hollows and buildings."},
	"FAUNA_LECHUZA_PELIGRO": {"es": "No está amenazada en Argentina (categoría nacional consultada); pierde refugios y puede intoxicarse con rodenticidas.", "en": "Not threatened in Argentina (national category consulted); it is losing roosts and can be poisoned by rodenticides."},
	"FAUNA_LECHUZA_CAZA": {"es": "La persecución y el uso de venenos para roedores pueden afectarla indirectamente.", "en": "Persecution and the use of rodent poisons can affect it indirectly."},
	"FAUNA_LECHUZA_COME": {"es": "Sobre todo roedores; también puede capturar otros animales pequeños.", "en": "Mostly rodents; it may also catch other small animals."},
	"FAUNA_LECHUZA_RELACION": {"es": "No se encontró evidencia directa de depredación de horneros por esta especie; su dieta se compone principalmente de pequeños mamíferos.", "en": "No direct evidence was found of this species preying on horneros; its diet is made up mainly of small mammals."},

	"FAUNA_LECHUZON_NOMBRE": {"es": "Lechuzón orejudo", "en": "Striped Owl"},
	"FAUNA_LECHUZON_DESCRIPCION": {"es": "Búho nocturno con penachos de plumas que parecen orejas; caza al acecho y en vuelos bajos.", "en": "A nocturnal owl with feather tufts that look like ears; it hunts by ambush and in low flights."},
	"FAUNA_LECHUZON_HABITAT": {"es": "Desde Centroamérica hasta Argentina y Uruguay; frecuenta montes abiertos, pastizales, humedales y bordes de ciudades.", "en": "From Central America to Argentina and Uruguay; it frequents open woodlands, grasslands, wetlands and city edges."},
	"FAUNA_LECHUZON_PELIGRO": {"es": "No está amenazado en Argentina ni globalmente (Preocupación menor).", "en": "Not threatened in Argentina or globally (Least Concern)."},
	"FAUNA_LECHUZON_CAZA": {"es": "Puede verse afectado por pérdida de hábitat, persecución y colisiones con vehículos.", "en": "It may be affected by habitat loss, persecution and collisions with vehicles."},
	"FAUNA_LECHUZON_COME": {"es": "Roedores y otros mamíferos pequeños, aves, reptiles e insectos.", "en": "Rodents and other small mammals, birds, reptiles and insects."},
	"FAUNA_LECHUZON_RELACION": {"es": "Se registró un hornero entre las presas identificadas en egagrópilas de esta especie en Santa Fe: es un registro puntual, no una presa frecuente demostrada.", "en": "A hornero was recorded among the prey identified in this species' pellets in Santa Fe: it's a one-off record, not proof of frequent prey."},

	"FAUNA_TORDO_NOMBRE": {"es": "Tordo renegrido", "en": "Shiny Cowbird"},
	"FAUNA_TORDO_DESCRIPCION": {"es": "Ave oscura y gregaria; es parásita de cría obligada: pone sus huevos en nidos de otras aves.", "en": "A dark, gregarious bird; it is an obligate brood parasite: it lays its eggs in other birds' nests."},
	"FAUNA_TORDO_HABITAT": {"es": "Gran parte de Sudamérica, incluida Argentina; campos, pastizales, áreas rurales y ciudades.", "en": "Much of South America, including Argentina; fields, grasslands, rural areas and cities."},
	"FAUNA_TORDO_PELIGRO": {"es": "No está globalmente amenazado (Preocupación menor) y figura como no amenazado en Argentina.", "en": "Not globally threatened (Least Concern) and listed as not threatened in Argentina."},
	"FAUNA_TORDO_CAZA": {"es": "No suele cazarse por consumo; puede ser perseguido localmente por considerarlo perjudicial para aves de cría o cultivos.", "en": "It isn't usually hunted for food; it may be persecuted locally for being considered harmful to breeding birds or crops."},
	"FAUNA_TORDO_COME": {"es": "Semillas e insectos; aprovecha granos y alimento disponible en el suelo.", "en": "Seeds and insects; it takes advantage of grain and food available on the ground."},
	"FAUNA_TORDO_RELACION": {"es": "No es depredador: puede parasitar nidos de hornero. Los adultos reconocen y expulsan algunos huevos parásitos.", "en": "It isn't a predator: it may parasitize hornero nests. The adults recognize and throw out some parasitic eggs."},

	"FAUNA_GOLONDRINA_NOMBRE": {"es": "Golondrina ceja blanca", "en": "White-rumped Swallow"},
	"FAUNA_GOLONDRINA_DESCRIPCION": {"es": "Golondrina migratoria pequeña, de alas largas y rabadilla blanca; captura insectos durante el vuelo.", "en": "A small migratory swallow with long wings and a white rump; it catches insects in flight."},
	"FAUNA_GOLONDRINA_HABITAT": {"es": "Cono sur de Sudamérica; se encuentra en campos, humedales y zonas rurales, y anida en cavidades o estructuras.", "en": "The Southern Cone of South America; it is found in fields, wetlands and rural areas, and nests in cavities or structures."},
	"FAUNA_GOLONDRINA_PELIGRO": {"es": "No se considera globalmente amenazada (Preocupación menor); sus poblaciones pueden verse afectadas localmente.", "en": "Not considered globally threatened (Least Concern); its populations can be affected locally."},
	"FAUNA_GOLONDRINA_CAZA": {"es": "Puede afectarla la pérdida de sitios de nidificación, los pesticidas y la reducción de insectos.", "en": "It may be affected by the loss of nesting sites, pesticides and declining insect numbers."},
	"FAUNA_GOLONDRINA_COME": {"es": "Insectos que captura en vuelo.", "en": "Insects it catches in flight."},
	"FAUNA_GOLONDRINA_RELACION": {"es": "No se conoce como depredadora del hornero; ambas pueden compartir áreas abiertas y alimentarse de recursos distintos.", "en": "It isn't known as a predator of the hornero; both may share open areas while feeding on different resources."},

	"FAUNA_BENTEVEO_NOMBRE": {"es": "Benteveo común", "en": "Great Kiskadee"},
	"FAUNA_BENTEVEO_DESCRIPCION": {"es": "Tirano robusto y ruidoso, reconocible por su ceja blanca y vientre amarillo; es muy oportunista.", "en": "A sturdy, noisy flycatcher, recognizable by its white eyebrow and yellow belly; it is highly opportunistic."},
	"FAUNA_BENTEVEO_HABITAT": {"es": "Desde el sur de Estados Unidos hasta Argentina; vive en montes abiertos, orillas, parques, campos y jardines.", "en": "From the southern United States to Argentina; it lives in open woodlands, riverbanks, parks, fields and gardens."},
	"FAUNA_BENTEVEO_PELIGRO": {"es": "No está globalmente amenazado (Preocupación menor).", "en": "Not globally threatened (Least Concern)."},
	"FAUNA_BENTEVEO_CAZA": {"es": "No suele cazarse; puede sufrir pérdida de hábitat, atropellamientos y persecución local.", "en": "It isn't usually hunted; it may suffer habitat loss, roadkill and local persecution."},
	"FAUNA_BENTEVEO_COME": {"es": "Insectos, frutos, peces pequeños y otros vertebrados pequeños; también puede tomar huevos o pichones.", "en": "Insects, fruit, small fish and other small vertebrates; it may also take eggs or chicks."},
	"FAUNA_BENTEVEO_RELACION": {"es": "Podría depredar huevos o pichones accesibles por su dieta oportunista, pero no se halló un registro directo específico sobre horneros.", "en": "Given its opportunistic diet it could prey on accessible eggs or chicks, but no specific direct record involving horneros was found."},

	"FAUNA_CONDOR_NOMBRE": {"es": "Cóndor andino", "en": "Andean Condor"},
	"FAUNA_CONDOR_DESCRIPCION": {"es": "Enorme ave carroñera que planea largas distancias y ayuda a mantener limpios los ecosistemas.", "en": "A huge scavenging bird that soars over long distances and helps keep ecosystems clean."},
	"FAUNA_CONDOR_HABITAT": {"es": "Vive en montañas, quebradas y estepas a lo largo de los Andes y en sierras del centro argentino.", "en": "It lives in mountains, ravines and steppes along the Andes and in the hills of central Argentina."},
	"FAUNA_CONDOR_PELIGRO": {"es": "Está amenazado en Argentina y globalmente figura como Vulnerable; el envenenamiento es una amenaza grave.", "en": "It is threatened in Argentina and listed as Vulnerable globally; poisoning is a serious threat."},
	"FAUNA_CONDOR_CAZA": {"es": "Históricamente perseguido; hoy lo afectan sobre todo cebos tóxicos, plomo, pérdida de alimento y perturbación de sitios de cría.", "en": "Historically persecuted; today it is mainly affected by poisoned baits, lead, loss of food and disturbance of breeding sites."},
	"FAUNA_CONDOR_COME": {"es": "Carroña, especialmente grandes mamíferos; no caza animales vivos como conducta habitual.", "en": "Carrion, especially from large mammals; hunting live animals is not its usual behavior."},
	"FAUNA_CONDOR_RELACION": {"es": "No es un cazador de horneros: se alimenta de carroña y no representa una amenaza directa para el nido.", "en": "It doesn't hunt horneros: it feeds on carrion and poses no direct threat to the nest."},

	"FAUNA_COMADREJA_NOMBRE": {"es": "Comadreja overa", "en": "White-eared Opossum"},
	"FAUNA_COMADREJA_DESCRIPCION": {"es": "Marsupial nocturno, omnívoro y trepador, con cola prensil; también se lo llama comadreja común.", "en": "A nocturnal, omnivorous, tree-climbing marsupial with a prehensile tail; it is also called the common opossum."},
	"FAUNA_COMADREJA_HABITAT": {"es": "La comadreja overa ocupa gran parte de Argentina y países vecinos; usa montes, humedales, áreas rurales y ciudades.", "en": "The white-eared opossum ranges over much of Argentina and neighboring countries; it uses woodlands, wetlands, rural areas and cities."},
	"FAUNA_COMADREJA_PELIGRO": {"es": "La comadreja overa no está amenazada (Preocupación menor); no debe generalizarse a todas las especies llamadas comadrejas.", "en": "The white-eared opossum is not threatened (Least Concern); this shouldn't be generalized to every species called an opossum."},
	"FAUNA_COMADREJA_CAZA": {"es": "Puede ser perseguida por entrar en gallineros; también la afectan atropellamientos y pérdida de refugios.", "en": "It may be persecuted for getting into henhouses; it is also affected by roadkill and loss of shelter."},
	"FAUNA_COMADREJA_COME": {"es": "Frutos, insectos, pequeños vertebrados, huevos y carroña.", "en": "Fruit, insects, small vertebrates, eggs and carrion."},
	"FAUNA_COMADREJA_RELACION": {"es": "Podría saquear huevos o pichones en un nido accesible, pero no se halló evidencia directa específica para horneros.", "en": "It could raid eggs or chicks from an accessible nest, but no specific direct evidence involving horneros was found."},

	"FAUNA_GATO_CIMARRON_NOMBRE": {"es": "Gato cimarrón", "en": "Feral Cat"},
	"FAUNA_GATO_CIMARRON_DESCRIPCION": {"es": "Gato doméstico (Felis catus) que vive sin depender de personas; es un depredador introducido.", "en": "A domestic cat (Felis catus) that lives without depending on people; it is an introduced predator."},
	"FAUNA_GATO_CIMARRON_HABITAT": {"es": "Se adapta a ambientes rurales, periurbanos, montes e islas de Argentina y Latinoamérica.", "en": "It adapts to rural and suburban areas, woodlands and islands across Argentina and Latin America."},
	"FAUNA_GATO_CIMARRON_PELIGRO": {"es": "No es una especie silvestre amenazada; sus poblaciones asilvestradas pueden amenazar fauna nativa.", "en": "It isn't a threatened wild species; its feral populations can threaten native wildlife."},
	"FAUNA_GATO_CIMARRON_CAZA": {"es": "Puede ser controlado o perseguido; el manejo responsable incluye evitar abandonos y proteger la fauna silvestre.", "en": "It may be controlled or persecuted; responsible management includes preventing abandonment and protecting wildlife."},
	"FAUNA_GATO_CIMARRON_COME": {"es": "Aves, roedores, reptiles e insectos, además de alimento provisto por personas.", "en": "Birds, rodents, reptiles and insects, plus food provided by people."},
	"FAUNA_GATO_CIMARRON_RELACION": {"es": "Puede cazar horneros adultos, volantones o pichones fuera del nido; el riesgo depende del acceso y del contexto local.", "en": "It can hunt adult horneros, fledglings or chicks outside the nest; the risk depends on access and the local context."},

	"FAUNA_ZORRO_NOMBRE": {"es": "Zorro gris pampeano", "en": "Pampas Fox"},
	"FAUNA_ZORRO_DESCRIPCION": {"es": "Cánido oportunista de tamaño mediano, también llamado zorro pampeano o zorro gris chico.", "en": "A medium-sized, opportunistic canid, also known as the Azara's fox or pampas gray fox."},
	"FAUNA_ZORRO_HABITAT": {"es": "Centro y sur de Sudamérica; ocupa pastizales, montes, matorrales y estepas, incluido el centro de Argentina.", "en": "Central and southern South America; it lives in grasslands, woodlands, scrublands and steppes, including central Argentina."},
	"FAUNA_ZORRO_PELIGRO": {"es": "No está globalmente amenazado; la persecución y la caza generan presión en algunas zonas.", "en": "Not globally threatened; persecution and hunting put pressure on it in some areas."},
	"FAUNA_ZORRO_CAZA": {"es": "Persecución por conflictos con animales domésticos, caza por pieles y atropellamientos son presiones conocidas.", "en": "Persecution over conflicts with domestic animals, hunting for fur and roadkill are known pressures."},
	"FAUNA_ZORRO_COME": {"es": "Roedores, aves, reptiles, insectos, frutos y carroña; la proporción depende de la región.", "en": "Rodents, birds, reptiles, insects, fruit and carrion; the mix depends on the region."},
	"FAUNA_ZORRO_RELACION": {"es": "Podría capturar aves o revisar nidos accesibles, pero no se encontró un registro directo específico de depredación de horneros.", "en": "It could catch birds or check accessible nests, but no specific direct record of it preying on horneros was found."},

	"FAUNA_LAUCHA_NOMBRE": {"es": "Laucha de campo", "en": "Small Vesper Mouse"},
	"FAUNA_LAUCHA_DESCRIPCION": {"es": "Roedor pequeño, mayormente nocturno, conocido también como laucha chica o laucha de campo.", "en": "A small, mostly nocturnal rodent, also known as the field mouse."},
	"FAUNA_LAUCHA_HABITAT": {"es": "Norte de Paraguay y sudeste de Bolivia hasta el centro de Argentina; frecuente en campos y áreas agrícolas.", "en": "From northern Paraguay and southeastern Bolivia to central Argentina; common in fields and farmland."},
	"FAUNA_LAUCHA_PELIGRO": {"es": "No se considera amenazado; la intensidad de la agricultura y los rodenticidas pueden afectar poblaciones locales.", "en": "Not considered threatened; intensive farming and rodenticides can affect local populations."},
	"FAUNA_LAUCHA_CAZA": {"es": "Se lo controla en cultivos y viviendas; los rodenticidas afectan también a sus depredadores.", "en": "It is controlled in crops and homes; rodenticides also harm its predators."},
	"FAUNA_LAUCHA_COME": {"es": "Semillas, brotes e insectos; es presa de numerosas rapaces y mamíferos.", "en": "Seeds, sprouts and insects; it is prey for many raptors and mammals."},
	"FAUNA_LAUCHA_RELACION": {"es": "No es un depredador del hornero; forma parte de la red alimentaria de las rapaces que pueden compartir su ambiente.", "en": "It isn't a predator of the hornero; it's part of the food web of the raptors that may share its habitat."},

	"FAUNA_PUMA_NOMBRE": {"es": "Puma", "en": "Puma"},
	"FAUNA_PUMA_DESCRIPCION": {"es": "Puma (Puma concolor), gran felino solitario que regula las poblaciones de sus presas.", "en": "The puma (Puma concolor), a large solitary cat that regulates the populations of its prey."},
	"FAUNA_PUMA_HABITAT": {"es": "Desde Canadá hasta el extremo sur de Sudamérica; ocupa montañas, bosques, montes, pastizales y estepas.", "en": "From Canada to the southern tip of South America; it lives in mountains, forests, woodlands, grasslands and steppes."},
	"FAUNA_PUMA_PELIGRO": {"es": "Preocupación menor a escala global; en Argentina y varias regiones sus poblaciones sufren persecución y fragmentación.", "en": "Least Concern globally; in Argentina and several regions its populations suffer persecution and fragmentation."},
	"FAUNA_PUMA_CAZA": {"es": "Perseguido por conflictos con la ganadería y por caza; también lo afectan la pérdida y fragmentación de hábitat.", "en": "Persecuted over conflicts with ranching and by hunting; it is also affected by habitat loss and fragmentation."},
	"FAUNA_PUMA_COME": {"es": "Mamíferos medianos y grandes; también aves y presas pequeñas cuando están disponibles.", "en": "Medium and large mammals; also birds and small prey when available."},
	"FAUNA_PUMA_RELACION": {"es": "No es un depredador probable de un hornero adulto o de un nido alto; no se halló evidencia directa de interacción.", "en": "It isn't a likely predator of an adult hornero or of a high nest; no direct evidence of interaction was found."},

	"FAUNA_YARARA_NOMBRE": {"es": "Yarará grande", "en": "Urutu Pit Viper"},
	"FAUNA_YARARA_DESCRIPCION": {"es": "Víbora venenosa de cuerpo robusto, también llamada víbora de la cruz; contribuye al control de roedores.", "en": "A heavy-bodied venomous pit viper, also called the cross pit viper; it helps control rodents."},
	"FAUNA_YARARA_HABITAT": {"es": "Norte y centro de Argentina, Uruguay, Paraguay y sur de Brasil; prefiere pastizales húmedos, bañados y orillas.", "en": "Northern and central Argentina, Uruguay, Paraguay and southern Brazil; it prefers wet grasslands, marshes and riverbanks."},
	"FAUNA_YARARA_PELIGRO": {"es": "No amenazada en Argentina según la categorización consultada; no debe manipularse ni matarse por temor.", "en": "Not threatened in Argentina according to the categorization consulted; it shouldn't be handled or killed out of fear."},
	"FAUNA_YARARA_CAZA": {"es": "La persecución humana y la pérdida de hábitat son riesgos; también mueren en rutas.", "en": "Human persecution and habitat loss are risks; they also die on roads."},
	"FAUNA_YARARA_COME": {"es": "Principalmente roedores y otros pequeños vertebrados; la dieta depende de la especie y la edad.", "en": "Mainly rodents and other small vertebrates; the diet depends on the species and age."},
	"FAUNA_YARARA_RELACION": {"es": "No es un depredador típico de nidos; podría afectar huevos o pichones en circunstancias excepcionales, sin registro directo localizado.", "en": "It isn't a typical nest predator; it could take eggs or chicks in exceptional circumstances, with no direct record found."},

	"FAUNA_CULEBRA_NOMBRE": {"es": "Culebra arborícola verde", "en": "Green Racer"},
	"FAUNA_CULEBRA_DESCRIPCION": {"es": "Culebra verde diurna y semiarborícola; aunque no es una víbora, su mordedura puede causar envenenamiento local.", "en": "A green, diurnal, partly tree-dwelling snake; although it isn't a viper, its bite can cause local envenomation."},
	"FAUNA_CULEBRA_HABITAT": {"es": "Norte y este de Sudamérica, incluido el noreste argentino; vive en bosques, selvas y áreas abiertas con vegetación.", "en": "Northern and eastern South America, including northeastern Argentina; it lives in forests, jungles and open areas with vegetation."},
	"FAUNA_CULEBRA_PELIGRO": {"es": "No se la considera globalmente amenazada; enfrenta pérdida de hábitat y persecución por confusión con víboras.", "en": "Not considered globally threatened; it faces habitat loss and persecution from being mistaken for vipers."},
	"FAUNA_CULEBRA_CAZA": {"es": "Sufren persecución por confusión con víboras y pérdida de vegetación nativa.", "en": "They are persecuted after being mistaken for vipers and suffer from the loss of native vegetation."},
	"FAUNA_CULEBRA_COME": {"es": "Anfibios, lagartijas, aves y pequeños mamíferos.", "en": "Amphibians, lizards, birds and small mammals."},
	"FAUNA_CULEBRA_RELACION": {"es": "Por sus hábitos trepadores y dieta, podría acceder a huevos o pichones; no se encontró un registro directo de esta especie en nidos de hornero.", "en": "Given its climbing habits and diet, it could reach eggs or chicks; no direct record of this species in hornero nests was found."},

	"FAUNA_LAGARTO_NOMBRE": {"es": "Lagarto overo", "en": "Argentine Black and White Tegu"},
	"FAUNA_LAGARTO_DESCRIPCION": {"es": "Lagarto overo (Salvator merianae), reptil grande, diurno en época cálida y buen nadador.", "en": "The Argentine tegu (Salvator merianae), a large reptile, active by day in the warm season and a good swimmer."},
	"FAUNA_LAGARTO_HABITAT": {"es": "Centro y norte de Argentina y países vecinos; vive en montes, pastizales, humedales y bordes de ambientes rurales.", "en": "Central and northern Argentina and neighboring countries; it lives in woodlands, grasslands, wetlands and the edges of rural areas."},
	"FAUNA_LAGARTO_PELIGRO": {"es": "No está amenazado a escala global ni en Argentina según las evaluaciones consultadas; puede sufrir presión local.", "en": "Not threatened globally or in Argentina according to the assessments consulted; it may face local pressure."},
	"FAUNA_LAGARTO_CAZA": {"es": "Históricamente perseguido por su cuero y hoy afectado por atropellamientos y captura ilegal.", "en": "Historically persecuted for its hide, and today affected by roadkill and illegal capture."},
	"FAUNA_LAGARTO_COME": {"es": "Omnívoro: frutos, insectos, huevos, carroña y pequeños animales.", "en": "Omnivorous: fruit, insects, eggs, carrion and small animals."},
	"FAUNA_LAGARTO_RELACION": {"es": "Puede consumir huevos o animales pequeños si encuentra un nido accesible, pero no se halló un registro directo específico para horneros.", "en": "It may eat eggs or small animals if it finds an accessible nest, but no specific direct record involving horneros was found."},

	"FAUNA_AGUARA_NOMBRE": {"es": "Aguará guazú", "en": "Maned Wolf"},
	"FAUNA_AGUARA_DESCRIPCION": {"es": "El mayor cánido de Sudamérica: esbelto, de patas largas y pelaje rojizo con una crin oscura.", "en": "South America's largest canid: slender and long-legged, with reddish fur and a dark mane."},
	"FAUNA_AGUARA_HABITAT": {"es": "Centro y sur de Brasil, este de Bolivia, Paraguay, noroeste de Uruguay y noreste de Argentina. Prefiere pastizales y pajonales abiertos, a menudo junto a bañados, palmares y parches de monte.", "en": "Central and southern Brazil, eastern Bolivia, Paraguay, northwestern Uruguay and northeastern Argentina. It prefers open grasslands and tall-grass marshes, often near wetlands, palm groves and patches of woodland."},
	"FAUNA_AGUARA_PELIGRO": {"es": "Sí: está categorizado como Vulnerable (VU) en Argentina (SAREM, 2025) y como Casi Amenazado globalmente (UICN; evaluación más reciente disponible de 2015).", "en": "Yes: it is listed as Vulnerable (VU) in Argentina (SAREM, 2025) and as Near Threatened globally (IUCN; most recent assessment available from 2015)."},
	"FAUNA_AGUARA_CAZA": {"es": "Lo afectan la pérdida y fragmentación de pastizales por la expansión agropecuaria, los atropellamientos y la persecución o captura ilegal.", "en": "It is affected by the loss and fragmentation of grasslands due to agricultural expansion, roadkill, and persecution or illegal capture."},
	"FAUNA_AGUARA_COME": {"es": "Omnívoro: frutos silvestres, insectos y pequeños vertebrados, como roedores, armadillos, reptiles y aves.", "en": "Omnivorous: wild fruit, insects and small vertebrates such as rodents, armadillos, reptiles and birds."},
	"FAUNA_AGUARA_RELACION": {"es": "Puede comer aves pequeñas de forma oportunista, pero no es un depredador habitual del hornero y no se encontró evidencia específica de ataques a sus nidos.", "en": "It may eat small birds opportunistically, but it isn't a regular predator of the hornero, and no specific evidence of attacks on its nests was found."},
}
