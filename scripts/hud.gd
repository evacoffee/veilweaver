extends CanvasLayer

signal encounter_continue

@onready var encounter_popup: Control = $encounterpopup
@onready var encounter_text: Label = $encounterpopup/Panel/text
@onready var continue_button: Button = $encounterpopup/Panel/continue

func _ready():
	encounter_popup.hide()
	
	encounter_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	encounter_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	continue_button.pressed.connect(_on_continue_pressed)

func show_encounter(enemy_name: String):
	encounter_text.text = "You stepped on a " + enemy_name + "!"
	encounter_popup.show()

func _on_continue_pressed():
	encounter_popup.hide()
	encounter_continue.emit()
