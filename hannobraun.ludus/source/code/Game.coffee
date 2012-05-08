define "Game", [ "Images", "ModifiedRendering", "ModifiedInput", "MainLoop", "Logic", "Graphics" ], ( Images, Rendering, Input, MainLoop, Logic, Graphics )->
	imagePaths = [
		"images/gladiator-front.png"
		"images/spear-front.png"
		"images/sword-front.png"
		"images/shield-front.png"
		"images/gladiator-back.png"
		"images/spear-back.png"
		"images/sword-back.png"
		"images/shield-back.png" ]

	Images.loadImages imagePaths, ( rawImages ) ->
		images = Images.process( rawImages )

		renderData =
			"image": images

		Rendering.drawFunctions[ "text" ] = ( renderable, context, text ) ->
			context.fillStyle = text.textColor || "rgb(0,0,0)"
			if text.font?
				context.font = text.font
			if text.bold?
				context.font = "bold #{ context.font }"

			xPos = if text.centered[ 0 ]
				renderable.position[ 0 ] -
					context.measureText( text.string ).width / 2
			else
				renderable.position[ 0 ]

			yPos = if text.centered[ 1 ]
				renderable.position[ 1 ] + text.size / 2
			else
				renderable.position[ 1 ]

			context.fillText(
				text.string,
				xPos,
				yPos )

			if text.border
				context.strokeStyle = text.borderColor
				context.lineWidth   = text.borderWidth
				
				context.strokeText(
					text.string,
					xPos,
					renderable.position[ 1 ] )

		Rendering.drawFunctions[ "filledCircle" ] = ( renderable, context, circle ) ->
			context.fillStyle = circle.color

			context.beginPath()
			context.arc(
				renderable.position[ 0 ],
				renderable.position[ 1 ],
				circle.radius,
				0,
				2*Math.PI,
				false )
			context.fill()
			context.closePath()

		# Some keys have unwanted default behavior on website, like scrolling.
		# Fortunately we can tell the Input module to prevent the default
		# behavior of some keys.
		Input.preventDefaultFor( [
			"up arrow"
			"down arrow"
			"left arrow"
			"right arrow"
			"space" ] )

		display      = Rendering.createDisplay()
		currentInput = Input.createCurrentInput( display )
		gameState    = Logic.createGameState()
		renderState  = Graphics.createRenderState()

		Logic.initGameState( gameState )

		MainLoop.execute ( currentTimeInS, passedTimeInS ) ->
			Logic.updateGameState(
				gameState,
				currentInput,
				currentTimeInS,
				passedTimeInS )
			Graphics.updateRenderState(
				renderState,
				gameState,
				currentInput,
				passedTimeInS )
			Rendering.render(
				Rendering.drawFunctions,
				display,
				renderData,
				renderState.renderables )

			if gameState.reset
				gameState = Logic.createGameState()
				Logic.initGameState( gameState )
				renderState = Graphics.createRenderState()
