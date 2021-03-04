-- client.lua
-- local socket = require("socket")
local TcpClient = class("TcpClient")

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_CONNECTED_REFUSED = "connection refused"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

TcpClient.EVENT_DATA = "SOCKET_TCP_DATA"
TcpClient.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
TcpClient.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
TcpClient.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
TcpClient.EVENT_NOT_CONNECTED = "SOCKET_TCP_NOT_CONNECTED"
TcpClient.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"
TcpClient.EVENT_ERROR = "EVENT_ERROR"

local SOCKET_CHECK_TIME = 0.2

function TcpClient:ctor(params)
    self._host = params.host
    self._port = params.port
    self._is_connected = false

    cc.bind(self, "event")
end

function TcpClient:connect()
    local ipv6 = self:isIpv6(self.host)
    self.tcp = ipv6 and socket.tcp6() or socket.tcp()
    self.tcp:settimeout(0)
    self.tcp:setoption("tcp-nodelay", true)
    self:resetSchedule()

    self.connect_schedule_id = ScheduleMgr:create(function ()
        local succ, status = self:_connect()
        if succ then
            self:_recvData()
        else
        end
    end, SOCKET_CHECK_TIME)
end

function TcpClient:isIpv6(host)
    local addrinfo, err = socket.dns.getaddrinfo(host)
    if addrinfo then
        for i, v in ipairs(addrinfo) do
            if v.family == "inet6" then
                Log.print("TcpClient:isIpv6")
                return true
            end
        end
    end
    Log.print("TcpClient:isIpv4")
    return false
end

function TcpClient:resetSchedule()
    if self.connect_schedule_id then
        ScheduleMgr:destroy(self.connect_schedule_id)
        self.connect_schedule_id = nil
    end
    if self.recv_data_handler then
        ScheduleMgr:destroy(self.recv_data_handler)
        self.recv_data_handler = nil
    end
end

function TcpClient:_connect()
    local succ, status = self.tcp:connect(self.host, self.port)
    Log.print("TcpClient._connect: succ = %s", tostring(succ))
    Log.print("TcpClient._connect: status = %s", tostring(status))

    --说明有问题
    -- if succ ~= 1 or status ~= STATUS_ALREADY_CONNECTED then
    --     local __mysucc = succ or 999
    --     local __mystatus = status or 999
    -- end

    -- return succ == 1 or status == STATUS_ALREADY_CONNECTED, status
    return succ, status
end

function TcpClient:_recvData()
    Log.print("TcpClient.onConnectd ----------------------------")
    --连接成功，把不断重复连接的全局定时器去掉，加入一个新的全局定时，为检测连接数据
    self:resetSchedule()
    self._is_connected = true
    self:dispatchEvent({name=TcpClient.EVENT_CONNECTED})

    self.recv_data_handler = ScheduleMgr:create(function()
        self:_checkData()
    end, SOCKET_CHECK_TIME)
end

function TcpClient:_checkData()
    while true do
        if not self._is_connected then
            return
        end
        
        local __body, __status, __partial = self.tcp:receive("*a")

        if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
            Log.print("%s.checkData, status = %s", "TcpClient", tostring(status))
            self:_onDisconnect()
            return
         end
                
            if (__body and string.len(__body) == 0) or (__partial and string.len(__partial) == 0) then
                return 
            end
                
            if __body and __partial then
                
            __body = __body .. __partial
            
        end
        self:dispatchEvent({name=SocketTCP.EVENT_DATA, data=(__partial or __body), partial=__partial, body=__body})
    end
end

function TcpClient:_onDisconnect()
    Logger.printf("TcpClient.onDisconnect ----------------------------")
    self:dispatchEvent({name=TcpClient.EVENT_CLOSED})
    if self._disDialog ~= nil then
        return
    end

    self:_close()
    --[[当前版本不再支持重连，因为重连时机环境复杂
    --如果因为其他问题，导致需要调用该接口，主动断开连接，那么会尝试重连
    --重连内部有机制反复调用，重新连接，直到无法重连
    self.isConnected = false
    self:resetTimers()
    self.tcp:close()
    if self.onDisConnectedCallback then
        self.onDisConnectedCallback()
    end
    local reconnect = function()
        self.is_reconnecting = true
        self:_reconnect(function(ret)
            self.is_reconnecting = false
            if ret then
                if self.onReConnectSuccessCallback then
                    self.onReConnectSuccessCallback()
                end
            else
                -- close
                gk.log("%s.onClosed after try %d times ----------------------------", self.name, self.max_reconnect_times)
                self:close()
            end
        end)
    end
    if self.mockDisConnect then
        self.check_data_handler = scheduler.performWithDelayGlobal(reconnect, 6)
    else
        if self.max_reconnect_times > 0 then
            reconnect()
        else
            self:close()
        end
    end]]
end

function TcpClient:_close()
    Logger.printf("TcpClient.close ===============================")
    self._is_connected = false
    self:resetSchedule()
    if self.tcp then
        self.tcp:close()
        self.tcp = nil
    end
    self:removeAllEventListeners()
    self:dispatchEvent({name=TcpClient.EVENT_CLOSED})
end