vRP = Proxy.getInterface("vRP")

----- CONFIG -----
local rentCoords = {-1388.392211914,44.296436309814,53.61347579956} -- coordonatele rent-ului
local rentCar = "t20" -- codul de spawn al masinii
local timpRent = 10 -- aici pui cate minute vrei sa se poata inchiria masina (dupa X minute, masina se va sterge)
local spawnVeh = vector3(-1395.044555664,42.60832977295,53.437847137452) -- coordonatele unde sa se spawneze masina dupa ce o inchiriezi
local heading = 160.06 -- heading-ul masinii (in ce parte sa se spawneze atunci cand o inchiriezi)
-- [CA SA MODIFICATI PRETUL INCHIRIATULUI, VA DUCETI IN SERVER.LUA, SI AVETI ACOLO LA CONFIG] --
----- CONFIG -----

Meniu = false
Inchiriat = false

local CreateThread = Citizen.CreateThread
local Wait = Citizen.Wait
local isPressed = IsDisabledControlJustPressed

--- Incarcarea Iconitelor + blip ---
CreateThread(function()
  createBlip(rentCoords[1], rentCoords[2], rentCoords[3],"Inchirieri Autovit",76,63) -- adauga blip-ul pe harta
  local rentPhoto = CreateRuntimeTxd("rentPhoto")
  CreateRuntimeTextureFromImage(rentPhoto, "rentPhoto", "img/rentPhoto.png")
end)
--- Incarcarea Iconitelor + blip ---

--- De aici incepe magia :x ---
CreateThread(function()
     while true do
        Wait(1)
        local ped = PlayerPedId(-1)
        local pedc = GetEntityCoords(ped)
        if(Vdist(GetEntityCoords(GetPlayerPed(-1)),rentCoords[1],rentCoords[2],rentCoords[3]) <= 3.0) then
              DrawMarker(6, rentCoords[1],rentCoords[2],rentCoords[3], 0.5, 0.9, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 80, false, false, 2, true, nil, false)
              DrawMarker(36, rentCoords[1],rentCoords[2],rentCoords[3], 0.5, 0.9, 0.0, 0.0, 360.0, 0.0, 0.5, 0.5, 0.5, 63, 191, 63, 80, false, false, 2, true, nil, false)
              drawSubtitleText("Apasa ~g~[E] ~w~pentru a deschide ~r~meniul")
            if isPressed(0, 38) then
                if not Inchiriat then
                    Meniu = true
                else
                    vRP.notify({'~r~Ai inchiriat deja o masina !'})
                end
            elseif Meniu then
                         DisableControlAction(0,24,true)
                         DisableControlAction(0,47,true)
                         DisableControlAction(0,58,true)
                         DisableControlAction(0,263,true)
                         DisableControlAction(0,264,true)
                         DisableControlAction(0,257,true)
                         DisableControlAction(0,140,true)
                         DisableControlAction(0,141,true)
                         DisableControlAction(0,142,true)
                         DisableControlAction(0,143,true)
                         DisableControlAction(0, 1, true)
                         DisableControlAction(0, 2, true)
                         DrawRect(0.5,0.5,0.4,0.4,25,25,25,225) -- meniul main
                         DrawRect(0.5,0.677,0.055,0.025,63,127,191,255) -- butonul "anuleaza"
                         --- BORDERS ---
                         DrawRect(0.3,0.500,0.005,0.400,63,127,191,255) -- stanga
                         DrawRect(0.7,0.500,0.005,0.400,63,127,191,255) -- dreapta
                         DrawRect(0.5,0.300,0.405,0.005,63,127,191,255) -- sus
                         DrawRect(0.5,0.700,0.405,0.005,63,127,191,255) -- jos
                         ---------------
                         drawCustomScreenText(0.5, 0.66, 0,0, 0.38, "~w~ANULEAZA", 255, 255, 255, 230, 6, 1)
                         drawCustomScreenText(0.5, 0.255, 0,0, 0.58, "AUTOVIT", 63, 127, 191, 255, 6, 1)
                         drawCustomScreenText(0.5, 0.30, 0,0, 0.50, "APASA PE MASINA PENTRU A O INCHIRIA\n("..timpRent.." MINUTE)", 255, 255, 255, 230, 6, 1)
                         DrawSprite("rentPhoto","rentPhoto",0.50, 0.45,0.21,0.24,0.0,255,255,255,255)  -- poza masina
                         ShowCursorThisFrame()
                if(isCursorInPosition(0.5, 0.68, 0.070, 0.020))then  
                  SetMouseCursorSprite(5)
                  if isPressed(0, 24) then
                    Meniu = false
                end
              elseif(isCursorInPosition(0.50, 0.50, 0.13, 0.20)) then
                    SetMouseCursorSprite(5)
                    if isPressed(0, 24) then
                        Meniu = false
                        TriggerServerEvent('InchiriazaMasinaInMM',rentCar)
                    end
                  end
            end
          else
        end
  end
end)
--- Aici se termina magia :c ---

------- FUNCTIONS (DO NOT TOUCH) -------
RegisterNetEvent('SpawnVehInMM')
AddEventHandler('SpawnVehInMM',function(theVeh)
    faMasinaAdvZic(theVeh,spawnVeh,heading)
end)

function faMasinaAdvZic(masina,pos,heading)
    local hash = GetHashKey(masina)
    local n = 0
    while not HasModelLoaded(hash) and n < 500 do
        RequestModel(hash)
        Citizen.Wait(10)
        n = n+1
    end

    if HasModelLoaded(hash) then
        Inchiriat = false
        veh = CreateVehicle(hash,pos,heading,true,false)
        SetEntityHeading(veh,heading)
        SetEntityInvincible(veh,false)
        SetModelAsNoLongerNeeded(hash)
        SetVehicleNumberPlateTextIndex(veh,2)
        SetVehicleNumberPlateText(veh,"AUTOVIT")
        SetPedIntoVehicle(GetPlayerPed(-1),veh,-1)

        Citizen.SetTimeout(timpRent * 60 * 1000,function()
            if DoesEntityExist(veh) then
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
                vRP.notify({'~g~Masina pe care ai inchiriat-o a fost returnata !'})
            end
        end)

    else
        vRP.notify({'~r~Masina nu a fost incarcata!'})
    end    
end

function isCursorInPosition(x, y, width, height)
    local sx, sy = GetActiveScreenResolution()
    local cx, cy = GetNuiCursorPosition()
    local cx, cy = (cx / sx), (cy / sy)

    local width = width / 2
    local height = height / 2

    if (cx >= (x - width) and cx <= (x + width)) and (cy >= (y - height) and cy <= (y + height)) then
        return true
    else
        return false
    end
end

function drawCustomScreenText(x,y ,width,height,scale, text, r,g,b,a, font, center)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextCentre(center)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function drawSubtitleText(m_text, showtime)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(m_text)
    DrawSubtitleTimed(showtime, 1)
end

function createBlip(x,y,z,name,type,color)
    blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
end

function DrawText3D(x,y,z, text) 
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

  local scale = (1/dist)*2
  local fov = (1/GetGameplayCamFov())*130
  local scale = scale*fov
  
  if onScreen then
      SetTextScale(0.3*scale, 0.55*scale)
      SetTextFont(6)
      SetTextProportional(1)
      SetTextColour( 100, 200, 200, 255 )
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextColour(255,0,0,160)
      SetTextCentre(1)
      AddTextComponentString(text)
      World3dToScreen2d(x,y,z, 0)
      DrawText(_x,_y)
  end
end
-----------------------------------------
