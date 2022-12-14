require "lib.moonloader"

script_authors("Memes & Hatori")
script_description("������ 060822")
script_version("09.08.2022")
script_properties('Work-in-pause')
script_url("https://github.com/MemesClub/sletchecker?")

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('��������� %d �� %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('�������� ���������� ���������.')sampAddChatMessage(b..'���������� ���������!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'���������� ������ ��������. �������� ���������� ������..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': ���������� �� ���������.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, ������� �� �������� �������� ����������. ��������� ��� ��������� �������������� �� '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/rangeraid/checkerslen/main/sletchecker%20(2).lua" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://raw.githubusercontent.com/rangeraid/checkerslen/main/penIs.json"
        end
    end
end

local idstr = '%[(%d+)%] (.+) %| �������: (%d+) %| UID: (%d+)' -- [00:39:52] [1] Cursed_Gitlerov | �������: 0 | UID: -1 | packetloss: 0.00 (��������� �������)
local house = '(.+) (.+)%[(%d+)%] ����� ��� ID: (%d+) �� ���. ���� �� (%d+).(%d+) ms!'
local biz = '(.+) (.+)%[(%d+)%] ����� ������ ID: (%d+) �� ���. ���� �� (%d+).(%d+) ms!'
local car = '(.+) (.+)%[(%d+)%] ����� ��������� �� ���� %((.+)%), ����: (.+), ���������: (.+)'

local encoding = require 'encoding' -- ���������� ��� ���������� �������� ������� ����
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'lib.samp.events' -- ���������� ��� ���� �������� ������ �� ������
local effil = require 'effil' -- ��� ������������ ��������
local check= false
local url = 'https://discord.com/api/webhooks/1003780941291991090/JdnaUneuCFtQpxGbW2UUbfCqfUjipDjJ0zIMUnN4B1CFUBYCYyjVEsVxR1Wk_6Wis7SG'
local data = {
    ['username'] = '',
    ['avatar_url'] = '',
    ['content'] = '',
    ['embeds'] = {
        {
            ['title'] = '',
            ['description'] = '',
            ['color'] = ''
        }
    }
}

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    -- ������ ���, ���� ������ ��������� �������� ����������
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
nickname = sampGetPlayerNickname(id)
data['username'] = nickname
end

function sampev.onServerMessage(color, text)
    if text:find(idstr) and check then
        check=false
        local playerId, playerName, playerlvl, playerUID = text:match(idstr)
        data['embeds'][1]['description'] =data['embeds'][1]['description']..'�����: '..playerName..' ['..playerId..']\n�������: '..playerlvl..'\nUID: '..playerUID..''
        asyncHttpRequest('POST', url, {headers = {['content-type'] = 'application/json'}, data = u8(encodeJson(data))})
        return false
    end
    
    if text:find(house) then
      local nothing,playerName, playerId, houseId, timeslet, timesletms  = text:match(house)  -- [02:00:08] Liniks_Burton [3] ����� ��� ID: 481 �� ���. ���� �� 1.19 ms! (old)
      playerId=tonumber(playerId)
      data['embeds'][1]['description'] = '��� ���������: ��� ['..houseId..'] ('..timeslet.. '.' ..timesletms..'ms)\n'
      data['embeds'][1]['color']=0x9b59b6
      send_rpc_command('/id '..playerId)
      check=true
      return
    end
    
    if text:find(biz) then
      local nothing,playerName, playerId, bizId, timeslet, timesletms  = text:match(biz)  -- [04:00:24] Cristiano_Depressed [179] ����� ������ ID: 93 �� ���. ���� �� 2.84 ms! (old)
      playerId=tonumber(playerId)
      data['embeds'][1]['description'] = '��� ���������: ������ ['..bizId..'] ('..timeslet.. '.' ..timesletms..'ms)\n'
      data['embeds'][1]['color']=0x9b59b6
      send_rpc_command('/id '..playerId)
      check=true
      return
    end
    
    if text:find(car) then
      local nothing,playerName, playerId, carname, price, salon  = text:match(car) -- [A] Player[777] ����� ��������� �� ���� (VAZ 2108), ����: $100000, ���������: ������.
      playerId=tonumber(playerId)
      data['embeds'][1]['description'] = '��� ���������:\n��������� '..carname..' ['..price..']  '..salon
      data['embeds'][1]['color']=0xfa0a3e
      send_rpc_command('/id '..playerId)
      check=true
      return
    end
end

function asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function (method, url, args)
      local requests = require 'requests'
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- ���� ������ ��� ������� ��������� ������ � ������.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- �������� ���������� ������
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function send_rpc_command(text)
    local bs = raknetNewBitStream()
    local rn = require 'samp.raknet'
    raknetBitStreamWriteInt32(bs, #text)
    raknetBitStreamWriteString(bs, text)
    raknetSendRpc(rn.RPC.SERVERCOMMAND, bs)
    raknetDeleteBitStream(bs)
end
