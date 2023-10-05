export type ResolvedInput = Enum.KeyCode | Enum.UserInputType | Enum.UserInputState
export type InputSystem = {
    InputSettings: { [string]: any },

    InputBegan: (resolvedInput: ResolvedInput, input: InputObject, processed: boolean) -> (),
    InputChanged: (resolvedInput: ResolvedInput, input: InputObject) -> any,
    InputEnded: (resolvedInput: ResolvedInput, input: InputObject) -> ()
}

return true
