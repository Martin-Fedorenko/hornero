extends Node
## Idioma de los textos (autoload "Idioma"). Arma las traducciones de Godot a
## partir de scripts/textos.gd y aplica el idioma guardado en Ajustes.
##
## Los Label, Button y RichTextLabel cuyo `text` es una clave de textos.gd se
## traducen solos y se actualizan al cambiar de idioma. Para textos armados
## en código (con %s, por ejemplo) se usa Idioma.t("CLAVE").

signal cambiado

const Textos := preload("res://scripts/textos.gd")
## En orden: el botón del menú pasa de uno al siguiente.
const IDIOMAS: Array[String] = ["es", "en"]


## En _init: así las traducciones ya están cargadas antes de que se cree
## cualquier texto.
func _init() -> void:
	for codigo in IDIOMAS:
		var traduccion := Translation.new()
		traduccion.locale = codigo
		for clave: String in Textos.TEXTOS:
			var textos: Dictionary = Textos.TEXTOS[clave]
			traduccion.add_message(clave, textos.get(codigo, textos["es"]))
		TranslationServer.add_translation(traduccion)


func _ready() -> void:
	TranslationServer.set_locale(actual())


func actual() -> String:
	return Ajustes.idioma


## Todos los textos de la pantalla se actualizan solos.
func cambiar(codigo: String) -> void:
	if codigo not in IDIOMAS or codigo == actual():
		return
	Ajustes.cambiar_idioma(codigo)
	TranslationServer.set_locale(codigo)
	cambiado.emit()


func siguiente() -> String:
	return IDIOMAS[(IDIOMAS.find(actual()) + 1) % IDIOMAS.size()]


## El texto de `clave` en el idioma actual (la clave misma si no existe).
func t(clave: String) -> String:
	return String(TranslationServer.translate(clave))
