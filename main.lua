local baseDir = fs.getDir(shell.getRunningProgram())
local commandDir = fs.combine(baseDir,"commands")
local configPath = fs.combine(baseDir,"config")
local config = {}

os.loadAPI(fs.combine(baseDir,"color.lua"))

local findAnyPeripheral = function(...)
	local arg = {...}
	local periph
	for a = 1, #arg do
		periph = peripheral.find(arg[a])
		if periph then
			return periph
		end
	end
	return false
end

local getEvents = function(...)
	local arg, evt = {...}
	while true do
		evt = {os.pullEvent()}
		if #arg > 0 then
			for a = 1, #arg do
				if evt[1] == arg[a] then
					return table.unpack(evt)
				end
			end
		else
			return table.unpack(evt)
		end
	end
end

local chatbox, CB
local getChatbox = function()
	chatbox = findAnyPeripheral("chatbox","chat_box")
	if chatbox then
		CB = {
			say = chatbox.say,
			tell = chatbox.tell,
		}
		return true
	else
		return false
	end
end

local writeConfig = function()
	local file = fs.open(configPath,"w")
	file.write(textutils.serialize(config))
	file.close()
end

local readConfig = function()
	local file = fs.open(configPath,"r")
	config = textutils.unserialize(file.readAll())
	file.close()
end

local explode = function(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,false) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end

local runCommand = function(command, ...)
	local cmdList = fs.list(commandDir)
	for a = 1, #cmdList do
		if cmdList[a]:lower() == command:lower() do
			local comm = loadfile(fs.combine(commandDir,cmdList[a]))
			local golly_G = setmetatable({}, {__index=(_ENV or getfenv())})
			golly_G.CB = CB
			golly_G.shell.getRunningProgram = function() return fs.combine(commandDir,cmdList[a]) end
			comm = setfenv(comm,golly_G)
			return true, comm(...)
		end
	end
	return false, "No such command."
end

local main = function()
	while true do
		local playerName, message = getEvents("chat", "chat_message")
		local parse = explode(" ",message)
		local res, output = runCommand(table.unpack(parse))
	end
end
