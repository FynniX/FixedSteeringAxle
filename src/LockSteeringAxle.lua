---@class LockSteeringAxle
LockSteeringAxle = {}

function LockSteeringAxle.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Attachable, specializations)
end

function LockSteeringAxle.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "setSteeringAxle", LockSteeringAxle.setSteeringAxle)
end

function LockSteeringAxle.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", LockSteeringAxle)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", LockSteeringAxle)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", LockSteeringAxle)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", LockSteeringAxle)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", LockSteeringAxle)
    SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", LockSteeringAxle)
end

function LockSteeringAxle:onLoad(savegame) 
    local spec = self:getSpec();
    local spec_wheels = self.spec_wheels;

    spec.hasSteeringAxle = false;

    if spec_wheels == nil or #spec_wheels.wheels == 0 then
		return;
	end;

    local xml = self.xmlFile.handle;
    local WheelId = Utils.getNoNil(spec_wheels.configurations["wheel"], 1);
    local WheelConfigurationKey = string.format("vehicle.wheels.wheelConfigurations.wheelConfiguration(%d).wheels", WheelId - 1);
    
    local WheelNumber = 0;
    while true do
        local WheelKey = WheelConfigurationKey .. string.format(".wheel(%d)", WheelNumber);

        if not hasXMLProperty(xml, WheelKey) then
            break;
        end

        local AxleRotMax = Utils.getNoNil(getXMLFloat(xml, WheelKey .. ".steeringAxle#rotMax"), 0);

        if AxleRotMax ~= 0 then
            spec.hasSteeringAxle = true;
        end

        WheelNumber = WheelNumber + 1;
    end

    if spec.hasSteeringAxle then
        if savegame ~= nil then
            spec.isLocked = Utils.getNoNil(getXMLBool(savegame.xmlFile.handle, savegame.key .. ".LockSteeringAxle.lockSteeringAxle#isLocked"), false);
        else
            spec.isLocked = false;
        end

        self:setSteeringAxle(spec.isLocked, false);
    end
end

function LockSteeringAxle:onUpdate()
    local spec = self:getSpec()
    local spec_attachable = self.spec_attachable

    if self.isClient and spec.hasSteeringAxle then
        local ActionButton = spec.actionEvents[InputAction.TOGGLE_LOCK_STEERING_AXLE]

        if ActionButton ~= nil then
            local currentText = g_i18n:getText("LOCK_STEERING_AXLE")

            if spec.isLocked then
                currentText = g_i18n:getText("UNLOCK_STEERING_AXLE")
            end

            g_inputBinding:setActionEventActive(ActionButton.actionEventId, true);
            g_inputBinding:setActionEventText(ActionButton.actionEventId, currentText);
        end
    end

    if spec.isLocked and spec.hasSteeringAxle then
        spec_attachable.steeringAxleAngle = 0
        spec_attachable.updateSteeringAxleAngle = false
    else
        spec_attachable.updateSteeringAxleAngle = true
    end
end

function LockSteeringAxle:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection) 
    local spec = self:getSpec()
    local spec_attachable = self.spec_attachable

    if self.isClient and spec.hasSteeringAxle and spec_attachable.steeringAxleTargetNode == nil then
        self:clearActionEventsTable(spec.actionEvents)
        
        if isActiveForInputIgnoreSelection then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LOCK_STEERING_AXLE, self, LockSteeringAxle.ToggleSteeringAxle, false, true, false, true, nil)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(actionEventId, true)
			g_inputBinding:setActionEventActive(actionEventId, false)
        end
    end
end

function LockSteeringAxle:onWriteStream(streamId, connection)
	if not connection:getIsServer() then
        local spec = self:getSpec();

        if spec.hasSteeringAxle then
            streamWriteBool(spec.isLocked);
        end
	end;
end;

function LockSteeringAxle:onReadStream(streamId, connection)
	if connection:getIsServer() then
        local spec = self:getSpec();

        if spec.hasSteeringAxle then
            spec.isLocked = Utils.getNoNil(streamReadBool(streamId), false);
            self:setSteeringAxle(spec.isLocked, true);
        end
	end;
end;

function LockSteeringAxle:saveToXMLFile(xmlFile, key)
    local spec = self:getSpec();

    if spec.hasSteeringAxle then
        setXMLBool(xmlFile.handle, key .. "#isLocked", spec.isLocked);
    end
end

function LockSteeringAxle.ToggleSteeringAxle(self)
    local spec = self:getSpec()
    self:setSteeringAxle(not spec.isLocked, false);
end

function LockSteeringAxle:setSteeringAxle(isLocked, noEventSend)
	local spec = self:getSpec()
	
	if isLocked ~= spec.isLocked then
		spec.isLocked = isLocked;
	end;

    LockSteeringAxleEvent.sendEvent(self, isLocked, noEventSend);
end;