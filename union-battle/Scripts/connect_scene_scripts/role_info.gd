extends VBoxContainer

# Each of the labels this container contains
@onready var role_title:	Label  = $RoleTitle
@onready var role_info:		Label  = $RoleInfo

# The role names as strings
var			 admin_name:	String = "Admin"
var			 unionist_name: String = "Unionist"

# The role descriptions
var			admin_info:		String = "Your Goal: Have more Money by the end of the game than the\nUnionists have points to win!\n\nYour Stats:\n- Money: How rich you are! This decreases as the strike\nprogresses, but approving Unionist priorities will give them\npoints that could add up to be more than you're worth, so\nmanage your money wisely!\n\nOn Your Turn You Can:\n- Play a card on a Unionist to affect their Engagement and Risk\nlevels\n- Draw a card from the Admin Pile\n\n\n- Tip: You have the final say on if a Unionist priority is approved!"
var			unionist_info:  String = "Your Goal: Get your own priorities approved by the Admin to\nearn points and win!\n\nYour Stats:\n- Engagement: How much support you have for the strike. If\nyour engagement reaches 0, you can't play!\n- Risk: How much risk there is to you striking. If your risk\nreaches 10, you can't play.\n\nOn Your Turn You Can:\n- Play a card on yourself or another Unionist to affect their\nEngagement and Risk levels\n- Draw a card from the Unionist Pile\n- Put forward a priority to be approved by the admin\n\n- Tip: Not all Unionists have the same priorities!"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Sets the unionist info text
func _on_unionist_button_down() -> void:
	role_title.text = unionist_name
	role_info.text  = unionist_info

# Sets the admin info text
func _on_admin_button_down() -> void:
	role_title.text = admin_name
	role_info.text  = admin_info
