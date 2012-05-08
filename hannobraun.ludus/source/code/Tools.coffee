define "Tools", [], ->
	module =
		pointInRectangle: ( point, rectanglePosition, rectangleSize ) ->
			minX = rectanglePosition[ 0 ] - rectangleSize[ 0 ] / 2
			minY = rectanglePosition[ 1 ] - rectangleSize[ 1 ] / 2
			maxX = rectanglePosition[ 0 ] + rectangleSize[ 0 ] / 2
			maxY = rectanglePosition[ 1 ] + rectangleSize[ 1 ] / 2

			pointerX = point[ 0 ]
			pointerY = point[ 1 ]

			minX < pointerX < maxX and minY < pointerY < maxY
