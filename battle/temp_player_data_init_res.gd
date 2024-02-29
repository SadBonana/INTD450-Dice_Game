## HACK: Currently BattlaPlayer is different from BattleEnemy because
## BattleEnemy gets its values from a res file whie BattlePlayer does
## not. There are many advantages with having a res file for the player.
## for one, you can easily tweak values or swap out the res with another
## to test game balance. For two, it makes it much easier to import
## Die resources for the player's dice bag. The issues, are one, that if
## we're doing this, it disereves a proper implementation where we
## a an ActorResBase, which then is inherited by the player and enemy
## resource files and... Two, the bigger issue, is that at the moment,
## the dice bag will only be imported to the PlayerData singleton once
## the battle scene first starts, as you can easily pass a resource to
## a node in the inspector, but can't do that for a standalone script.
## This may not be a huge problem but, it could cause issues down the line.
##
## Anyways, this is a temp file and should be replaced with a
## proper implementation later: TODO.
class_name PlayerDataInit extends Resource

@export var dice: Array[Die]
