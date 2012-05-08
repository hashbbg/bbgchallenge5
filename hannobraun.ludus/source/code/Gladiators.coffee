define "Gladiators", [ "ModifiedInput", "Tools", "Vec2" ], ( Input, Tools, Vec2 ) ->
	nextEntityId = 0

	maxChargeByAction =
		"attack"  : 100
		"block"   : 20
		"cooldown": 20

	maxCharge = 0
	for action, maxChargeForAction of maxChargeByAction
		maxCharge = Math.max( maxCharge, maxChargeForAction )

	chargePerS = 20

	weaponDamage =
		"spear" : 30
		"sword" : 20
		"shield": 10

	weaponBlock =
		"spear" : 0.2
		"sword" : 0.4
		"shield": 0.6

	module =
		maxHealth: 150

		maxChargeByAction: maxChargeByAction
		maxCharge: maxCharge

		selectionRectangleSize: [ 110, 150 ]

		createEntity: ( args ) ->
			id = nextEntityId
			nextEntityId += 1

			entity =
				id: id
				components:
					"positions": args.position
					"gladiators":
						side  : args.side
						facing: args.facing

						health: module.maxHealth
						weapon: args.weapon
						target: null

						targetPosition: null

						highlighted: false
						selected   : false

						action: "ready"
						charge: 0

		applyInput: ( currentInput, gladiators, positions, selection ) ->
			for entityId, gladiator of gladiators
				position = positions[ entityId ]

				mouseOverGladiator = Tools.pointInRectangle(
					currentInput.pointerPosition,
					position,
					module.selectionRectangleSize )

				if mouseOverGladiator and gladiator.action == "ready"
					gladiator.highlighted = true

					selectionKeyDown =
						Input.isKeyDown( currentInput, "left mouse button" )

					if gladiator.side == "player" and selectionKeyDown
						previouslySelected =
							gladiators[ selection.currentlySelected ]
						if previouslySelected?
							previouslySelected.selected = false

						gladiator.selected = true
						selection.currentlySelected = entityId

				else
					gladiator.highlighted = false

		handleActions: ( gameState, gladiators, positions ) ->
			unless gameState.clickedButton == null
				gladiator =
					gladiators[ gameState.gladiatorSelection.currentlySelected ]
				gameState.gladiatorSelection.currentlySelected = null
				gladiator.selected = false

				gladiator.action = gameState.clickedButton.button
				gladiator.target = gameState.clickedButton.gladiatorId

				gladiator.targetPosition =
					Vec2.copy( positions[ gladiator.target ] )

			gameState.clickedButton = null

		updateActions: ( gladiators, passedTimeInS ) ->
			for entityId, gladiator of gladiators
				if gladiators[ gladiator.target ]? or gladiator.action == "cooldown"
					if maxChargeByAction[ gladiator.action ]?
						gladiator.charge += chargePerS * passedTimeInS

					maxCharge = maxChargeByAction[ gladiator.action ]
					if gladiator.charge >= maxCharge
						gladiator.charge = 0

						target = gladiators[ gladiator.target ]
						damage = weaponDamage[ gladiator.weapon ]

						switch gladiator.action
							when "attack"
								target.health -= damage
							when "block"
								enemyDamage = weaponDamage[ target.weapon ]
								damageBlock = weaponBlock[ gladiator.weapon ]
								
								damageAfterBlock = enemyDamage * ( 1 - damageBlock )

								target.action = "ready"
								target.charge = 0

								gladiator.health -= damageAfterBlock



						gladiator.action = switch gladiator.action
							when "cooldown" then "ready"
							else "cooldown"

						gladiator.target = null
				else
					gladiator.target = null
					gladiator.charge = 0
					gladiator.action = "ready"

		killGladiators: ( gladiators, destroyEntity ) ->
			for entityId, gladiator of gladiators
				if gladiator.health <= 0
					destroyEntity( entityId )

		updateAi: ( gladiators, positions, aiControl, passedTimeInS ) ->
			aiControl.nextAction -= passedTimeInS

			if aiControl.nextAction <= 0
				aiControl.nextAction = Math.random() * 3

				attackingPlayerGladiators = []
				allPlayerGladiators       = []

				readyAiGladiators = []

				for entityId, gladiator of gladiators
					if gladiator.side == "player"
						allPlayerGladiators.push( {
							id: entityId
							gladiator: gladiator } )

						if gladiator.action == "attack"
							attackingPlayerGladiators.push( {
								id: entityId
								gladiator: gladiator } )

					if gladiator.side == "ai" and gladiator.action == "ready"
						readyAiGladiators.push( {
							id: entityId
							gladiator: gladiator } )

				if readyAiGladiators.length > 0 and allPlayerGladiators.length > 0
					gladiator = readyAiGladiators[ Math.floor( Math.random() * readyAiGladiators.length ) ].gladiator


					action = null

					if attackingPlayerGladiators.length > 0
						attackProbability = 0
						blockProbability  = 0

						switch gladiator.weapon
							when "spear"
								attackProbability = 3
								blockProbability  = 1
							when "sword"
								attackProbability = 2
								blockProbability  = 2
							when "shield"
								attackProbability = 1
								blockProbability  = 3

						if Math.random() * ( attackProbability + blockProbability ) < attackProbability
							action = "attack"
						else
							action = "block"
					else
						action = "attack"


					target = null

					potentialTargets = if action == "block"
						attackingPlayerGladiators
					else
						allPlayerGladiators

					target = potentialTargets[ Math.floor( Math.random() * potentialTargets.length ) ].id			
					

					gladiator.action = action
					gladiator.target = target

					gladiator.targetPosition =
						Vec2.copy( positions[ target ] )
