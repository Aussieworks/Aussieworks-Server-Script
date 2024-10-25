# Commands
this document goes through all the current commands and what they do. [optinonal varible] {required varible} (perm required to run command if any)
## Player
### ?pi [peer_id]
when no value is inputed into the ?pi command, it will list all the players saved in playerdata along with their peer_id, name and steam_id. when a peer_id is inputed it will show their peer_id, name, steam_id, antisteal status and pvp status.
#### alias: none
### ?tpp {peer_id} [peer_id] (PermMod)
when one peer_id is inputed into the ?tpp command, it will teleport the player sending the command to the player whos peer_id has been inputed. if both values are provided then it will teleport the payer with the first inputed peer_id to the player with the second. if a player does not exist with any inputed peer_id's it will teleport them to the starter island at 0,0.
#### alias: none
### ?tpv {vehicle_id}
It teleports the sender of the command to the inputed vehicles vehicle_id location.
#### alias: none
### ?auth
if the sender of the command has not been authed it will give them auth and notify them. else it will tell them they already have been authed.
#### alias: none
### ?warn {peer_id} [reason] (PermMod)
removes auth from the player with the inputed peer_id, along with notifying them about the warn and the reason for the warn if their is one, and despawning all their vehicles.
#### alias: none
## Vehicles
### ?c
despawns all of senders vehicles and notifys them. if they have no vehicles spawned it will notify them that they dont have any spawned.
#### alias: ?clear
### ?pc {peer_id} (PermAdmin)
despawns all the vehicles belonging to the player with the inputed peer_id. if they have nothing spawned it will notify the sender that they dont have anything to despawn.
#### alias: ?playerclear
### ?ca (PermAdmin)
despawns all spawned vehicles.
#### alias: ?clearall
### ?pvp
toggles pvp state for sender, notifys and and announces in chat of the pvp state change. if pvp is false it will set all senders invulnerabilty to true and if pvp is true it will set it to false, allowing senders vehicles to be dammaged. it will also update all senders vehicles tooltips to reflect the new pvp state.
#### alias: none
### ?forcepvp {peer_id} [true/false] (PermAdmin)
same as the ?pvp command but instead of toggling the senders pvp it toggles the player with the inputed peer_id's pvp. if a true/false value is inputed after the peer_id it will set the pvp state to that.
#### alias: none
### ?repair
resets the vehicle state of all senders spawned vehicles, and announces it in chat. aka repairing the vehicles and restocking them.
#### alias: none
### ?as
toggles senders antisteal and notifys them. when antisteal or as is true all their vehicles cant be taken back to the workbench, and when it is false they can betaken back to the workbench.
#### alias: ?antisteal
### ?forceas {peer_id} [true/false] (PermAdmin)
same as the ?as command but intead of toggling the senders anitsteal it toggles the player with the inputed peer_id's antisteal. if a true/false value is inputed after the peer_id it will set the antisteal state to that.
#### alias: ?forceantisteal
## Misc
### ?pvplist
announces all online players with pvp on in chat to the sender.
#### alias: none
### ?ut
announces the uptime of the server in chat to the sender.
#### alias: ?uptime
### ?help
lists all of the commands and a simplifyed version of what they do.
#### alias: none
### ?w {fog/"reset"} {rain} {wind} (PermAdmin)
sets the weather to inputed values. if the first inputed value is "reset" the it will set the fog, rain and wind all to a value of 0.
#### alias: ?weather
### ?setmoney {value} (PermAdmin)
sets servers money to inputed value.
#### alias: none
### ?disc
announces the discord link set in settings to the sender in chat.
#### alias: ?discord
### ?printchat (PermAdmin)
used in the testing of the customchat. when run by someone with PermAdmin it prints the custom chat into chat.
#### alias: none
### ?clearchat (PermMod)
when run by someone with PermMod and it prints a bunch of blank line and then a little banner at the bottem saying who the chat was cleared by.
#### alias: none
### ?msg {peer_id} {message}
when peer id is inputed it will send the message to player with the inputed peer id. this message is only shown to the sender and the person with the inputed peer id
#### alias: none
### ?version
shows script version and if sender had PermMod or greater it shows the current settings
#### alias: ?ver
