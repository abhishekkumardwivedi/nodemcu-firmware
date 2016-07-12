----------- [ Configure these before flashing ] --------------------------
dev_id      = "table1"      -- this is the id given to this mqtt client
                            -- and has to be unique for each.
wifi_ssid   = "BOX2"
wifi_passwd = "test12345"
mqtt_host   = 192.168.0.103 --mqtt broker server ip address
--------------------------------------------------------------------------/

-----------[ DONT change these. Keep in sync with server ]----------------
mqtt_port    = 8884
topic_order  = "order"
topic_ticket = "ticket"
topic_cancel = "cancel"
--------------------------------------------------------------------------/

print("WiFi connection initiated.....")
print(wifi.sta.getip())
--nil
wifi.setmode(wifi.STATION)
wifi.sta.config("BOX2","test12345")
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
     if wifi.sta.getip() == nil then
         print("Connecting...")
     else
         tmr.stop(1)
         print("WiFi Connected. IP = "..wifi.sta.getip())

         --------------MQTT ------------------------
        m_dis={}
        function printMsg(m,t,pl)
            if pl~=nil then
                print(t.." : "..pl);
            end
        end

        -- Lua: mqtt.Client(clientid, keepalive, user, pass)
        m=mqtt.Client("nodemcu1",60,"test","test123")

        m:on("connect",function(m)
            print("connection "..node.heap())
            m:subscribe("/test/broadcast",0,function(m) print("sub done") end)
            end )

        m:on("offline", function(conn)
            print("disconnect to broker...")
            print(node.heap())
        end)
        m:on("message", printMsg )

        -- Lua: mqtt:connect( host, port, secure, auto_reconnect, function(client) )
        m:connect("192.168.0.103",8884,0,1)
        tmr.alarm(0,10000,1,function()
            m:publish("/breathing/"..dev_id, dev_id.." breathing "..tmr.time(),0,0) -- keep server know that
                                                             -- I am alive. For Debugging.
            end)
         -------------------------------------------
     end
end)