function translation(string, secondVariable)
    local result = Translation[Config.Locale][string]
    if secondVariable then
        result = result:gsub("%%s", secondVariable)
    end
    return result or string
end
