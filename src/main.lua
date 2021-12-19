---@type string directory of the mod.
local mod_directory = g_currentModDirectory or ""
---@type string name of the mod.
local mod_name = g_currentModName or "unknown"

RegisterLockSteeringAxle = {}
RegisterLockSteeringAxle.loaded = false
RegisterLockSteeringAxle.debug = false

function RegisterLockSteeringAxle.register(typeManager)
    if RegisterLockSteeringAxle.debug then print("LockSteeringAxle -- register!") end

    if typeManager.typeName == "vehicle" then
        g_specializationManager:addSpecialization("lockSteeringAxle", "LockSteeringAxle", mod_directory .. "src/LockSteeringAxle.lua", nil)

        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(Attachable, typeEntry.specializations) then
                g_vehicleTypeManager:addSpecialization(typeName, mod_name .. ".lockSteeringAxle")
            end
        end
    end
end

function RegisterLockSteeringAxle:init()
    if RegisterLockSteeringAxle.debug then print("LockSteeringAxle -- init!") end
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, RegisterLockSteeringAxle.register)
end

---Helper method for getting the scoped spec table.
function Vehicle:getSpec()
    return self["spec_" .. mod_name .. ".lockSteeringAxle"]
end

RegisterLockSteeringAxle:init()