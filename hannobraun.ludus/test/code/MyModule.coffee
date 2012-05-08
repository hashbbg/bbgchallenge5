MyModule = load( "MyModule" )

describe "MyModule", ->
	it "should be awesome", ->
		expect( MyModule.itIsAwesome ).to.equal( true )
