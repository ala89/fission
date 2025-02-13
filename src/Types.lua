export type State<T> = {
    type: "State"
}

export type CanBeState<T> = T | State<T>

export type Use = <T>(obj: CanBeState<T>) -> T

export type EqFn = <T>(a: T, b: T) -> boolean

export type Destructor = <T>(T) -> ()

export type Observer = {
  	onChange: (Observer, callback: () -> ()) -> (() -> ()),
    onDefer: (Observer, callback: () -> ()) -> (() -> ()),
    onBind: (Observer, callback: () -> ()) -> (() -> ())
}

export type SpecialKey = {
	type: "SpecialKey"
}

export type Value<T> = {
    type: "State",
    set: (Value<T>, newValue: T) -> ()
}

return nil