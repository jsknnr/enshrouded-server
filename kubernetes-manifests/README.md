# Enshrouded server statefulSet on Kubernetes

Review the manifests and make changes for your cluster. Each file should be reviewed and possibly edited.

Apply in this order:
- enshrouded-ns-privs.yaml
- enshrouded-server_configmap.yaml
- statefulset.yaml
- service.yaml

## Configure server

Either edit the configMap before applying, or use:\
`kubectl edit configmaps enshrouded-config`

References for server config:
https://nodecraft.com/support/games/enshrouded/changing-settings-for-an-enshrouded-server#h-key-server-settings-breakdown-e9f41b9a22 \
https://guides.gamehostbros.com/games/enshrouded/custom-difficulty-settings/ \

Units involving time are in nanoseconds (1/1,000,000,000 of a second), in-game they are displayed as minutes, you can calculate your desired value using this calculator:\
https://www.unitconverters.net/time/minute-to-nanosecond.htm

## Official Server Readme
```
                     _                             _             _
                    ( )                           ( )           ( )
   __    ___    ___ | |__   _ __   _    _   _    _| |   __     _| |
 /'__`\/' _ `\/',__)|  _ `\( '__)/'_`\ ( ) ( ) /'_` | /'__`\ /'_` |
(  ___/| ( ) |\__, \| | | || |  ( (_) )| (_) |( (_| |(  ___/( (_| |
`\____)(_) (_)(____/(_) (_)(_)  `\___/'`\___/'`\__,_)`\____)`\__,_)
              ___    __   _ __  _   _    __   _ __
            /',__) /'__`\( '__)( ) ( ) /'__`\( '__)
            \__, \(  ___/| |   | \_/ |(  ___/| |    _
            (____/`\____)(_)   `\___/'`\____)(_)   (_)
      ______
      (______)
                                    _           ___
          _                        (_)        /'___)
          (_)  ___    _     ___     | |  ___  | (__   _
          | |/',__) /'_`\ /' _ `\   | |/' _ `\| ,__)/'_`\
          | |\__, \( (_) )| ( ) |   | || ( ) || |  ( (_) )
      _  | |(____/`\___/'(_) (_)   (_)(_) (_)(_)  `\___/'
      ( )_| |
      `\___/'

                                                    Version: 0.7.4.0
```

The following paragraphs describe options and valid values that hosts of dedicated servers can configure by editing the file enshrouded_server.json, located in the same folder as the enshrouded_server.exe.

### PERMISSION SETTINGS

Enshrouded allows hosts to define permissions for groups of players. This document leads through the new functions and also highlights areas that hosts need to be aware of.

#### Dedicated server hosting - Using the pre-update 2 settings

In Update 2 of Enshrouded the structure of the `enshrouded_server.json` had to be adapted to support multiple passwords. The password for a server was previously defined in line 3 of the file `enshrouded_server.json` via “password”: “”. This line is no longer used to setup the password for dedicated servers! However, if the game detects a password defined in line 3, it will set up a new “userGroup” called “default” which uses the password and automatically grants the same permission level as what players were accustomed to up until Update 2. This means if the host of a dedicated server chooses to not change anything, the dedicated server will still be protected by the same password and the permissions of joining players will stay the same.

#### Dedicated server hosting - Setting up user groups

Player permissions for playing on servers are handled via user groups. Each group can be set up in the `enshrouded_server.json` with a unique configuration of permissions and an accompanying password that grants the permissions to the logged-in player. By default, the `enshrouded_server.json` starts with 3 user groups which may serve as a base for hosts. The presets are:

`Admin:`
  - Changes to the player bases are allowed.
  - Using chests and other containers are allowed.
  - Kicking and banning other players is allowed.

`Friend:`
  - Changes to the player bases are allowed.
  - Using chests and other containers are allowed.

`Guest:`
  - Changes to the player bases are not allowed.
  - Using chests and other containers are not allowed.

**Please note: all user groups have full access to the game world outside the player bases and can engage in combat, collect materials, dig for resources, solve quests etc.**

**Please also note: the presets mentioned above are only generated when the `enshrouded_server.json` is freshly created after updating Enshrouded with update 2. When the game detects an already defined password, only the “default” user group is created with the permission configuration identical to “Friend” from the presets above. By default, when a fresh `enshrouded_server.json` is created, randomized passwords are set to prevent unwanted players from joining the server.**

#### Custom player permission groups 

The `enshrouded_server.json` also allows setting up new and unique user groups. Simply add a new user group section with a new name, define a password and select the permissions needed for the player group. For example, it could be interesting to allow a user group to access the content of chests, other containers or workstations but not to allow adding/deleting props and voxels in the player bases. 

Another setting that can be configured for each user group is a number of reserved slots for that particular user group. This is set by adding this line to the user group:

`"reservedSlots": 1`

When 1 or more reserved slots are set, the lobby will be marked as “full” for players who try to log into the server under a different user group and would fill up all session slots. This allows for example Admins or Friends to join even if there is a high demand for slots by “Guests”. 

### DIFFICULTY- AND GAMEPLAY SETTINGS

Update 0.7.3.0 introduced a number of difficulty- and gameplay settings that can be configured for the dedicated server via the `enshrouded_server.json` - file.

**Note:** when no `enshrouded_server.json` config file is found, then a fresh file is created with the start of the enshrouded_server exe.

#### Difficulty setting presets

`"gameSettingsPreset":`

The options are:
  - **"Default”** - The “Default” difficulty setting configures all values to default. It is the direct continuation of how Enshrouded was configured up until update 0.7.3.0 and is the recommended setting for first-time players.
  - **“Relaxed”** - The “Relaxed” preset reduces the amount of enemies and provides players with more resources and loot. This mode targets players who are most interested in base-building and light-hearted adventuring.
  - **“Hard”** - The “Hard” preset increases the amount of enemies and makes them more aggressive to give players a tougher combat experience.
  - **“Survival”** - The “Survival” preset is for those who seek some punishment with additional survival mechanics on top of more aggressive enemies.
  - **“Custom”** - When “Custom” is selected, a long list of individual settings can be tweaked. 

#### Individual Custom Settings including default values

```json
Player Health
"gameSettings": {
"playerHealthFactor": 1,
}
Scales the max health for players by a factor. Ingame, the factor is represented by a percentage.
Min value: 0.25
Max value: 4
```

```json
Player Mana
"gameSettings": {
"playerManaFactor": 1,
}
Scales the max mana for players by a factor. Ingame, the factor is represented by a percentage.
Min value: 0.25
Max value: 4
```

```json
Player Stamina
"gameSettings": {
"playerStaminaFactor": 1,
}
Scales the max stamina for players by a factor. Ingame, the factor is represented by a percentage.
Min value: 0.25
Max value: 4
```

```json
Weapon Durability
"gameSettings": {
"enableDurability": true,
}
If this setting is set to “false”, weapons don't break anymore.
Options: true / false
```

```json
Hunger and Starvation
"gameSettings": {
"enableStarvingDebuff": false,
}
Enables hunger and starvation. During starvation, the player loses health periodically until death if no food or drink is consumed.
Options: true / false
```

```json
Food Buff Duration
"gameSettings": {
"foodBuffDurationFactor": 1,
}
Scales food buff durations. Ingame, the factor is represented by a percentage.
Min value: 0.5
Max value: 2
```

```json
Hungry State Duration
"gameSettings": {
"fromHungerToStarving": 600000000000,
}
This setting controls the length of the hungry state before the starving sets in. The unit in this setting is nanoseconds. Ingame the time is displayed in minutes.
Min value: 5 minutes
Max value: 20 minutes
```

```json
Shroud time duration modifier
"gameSettings": {
"shroudTimeFactor": 1,
}
Scales how long player characters can remain within the Shroud. Ingame, the factor is represented by a percentage.
Min value: 0.5 
Max value: 2
```

```json
Enemy Amount
"gameSettings": {
"randomSpawnerAmount": "Normal"
}
This setting controls the amount of enemies in the world. 
Options: Few / Normal / Many / Extreme 
```

```json
Mining Effectiveness
"gameSettings": {
"miningDamageFactor": 1,
}
This scales the mining damage. A higher mining damage leads to increased terraforming and more yield of resources per hit. Ingame, the factor is represented by a percentage.
Min value: 0.5 
Max value: 2
```

```json
Plant Growth Speed
"gameSettings": {
"plantGrowthSpeedFactor": 1,
}
Scales the value of the plant growth speed. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Resources Gain Modifier
"gameSettings": {
"resourceDropStackAmountFactor": 1,
}
Scales the amount of materials per loot stack in chests, defeated enemies etc. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Workstation Effectiveness
"gameSettings": {
"factoryProductionSpeedFactor": 1,
}
Scales the length of production times for workshop items. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Weapon Recycling Yield Modifier
"gameSettings": {
"perkUpgradeRecyclingFactor": 0.100000,
}
Scales the amount of Runes that are returned to you when salvaging upgraded weapons. Ingame, the factor is represented by a percentage.
Min value: 0 
Max value: 1
```

```json
Weapon Upgrading Costs
"gameSettings": {
"perkCostFactor": 1,
}
Scales the amount of Runes required for upgrading weapons. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Combat Experience Modifier
"gameSettings": {
"experienceCombatFactor": 1,
}
Scales the amount of XP received through combat. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Mining Experience Modifier
"gameSettings": {
"experienceMiningFactor": 1,
}
Scales the amount of XP received by mining resources. Ingame, the factor is represented by a percentage.
Min value: 0 
Max value: 2
```

```json
Exploration Experience Modifier
"gameSettings": {
"experienceExplorationQuestsFactor": 1,
}
Scales the amount of XP received by exploring and completing quests. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 2
```

```json
Modifier for simultaneous Enemy Attacks
"gameSettings": {
"aggroPoolAmount": "Normal"
}
This setting controls how many enemies are allowed to attack at the same time. Ingame, the factor is represented by a percentage.
Options: Few / Normal / Many / Extreme
```

```json
Enemy Damage
"gameSettings": {
"enemyDamageFactor": 1,
}
Scales all enemy damage by this value - except for bosses. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 5
```

```json
Enemy Health
"gameSettings": {
"enemyHealthFactor": 1,
}
Scales all enemy health by this value - except for bosses. Ingame, the factor is represented by a percentage.
Min value: 0.25 
Max value: 4
```

```json
Enemy Stun Modifier
"gameSettings": {
"enemyStaminaFactor": 1,
}
Scales all enemy stamina by this value. It will take longer to stun enemies with a higher enemy stamina. This excludes bosses. Ingame, the factor is represented by a percentage.
Min value: 0.5 
Max value: 2
```

```json
Enemy Perception Modifier
"gameSettings": {
"enemyPerceptionRangeFactor": 1,
}
Scales how far enemies can see and hear the player. This excludes bosses. Ingame, the factor is represented by a percentage.
Min value: 0.5 
Max value: 2
```

```json
Boss Damage Modifier
"gameSettings": {
"bossDamageFactor": 1,
}
This setting scales the damage of boss attacks. Ingame, the factor is represented by a percentage.
Min value: 0.2 
Max value: 5
```

```json
Boss Health Modifier
"gameSettings": {
"bossHealthFactor": 1,
}
Scales all health of bosses by this value. Ingame, the factor is represented by a percentage.
Min value: 0.2 
Max value: 5
```

```json
Enemy Attacks Modifier
"gameSettings": {
"threatBonus": 1,
}
Scales the frequency of enemy attacks. This excludes bosses. Ingame, the factor is represented by a percentage.
Min value: 0.25
Max value: 4
```

```json
Pacified Enemies
"gameSettings": {
"pacifyAllEnemies": false,
}
If turned on, enemies won't attack the players until they are attacked. This excludes bosses.
Options: true / false
```

```json
Daytime 
"gameSettings": {
"dayTimeDuration": 1800000000000
}
Scales the length of daytime. A smaller value equals shorter daytime. The unit is nanoseconds. Ingame, the time is displayed in minutes.
Min value: 2 minutes
Max value: 60 minutes
```

```json
Nighttime 
"gameSettings": {
"nightTimeDuration": 720000000000
}
Scales the length of daytime. A smaller value equals a shorter nighttime. The unit is nanoseconds. Ingame, the time is displayed in minutes.
Min value: 2 minutes
Max value: 60 minutes
```

```json
Tombstone Mode
"gameSettings": {
"tombstoneMode": "AddBackpackMaterials"
}
The players can either keep or lose all items from their backpack when dying. In the default setting, they only lose materials. Lost items are stored in a tombstone and can be recovered there.
Options: AddBackpackMaterials / Everything / NoTombstone 
```

#### Update 0.7.4.0 introduced a few new user settings

```json
Player body heat against cold weather
"gameSettings": {
"playerBodyHeatFactor": 1,
}
Scales the max amount of available body heat in the player. The higher the factor the longer the player can stay in very cold areas before hypothermia sets in. 
Min value: 0.5
Max value: 2
```

```json
Weather phenomena frequency
"gameSettings": {
"weatherFrequency": "Normal",
}
This setting allows defining how often new weather phenomena appear in the game world.
Options: Disabled / Rare / Normal / Often
```

```json
Taming failure repercussions
"gameSettings": {
"tamingStartleRepercussion": "LoseSomeProgress",
}
This setting allows defining how the game reacts when the player startles the wildlife during taming. Progress is visualized by hearts in the game.
Options: KeepProgress / LoseSomeProgress / LoseAllProgress
```

```json
Air turbulences while gliding
"gameSettings": {
"enableGliderTurbulences": true,
}
If turned off, the glider will not be affected by air turbulences, just as in previous versions of the game.
Options: true / false
```

### DEFAULT `enshrouded_server.json` / VERSION 0.7.4.0

```json
{
	"name": "Enshrouded Server",
	"saveDirectory": "./savegame",
	"logDirectory": "./logs",
	"ip": "0.0.0.0",
	"queryPort": 15637,
	"slotCount": 16,
	"gameSettingsPreset": "Default",
	"gameSettings": {
		"playerHealthFactor": 1,
		"playerManaFactor": 1,
		"playerStaminaFactor": 1,
		"playerBodyHeatFactor": 1,
		"enableDurability": true,
		"enableStarvingDebuff": false,
		"foodBuffDurationFactor": 1,
		"fromHungerToStarving": 600000000000,
		"shroudTimeFactor": 1,
		"tombstoneMode": "AddBackpackMaterials",
		"enableGliderTurbulences": true,
		"weatherFrequency": "Normal",
		"miningDamageFactor": 1,
		"plantGrowthSpeedFactor": 1,
		"resourceDropStackAmountFactor": 1,
		"factoryProductionSpeedFactor": 1,
		"perkUpgradeRecyclingFactor": 0.500000,
		"perkCostFactor": 1,
		"experienceCombatFactor": 1,
		"experienceMiningFactor": 1,
		"experienceExplorationQuestsFactor": 1,
		"randomSpawnerAmount": "Normal",
		"aggroPoolAmount": "Normal",
		"enemyDamageFactor": 1,
		"enemyHealthFactor": 1,
		"enemyStaminaFactor": 1,
		"enemyPerceptionRangeFactor": 1,
		"bossDamageFactor": 1,
		"bossHealthFactor": 1,
		"threatBonus": 1,
		"pacifyAllEnemies": false,
		"tamingStartleRepercussion": "LoseSomeProgress",
		"dayTimeDuration": 1800000000000,
		"nightTimeDuration": 720000000000
	},
	"userGroups": [
		{
			"name": "Admin",
			"password": "AdminXXXXXXXX",
			"canKickBan": true,
			"canAccessInventories": true,
			"canEditBase": true,
			"canExtendBase": true,
			"reservedSlots": 0
		},
		{
			"name": "Friend",
			"password": "FriendXXXXXXXX",
			"canKickBan": false,
			"canAccessInventories": true,
			"canEditBase": true,
			"canExtendBase": false,
			"reservedSlots": 0
		},
		{
			"name": "Guest",
			"password": "GuestXXXXXXXX",
			"canKickBan": false,
			"canAccessInventories": false,
			"canEditBase": false,
			"canExtendBase": false,
			"reservedSlots": 0
		}
	]
}
```
