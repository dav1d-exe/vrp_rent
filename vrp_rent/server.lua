local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_rent")

----- CONFIG -----
local pretRent = 1000
----- CONFIG -----

RegisterServerEvent('InchiriazaMasinaInMM')
AddEventHandler('InchiriazaMasinaInMM',function(theVehicle)
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
		if vRP.tryFullPayment({user_id,pretRent}) then
			vRPclient.notify(thePlayer,{'~g~Tocmai ai inchiriat o masina pentru pretul de '..formatMoney(pretRent)..'$ !'})
			TriggerClientEvent('SpawnVehInMM',thePlayer,theVehicle)
		else
			vRPclient.notify(thePlayer,{'~r~Nu ai destui bani pentru a inchiria o masina !'})
		end
end)




--- NU ATINGE !!! ---
function formatMoney(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end
--------------------

