AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() == resourceName) then
    Config.Functions.onend()
  end
end)
