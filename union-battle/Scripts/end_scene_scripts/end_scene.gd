extends Node2D

var priority_worth = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	resolve_undecideds()

	#$GameOverLabel.font.Size = 48
	$GameOverLabel.text = "Game Over! The remaining priorities (if any) were referred to 3rd party arbitration"
	var unionists = []
	var admin = null
	for player in Globals.PLAYERS:
		if player.is_player_union():
			unionists.append(player)
		else:
			admin = player
	
	#Get the Victory Points for all of the Unionists
	var unionist_vps = []
	for unionist in unionists:
		var vps = unionist.get_engagement()
		for priority in unionist.get_priorities():
			for i in range(len(Globals.yes_priority_btns)):
				if priority == Globals.yes_priority_btns[i].text:
					vps += priority_worth
					break
		unionist_vps.append(vps)
	
	#Get Victory Points for the admin
	var admin_vps = admin.get_money()

	#now we combine with the admin as the 4th player
	var players = unionists
	players.append(admin)
	var player_vps = unionist_vps
	player_vps.append(admin_vps)

	#Now we order
	var index_ordering = [0]
	for i in range(1, player_vps.size()):
		for j in range(len(index_ordering) + 1):
			if j == len(index_ordering):
				index_ordering.push_back(i)
				break
			elif player_vps[i] > player_vps[index_ordering[j]]:
				index_ordering.insert(j, i)
				break


	#$WhoWonLabel.font.Size = 36
	var final_text = "The Winner is " + players[index_ordering[0]].get_player_name() + " with " + str(player_vps[index_ordering[0]]) + " victory points\nThen its\n"
	for i in range(1, players.size()):
		final_text = final_text + players[index_ordering[i]].get_player_name() + " with " + str(player_vps[index_ordering[i]]) + " victory points\n"
	$WhoWonLabel.text = final_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func resolve_undecideds():
	var coin = RandomNumberGenerator.new()
	for i in range(Globals.undecided_priority_btns.size() - 1, -1, -1):
		var coin_flip = coin.randi_range(0, 1)
		if coin_flip == 0:
			Globals.yes_priority_btns.append(Globals.undecided_priority_btns[i])
			Globals.undecided_priority_btns.remove_at(i)
		else:
			Globals.no_priority_btns.append(Globals.undecided_priority_btns[i])
			Globals.undecided_priority_btns.remove_at(i)
