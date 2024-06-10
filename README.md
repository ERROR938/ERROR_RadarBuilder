# Radars

### Le script est intéractif en jeu, il suffit d'avoir un des rôles du config pour pouvoir ouvrir le menu des radars (job police par défaut).

# Coyote

### Si vous avez ox_inventory, veuillez mettre ceci dans ox_inventory/data/items.lua.

```lua
	['coyote'] = {
		label = 'Coyote',
	},
```

### Dans le cas contraire, ajoutez l'item du fichier `radars.sql` dans la base de données.

# Dependences

### Pour installer le script, il faut : `ox_lib`, `oxmysql`, `es_extended`