# EditableEquation
This is an app with the goal of creating a mobile-first advanced scientific calculator.

## Features
- [ ] This is a thing

## `EditableEquationKit`
This is the package that powers EditableEquation.

### Features
// TODO

### Terminology
- `EquationToken`: A protocol defining a single token. Do not implement.
- `GroupEquationToken`: A protocol implementing `EquationToken`, representing a token that contains other tokens

### Sub-packages
- `EditableEquationCore`: This is where all the foundational protocols are defined. You 
should only import this if you are defining a custom Group Token
- `EditableEquationKit`: This is where the functionality is defined, including the tokens' 
and managers' implementations.
- `EditableEquationUI`: This is where the UI of EditableEquationKit is defined.
