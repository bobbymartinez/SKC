-- Tutorial: https://www.youtube.com/watch?v=nfaE7NQhMlc&list=PL3wt7cLYn4N-3D3PTTUZBM2t1exFmoA2G
-- FUNCTION
--[[
local myFunc = function() 
	local x;
	x = 3;
  return x;
end
--]]
-- CLASS
--[[
local MyClass = {
  -- index:
  1,2,3,4,
  -- hash table:
  size = 5,
}
--]]
-- FOR LOOP (NUMERIC)
--[[

for i = startValue, endValue, stepValue do
  -- code to iterate
end

--]]
-- FOR LOOP (GENERIC)
-- will iterate index part first then hash table portion
-- Will not necessarily print hash table in order
--[[

for key, value in pairs(tbl) do
  -- code to iterate
end

--]]
-- to print out just the index part, use ipairs
-- WHILE LOOP
--[[

while (true) do
end

--]]
-- DO LOOP
--[[

repeat
until (condition)

--]]
-- No switch statements, no continue statements (there is a break)
-- LAYERS
-- Layers placed in order to display graphics
-- Frame = Canvas, Layer = paint on top
-- BACKGROUND
-- BORDER
-- ARTWORK
-- OVERLAY
-- HIGHLIGHT
------------------------------------------------------------------------------------------------
local _, core = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["config"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		print(" ");
		core:Print("List of slash commands:")
		core:Print("|cff00cc66/skc config|r - shows config menu");
		core:Print("|cff00cc66/skc help|r - shows help info");
		print(" ");
	end,
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...));
		end
	}
};

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/skc" with no additional args.
		core.commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "SKC:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- WARNING: self automatically becomes events frame!
function core:init(event, name)
	if (name ~= "SKC") then return end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_SKC1 = "/skc";
	SlashCmdList.SKC = HandleSlashCommands;
	
    core:Print("Welcome back", UnitName("player").."!");
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);