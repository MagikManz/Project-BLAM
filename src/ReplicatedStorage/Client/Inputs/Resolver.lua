local MAPPED_KEYS: { { Enum.KeyCode | Enum.UserInputType | Enum.UserInputState }  }  = {
    { Enum.KeyCode.Q, Enum.KeyCode.DPadLeft },
    { Enum.KeyCode.R, Enum.KeyCode.ButtonX },
    { Enum.KeyCode.ButtonY },
    { Enum.KeyCode.ButtonR3 }, 
    { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 },
    { Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2 },
    { Enum.UserInputType.MouseWheel, Enum.KeyCode.Thumbstick2 },

    { Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3 }
}

return function(inputObject: InputObject): (Enum.KeyCode | Enum.UserInputType | Enum.UserInputState)?
    for _, keys in ipairs(MAPPED_KEYS) do
        if table.find(keys, inputObject.KeyCode) or table.find(keys, inputObject.UserInputType) then
            return keys[1]
        end
    end

    return nil
end
