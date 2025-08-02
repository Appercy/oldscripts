local sprites = {}

function NewSprite(TxtDictionary, TxtName, X, Y, Width, Height, Heading, R, G, B, A)
    local sprite = Sprite.New(TxtDictionary, TxtName, X, Y, Width, Height, Heading, R, G, B, A)
    table.insert(sprites, sprite)
    return sprite
end


function createrectangle()