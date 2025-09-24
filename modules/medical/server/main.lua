local BW = exports['bw_framework']:GetCoreObject()

-- Server-side code for medical
AddEventHandler('BW:Server:OnResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Initialize module when resource starts
end)

-- Add more server-side code here
