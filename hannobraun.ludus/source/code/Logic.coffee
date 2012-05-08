define "Logic", [ "ModifiedInput", "Entities", "Gladiators" ], ( Input, Entities, Gladiators ) ->
	entityFactories =
		"gladiator": Gladiators.createEntity

	determineWinner = ( gameState, gladiators ) ->
		aiGladiators     = 0
		playerGladiators = 0

		for entityId, gladiator of gladiators
			switch gladiator.side
				when "ai"     then aiGladiators += 1
				when "player" then playerGladiators += 1

		if aiGladiators == 0
			gameState.winner = "player"
		if playerGladiators == 0
			gameState.winner = "ai"

	resetGame = ( gameState, currentInput ) ->
		unless gameState.winner == 0
			if Input.isKeyDown( currentInput, "enter" )
				gameState.reset = true


	# There are functions for creating and destroying entities in the Entities
	# module. We will mostly use shortcuts however. They are declared here and
	# defined further down in initGameState.
	createEntity  = null
	destroyEntity = null

	module =
		createGameState: ->
			gameState =
				gladiatorSelection:
					currentlySelected: null

				clickedButton: null

				winner: null
				reset : false

				aiControl:
					nextAction: 0

				# Game entities are made up of components. The components will
				# be stored in this map.
				components: {}

		initGameState: ( gameState ) ->
			# These are the shortcuts we will use for creating and destroying
			# entities.
			createEntity = ( type, args ) ->
				Entities.createEntity(
					entityFactories,
					gameState.components,
					type,
					args )
			destroyEntity = ( entityId ) ->
				Entities.destroyEntity(
					gameState.components,
					entityId )

			createEntity( "gladiator", {
				position: [ -160, -100 ]
				weapon  : "spear"
				facing  : "front",
				side    : "ai" } )
			createEntity( "gladiator", {
				position: [ 0, -100 ]
				weapon  : "sword"
				facing  : "front",
				side    : "ai" } )
			createEntity( "gladiator", {
				position: [ 160, -100 ]
				weapon  : "shield"
				facing  : "front",
				side    : "ai" } )

			createEntity( "gladiator", {
				position: [ -160, 100 ]
				weapon  : "spear"
				facing  : "back",
				side    : "player" } )
			createEntity( "gladiator", {
				position: [ 0, 100 ]
				weapon  : "sword"
				facing  : "back",
				side    : "player" } )
			createEntity( "gladiator", {
				position: [ 160, 100 ]
				weapon  : "shield"
				facing  : "back",
				side    : "player" } )

		updateGameState: ( gameState, currentInput, timeInS, passedTimeInS ) ->
			Gladiators.applyInput(
				currentInput,
				gameState.components.gladiators,
				gameState.components.positions,
				gameState.gladiatorSelection )
			Gladiators.handleActions(
				gameState,
				gameState.components.gladiators,
				gameState.components.positions )
			Gladiators.updateActions(
				gameState.components.gladiators,
				passedTimeInS )
			Gladiators.killGladiators(
				gameState.components.gladiators,
				destroyEntity )
			Gladiators.updateAi(
				gameState.components.gladiators,
				gameState.components.positions,
				gameState.aiControl,
				passedTimeInS )

			determineWinner(
				gameState,
				gameState.components.gladiators )
			resetGame(
				gameState,
				currentInput )
