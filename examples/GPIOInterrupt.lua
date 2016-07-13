pinTicket   = 1
pinOrder    = 2
pinCancel   = 3

function ticketISR(level)
  print("ticket ISR");
  if level == 1 and m~=nil then
     -- rising edge
     m:publish("/request/"..dev_id, "ticket",0,0)
  else
  end
end

function orderISR(level)
  print("order ISR");
  if level == 1 and m~=nil then
     -- rising edge
     m:publish("/request/"..dev_id, "order",0,0)
  else
  end
end

function cancelISR(level)
  print("cancel ISR");
  if level == 1 and m~=nil then
     -- rising edge
     m:publish("/request/"..dev_id, "cancel",0,0)
  else
  end
end

gpio.mode(pinTicket, gpio.INT);
gpio.mode(pinOrder, gpio.INT);
gpio.mode(pinCancel, gpio.INT);

gpio.trig(pinTicket, "high", ticketISR)
gpio.trig(pinOrder, "high", orderISR)
gpio.trig(pinCancel, "high", cancelISR)
