LockSteeringAxleEvent = {}
local LockSteeringAxleEvent_mt = Class(LockSteeringAxleEvent, Event)

InitEventClass(LockSteeringAxleEvent, "LockSteeringAxleEvent")

function LockSteeringAxleEvent:emptyNew()
    local self = Event.new(LockSteeringAxleEvent_mt)
    return self
end

function LockSteeringAxleEvent:new(vehicle, isLocked)
    local self = LockSteeringAxleEvent:emptyNew()
    self.vehicle = vehicle;
    self.isLocked = isLocked;

    return self;
end

function LockSteeringAxleEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle);
    streamWriteBool(streamId, self.isLocked);
end

function LockSteeringAxleEvent:readStream(streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId);
    self.isLocked = streamReadBool(streamId);

    self:run(connection);
end

function LockSteeringAxleEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection, self.vehicle);
    end

    self.vehicle:setSteeringAxle(self.isLocked, true);
end

function LockSteeringAxleEvent.sendEvent(vehicle, isLocked, noEventSend)
    if noEventSend == nil or not noEventSend then
        if g_server ~= nil then
            g_server:broadcastEvent(LockSteeringAxleEvent:new(vehicle, isLocked), nil, nil, vehicle)
        else
            g_client:getServerConnection():sendEvent(LockSteeringAxleEvent:new(vehicle, isLocked))
        end
    end
end