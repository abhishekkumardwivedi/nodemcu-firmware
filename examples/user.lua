----------- [ Configure these before flashing ] --------------------------
dev_id      = "table1"      -- this is the id given to this mqtt client
                            -- and has to be unique for each.
wifi_ssid   = "BOX2"
wifi_passwd = "test12345"
mqtt_host   = "192.168.0.104" --mqtt broker server ip address
mqtt_port    = 8884
--------------------------------------------------------------------------/

-----------[ DONT change these. Keep in sync with server ]----------------
topic_order  = "order"
topic_ticket = "ticket"
topic_cancel = "cancel"
--------------------------------------------------------------------------/

-------------------------
--  IO      ESP8266 pin
--  0[*]    GPIO16  --  [pin 0 doesn't support interrupt]

--  1       GPIO5   
--  2       GPIO4   
--  3       GPIO0   
--  4       GPIO2   
--  5       GPIO14  
--  6       GPIO12  
--  7       GPIO13
--  8       GPIO15

--  9       GPIO3
--  10      GPIO1
--  11      GPIO9
--  12      GPIO10
-----------------------
-----[input pins to be used, config it according to h/w connection] ---------
pinTicket   = 5
pinOrder    = 6
pinCancel   = 7
-----------------------------------------------------------------------------/

----------------- All config ends here --------------------------------------/

print("WiFi connection initiated.....")
print(wifi.sta.getip())
--nil
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_passwd)
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
        m=mqtt.Client(dev_id, 60, "test", "test123")

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
        m:connect(mqtt_host, mqtt_port, 0, 1)
        tmr.alarm(0,10000,1,function()
            m:publish("/breathing/"..dev_id, dev_id.." breathing "..tmr.time(),0,0) -- keep server know that
                                                             -- I am alive. For Debugging.
            end)
         -------------------------------------------
     end
end)

oldlevel_ticket = 0
function ticketISR(level)
  print("ticket ISR");
  if level == 1 and m~=nil and oldlevel_ticket == 0 then
     oldlevel_ticket = 1
     -- rising edge
     m:publish("/request/"..dev_id, topic_ticket, 0, 0)
  else
     oldlevel_ticket = 0
  end
end

function orderISR(level)
  print("order ISR");
  if level == 1 and m~=nil then
     -- rising edge
     m:publish("/request/"..dev_id, topic_order, 0, 0)
  else
  end
end

function cancelISR(level)
  print("cancel ISR");
  if level == 1 and m~=nil then
     -- rising edge
     m:publish("/request/"..dev_id, topic_cancel, 0, 0)
  else
  end
end

gpio.mode(pinTicket, gpio.INPUT);
gpio.mode(pinOrder, gpio.INT);
gpio.mode(pinCancel, gpio.INT);

gpio.trig(pinTicket, "high", ticketISR)
gpio.trig(pinOrder, "high", orderISR)
gpio.trig(pinCancel, "high", cancelISR)
