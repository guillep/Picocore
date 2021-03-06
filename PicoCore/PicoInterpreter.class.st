"
I'm an hybrid interpreter for the pico language. 
Pico language is nearly the same as Pharo except that it does not return in block, not blocks.

Pico only supports: 
	- message sends using send: and send:withArgument:
	- primitive compution using any pharo messages`
	- assignemt
	- direct access to variables stored in picoBlop objects.

It does not support global access, block, conditionals and loops.


For example in the following method x refers to x stored in an instance (an instance of the class PicoBlop) of the picoClass (an instance of the picoBlop class PicoColoredPoint).

dotProduct: aPicoPoint 
	""Answer a number that is the dot product of the receiver and the argument, aPoint. 
	That is, the two points are multipled and the coordinates of the result summed.""

	^ (x * (aPicoPoint send: #x)) + (y * (aPicoPoint send: #y))
	

Implementation
	arguments is an array to be able to pass arguments from a picoBlop expression to the interpreter.
	Internally the arguments are pushed in the current scope via this variable.	
	


Possible extensions:
Adding support for condition.

>> visitMessageNode: aMessageNode [

  (aMessageNode selector = #ifTrue:) ifTrue: [
      ^ self evaluateIfTrue: aMessageNode ].

  “Do the normal case”
]

>> evaluateIfTrue: aMessageNode [
  condition := aMessageNode receiver accept: self.
  condition = true “are pico booleans pharo booleans?”
    ifTrue: [ | blockNode |
      blockNode := aMessageNode arguments first.
      blockNode body acceptVisitor: self ]
]



"
Class {
	#name : #PicoInterpreter,
	#superclass : #RBCollectingProgramNodeVisitor,
	#instVars : [
		'stack',
		'arguments',
		'argumentIndex'
	],
	#category : #'PicoCore-Core'
}

{ #category : #accessing }
PicoInterpreter >> arguments: anArray [
	"Represent the original arguments of a message.
	Look at PicoBlop >> send: aSelector withArguments: anArray"
	arguments := anArray
]

{ #category : #initialization }
PicoInterpreter >> initialize [ 
	super initialize.
	arguments := #().
	stack := Stack new.
	"We create the first empty environment and push it on top of the 
	stack of enviroment corresponding to message send." 
	stack push: self newFrame.
]

{ #category : #'stack management' }
PicoInterpreter >> newFrame [
	"a new scope is an environment, i.e., a dictionary which support lookup in its parent.
	This is important to manage variable shadowing. A local temp can hide another temp of a parent
	scope in a local scope."
	^ CTEnvironment new
]

{ #category : #'stack management' }
PicoInterpreter >> pushNewFrame [
	"Pushing a new scope consists in creating a new dictionary whose parent is the top of the stack
	and pushing it as a new top. This way variable not found in current scope will be looked up in previous scope."

	| newTop |
	newTop := self newFrame.
	newTop parent: stack top.
	stack push: newTop 
	
]

{ #category : #accessing }
PicoInterpreter >> receiver [
	"Return the value of the binding to #self in the current scope."
	
	^ self valueOfTempVariable: #self
]

{ #category : #accessing }
PicoInterpreter >> receiver: anObject [
	"We add a new binding #self and the argument in the current scope."
	self setValueOfTempVariable: #self to: anObject 
]

{ #category : #'stack management' }
PicoInterpreter >> setValueOfTempVariable: name to: aValue [
	^ stack top at: name put: aValue 
]

{ #category : #'stack management' }
PicoInterpreter >> stack [
	^ stack
]

{ #category : #'stack management' }
PicoInterpreter >> valueOfTempVariable: name [
	"Return the value of the temporary named name in the current scope."
	
	^ stack top at: name
]

{ #category : #visiting }
PicoInterpreter >> visitArgumentNode: anArgumentNode [
	"Sent *each time* an argument node is found"

	^ self valueOfTempVariable: anArgumentNode name
]

{ #category : #visiting }
PicoInterpreter >> visitAssignmentNode: anAssignmentNode [
	
	| value |
	value := self visitNode: anAssignmentNode value. 
	anAssignmentNode variable isInstance
		ifTrue: [ self receiver setValueOfInstanceVariable: anAssignmentNode variable name to: value ]
		ifFalse: [ self setValueOfTempVariable: anAssignmentNode variable name to: value ]
]

{ #category : #visiting }
PicoInterpreter >> visitGlobalNode: aGlobalNode [

	^ Smalltalk globals at: aGlobalNode name ifAbsent: [ nil ]
]

{ #category : #visiting }
PicoInterpreter >> visitInstanceVariableNode: aVariableNode [

	^ self receiver valueOfInstanceVariable: aVariableNode name
]

{ #category : #visiting }
PicoInterpreter >> visitLiteralNode: aLiteralNode [
	
	^ aLiteralNode value
]

{ #category : #visiting }
PicoInterpreter >> visitMessageArgumentNodes: aCol [

	^ aCol collect: [ :each | self visitMessageArgumentNode: each ]
]

{ #category : #visiting }
PicoInterpreter >> visitMessageNode: aMessageNode [
	
	^ ((aMessageNode selector = #send:) or: [ aMessageNode selector = #send:withArguments: ])
		ifTrue: [ 
			| rec |
			self pushNewFrame.
			rec := (self visitMessageReceiver: aMessageNode receiver).
			self setValueOfTempVariable: #self to: rec. 
			arguments := aMessageNode arguments allButFirst flatCollect: [ :each | self visitNode: each ].
			"here the arguments are passed in a { } so we should dewrap."
			^ aMessageNode receiver isSuper
				ifTrue: [ self visitMethodNode: (rec picoClass picoSuperclass lookup: aMessageNode arguments first value) ]
				ifFalse: [ self visitMethodNode: (rec picoClass lookup: aMessageNode arguments first value) ]
			]		
		ifFalse: [  
			"we evaluate the receiver and the arguments and execute the selector using them."
			(self visitMessageReceiver: aMessageNode receiver) 
				perform: aMessageNode selector 	
				withArguments: (self visitMessageArgumentNodes: aMessageNode arguments) asArray
			 ]

]

{ #category : #'visiting variable' }
PicoInterpreter >> visitParameterNode: aNode [
	"We visit a method definition and its parameters i.e., foo: arg"
	
	self setValueOfTempVariable: aNode name to: (arguments at: argumentIndex).
	argumentIndex := argumentIndex + 1. 
]

{ #category : #'visiting variable' }
PicoInterpreter >> visitParameterNodes: aCol [

	argumentIndex := 1.
	super visitParameterNodes: aCol
]

{ #category : #visiting }
PicoInterpreter >> visitReturnNode: aMethodNode [
	| val | 
	val := super visitReturnNode: aMethodNode.
	stack pop.
	^ val
]

{ #category : #'visiting variable' }
PicoInterpreter >> visitSelfNode: aSelfNode [
	"The value of self is the message receiver"
	^ self receiver
]

{ #category : #'visiting variable' }
PicoInterpreter >> visitSuperNode: aSuperNode [
	"The value of super is the receiver. Yes madam!"

	^ self receiver
]

{ #category : #'visiting variable' }
PicoInterpreter >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [
	"We do nothing for declaration of temps since there is no initial value in the temps definition"

	^ self
]

{ #category : #'visiting variable' }
PicoInterpreter >> visitVariableNode: aNode [
	"The value of a variable is to look for in the current environment"
	"Note that visitVariableNode: is not invoked for instance variable.
	It is visitInstanceVariableNode: that deals with instance variable."
	
	^ self valueOfTempVariable: aNode name
]
