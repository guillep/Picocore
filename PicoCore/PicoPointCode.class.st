Class {
	#name : #PicoPointCode,
	#superclass : #PicoCodeRepository,
	#type : #variable,
	#category : #PicoCore
}

{ #category : #messages }
PicoPointCode >> directAccessToX [

	^ x
]

{ #category : #messages }
PicoPointCode >> dotProduct2: aPicoPoint [ 
	"Answer a number that is the dot product of the receiver and the argument, aPoint. 
	That is, the two points are multipled and the coordinates of the result summed."

	^ ((self send: #x) * (aPicoPoint send: #x)) + ((self send: #y) * (aPicoPoint send: #y))
]

{ #category : #messages }
PicoPointCode >> dotProduct: aPicoPoint [ 
	"Answer a number that is the dot product of the receiver and the argument, aPoint. 
	That is, the two points are multipled and the coordinates of the result summed."

	^ (x * (aPicoPoint send: #x)) + (y * (aPicoPoint send: #y))
]

{ #category : #'for lookup tests' }
PicoPointCode >> foo [ 
	
	'PicoPoint>>foo' traceCr.
	^ 5
]

{ #category : #messages }
PicoPointCode >> halfDotProduct: aPicoPoint [ 

	^ x * (aPicoPoint send: #x) 
]

{ #category : #'for lookup tests' }
PicoPointCode >> notOverridenFoo [ 
	
	'PicoPoint>>notOverridenFoo' traceCr.
	^ 55
]

{ #category : #'internal messages' }
PicoPointCode >> playingWithString [

	^ 'pico core is cool' size
]

{ #category : #'return and access' }
PicoPointCode >> return100 [

	^ 100
]

{ #category : #messages }
PicoPointCode >> sendingMessageToArgument: aPicoPoint [ 
	
	^ (aPicoPoint send: #x) 
]

{ #category : #messages }
PicoPointCode >> sendingMessageToArgument: anEvilPoint withArg: arg [
	
	^ (anEvilPoint send: #x) + arg
]

{ #category : #messages }
PicoPointCode >> sendingMessageToArgument: aPicoPoint withDifferentArgument: anArg [
	
	aPicoPoint send: #x: withArguments: {33}.
	^ aPicoPoint send: #x
]

{ #category : #'simple temp manipulation' }
PicoPointCode >> settingAValueFromTempToTemp2 [

	| temp temp2 | 
	temp := 10.
	temp2 := temp.
	^ temp2
]

{ #category : #'simple temp manipulation' }
PicoPointCode >> settingAValueToTemp [

	| temp | 
	temp := 10.
	^ temp
]

{ #category : #'simple temp manipulation' }
PicoPointCode >> settingAValueToTemp2 [

	| temp | 
	temp := 10.
	temp := 20.
	^ temp
]

{ #category : #'internal messages' }
PicoPointCode >> simpleMessage [

	^ 10 * 10
]

{ #category : #messages }
PicoPointCode >> summingArg: arg1 arg2: arg2 [
	
	^ arg1 + arg2
]

{ #category : #messages }
PicoPointCode >> swappingArg: arg1 arg2: arg2 [
	
	^ self send: #summingArg:arg2: withArguments: { arg1 . arg2}
]

{ #category : #'internal messages' }
PicoPointCode >> usingTempValue [

	| temp | 
	temp := 10.
	temp := temp + temp.
	^ temp
]

{ #category : #'return and access' }
PicoPointCode >> x [ 

	^ x
]

{ #category : #'return and access' }
PicoPointCode >> x: anInteger [

	x := anInteger
]

{ #category : #'return and access' }
PicoPointCode >> y [

	^ y
]

{ #category : #'return and access' }
PicoPointCode >> y: anInteger [

	y := anInteger
]