--------------------------------------
-- NAMESPACES
--------------------------------------
local _, core = ...; -- returns name of addon and namespace (core)
core.SKC_Main = {}; -- adds SKC_Main table to addon namespace

local SKC_Main = core.SKC_Main; -- assignment by reference in lua, ugh
local SKC_UIMain; -- Table for main GUI
local SKC_UICSV = {}; -- Table for GUI associated with CSV import and export
--------------------------------------
-- DEV CONTROLS
--------------------------------------
local HARD_DB_RESET = false; -- resets SKC_DB
local ML_OVRD = nil; -- name of faux ML override master looter permissions
local GL_OVRD = "Paskal"; -- name of faux GL to override guild leader permissions
local LOOT_SAFE_MODE = true; -- true if saving loot is immediately rejected
local LOOT_DIST_DISABLE = true; -- true if loot distribution is disabled
local LOG_ACTIVE_OVRD = false; -- true to force logging
local OVRD_CHARS = { -- characters which are pushed into GuildData
	-- Mctester = true,
	-- Skc = true,
};
-- verbosity
local VERBOSE = true; -- general verbosity flag
local COMM_VERBOSE = true; -- prints messages relating to addon communication
local LOOT_VERBOSE = true; -- prints lots of messages during loot distribution
--------------------------------------
-- LOCAL CONSTANTS
--------------------------------------
local DATE_FORMAT = "%m/%d/%Y %I:%M:%S %p"
local DAYS_TO_SECS = 86400;
local UI_DIMENSIONS = { -- ui dimensions
	MAIN_WIDTH = 920,
	MAIN_HEIGHT = 455,
	MAIN_BORDER_Y_TOP = -60,
	MAIN_BORDER_PADDING = 25,
	SK_TAB_TITLE_CARD_WIDTH = 80,
	SK_TAB_TITLE_CARD_HEIGHT = 40,
	SK_FILTER_WIDTH = 330,
	SK_FILTER_HEIGHT = 130,
	DECISION_WIDTH = 330,
	DECISION_HEIGHT = 200,
	SK_DETAILS_WIDTH = 270,
	SK_DETAILS_HEIGHT = 355,
	ITEM_WIDTH = 40,
	ITEM_HEIGHT = 40,
	SK_LIST_WIDTH = 175,
	SK_LIST_HEIGHT = 325,
	SK_LIST_BORDER_OFFST = 15,
	SK_CARD_SPACING = 6,
	SK_CARD_WIDTH = 100,
	SK_CARD_HEIGHT = 20,
	BTN_WIDTH = 75,
	BTN_HEIGHT = 40,
	STATUS_BAR_BRDR_WIDTH = 290,
	STATUS_BAR_BRDR_HEIGHT = 40,
	STATUS_BAR_WIDTH_OFFST = 24,
	STATUS_BAR_HEIGHT_OFFST = 24,
	CSV_WIDTH = 660,
	CSV_HEIGHT = 300,
	CSV_EB_WIDTH = 600,
	CSV_EB_HEIGHT = 200,
};

local THEME = { -- general color themes
	PRINT = {
		NORMAL = {r = 0, g = 0.8, b = 1, hex = "00ccff"},
		WARN = {r = 1, g = 0.8, b = 0, hex = "ffcc00"},
		ERROR = {r = 1, g = 0.2, b = 0, hex = "ff3300"},
		IMPORTANT = {r = 1, g = 0, b = 1, hex = "ff00ff"},
	},
	STATUS_BAR_COLOR = {0.0,0.6,0.0},
};

local OnClick_EditDropDownOption; -- forward declare for drop down menu details
local CLASSES = { -- wow classes
	Druid = {
		text = "Druid",
		color = {
			r = 1.0,
			g = 0.49,
			b = 0.04,
			hex = "FF7D0A"
		},
		Specs = {
			Balance = {
				val = 1,
				text = "Balance",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Balance") end,
			},
			Resto = {
				val = 2,
				text = "Resto",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Resto") end
			},
			FeralTank = {
				val = 3,
				text = "FeralTank",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","FeralTank") end
			},
			FeralDPS = {
				val = 4,
				text = "FeralDPS",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","FeralDPS") end
			},
		},
		DEFAULT_SPEC = "Resto",
	},
	Hunter = {
		text = "",
		color = {
			r = 0.67, 
			g = 0.83,
			b = 0.45,
			hex = "ABD473"
		},
		Specs = {
			Any = {
				val = 5,
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Mage = {
		text = "",
		color = {
			r = 0.41, 
			g = 0.80,
			b = 0.94,
			hex = "69CCF0"
		},
		Specs = {
			Any = {
				val = 6,
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Paladin = {
		text = "",
		color = {
			r = 0.96, 
			g = 0.55,
			b = 0.73,
			hex = "F58CBA"
		},
		Specs = {
			Holy = {
				val = 7,
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Prot = {
				val = 8,
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			Ret = {
				val = 9,
				text = "Ret",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Ret") end
			},
		},
		DEFAULT_SPEC = "Holy",
	},
	Priest = {
		text = "",
		color = {
			r = 1.00, 
			g = 1.00,
			b = 1.00,
			hex = "FFFFFF"
		},
		Specs = {
			Holy = {
				val = 10,
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Shadow = {
				val = 11,
				text = "Shadow",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Shadow") end
			},
		},
		DEFAULT_SPEC = "Holy",
	},
	Rogue = {
		text = "",
		color = {
			r = 1.00, 
			g = 0.96,
			b = 0.41,
			hex = "FFF569"
		},
		Specs = {
			Any = {
				val = 12,
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
			Daggers = {
				val = 13,
				text = "Daggers",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Daggers") end
			},
			Swords = {
				val = 14,
				text = "Swords",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Swords") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Shaman = {
		text = "",
		color = {
			r = 0.96, 
			g = 0.55,
			b = 0.73,
			hex = "F58CBA"
		},
		Specs = {
			Ele = {
				val = 15,
				text = "Ele",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Ele") end
			},
			Enh = {
				val = 16,
				text = "Enh",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Enh") end
			},
			Resto = {
				val = 17,
				text = "Resto",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Resto") end
			},
		},
		DEFAULT_SPEC = "Resto",
	},
	Warlock = {
		text = "",
		color = {
			r = 0.58, 
			g = 0.51,
			b = 0.79,
			hex = "9482C9"
		},
		Specs = {
			Any = {
				val = 18,
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Warrior = {
		text = "",
		color = {
			r = 0.78, 
			g = 0.61,
			b = 0.43,
			hex = "C79C6E"
		},
		Specs = {
			DPS = {
				val = 19,
				text = "DPS",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DPS") end
			},
			Prot = {
				val = 20,
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			TwoHanded = {
				val = 21,
				text = "TwoHanded",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","TwoHanded") end
			},
			DualWield = {
				val = 22,
				text = "DualWield",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DualWield") end
			},
		},
		DEFAULT_SPEC = "DPS",
	},
};

local SPEC_CLASS = { -- used to quickly get spec name from value
	"DruidBalance",
	"DruidResto",
	"DruidFeralTank",
	"DruidFeralDPS",
	"HunterAny",
	"MageAny",
	"PaladinHoly",
	"PaladinProt",
	"PaladinRet",
	"PriestHoly",
	"PriestShadow",
	"RogueAny",
	"RogueDaggers",
	"RogueSwords",
	"ShamanEle",
	"ShamanEnh",
	"ShamanResto",
	"WarlockAny",
	"WarriorDPS",
	"WarriorProt",
	"WarriorTwoHanded",
	"WarriorDualWield",
}

local CHARACTER_DATA = { -- fields used to define character
	Name = {
		text = "Name",
		OPTIONS = {},
	},
	Class = {
		text = "Class",
		OPTIONS = {},
	},
	Spec = {
		text = "Spec",
		OPTIONS = {},
	},
	["Raid Role"] = {
		text = "Raid Role",
		OPTIONS = {
			DPS = {
				val = 0,
				text = "DPS",
			},
			Healer = {
				val = 1,
				text = "Healer",
			},
			Tank = {
				val = 2,
				text = "Tank",
			},
		},
	},
	["Guild Role"] = {
		text = "Guild Role",
		OPTIONS = {
			None = {
				val = 0,
				text = "None",
				func = function (self) OnClick_EditDropDownOption("Guild Role","None") end,
			},
			Disenchanter = {
				val = 1,
				text = "Disenchanter",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Disenchanter") end,
			},
			Banker = {
				val = 2,
				text = "Banker",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Banker") end,
			},
		},
	},
	Status = {
		text = "Status",
		OPTIONS = {
			Main = {
				val = 0,
				text = "Main",
				func = function (self) OnClick_EditDropDownOption("Status","Main") end,
			},
			Alt = {
				val = 1,
				text = "Alt",
				func = function (self) OnClick_EditDropDownOption("Status","Alt") end,
			},
		},
	},
	Activity = {
		text = "Activity",
		OPTIONS = {
			Active = {
				val = 0,
				text = "Active",
				func = function (self) OnClick_EditDropDownOption("Activity","Active") end,
			},
			Inactive = {
				val = 1,
				text = "Inactive",
				func = function (self) OnClick_EditDropDownOption("Activity","Inactive") end,
			},
		},
	},	
};

local LOOT_DECISION = {
	PENDING = 1,
	PASS = 2,
	SK = 3,
	ROLL = 4,
	TEXT_MAP = {
		"PENDING",
		"PASS",
		"SK",
		"ROLL",
	},
	OPTIONS = {
		MAX_TIME = 10,
		TIME_STEP = 1,
		ML_WAIT_BUFFER = 5, -- additional time that master looter waits before triggering auto pass (accounts for transmission delays)
	},
};

local PRIO_TIERS = { -- possible prio tiers and associated numerical ordering
	SK = {
		Main = {
			P1 = 1,
			P2 = 2,
			P3 = 3,
			P4 = 4,
			P5 = 5,
			OS = 6,
		},
		Alt = {
			P1 = 7,
			P2 = 8,
			P3 = 9,
			P4 = 10,
			P5 = 11,
			OS = 12,
		},
	},
	ROLL = {
		Main = {
			MS = 13,
			OS = 14,
		},
		Alt = {
			MS = 15,
			OS = 16,
		},
	},
	PASS = 17,
};

local LOG_OPTIONS = {
	["Timestamp"] = {
		Text = "Timestamp",
	},
	["Action"] = {
		Text = "Action",
		Options = {
			ALD = "Automatic Loot Distribution",
			ManSK = "Manual SK List Edit",
		},
	},
	["Source"] = {
		Text = "Source",
		Options = {
			SKC = "SKC",
			THIS_PLAYER = UnitName("player"),
		},
	},
	["SK List"] = {
		Text = "SK List",
		Options = {
			MSK = "MSK",
			TSK = "TSK",
		}
	},
	["Character"] = {
		Text = "Character",
	},
	["Item"] = {
		Text = "Item",
	},
	["Previous SK Position"] = {
		Text = "Previous SK Position",
	},
	["New SK Position"] = {
		Text = "New SK Position",
	},
};

--------------------------------------
-- REGISTER CHANNELS
--------------------------------------
CHANNELS = { -- channels for inter addon communication (const)
	LOGIN_SYNC_CHECK = "?Q!@$8aZpc8QqYyH",
	LOGIN_SYNC_PUSH = "6-F?8&2qBmrJE?pR",
	LOGIN_SYNC_PUSH_RQST = "d$8B=qB4VsW&4Y^D",
	SYNC_PUSH = "8EtTWxyA$r6x53=F",
	LOOT = "xBPE9,-Fjbc+A#rm",
	LOOT_DECISION = "ksg(AkE.*/@&+`8Q",
	LOOT_OUTCOME = "aP@yX9hQfU89K&C4",
};
for _,channel in pairs(CHANNELS) do
	C_ChatInfo.RegisterAddonMessagePrefix(channel);
end
--------------------------------------
-- LOCAL VARIABLES
--------------------------------------
local tmp_sync_var = {}; -- temporary variable used to hold incoming data when synchronizing
local UnFilteredCnt = 0; -- defines max count of sk cards to scroll over
local SK_MessagesSent = 0;
local SK_MessagesReceived = 0;
local event_states = { -- tracks if certain events have fired
	AddonLoaded = false,
	RaidLoggingActive = LOG_ACTIVE_OVRD, -- latches true when raid is entered (controls RaidLog)
	SyncRequestSent = false,
	LoginSyncName = {
		MSK = nil,
		TSK = nil,
		GuildData = nil,
		LootPrio = nil,
	},
	SyncCompleted = {
		MSK = true,
		TSK = true,
		GuildData = true,
		LootPrio = true,
		Bench = true,
	},
};
local loot_manager = { -- collection of temporary variables used by ML to manage loot
	loot_msg_cnt = {}, -- map of item to count of messages sent to elligible player
	loot_decision_rcvd = {}, -- map of item to count of loot decisions received
	loot_distributed = {}, -- map of item to boolean if that item was distributed
};
local pending_loot = {}; -- array of item names and links to make loot decision about
local LootTimer = nil; -- current loot timer
local DD_State = 0; -- used to track state of drop down menu
local SetSK_Flag = false; -- true when SK position is being set
local SKC_Active = false; -- true when loot distribution is handled by SKC
local InitGuildSync = false; -- used to control for first time setup
--------------------------------------
-- CLASS DEFINITIONS / CONSTRUCTORS
--------------------------------------
CharacterData = {
	Name = nil, -- character name
	Class = nil, -- character class
	Spec = nil, -- character specialization (val)
	["Raid Role"] = nil, --DPS, Healer, or Tank
	["Guild Role"] = nil, --Disenchanter, Guild Banker, or None
	Status = nil, -- Main or Alt
	Activity = nil, -- Active or Inactive
	last_live_time = nil, -- most recent time added to ANY live list
}
CharacterData.__index = CharacterData;

function CharacterData:new(character_data,name,class)
	if character_data == nil then
		-- initalize fresh
		local obj = {};
		obj.Name = name;
		obj.Class = class;
		local default_spec = CLASSES[class].DEFAULT_SPEC;
		obj.Spec = CLASSES[class].Specs[default_spec].val;
		obj["Raid Role"] = CHARACTER_DATA["Raid Role"].OPTIONS[CLASSES[class].Specs[default_spec].RR].val;
		obj["Guild Role"] = CHARACTER_DATA["Guild Role"].OPTIONS.None.val;
		obj.Status = CHARACTER_DATA.Status.OPTIONS.Main.val;
		obj.Activity = CHARACTER_DATA.Activity.OPTIONS.Active.val;
		obj.last_live_time = time();
		setmetatable(obj,CharacterData);
		return obj;
	else
		-- set metatable of existing table
		setmetatable(character_data,CharacterData);
		return character_data;
	end
end

GuildData = {
	data = {}, --a hash table that maps character name to CharacterData
	edit_ts_raid = nil, -- timestamp of most recent edit (in a raid)
	edit_ts_generic = nil, -- timestamp of most recent edit
	activity_thresh = nil, -- time threshold [days] which changes activity from Active to Inactive
};
GuildData.__index = GuildData;

function GuildData:new(guild_data)
	if guild_data == nil then
		-- initalize fresh
		local obj = {};
		obj.data = {};
		obj.edit_ts_raid = 0;
		obj.edit_ts_generic = 0;
		obj.activity_thresh = 30;
		setmetatable(obj,GuildData);
		return obj;
	else
		-- set metatable of existing table and all sub tables
		for key,value in pairs(guild_data.data) do
			guild_data.data[key] = CharacterData:new(guild_data.data[key],nil,nil);
		end
		setmetatable(guild_data,GuildData);
		return guild_data;
	end
end

SK_Node = {
	above = nil, -- character name above this character in ths SK list
	below = nil, -- character name below this character in the SK list
	abs_pos = nil, -- absolute position of this node in the full list
	live = false, -- used to indicate a node that is currently in the live list
};
SK_Node.__index = SK_Node;

function SK_Node:new(sk_node,above,below)
	if sk_node == nil then
		-- initalize fresh
		local obj = {};
		obj.above = above or nil;
		obj.below = below or nil;
		obj.abs_pos = 1;
		obj.live = false;
		setmetatable(obj,SK_Node);
		return obj;
	else
		-- set metatable of existing table
		setmetatable(sk_node,SK_Node);
		return sk_node;
	end
end

SK_List = { --a doubly linked list table where each node is referenced by player name. Each node is a SK_Node:
	top = nil, -- top name in list
	bottom = nil, -- bottom name in list
	live_bottom = nil, -- bottom name in live list
	list = {}, -- list of SK_Node
	edit_ts_raid = nil, -- timestamp of most recent edit (in a raid)
	edit_ts_generic = nil, -- timestamp of most recent edit
};
SK_List.__index = SK_List;

function SK_List:new(sk_list)
	if sk_list == nil then
		-- initalize fresh
		local obj = {};
		obj.top = nil; 
		obj.bottom = nil;
		obj.live_bottom = nil;
		obj.list = {};
		obj.edit_ts_raid = 0;
		obj.edit_ts_generic = 0;
		setmetatable(obj,SK_List);
		return obj;
	else
		-- set metatable of existing table and all sub tables
		for key,value in pairs(sk_list.list) do
			sk_list.list[key] = SK_Node:new(sk_list.list[key],nil,nil);
		end
		setmetatable(sk_list,SK_List);
		return sk_list;
	end
end

Prio = {
	sk_list = nil, -- associated sk_list
	reserved = false, -- true if main prio over alts
	DE = false, -- true if item should be disenchanted before going to guild banker
	open_roll = false, -- open roll for this tiem
	prio = {}, -- map of SpecClass to prio level (P1,P2,P3,P4,P5)
};
Prio.__index = Prio;

function Prio:new(prio)
	if prio == nil then
		-- initalize fresh
		local obj = {};
		obj.prio = {}; -- default is equal prio for all (considered OS for all)
		obj.reserved = false;
		obj.DE = false;
		obj.open_roll = false;
		obj.sk_list = "MSK";
		setmetatable(obj,Prio);
		return obj;
	else
		-- set metatable of existing table
		setmetatable(prio,Prio);
		return prio;
	end
end

LootPrio = {
	items = {},-- hash table mapping lootName to Prio object
	edit_ts_raid = nil, -- timestamp of most recent edit (in a raid)
	edit_ts_generic = nil, -- timestamp of most recent edit (non-raid)
}; 
LootPrio.__index = LootPrio;

function LootPrio:new(loot_prio)
	if loot_prio == nil then
		-- initalize fresh
		local obj = {};
		obj.items = {};
		obj.edit_ts_raid = 0;
		obj.edit_ts_generic = 0;
		setmetatable(obj,LootPrio);
		return obj;
	else
		-- set metatable of existing table
		for key,value in pairs(loot_prio.items) do
			loot_prio.items[key] = Prio:new(loot_prio.items[key]);
		end
		setmetatable(loot_prio,LootPrio);
		return loot_prio;
	end
end

Loot = {
	lootName = nil, -- item name
	lootLink = nil, -- item link
	loot_option = "SK", -- option that players have to get this item SK or ROLL (text)
	sk_list = "MSK", -- name of associated sk list (MSK TSK)
	decisions = {}, -- map from character name to LOOT_DECISION
	prios = {}, -- map from character name to PRIO_TIERS
	sk_pos = {}, -- map from character name to absolute SK position on corresponding sk_list
	awarded = false, -- true when loot has been awarded
}; 
Loot.__index = Loot;

function Loot:new(loot,item_name,item_link,loot_option,sk_list)
	if loot == nil then
		-- initalize fresh
		local obj = {};
		obj.lootName = item_name;
		obj.lootLink = item_link;
		obj.loot_option = loot_option or "SK";
		obj.sk_list = sk_list or "MSK";
		obj.decisions = {};
		obj.prios = {};
		obj.sk_pos = {};
		obj.awarded = false;
		setmetatable(obj,Loot);
		return obj;
	else
		-- set metatable of existing table
		setmetatable(loot,Loot);
		return loot;
	end
end

LootManager = {
	loot_master = nil, -- name of the master looter
	current_loot = nil, -- Loot object of loot that is being decided on
	pending_loot = {}, -- array of Loot objects
	current_loot_timer = nil, -- timer used to track when decision time has expired
}; 
LootManager.__index = LootManager;

function LootManager:new(loot_manager)
	if loot_manager == nil then
		-- initalize fresh
		local obj = {};
		obj.loot_master = nil;
		obj.current_loot = Loot:new(nil);
		obj.pending_loot = {};
		obj.current_loot_timer = nil;
		setmetatable(obj,LootManager);
		return obj;
	else
		-- reset timer
		loot_manager.current_loot_timer = nil;
		-- set metatable of existing table
		loot_manager.current_loot = Loot:new(loot_manager.current_loot);
		for key,value in ipairs(loot_manager.pending_loot) do
			loot_manager.pending_loot[key] = Loot:new(loot_manager.pending_loot[key]);
		end
		setmetatable(loot_manager,LootManager);
		return loot_manager;
	end
end

--------------------------------------
-- HELPER METHODS
--------------------------------------
local function WriteToLog(time_txt,action,src,sk_list,character,item,prev_sk_pos,new_sk_pos)
	-- writes new log entry (if raid logging active)
	if not event_states.RaidLoggingActive then return end
	local idx = #SKC_DB.RaidLog + 1;
	SKC_DB.RaidLog[idx] = {};
	if time_txt == nil then
		SKC_DB.RaidLog[idx][1] = date(DATE_FORMAT);
	else
		SKC_DB.RaidLog[idx][1] = time_txt;
	end
	SKC_DB.RaidLog[idx][2] = action;
	SKC_DB.RaidLog[idx][3] = src;
	SKC_DB.RaidLog[idx][4] = sk_list;
	SKC_DB.RaidLog[idx][5] = character;
	SKC_DB.RaidLog[idx][6] = item;
	SKC_DB.RaidLog[idx][7] = prev_sk_pos;
	SKC_DB.RaidLog[idx][8] = new_sk_pos;
	return;
end

--------------------------------------
-- CLASS METHODS
--------------------------------------

function GuildData:length()
	local count = 0;
	for _ in pairs(self.data) do count = count + 1 end
	return count;
end

function GuildData:GetFirstGuildRoles()
	-- scan guild data and return first disenchanter and banker
	local disenchanter = nil;
	local banker = nil;
	for char_name,data_tmp in pairs(self.data) do
		if disenchanter == nil and data_tmp["Guild Role"] == CHARACTER_DATA["Guild Role"].OPTIONS.Disenchanter.val then
			disenchanter = char_name;
		end
		if banker == nil and data_tmp["Guild Role"] == CHARACTER_DATA["Guild Role"].OPTIONS.Banker.val then
			banker = char_name;
		end
	end
	return disenchanter, banker;
end

function GuildData:GetData(name,field)
	-- returns text for a given name and field
	local value = self.data[name][field];
	if field == "Name" or field == "Class" then
		return value;
	elseif field == "Spec" then
		local class = self.data[name].Class;
		for _,data in pairs(CLASSES[class].Specs) do
			if data.val == value then
				return data.text;
			end
		end
	else
		for _,data in pairs(CHARACTER_DATA[field].OPTIONS) do
			if data.val == value then
				return data.text;
			end
		end
	end
end

function GuildData:SetData(name,field,value)
	-- assigns data based on field and string name of value
	if field == "Name" or field == "Class" then
		self.data[name][field] = value;
	elseif field == "Spec" then
		local class = self.data[name].Class;
		self.data[name][field] = CLASSES[class].Specs[value].val;
	elseif field == "Activity" then
		local curr_str = self:GetData(name,field);
		local new_str = CHARACTER_DATA[field].OPTIONS[value].text
		if curr_str == "Active" and new_str == "Inactive" then
			SKC_DB.GuildData:SetLastLiveTime(name,time()-SKC_DB.GuildData:GetActivityThreshold()*DAYS_TO_SECS);
		elseif curr_str == "Inactive" and new_str == "Active" then
			SKC_DB.GuildData:SetLastLiveTime(name,time());
		end
		self.data[name][field] = CHARACTER_DATA[field].OPTIONS[value].val;
	else
		self.data[name][field] = CHARACTER_DATA[field].OPTIONS[value].val;
	end
	-- update raid role
	if field == "Spec" then
		local class = self.data[name].Class;
		local spec = value;
		local raid_role = CLASSES[class].Specs[spec].RR;
		self.data[name]["Raid Role"] = CHARACTER_DATA["Raid Role"].OPTIONS[raid_role].val;
	end
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	return;
end

function GuildData:Exists(name)
	-- returns true if given name is in data
	return self.data[name] ~= nil;
end

function GuildData:Add(name,class)
	self.data[name] = CharacterData:new(nil,name,class);
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	return;
end

function GuildData:Remove(name)
	if not self:Exists(name) then return end
	self.data[name] = nil;
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	return;
end

function GuildData:GetClass(name)
	-- gets SpecClass of given name
	if not self:Exists(name) then return nil end
	return self.data[name].Class;
end

function GuildData:GetSpec(name)
	-- gets spec value of given name
	if not self:Exists(name) then return nil end
	return self.data[name].Spec;
end

function GuildData:GetSpecClass(name)
	-- gets SpecClass (string) of given name
	if not self:Exists(name) then return nil end
	return (self.data[name].Spec..self.data[name].Class);
end

function GuildData:SetLastLiveTime(name,ts)
	self.data[name].last_live_time = ts;
	return;
end

function GuildData:CalcActivity(name)
	-- calculate time difference (in seconds)
	return ((time() - self.data[name].last_live_time));
end

function GuildData:CheckActivity(name)
	-- checks activity level
	-- returns true if still active
	return (self:CalcActivity(name) < self.activity_thresh*DAYS_TO_SECS);
end

function GuildData:SetActivityThreshold(new_thresh)
	-- sets new activity threshold (input days, stored as seconds)
	self.activity_thresh = new_thresh;
	return;
end

function GuildData:GetActivityThreshold()
	-- returns activity threshold in days
	return self.activity_thresh;
end

function SK_List:Exists(name)
	-- returns true if given name is in data
	return self.list[name] ~= nil;
end

function SK_List:length()
	local count = 0;
	for _ in pairs(self.list) do count = count + 1 end
	return count;
end

function SK_List:GetPos(name)
	-- gets the absolute position of this node
	return self.list[name].abs_pos;
end

function SK_List:CheckIfFucked()
	-- checks integrity of list
	-- invalid if non empty list has nil bottom node or node below bottom is not nil
	if self:length() ~=0 and (self.bottom == nil or self.list[self.bottom].below ~= nil) then
		SKC_Main:Print("ERROR","Your database is fucked.")
		return true;
	end
	return false;
end

function SK_List:SetLiveBottom()
	-- scan list to find bottom live player
	-- note, this method does not change the updated timestamp
	if self:CheckIfFucked() then return false end
	local current_name = self.top;
	local live_bottom_tmp = nil;
	while (current_name ~= nil) do
		if self.list[current_name].live then
			live_bottom_tmp = current_name;
		end
		current_name = self.list[current_name].below;
	end
	-- assign
	self.live_bottom = live_bottom_tmp;
	return true;
end

function SK_List:ResetPos()
	-- resets absolute positions of all nodes
	if self:CheckIfFucked() then return false end
	-- scan list and assign positions
	local idx = 1;
	local current_name = self.top;
	while (current_name ~= nil) do
		self.list[current_name].abs_pos = idx;
		current_name = self.list[current_name].below;
		idx = idx + 1;
	end
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	return true;
end

function SK_List:PushTop(name)
	-- Push name on top
	-- check if current bottom
	if self.bottom == name then
		-- adjust new bottom
		local new_bot = self.list[name].above
		self.list[new_bot].below = nil;
		self.bottom = new_bot;
	else
		-- regular node
		-- Remove name from current spot
		local above_tmp = self.list[name].above;
		local below_tmp = self.list[name].below;
		self.list[above_tmp].below = below_tmp;
		self.list[below_tmp].above = above_tmp;
	end
	-- put on top
	self.list[self.top].above = name;
	self.list[name].below = self.top;
	self.list[name].above = name;
	-- adjust top tracker
	self.top = name;
	-- adjust position
	self:ResetPos();
	-- adjust live bottom
	self:SetLiveBottom();
	-- reset positions / adjust time
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	return true;
end

function SK_List:ReturnList()
	-- Returns list in ordered array
	-- check data integrity
	if self:CheckIfFucked() then return({}) end;
	-- Scan list in order
	local list_out = {};
	local idx = 1;
	local current_name = self.top;
	while (current_name ~= nil) do
		list_out[idx] = current_name;
		current_name = self.list[current_name].below;
		idx = idx + 1;
	end
	return(list_out);
end

function SK_List:PrintNode(name)
	if self.list[name] == nil then
		SKC_Main:Print("ERROR",name.." not in list");
	elseif self.top == nil then
		SKC_Main:Print("IMPORTANT","EMPTY");
	elseif self.top == name and self.top == self.bottom then
		SKC_Main:Print("IMPORTANT",name);
	elseif self.top == name then
		SKC_Main:Print("IMPORTANT","TOP-->"..name.."-->"..self.list[name].below);
	elseif self.bottom == name then
		SKC_Main:Print("IMPORTANT",self.list[name].above.."-->"..name.."-->BOTTOM");
	else
		SKC_Main:Print("IMPORTANT",self.list[name].above.."-->"..name.."-->"..self.list[name].below);
	end
	return;
end

function SK_List:PrintList()
	-- prints list in order
	-- check data integrity
	if self:CheckIfFucked() then return end;
	-- Scan list in order
	local current_name = self.top;
	while (current_name ~= nil) do
		self:PrintNode(current_name);
		current_name = self.list[current_name].below;
	end
	return;
end

function SK_List:InsertBelow(name,new_above_name,verbose)
	-- Insert item below new_above_name
	if name == nil then
		SKC_Main:Print("ERROR","nil name to SK_List:InsertBelow()");
		return false;
	end
	-- check special cases
	if self.top == nil then
		-- First node in list
		self.top = name;
		self.bottom = name;
		self.list[name] = SK_Node:new(self.list[name],name,nil);
		-- adjust position
		self:ResetPos();
		-- adjust live bottom
		self:SetLiveBottom();
		local ts = time();
		self.edit_ts_generic = ts;
		if SKC_Active then self.edit_ts_raid = ts end
		if verbose then self:PrintNode(name) end
		return true;
	elseif name == new_above_name then
		-- do nothing
		return true;
	end
	if new_above_name == nil then
		SKC_Main:Print("ERROR","nil new_above_name for SK_List:InsertBelow()");
		return false;
	end
	-- check that new_above_name is in list
	if self.list[new_above_name] == nil then
		SKC_Main:Print("ERROR","New above, "..new_above_name..", not in list [insert]");
		return false 
	end
	-- Instantiates if does not exist
	if self.list[name] == nil then
		-- new node
		self.list[name] = SK_Node:new(self.list[name],nil,nil);
	else
		-- existing node
		if self:CheckIfFucked() then return false end
		if self.list[name].above == new_above_name then
			-- already in correct order
			if verbose then self:PrintNode(name) end
			return true;
		end
		-- remove name from list
		local above_tmp = self.list[name].above;
		local below_tmp = self.list[name].below;
		if name == self.top then
			-- name is current top
			self.list[below_tmp].above = below_tmp;
			self.top = below_tmp;
		elseif name == self.bottom then
			-- name is current bottom node
			self.list[above_tmp].below = nil;
			self.bottom = above_tmp;
		else
			-- name is middle node
			self.list[below_tmp].above = above_tmp;
			self.list[above_tmp].below = below_tmp;
		end
	end
	-- get new below
	local new_below_name = self.list[new_above_name].below;
	-- insert to new location
	self.list[name].above = new_above_name;
	self.list[name].below = new_below_name;
	-- adjust surrounding
	self.list[new_above_name].below = name;
	if new_below_name ~= nil then self.list[new_below_name].above = name end
	-- check if new bottom or top and adjust
	if self.list[name].below == nil then self.bottom = name end
	if self.list[name].above == name then self.top = name end
	-- adjust position
	self:ResetPos();
	-- adjust live bottom
	self:SetLiveBottom();
	local ts = time();
	self.edit_ts_generic = ts;
	if SKC_Active then self.edit_ts_raid = ts end
	if verbose then self:PrintNode(name) end
	return true;
end

function SK_List:SetByPos(name,pos)
	-- sets the absolute position of given name
	local des_pos = pos;
	if self:CheckIfFucked() then return false end
	local curr_pos = self:GetPos(name);
	if pos == curr_pos then
		return true;
	elseif pos < curr_pos then
		-- desired position is above current position
		-- account for moving self node
		des_pos = des_pos - 1;
	end
	if des_pos == 0 then
		return self:PushTop(name);
	end
	-- find where to insert below
	local current_name = self.top;
	while (current_name ~= nil) do
		if (self:GetPos(current_name) == des_pos) then
			-- desired position found, insert
			return self:InsertBelow(name,current_name);
		end
		current_name = self.list[current_name].below;
	end
	return false;
end

function SK_List:PushBack(name)
	-- Pushes name to back (bottom) of list (creates if does not exist)
	return  self:InsertBelow(name,self.bottom);
end

function SK_List:PushBackLive(name)
	-- Pushes name to back (bottom of live) of list (creates if does not exist)
	return self:InsertBelow(name,self.live_bottom);
end

function SK_List:SetSK(name,new_above_name)
	-- Removes player from list and sets them to specific location
	-- returns error if names not already i list
	if self.list[name] == nil or self.list[new_above_name] == nil then
		SKC_Main:Print("ERROR",name.." or "..new_above_name.." not in list");
		return false
	else
		return self:InsertBelow(name,new_above_name);
	end
end

function SK_List:Remove(name)
	-- removes character from sk list
	-- sk first
	self:PushBack(name);
	-- get new bottom
	local bot = self.list[name].above;
	-- remove node
	self.list[name] = nil;
	-- update new bottom node
	self.list[bot].below = nil;
	self.list.bottom = bot;
	-- no need to update position because PushBack first
	-- Update live bottom
	self:SetLiveBottom();
	return;
end

function SK_List:GetBelow(name)
	-- gets the name of the character below name
	return self.list[name].below;
end

function SK_List:SetLive(name,live_status)
	-- note, this method does not change the updated timestamp
	if not self:Exists(name) then 
		SKC_Main:Print("ERROR",name.." does not exist")
		return false;
	end
	self.list[name].live = live_status;
	return true;
end

function SK_List:GetLive(name)
	return self.list[name].live;
end

function LootPrio:length()
	local count = 0;
	for _ in pairs(self.items) do count = count + 1 end
	return count;
end

local function GetSpecClassColor(spec_class)
	-- Returns color code for given SpecClass
	for class,tbl in pairs(CLASSES) do
		if string.find(spec_class,class) ~= nil then
			return tbl.color.r, tbl.color.g, tbl.color.b, tbl.color.hex;
		end
	end
	return nil,nil,nil,nil;
end

function LootPrio:Exists(lootName)
	-- returns true if given name is in data
	return self.items[lootName] ~= nil;
end

-- Prio = {
-- 	sk_list = nil, -- associated sk_list
-- 	reserved = false, -- true if main prio over alts
-- 	DE = false, -- true if item should be disenchanted before going to guild banker
-- 	open_roll = false, -- open roll for this tiem
-- 	prio = {}, -- map of SpecClass to prio level (P1,P2,P3,P4,P5)
-- };

function LootPrio:GetSKList(lootName)
	if lootName == nil then return nil end
	if not self:Exists(lootName) then return nil end
	return self.items[lootName].sk_list;
end

function LootPrio:GetReserved(lootName)
	if lootName == nil then return nil end
	if not self:Exists(lootName) then return nil end
	return self.items[lootName].reserved;
end

function LootPrio:GetDE(lootName)
	if lootName == nil then return nil end
	if not self:Exists(lootName) then return nil end
	return self.items[lootName].DE;
end

function LootPrio:GetOpenRoll(lootName)
	if lootName == nil then return nil end
	if not self:Exists(lootName) then return nil end
	return self.items[lootName].open_roll;
end

function LootPrio:GetPrio(lootName,spec_idx)
	if lootName == nil then return nil end
	if not self:Exists(lootName) then return nil end
	return self.items[lootName].prio[spec_idx];
end

function LootPrio:IsElligible(lootName,char_name)
	-- character is elligible if their spec is non null in the loot prio
	local spec_idx = SKC_DB.GuildData:GetSpec(char_name);
	local elligible = false;
	if spec_idx == nil then 
		elligible = false;
	else
		elligible = self:GetPrio(lootName,spec_idx) ~= PRIO_TIERS.PASS;
	end
	if LOOT_VERBOSE then
		if elligible then 
			SKC_Main:Print("NORMAL",char_name.." is elligible for "..lootName);
		else
			SKC_Main:Print("ERROR",char_name.." is not elligible for "..lootName);
		end
	end
	return elligible;
end

function LootPrio:PrintPrio(lootName,lootLink)
	-- prints the prio of given item (or item link)
	local data;
	if lootName == nil then
		SKC_Main:Print("NORMAL","Loot Prio contains "..self:length().." items");
		return;
	elseif self.items[lootName] == nil then
		SKC_Main:Print("ERROR","Item name not found in prio database");
		return;
	else
		data = self.items[lootName];
		print(" ");
		if lootLink == nil then 
			SKC_Main:Print("IMPORTANT",lootName);
		else
			SKC_Main:Print("IMPORTANT",lootLink);
		end
	end
	-- print associated sk list
	SKC_Main:Print("NORMAL","SK List: "..data.sk_list);
	-- print reserved states
	if data.reserved then
		SKC_Main:Print("NORMAL","Reserved: TRUE");
	else
		SKC_Main:Print("NORMAL","Reserved: FALSE");
	end
	-- print disenchant or guild bank default
	if data.DE then
		SKC_Main:Print("NORMAL","All Pass: Disenchant");
	else
		SKC_Main:Print("NORMAL","All Pass: Guild Bank");
	end
	-- print open roll
	if data.open_roll then
		SKC_Main:Print("NORMAL","Open Roll: TRUE");
	else
		SKC_Main:Print("NORMAL","Open Roll: FALSE");
	end
	-- create map from prio level to concatenated string of SpecClass's
	local spec_class_map = {};
	for i = 1,6 do
		spec_class_map[i] = {};
	end
	for spec_class_idx,plvl in pairs(data.prio) do
		if plvl ~= PRIO_TIERS.PASS then spec_class_map[plvl][#(spec_class_map[plvl]) + 1] = SPEC_CLASS[spec_class_idx] end
	end
	for plvl,tbl in ipairs(spec_class_map) do
		if plvl == 6 then
			SKC_Main:Print("NORMAL","OS Prio:");
		else
			SKC_Main:Print("NORMAL","MS Prio "..plvl..":");
		end
		for _,spec_class in pairs(tbl) do
			local hex = select(4, GetSpecClassColor(spec_class));
			DEFAULT_CHAT_FRAME:AddMessage("         "..string.format("|cff%s%s|r",hex:upper(),spec_class));
		end
	end
	print(" ");
	return;
end

-- Loot = {
-- 	lootName = nil, -- item name
-- 	lootLink = nil, -- item link
-- 	loot_option = "SK", -- option that players have to get this item SK or ROLL (text)
-- 	sk_list = "MSK", -- name of associated sk list (MSK TSK)
-- 	decisions = {}, -- map from character name to LOOT_DECISION
-- 	prios = {}, -- map from character name to PRIO_TIERS
-- 	sk_pos = {}, -- map from character name to absolute SK position on corresponding sk_list
--  awarded = false, -- true when loot has been awarded
-- }; 
-- Loot.__index = Loot;

-- LootManager = {
--  loot_master = nil,
--  current_loot = nil,
-- 	pending_loot = {}, -- array of Loot objects
-- }; 
-- LootManager.__index = LootManager;

function LootManager:Reset()
	-- reset loot manager
	self.pending_loot = {};
	self.current_loot_timer = nil;
	self.current_loot = nil;
	return;
end

function LootManager:GetLootIdx(item_name,silent)
	-- returns index for given item name
	for idx,loot in ipairs(self.pending_loot) do
		if item_name == loot.lootName then return idx end
	end
	if not silent then SKC_Main:Print("ERROR",item_name.." not in LootManager") end;
	return nil;
end

function LootManager:SetCurrentLootDirect(item_name,item_link,loot_option,sk_list)
	-- directly writes new Loot object for current loot
	self.current_loot = Loot:new(nil,item_name,item_link,loot_option,sk_list);
	return
end

function LootManager:SetCurrentLootByIdx(loot_idx)
	-- sets current loot by index of loot already in pending_loot
	-- only usable my loot master
	if not SKC_Main:isML() then
		SKC_Main:Print("ERROR","Cannot SetCurrentLootByIdx, not loot master");
		return 
	end
	if self.pending_loot[loot_idx] == nil then
		SKC_Main:Print("ERROR","Cannot SetCurrentLootByIdx, index "..loot_idx.." not found");
		return;
	end
	local item_name = self.pending_loot[loot_idx].lootName;
	local item_link = self.pending_loot[loot_idx].lootLink;
	local loot_option = self.pending_loot[loot_idx].loot_option;
	local sk_list = self.pending_loot[loot_idx].sk_list;
	self:SetCurrentLootDirect(item_name,item_link,loot_option,sk_list);
	return
end

function LootManager:GetCurrentLootName()
	if self.current_loot == nil then
		SKC_Main:Print("ERROR","Current loot not set");
		return nil;
	end
	return self.current_loot.lootName;
end

function LootManager:GetCurrentLootLink()
	if self.current_loot == nil then
		SKC_Main:Print("ERROR","Current loot not set");
		return nil;
	end
	return self.current_loot.lootLink;
end

function LootManager:GetCurrentLootOption()
	if self.current_loot == nil then
		SKC_Main:Print("ERROR","Current loot not set");
		return nil;
	end
	return self.current_loot.loot_option;
end

function LootManager:GetCurrentLootSKList()
	if self.current_loot == nil then
		SKC_Main:Print("ERROR","Current loot not set");
		return nil;
	end
	return self.current_loot.sk_list;
end

function LootManager:AddLoot(item_name,item_link)
	-- add new loot item to pending_loot
	-- check if item already added
	if self:GetLootIdx(item_name,true) ~= nil then
		if VERBOSE then SKC_Main:Print("WARN",item_link.." already added to LootManager") end
		return nil;
	end
	local idx = #self.pending_loot + 1;
	local loot_option = "SK"
	if SKC_DB.LootPrio:GetOpenRoll(item_name) then loot_option = "ROLL" end
	local sk_list = SKC_DB.LootPrio:GetSKList(item_name);
	self.pending_loot[idx] = Loot:new(nil,item_name,item_link,loot_option,sk_list);
	if LOOT_VERBOSE then 
		SKC_Main:Print("WARN","Added "..item_link);
		SKC_Main:Print("WARN","Loot Option:  "..loot_option);
		SKC_Main:Print("WARN","SK List:  "..sk_list);
	end
	return idx;
end

function LootManager:AddCharacter(char_name,item_idx)
	-- add given character as pending loot decision for given item index
	-- get index of given item_name
	if item_idx == nil then
		item_idx = self:GetLootIdx(item_name);
		if item_idx == nil then return end
	end
	-- set player decision to pending
	self.pending_loot[item_idx].decisions[char_name] = LOOT_DECISION.PENDING;
	return;
end

function LootManager:SendLootMsgs(item_idx)
	-- send loot message to all elligible characters
	-- construct message
	local loot_msg = self.pending_loot[item_idx].lootName..","..self.pending_loot[item_idx].lootLink..","..self.pending_loot[item_idx].loot_option..","..self.pending_loot[item_idx].sk_list;
	-- scan elligible players and send message
	for char_name,_ in pairs(self.pending_loot[item_idx].decisions) do
		-- check that player is online
		if UnitExists(char_name) then 
			ChatThrottleLib:SendAddonMessage("NORMAL",CHANNELS.LOOT,loot_msg,"WHISPER",char_name,"main_queue");
		else
			SKC_Main:Print("ERROR",char_name.." does not exist");
		end
	end
	return;
end

local function StripRealmName(full_name)
	local name,_ = strsplit("-",full_name,2);
	return(name);
end

function LootManager:StartPersonalLootDecision()
	if self.current_loot == nil then 
		if LOOT_VERBOSE then SKC_Main:Print("ERROR","No loot to decide on") end
		return;
	end
	-- Begins personal loot decision process
	local loot_option = self:GetCurrentLootOption();
	local sk_list = self:GetCurrentLootSKList();
	local alert_msg = "Would you like to ";
	if loot_option == "SK" then
		alert_msg = alert_msg..sk_list;
	else
		alert_msg = alert_msg..loot_option;
	end
	alert_msg = alert_msg.." for "..self:GetCurrentLootLink().."?"
	SKC_Main:Print("IMPORTANT",alert_msg);
	-- Trigger GUI
	SKC_Main:DisplayLootDecisionGUI(loot_option,sk_list);
	return;
end

function LootManager:LootDecisionPending()
	-- returns true if there is still loot currently being decided on
	if self.current_loot_timer == nil then
		-- no pending loot decision
		return false;
	else
		if self.current_loot_timer:IsCancelled() then
			-- no pending loot decision
			return false;
		else
			-- pending loot decision
			SKC_Main:Print("ERROR","Still waiting on loot decision for "..self:GetCurrentLootLink());
			return true;
		end
	end
end

function LootManager:ReadLootMsg(msg,sender)
	-- reads loot message on local client side (not necessarily ML)
	-- saves item into current loot index and loot_master
	self.loot_master = StripRealmName(sender);
	local item_name, item_link, loot_option, sk_list = strsplit(",",msg,4);
	self:SetCurrentLootDirect(item_name,item_link,loot_option,sk_list);
	-- start GUI
	self:StartPersonalLootDecision()
	return;
end

function LootManager:SendLootDecision(loot_decision)
	SKC_Main:Print("NORMAL","You selected "..LOOT_DECISION.TEXT_MAP[loot_decision].." for "..self:GetCurrentLootLink());
	local msg = self:GetCurrentLootName()..","..loot_decision;
	ChatThrottleLib:SendAddonMessage("NORMAL",CHANNELS.LOOT_DECISION,msg,"WHISPER",self.loot_master,"main_queue");
	return;
end

function LootManager:GiveLoot(loot_name,loot_link,winner)
	-- sends loot to winner
	local success = false;
	-- find item
	for i_loot = 1, GetNumLootItems() do
		-- get item data
		local _, lootName, _, _, _, _, _, _, _ = GetLootSlotInfo(i_loot);
		if lootName == loot_name then
			-- find character in raid
			for i_char = 1,40 do
				if GetMasterLootCandidate(i_loot, i_char) == winner then
					if LOOT_DIST_DISABLE or LOOT_SAFE_MODE then
						SKC_Main:Print("IMPORTANT","Faux distribution of loot successful!");
					else 
						GiveMasterLoot(i_loot,i_char);
					end
					success = true;
				end
			end
		end
	end
	if not success then
		SKC_Main:Print("ERROR","Failed to award "..loot_link.." to "..winner);
	end
	return success;
end

function LootManager:SendOutcomeMsg(winner,winner_decision,loot_link,DE,sk_list,send_success)
	-- constructs and sends outcome message
	local msg = nil;
	if winner_decision == LOOT_DECISION.SK then
		msg = winner.." won "..loot_link.." by "..sk_list.."!";
	elseif winner_decision == LOOT_DECISION.ROLL then
		msg = winner.." won "..loot_link.." by ROLL!";
	else
		-- Everyone passed
		msg = "Everyone passed on "..loot_link..", awarded to "..winner;
		if DE then
			msg = msg.." to be disenchanted."
		else
			msg = msg.." for the guild bank."
		end
	end
	if not send_success then
		msg = msg.." Send failed, item given to master looter."
	end
	ChatThrottleLib:SendAddonMessage("NORMAL",CHANNELS.LOOT_OUTCOME,msg,"RAID",nil,"main_queue");
	return;
end

function LootManager:AwardLoot(loot_idx,winner,winner_decision)
	-- award actual loot to winner, perform SK (if necessary), and send alert message
	-- initialize
	local loot_name = self.pending_loot[loot_idx].lootName;
	local loot_link = self.pending_loot[loot_idx].lootLink;
	local success = false;
	local DE = SKC_DB.LootPrio:GetDE(self.pending_loot[loot_idx].lootName);
	local disenchanter, banker = SKC_DB.GuildData:GetFirstGuildRoles();
	local sk_list = self.pending_loot[loot_idx].sk_list;
	-- check if everyone passed
	if winner == nil then
		if DE then
			if disenchanter == nil then 
				winner = UnitName("player");
			else 
				winner = disenchanter;
			end
		else
			if banker == nil then 
				winner = UnitName("player");
			else 
				winner = banker;
			end
		end
	end
	-- perform SK (if necessary)
	if winner_decision == LOOT_DECISION.SK then
		-- perform SK on winner (below current live bottom)
		success = SKC_DB[sk_list]:PushBackLive(winner);
		if not success then
			SKC_Main:Print("ERROR",sk_list.." for "..winner.." failed");
		else
			local prev_pos = SKC_DB[sk_list]:GetPos(winner);
			WriteToLog(
				nil,
				LOG_OPTIONS["Action"].Options.ALD,
				LOG_OPTIONS["Source"].Options.SKC,
				LOG_OPTIONS["SK List"].Options[sk_list],
				winner,
				loot_name,
				prev_pos,
				SKC_DB[sk_list]:GetPos(winner)
			);
		end
		-- reload UI
		SKC_Main:ReloadUIMain();
	end
	-- send loot
	success = self:GiveLoot(loot_name,loot_link,winner);
	if not success then
		-- looting failed, send item to ML
		self:GiveLoot(loot_name,loot_link,UnitName("player"));
	end
	-- send outcome message
	self:SendOutcomeMsg(winner,winner_decision,loot_link,DE,sk_list,success)
	-- mark loot asawarded
	self.pending_loot[loot_idx].awarded = true;
	self.current_loot_timer:Cancel();
	self.current_loot_timer = nil;
	return;
end

function LootManager:DetermineWinner(loot_idx)
	-- Determines winner for given item, awards loot to player, and sends alert message to raid
	local winner = nil;
	local winner_decision = LOOT_DECISION.PASS;
	local winner_prio = PRIO_TIERS.PASS;
	local winner_sk_pos = nil;
	local winner_roll = nil; -- random number [0,1)
	-- scan decisions and determine winner
	for char_name,loot_decision in pairs(self.pending_loot[loot_idx].decisions) do
		if loot_decision ~= LOOT_DECISION.PASS then
			local new_winner = false;
			local prio_tmp = self.pending_loot[loot_idx].prios[char_name];
			local sk_pos_tmp = self.pending_loot[loot_idx].sk_pos[char_name];
			local roll_tmp = math.random();
			if prio_tmp < winner_prio then
				-- higher prio, automatic winner
				new_winner = true;
			elseif prio_tmp == winner_prio then
				-- prio tie
				if loot_decision == LOOT_DECISION.SK then
					if sk_pos_tmp < winner_sk_pos then
						-- char_name is higher on SK list, new winner
					end
				elseif loot_decision == LOOT_DECISION.ROLL then
					if roll_tmp > winner_roll then
						-- char_name won roll (tie goes to previous winner)
					end
				end
			end
			if new_winner then
				if LOOT_VERBOSE then
					SKC_Main:Print("IMPORTANT","Previous Winner");
					if winner == nil then
						SKC_Main:Print("WARN","NULL");
					else
						SKC_Main:Print("WARN","winner:  "..winner);
						SKC_Main:Print("WARN","winner_decision:  "..LOOT_DECISION.TEXT_MAP[winner_decision]);
						SKC_Main:Print("WARN","winner_prio:  "..winner_prio);
						SKC_Main:Print("WARN","winner_sk_pos:  "..winner_sk_pos);
						SKC_Main:Print("WARN","winner_roll:  "..winner_roll);
					end
				end
				winner = char_name;
				winner_decision = loot_decision;
				winner_prio = prio_tmp;
				winner_sk_pos = sk_pos_tmp;
				winner_roll = roll_tmp;
				if LOOT_VERBOSE then 
					SKC_Main:Print("IMPORTANT","New Winner");
					SKC_Main:Print("WARN","winner:  "..winner);
					SKC_Main:Print("WARN","winner_decision:  "..LOOT_DECISION.TEXT_MAP[winner_decision]);
					SKC_Main:Print("WARN","winner_prio:  "..winner_prio);
					SKC_Main:Print("WARN","winner_sk_pos:  "..winner_sk_pos);
					SKC_Main:Print("WARN","winner_roll:  "..winner_roll);
				end
			end
		end
	end
	-- award loot to winner
	-- note, winner is nil if everyone passed
	self:AwardLoot(loot_idx,winner,winner_decision);
	return;
end

function LootManager:DeterminePrio(loot_idx,char_name)
	-- determines loot prio (PRIO_TIERS) of given char for given loot item
	-- get character spec
	local spec = SKC_DB.GuildData:GetSpec(char_name);
	-- start with base prio of item for given spec, then adjust based on character attributes
	local prio = SKC_DB.LootPrio:GetPrio(self.pending_loot[loot_idx].lootName,spec);
	local loot_name = self.pending_loot[loot_idx].lootName;
	local reserved = SKC_DB.LootPrio:GetReserved(loot_name);
	local spec_type = "MS";
	if prio == PRIO_TIERS.SK.Main.OS then spec_type = "OS" end
	-- get character main / alt status
	local status = SKC_DB.GuildData:GetData(char_name,"Status"); -- text version (Main or Alt)
	local loot_decision = self.pending_loot[loot_idx].decisions[char_name];
	if loot_decision == LOOT_DECISION.SK then
		if reserved and status == "Alt" then
			prio = prio + PRIO_TIERS.SK.Main.OS; -- increase prio past that for any main
		end
	elseif loot_decision == LOOT_DECISION.ROLL then
		prio = PRIO_TIERS.ROLL[status][spec_type];
	elseif loot_decision == LOOT_DECISION.PASS then
		prio = PRIO_TIERS.PASS;
	end
	self.pending_loot[loot_idx].prios[char_name] = prio;
	if LOOT_VERBOSE then
		SKC_Main:Print("IMPORTANT","Prio for "..char_name);
		SKC_Main:Print("WARN","spec: "..SPEC_CLASS[spec]);
		SKC_Main:Print("WARN","status: "..status);
		if reserved then
			SKC_Main:Print("WARN","reserved: TRUE");
		else
			SKC_Main:Print("WARN","reserved: FALSE");
		end
		SKC_Main:Print("WARN","loot_decision: "..LOOT_DECISION.TEXT_MAP[loot_decision]);
		SKC_Main:Print("WARN","spec_type: "..spec_type);
		SKC_Main:Print("WARN","prio: "..prio);
	end
	return;
end

function LootManager:ForceDistribution()
	-- forces loot distribution due to timeout
	SKC_Main:Print("WARN","Time expired for players to decide on "..self:GetCurrentLootLink());
	-- set all currently pending players to pass
	for char_name, decision in pairs(self.current_loot.decisions) do
		if decision == LOOT_DECISION.PENDING then
			SKC_Main:Print("WARN",char_name.." never responded, automoatically passing");
			self.current_loot.decisions[char_name] = LOOT_DECISION.PASS;
		end
	end
	self:DetermineWinner(self:GetLootIdx(self:GetCurrentLootName()));
	return;
end

local function ForceDistribution()
	-- wrapper because i cant figure out how to call object method from After()
	SKC_DB.LootManager:ForceDistribution();
	return;
end

function LootManager:KickOff()
	-- determine if there is still pending loot that needs to be decided on
	-- MASTER LOOTER ONLY
	if not SKC_Main:isML() then
		SKC_Main:Print("ERROR","Cannot KickOFF, not loot master");
		return;
	end
	for loot_idx,loot in ipairs(self.pending_loot) do
		if not loot.awarded then 
			self:SendLootMsgs(loot_idx); -- sends loot messages to all elligible players
			-- store item as current item on ML side (does not trigger loot decision)
			self:SetCurrentLootByIdx(loot_idx);
			-- Start timer for when loot is automatically passed on by players that never responded
			self.current_loot_timer = C_Timer.NewTimer(LOOT_DECISION.OPTIONS.MAX_TIME + LOOT_DECISION.OPTIONS.ML_WAIT_BUFFER, ForceDistribution);
			return;
		end
	end
	SKC_Main:Print("IMPORTANT","Loot distribution complete");
	return;
end

function LootManager:ReadLootDecision(msg,sender)
	-- read loot decision from loot participant
	-- determines if all decisions received and ready to allocate loot
	-- MASTER LOOTER ONLY
	if not SKC_Main:isML() then return end
	local char_name = StripRealmName(sender);
	local loot_name, loot_decision = strsplit(",",msg,2);
	loot_decision = tonumber(loot_decision);
	local loot_idx = self:GetLootIdx(loot_name);
	-- save decision
	if LOOT_VERBOSE then 
		SKC_Main:Print("IMPORTANT","Reading Loot Decision");
		SKC_Main:Print("WARN","char_name:  "..char_name);
		SKC_Main:Print("WARN","loot_name:  "..loot_name);
		SKC_Main:Print("WARN","loot_idx:  "..loot_idx);
		SKC_Main:Print("WARN","loot_decision:  "..LOOT_DECISION.TEXT_MAP[loot_decision]);
	end
	if self:GetCurrentLootName() ~= loot_name then
		SKC_Main:Print("ERROR","Received decision for item other than current_loot");
		return;
	end
	self.pending_loot[loot_idx].decisions[char_name] = loot_decision;
	-- save current position in corresponding sk list
	local sk_list = self.pending_loot[loot_idx].sk_list;
	self.pending_loot[loot_idx].sk_pos[char_name] = SKC_DB[sk_list]:GetPos(char_name);
	-- calculate / save prio
	self:DeterminePrio(loot_idx,char_name);
	-- Determine if all decisions collected
	for char_name_tmp,ld_tmp in pairs(self.pending_loot[loot_idx].decisions) do
		if ld_tmp == LOOT_DECISION.PENDING then 
			SKC_Main:Print("WARN","Waiting on:  "..char_name_tmp);
			return;
		end
	end
	-- Determine winner and award loot
	self:DetermineWinner(loot_idx);
	-- Check if any remaning loot to distribute
	self:KickOff();
	return;
end
--------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------
local function StrOut(inpt)
	if inpt == " " then return nil else return inpt end
end

local function NumOut(inpt)
	if inpt == " " then return nil else return tonumber(inpt) end
end

local function BoolOut(inpt)
	if inpt == " " then return nil else return ( (inpt == "1") or (inpt == "TRUE") ) end
end

local function NilToStr(inpt)
	if inpt == nil then return " " else return tostring(inpt) end
end

local function BoolToStr(inpt)
	if inpt then return "1" else return "0" end
end

local function ResetRaidLogging()
	SKC_DB.RaidLog = {};
	-- Initialize with header
	WriteToLog(
		LOG_OPTIONS["Timestamp"].Text,
		LOG_OPTIONS["Action"].Text,
		LOG_OPTIONS["Source"].Text,
		LOG_OPTIONS["SK List"].Text,
		LOG_OPTIONS["Character"].Text,
		LOG_OPTIONS["Item"].Text,
		LOG_OPTIONS["Previous SK Position"].Text,
		LOG_OPTIONS["New SK Position"].Text
	);
	SKC_Main:Print("WARN","Initialized RaidLog");
end

local function UpdatedActivity(name)
	-- check if activity exceeds threshold and updates if different
	local activity = "Inactive";
	if SKC_DB.GuildData:CheckActivity(name) then activity = "Active" end
	if SKC_DB.GuildData:GetData(name,"Activity") ~= activity then
		if not init then SKC_Main:Print("IMPORTANT",name.." set to "..activity) end
		SKC_DB.GuildData:SetData(name,"Activity",activity);
	end
end

local function SyncGuildData()
	-- synchronize GuildData with guild roster
	if not event_states.SyncCompleted.GuildData then
		if VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, incomplete sync") end
		return;
	end
	if not IsInGuild() then
		if VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, not in guild") end
		return;
	end
	if not SKC_Main:isGL() then
		-- only fetch data if guild leader
		if VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, not guild leader") end
		return;
	end
	if GetNumGuildMembers() <= 1 then
		-- only fetch data if guild leader
		if VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, no guild members") end
		return;
	end
	event_states.SyncCompleted.GuildData = false;
	-- Scan guild roster and add new players
	local guild_roster = {};
	for idx = 1, GetNumGuildMembers() do
		local full_name, _, _, level, class = GetGuildRosterInfo(idx);
		local name = StripRealmName(full_name);
		if level == 60 or OVRD_CHARS[name] then
			guild_roster[name] = true;
			if not SKC_DB.GuildData:Exists(name) then
				-- new player, add to DB and SK lists
				SKC_DB.GuildData:Add(name,class);
				SKC_DB.MSK:PushBack(name);
				SKC_DB.TSK:PushBack(name);
				if not InitGuildSync then SKC_Main:Print("NORMAL",name.." added to databases") end
			end
			-- check activity level and update
			UpdatedActivity(name);
		end
	end
	-- Scan guild data and remove players
	for name,data in pairs(SKC_DB.GuildData.data) do
		if guild_roster[name] == nil then
			SKC_DB.MSK:Remove(name);
			SKC_DB.TSK:Remove(name);
			SKC_DB.GuildData:Remove(name);
			if not InitGuildSync then SKC_Main:Print("ERROR",name.." removed from databases") end
		end
	end
	-- if InitGuildSync then
	-- 	SKC_DB.GuildData.edit_ts_generic = 0;
	-- 	SKC_DB.GuildData.edit_ts_raid = 0;
	-- 	SKC_DB.MSK.edit_ts_generic = 0;
	-- 	SKC_DB.MSK.edit_ts_raid = 0;
	-- 	SKC_DB.TSK.edit_ts_generic = 0;
	-- 	SKC_DB.TSK.edit_ts_raid = 0;
	-- end
	UnFilteredCnt = SKC_DB.GuildData:length();
	if InitGuildSync and (SKC_DB.GuildData:length() ~= 0) then
		-- init sync completed
		SKC_Main:Print("WARN","Populated fresh GuildData ("..SKC_DB.GuildData:length()..")");
		InitGuildSync = false;
	end
	event_states.SyncCompleted.GuildData = true;
	if VERBOSE then SKC_Main:Print("NORMAL","SyncGuildData success!") end
	return;
end

local function ActivateSKC(verbose)
	-- master control for wheter or not loot is managed with SKC
	local active_prev = SKC_Active;
	-- set activity
	SKC_Active = SKC_DB.SKC_Enable and UnitInRaid("player") ~= nil and GetLootMethod() == "master";
	-- add message
	if verbose then
		if SKC_Active and not active_prev then
			SKC_Main:Print("IMPORTANT","Active");
			if SKC_Main:isML() then 
				SKC_Main:Print("NORMAL","Don't forget to add benched characters");
			end
		elseif not SKC_Active and active_prev then
			SKC_Main:Print("IMPORTANT","Inactive");
		end
	end
	return
end

local function AddToLiveLists(name,live_status)
	-- adds player to live lists and records time in guild data
	local sk_lists = {"MSK","TSK"};
	for _,sk_list in pairs(sk_lists) do
		local success = SKC_DB[sk_list]:SetLive(name,live_status);
		if not success then return false end
	end
	-- update guild data
	local ts = time();
	SKC_DB.GuildData:SetLastLiveTime(name,ts);
	return true;
end

local function UpdateLiveList()
	-- Adds every player in raid to live list
	ActivateSKC(true);

	-- Scan raid and update live list
	for char_name,_ in pairs(SKC_DB.GuildData.data) do
		if UnitInRaid(char_name) ~= nil then
			AddToLiveLists(char_name,true);
		end
	end

	-- Scan bench and adjust live
	for _,char_name in ipairs(SKC_DB.Bench) do
		AddToLiveLists(char_name,true);
	end

	-- Set live_bottom for all lists
	SKC_DB.MSK:SetLiveBottom();
	SKC_DB.TSK:SetLiveBottom();

	-- Reload GUI
	SKC_Main:ReloadUIMain();
	return;
end

local function OnAddonLoad(addon_name)
	if addon_name ~= "SKC" then return end
	-- Initialize DBs 
	InitGuildSync = false; -- only initialize if hard reset or new install
	if SKC_DB == nil or HARD_DB_RESET then
		if HARD_DB_RESET then SKC_Main:Print("IMPORTANT","HARD_DB_RESET") end
		InitGuildSync = true;
		SKC_DB = {};
	end
	if SKC_DB == nil or HARD_DB_RESET then
		SKC_DB.SKC_Enable = nil;
		SKC_Main:Enable(true);
	end
	if SKC_DB.GuildData == nil or HARD_DB_RESET then
		SKC_DB.GuildData = nil;
		SKC_Main:Print("WARN","Initialized GuildData");
	end
	if SKC_DB.LootPrio == nil or HARD_DB_RESET then 
		SKC_DB.LootPrio = nil;
		SKC_Main:Print("WARN","Initialized LootPrio");
	end
	if SKC_DB.MSK == nil or HARD_DB_RESET then 
		SKC_DB.MSK = nil;
		SKC_Main:Print("WARN","Initialized MSK");
	end
	if SKC_DB.TSK == nil or HARD_DB_RESET then 
		SKC_DB.TSK = nil;
		SKC_Main:Print("WARN","Initialized TSK");
	end
	if SKC_DB.RaidLog == nil or HARD_DB_RESET then
		SKC_DB.RaidLog = {};
		SKC_Main:Print("WARN","Initialized RaidLog");
	end
	if LOG_ACTIVE_OVRD then
		ResetRaidLogging();
	end
	if SKC_DB.Bench == nil or HARD_DB_RESET then
		SKC_DB.Bench = {}; -- array of names on bench
		SKC_Main:Print("WARN","Initialized Bench");
	end
	if SKC_DB.LootManager == nil or HARD_DB_RESET then
		SKC_DB.LootManager = nil
		SKC_Main:Print("WARN","Initialized LootManager");
	end
	if SKC_DB.FilterStates == nil or HARD_DB_RESET then
		SKC_DB.FilterStates = {
			DPS = true,
			Healer = true,
			Tank = true,
			Live = false,
			Main = true,
			Alt = true,
			Active = true,
			Inactive = false,
			Druid = true,
			Hunter = true,
			Mage = true,
			Paladin = UnitFactionGroup("player") == "Alliance",
			Priest = true;
			Rogue = true,
			Shaman = UnitFactionGroup("player") == "Horde",
			Warlock = true,
			Warrior = true,
		};
		SKC_Main:Print("WARN","Initialized FilterStates");
	end
	-- Initialize or refresh metatables
	SKC_DB.GuildData = GuildData:new(SKC_DB.GuildData);
	SKC_DB.LootPrio = LootPrio:new(SKC_DB.LootPrio);
	SKC_DB.MSK = SK_List:new(SKC_DB.MSK);
	SKC_DB.TSK = SK_List:new(SKC_DB.TSK);
	SKC_DB.LootManager = LootManager:new(SKC_DB.LootManager);
	-- Addon loaded
	event_states.AddonLoaded = true;
	-- Update live list
	UpdateLiveList();
	return;
end

local function GetScrollMax()
	return((UnFilteredCnt)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING));
end

local function OnMouseWheel_ScrollFrame(self,delta)
    -- delta: 1 scroll up, -1 scroll down
	-- value at top is 0, value at bottom is size of child
	-- scroll so that one wheel is 3 SK cards
	local scroll_range = self:GetVerticalScrollRange();
	local inc = 3 * (UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING)
    local newValue = math.min( scroll_range , math.max( 0 , self:GetVerticalScroll() - (inc*delta) ) );
    self:SetVerticalScroll(newValue);
    return
end

local function UpdateSKUI()
	-- populates the SK list
	local sk_list = SKC_UIMain["sk_list_border"].Title.Text:GetText();

	-- Addon not yet loaded, return
	if not event_states.AddonLoaded then return end

	-- Hide all cards
	for idx = 1, SKC_DB.GuildData:length() do
		SKC_UIMain.sk_list.NumberFrame[idx]:Hide();
		SKC_UIMain.sk_list.NameFrame[idx]:Hide();
	end

	-- Populate non filtered cards
	local print_order = SKC_DB[sk_list]:ReturnList();
	local idx = 1;
	for key,name in ipairs(print_order) do
		local class_tmp = SKC_DB.GuildData:GetData(name,"Class");
		local raid_role_tmp = SKC_DB.GuildData:GetData(name,"Raid Role");
		local status_tmp = SKC_DB.GuildData:GetData(name,"Status");
		local activity_tmp = SKC_DB.GuildData:GetData(name,"Activity");
		local live_tmp = SKC_DB[sk_list]:GetLive(name);
		-- only add cards to list which are not being filtered
		if SKC_DB.FilterStates[class_tmp] and 
		   SKC_DB.FilterStates[raid_role_tmp] and
		   SKC_DB.FilterStates[status_tmp] and
		   SKC_DB.FilterStates[activity_tmp] and
		   (live_tmp or (not live_tmp and not SKC_DB.FilterStates.Live)) then
			-- Add number text
			SKC_UIMain.sk_list.NumberFrame[idx].Text:SetText(SKC_DB[sk_list]:GetPos(name));
			SKC_UIMain.sk_list.NumberFrame[idx]:Show();
			-- Add name text
			SKC_UIMain.sk_list.NameFrame[idx].Text:SetText(name)
			-- create class color background
			SKC_UIMain.sk_list.NameFrame[idx].bg:SetColorTexture(CLASSES[class_tmp].color.r,CLASSES[class_tmp].color.g,CLASSES[class_tmp].color.b,0.25);
			SKC_UIMain.sk_list.NameFrame[idx]:Show();
			-- increment
			idx = idx + 1;
		end
	end
	UnFilteredCnt = idx; -- 1 larger than max cards
	-- update scroll length
	SKC_UIMain.sk_list.SK_List_SF:GetScrollChild():SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,GetScrollMax());
end

local function OnCheck_FilterFunction (self, button)
	SKC_DB.FilterStates[self.text:GetText()] = self:GetChecked();
	UpdateSKUI();
	return;
end

local function Refresh_Details(name)
	local fields = {"Name","Class","Spec","Raid Role","Guild Role","Status","Activity","Last Raid"};
	if name == nil then
		-- reset
		for _,field in pairs(fields) do
			SKC_UIMain["Details_border"][field].Data:SetText(nil);
		end
		-- Initialize with instructions
		SKC_UIMain["Details_border"]["Name"].Data:SetText("            Click on a character."); -- lol, so elegant
	else
		for _,field in pairs(fields) do
			if field == "Last Raid" then
				-- calculate # days since last active
				local days = math.floor(SKC_DB.GuildData:CalcActivity(name)/DAYS_TO_SECS);
				SKC_UIMain["Details_border"][field].Data:SetText(days.." days ago");
			else
				SKC_UIMain["Details_border"][field].Data:SetText(SKC_DB.GuildData:GetData(name,field));
			end
		end
		-- updated class color
		local class_color = CLASSES[SKC_DB.GuildData:GetData(name,"Class")].color
		SKC_UIMain["Details_border"]["Class"].Data:SetTextColor(class_color.r,class_color.g,class_color.b,1.0);
		-- update last raid time
		UpdatedActivity(name);
	end
	return
end

local function PopulateData(name)
	-- Refresh details
	Refresh_Details(name);
	-- Update SK cards
	UpdateSKUI();
	return;
end

local function SyncPushSend(db_name,addon_channel,game_channel,name)
	-- send target database to name
	if COMM_VERBOSE then SKC_Main:Print("WARN","SyncPushSend for "..db_name.." through "..game_channel) end
	if name ~= nil then
		name = StripRealmName(name);
		if COMM_VERBOSE then SKC_Main:Print("WARN","name: "..name) end
	end
	local db_msg = nil;
	if db_name == "MSK" or db_name == "TSK" then
		db_msg = "INIT,"..
			db_name..","..
			NilToStr(SKC_DB[db_name].edit_ts_generic)..","..
			NilToStr(SKC_DB[db_name].edit_ts_raid);
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		db_msg = "META,"..
			db_name..","..
			NilToStr(SKC_DB[db_name].top)..","..
			NilToStr(SKC_DB[db_name].bottom)..","..
			NilToStr(SKC_DB[db_name].live_bottom);
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		for node_name,node in pairs(SKC_DB[db_name].list) do
			db_msg = "DATA,"..
				db_name..","..
				NilToStr(node_name)..","..
				NilToStr(node.above)..","..
				NilToStr(node.below)..","..
				NilToStr(node.abs_pos)..","..
				BoolToStr(node.live);
			ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		end
	elseif db_name == "GuildData" then
		db_msg = "INIT,"..
			db_name..","..
			NilToStr(SKC_DB.GuildData.edit_ts_generic)..","..
			NilToStr(SKC_DB.GuildData.edit_ts_raid)..","..
			NilToStr(SKC_DB.GuildData.activity_thresh);
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		for guildie_name,c_data in pairs(SKC_DB.GuildData.data) do
			db_msg = "DATA,"..
				db_name..","..
				NilToStr(guildie_name)..","..
				NilToStr(c_data.Class)..","..
				NilToStr(c_data.Spec)..","..
				NilToStr(c_data["Raid Role"])..","..
				NilToStr(c_data["Guild Role"])..","..
				NilToStr(c_data.Status)..","..
				NilToStr(c_data.Activity)..","..
				NilToStr(c_data.last_live_time);
			ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		end
	elseif db_name == "LootPrio" then
		db_msg = "INIT,"..
			db_name..","..
			NilToStr(SKC_DB.LootPrio.edit_ts_generic)..","..
			NilToStr(SKC_DB.LootPrio.edit_ts_raid);
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");	
		for item,prio in pairs(SKC_DB.LootPrio.items) do
			db_msg = "META,"..
				db_name..","..
				NilToStr(item)..","..
				NilToStr(prio.sk_list)..","..
				BoolToStr(prio.reserved)..","..
				BoolToStr(prio.DE)..","..
				BoolToStr(prio.open_roll);
			ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
			db_msg = "DATA,"..db_name..","..NilToStr(item)..",";
			for _,plvl in ipairs(prio.prio) do
				db_msg = db_msg..","..NilToStr(plvl);
			end
			ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		end
	elseif db_name == "Bench" then
		db_msg = "INIT,"..db_name;
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
		db_msg = "DATA,"..db_name;
		for _,char_name in ipairs(SKC_DB.Bench) do
			db_msg = db_msg..","..NilToStr(char_name);
		end
		ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
	end
	local db_msg = "END,"..db_name..", ,"; --awkward spacing to make csv parsing work
	ChatThrottleLib:SendAddonMessage("NORMAL",addon_channel,db_msg,game_channel,name,"main_queue");
	return;
end

local function OnLoad_EditDropDown_Spec(self)
	local class = SKC_UIMain["Details_border"]["Class"].Data:GetText();
	for key,value in pairs(CLASSES[class].Specs) do
		UIDropDownMenu_AddButton(value);
	end
	return;
end

local function OnLoad_EditDropDown_GuildRole(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.None);
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.Disenchanter);
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.Banker);
	return;
end

local function OnLoad_EditDropDown_Status(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA.Status.OPTIONS.Alt);
	UIDropDownMenu_AddButton(CHARACTER_DATA.Status.OPTIONS.Main);
	return;
end

local function OnLoad_EditDropDown_Activity(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA.Activity.OPTIONS.Active);
	UIDropDownMenu_AddButton(CHARACTER_DATA.Activity.OPTIONS.Inactive);
	return;
end

function OnClick_EditDropDownOption(field,value) -- Must be global
	-- Triggered when drop down of edit button is selected
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	local class = SKC_UIMain["Details_border"]["Class"].Data:GetText();
	-- Edit GuildData
	local prev_val = SKC_DB.GuildData:GetData(name,field);
	prev_val = SKC_DB.GuildData:SetData(name,field,value);
	-- Refresh data
	PopulateData(name);
	-- Reset menu toggle
	DD_State = 0;
	-- send GuildData to all players
	SyncPushSend("GuildData",CHANNELS.SYNC_PUSH,"GUILD",nil);
	return;
end

local function OnClick_EditDetails(self, button)
	-- Manages drop down menu that is generated for edit buttons
	if not self:IsEnabled() then return end
	-- SKC_UIMain.EditFrame:Show();
	local ID = self:GetID();
	-- Populate drop down options
	local field;
	if ID == 3 then
		field = "Spec";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Spec) end
	elseif ID == 5 then
		-- Guild Role
		field = "Guild Role";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_GuildRole) end
	elseif ID == 6 then
		-- Status
		field = "Status";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Status) end
	elseif ID == 7 then
		-- Activity
		field = "Activity";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Activity) end
	else
		SKC_Main:Print("ERROR","Menu not found.");
		return;
	end
	ToggleDropDownMenu(1, nil, SKC_UIMain["Details_border"][field].DD, SKC_UIMain["Details_border"][field].DD, 0, 0);
	if DD_State == ID then
		DD_State = 0;
	else
		DD_State = ID;
	end
	return;
end

local function OnClick_SK_Card(self, button)
	if button=='LeftButton' and self.Text:GetText() ~= nill and DD_State == 0 and not SetSK_Flag then
		-- Populate data
		Refresh_Details(self.Text:GetText());
		-- Enable edit buttons
		SKC_UIMain["Details_border"]["Spec"].Btn:Enable();
		SKC_UIMain["Details_border"]["Guild Role"].Btn:Enable();
		SKC_UIMain["Details_border"]["Status"].Btn:Enable();
		SKC_UIMain["Details_border"]["Activity"].Btn:Enable();
		if SKC_Main:isGL() or SKC_Main:isML() then
			SKC_UIMain["Details_border"].SingleSK_Btn:Enable();
			SKC_UIMain["Details_border"].FullSK_Btn:Enable();
			SKC_UIMain["Details_border"].SetSK_Btn:Enable();
		end
	end
end

local function OnClick_FullSK(self)
	local sk_list = SKC_UIMain["sk_list_border"].Title.Text:GetText();
	-- On click event for full SK of details targeted character
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	-- Get initial position
	local prev_pos = SKC_DB[sk_list]:GetPos(name);
	-- Execute full SK
	local success = SKC_DB[sk_list]:PushBack(name);
	if success then 
		-- log
		WriteToLog(
			nil,
			LOG_OPTIONS["Action"].Options.ManSK,
			LOG_OPTIONS["Source"].Options.THIS_PLAYER,
			LOG_OPTIONS["SK List"].Options[sk_list],
			name,
			"",
			prev_pos,
			SKC_DB[sk_list]:GetPos(name)
		);
		SKC_Main:Print("IMPORTANT","Full SK on "..name);
		-- send SK data to all players
		SyncPushSend(sk_list,CHANNELS.SYNC_PUSH,"GUILD",nil);
		-- Refresh SK List
		UpdateSKUI();
	else
		SKC_Main:Print("ERROR","Full SK on "..name.." rejected");
	end
	return;
end

local function OnClick_SingleSK(self)
	-- On click event for full SK of details targeted character
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	local sk_list = SKC_UIMain["sk_list_border"].Title.Text:GetText();
	-- Get initial position
	local prev_pos = SKC_DB[sk_list]:GetPos(name);
	-- Execute full SK
	local name_below = SKC_DB[sk_list]:GetBelow(name);
	local success = SKC_DB[sk_list]:InsertBelow(name,name_below);
	if success then 
		-- log
		WriteToLog(
			nil,
			LOG_OPTIONS["Action"].Options.ManSK,
			LOG_OPTIONS["Source"].Options.THIS_PLAYER,
			LOG_OPTIONS["SK List"].Options[sk_list],
			name,
			"",
			prev_pos,
			SKC_DB[sk_list]:GetPos(name)
		);
		SKC_Main:Print("IMPORTANT","Single SK on "..name);
		-- send SK data to all players
		SyncPushSend(sk_list,CHANNELS.SYNC_PUSH,"GUILD",nil);
		-- Refresh SK List
		UpdateSKUI();
	else
		SKC_Main:Print("ERROR","Single SK on "..name.." rejected");
	end
	return;
end

local function OnClick_SetSK(self)
	-- On click event to set SK position of details targeted character
	-- Prompt user to click desired position number in list
	if SKC_UIMain["Details_border"]["Name"].Data ~= nil then
		SetSK_Flag = true;
		local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
		SKC_Main:Print("IMPORTANT","Click desired position in SK list for "..name);
	end
	return;
end

local function OnClick_NumberCard(self,button)
	-- On click event for number card in SK list
	if SetSK_Flag and SKC_UIMain["Details_border"]["Name"].Data ~= nil then
		local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
		local new_abs_pos = tonumber(self.Text:GetText());
		local sk_list = SKC_UIMain["sk_list_border"].Title.Text:GetText();
		-- Get initial position
		local prev_pos = SKC_DB[sk_list]:GetPos(name);
		-- Set new position
		local success = SKC_DB[sk_list]:SetByPos(name,new_abs_pos);
		if success then
			-- log
			WriteToLog(
				nil,
				LOG_OPTIONS["Action"].Options.ManSK,
				LOG_OPTIONS["Source"].Options.THIS_PLAYER,
				LOG_OPTIONS["SK List"].Options[sk_list],
				name,
				"",
				prev_pos,
				SKC_DB[sk_list]:GetPos(name)
			);
			SKC_Main:Print("IMPORTANT","Set SK position of "..name.." to "..SKC_DB[sk_list]:GetPos(name));
			-- send SK data to all players
			SyncPushSend(sk_list,CHANNELS.SYNC_PUSH,"GUILD",nil);
			-- Refresh SK List
			UpdateSKUI();
		else
			SKC_Main:Print("ERROR","Set SK on "..name.." rejected");
		end
		SetSK_Flag = false;
	end
	return;
end

local function OnMouseDown_ShowItemTooltip(self, button)
	--[[
		function ChatFrame_OnHyperlinkShow(chatFrame, link, text, button)
			SetItemRef(link, text, button, chatFrame);
		end
		https://wowwiki.fandom.com/wiki/API_ChatFrame_OnHyperlinkShow
		https://wowwiki.fandom.com/wiki/API_strfind

		chatFrame 
			table (Frame) - ChatFrame in which the link was clicked.
		link 
			String - The link component of the clicked hyperlink. (e.g. "item:6948:0:0:0...")
		text 
			String - The label component of the clicked hyperlink. (e.g. "[Hearthstone]")
		button 
			String - Button clicking the hyperlink button. (e.g. "LeftButton")
		
		lootLink ex:
			|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
		itemString ex:
			item:3299::::::::20:257::::::
		itemLabel ex:
			[Fractured Canine]
	--]]
	local decision_border_key = "Decision_border";
	local frame = SKC_UIMain[decision_border_key];
	local lootLink = SKC_UIMain[decision_border_key].lootLink:GetText();
	local itemString = string.match(lootLink,"item[%-?%d:]+");
	local itemLabel = string.match(lootLink,"|h.+|h");
	SetItemRef(itemString, itemLabel, button, frame);
end

local function SetSKItem()
	-- https://wow.gamepedia.com/ItemMixin
	-- local itemID = 19395; -- Rejuv
	local lootLink = SKC_DB.LootManager:GetCurrentLootLink();
	local item = Item:CreateFromItemLink(lootLink)
	item:ContinueOnItemLoad(function()
		-- item:GetlootLink();
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(lootLink);
		-- Set texture icon and link
		local decision_border_key = "Decision_border";
		SKC_UIMain[decision_border_key].ItemTexture:SetTexture(texture);
		SKC_UIMain[decision_border_key].lootLink:SetText(lootLink);
	end)
end

local function InitTimerBarValue()
	SKC_UIMain["Decision_border"].TimerBar:SetValue(0);
	SKC_UIMain["Decision_border"].TimerText:SetText(LOOT_DECISION.OPTIONS.MAX_TIME);
end

local function TimerBarHandler()
	local time_elapsed = SKC_UIMain["Decision_border"].TimerBar:GetValue() + LOOT_DECISION.OPTIONS.TIME_STEP;

	-- updated timer bar
	SKC_UIMain["Decision_border"].TimerBar:SetValue(time_elapsed);
	SKC_UIMain["Decision_border"].TimerText:SetText(LOOT_DECISION.OPTIONS.MAX_TIME - time_elapsed);

	if time_elapsed >= LOOT_DECISION.OPTIONS.MAX_TIME then
		-- out of time
		-- send loot response
		SKC_Main:Print("WARN","Time expired. You PASS on "..SKC_DB.LootManager:GetCurrentLootLink());
		LootTimer:Cancel();
		SKC_DB.LootManager:SendLootDecision(LOOT_DECISION.PASS);
	end

	return;
end

local function StartLootTimer()
	InitTimerBarValue();
	if LootTimer ~= nil and not LootTimer:IsCancelled() then LootTimer:Cancel() end
	-- start new timer
	LootTimer = C_Timer.NewTicker(LOOT_DECISION.OPTIONS.TIME_STEP, TimerBarHandler, LOOT_DECISION.OPTIONS.MAX_TIME/LOOT_DECISION.OPTIONS.TIME_STEP);
	return;
end

local function OnClick_PASS(self,button)
	if self:IsEnabled() then
		LootTimer:Cancel();
		SKC_DB.LootManager:SendLootDecision(LOOT_DECISION.PASS);
	end
	return;
end

local function OnClick_SK(self,button)
	if self:IsEnabled() then
		LootTimer:Cancel();
		SKC_DB.LootManager:SendLootDecision(LOOT_DECISION.SK);
	end
	return;
end

local function OnClick_ROLL(self,button)
	if self:IsEnabled() then
		LootTimer:Cancel();
		SKC_DB.LootManager:SendLootDecision(LOOT_DECISION.ROLL);
	end
	return;
end

local function CreateUICSV(name,import_btn)
	SKC_UICSV[name] = CreateFrame("Frame",name,UIParent,"UIPanelDialogTemplate");
	SKC_UICSV[name]:SetSize(UI_DIMENSIONS.CSV_WIDTH,UI_DIMENSIONS.CSV_HEIGHT);
	SKC_UICSV[name]:SetPoint("CENTER");
	SKC_UICSV[name]:SetMovable(true);
	SKC_UICSV[name]:EnableMouse(true);
	SKC_UICSV[name]:RegisterForDrag("LeftButton");
	SKC_UICSV[name]:SetScript("OnDragStart", SKC_UICSV[name].StartMoving);
	SKC_UICSV[name]:SetScript("OnDragStop", SKC_UICSV[name].StopMovingOrSizing);

	-- Add title
	SKC_UICSV[name].Title:SetPoint("LEFT", name.."TitleBG", "LEFT", 6, 0);
	SKC_UICSV[name].Title:SetText(name);

	-- Add edit box
	SKC_UICSV[name].SF = CreateFrame("ScrollFrame", nil, SKC_UICSV[name], "UIPanelScrollFrameTemplate");
	SKC_UICSV[name].SF:SetSize(UI_DIMENSIONS.CSV_EB_WIDTH,UI_DIMENSIONS.CSV_EB_HEIGHT);
	SKC_UICSV[name].SF:SetPoint("TOPLEFT",SKC_UICSV[name],"TOPLEFT",20,-40)
	SKC_UICSV[name].EditBox = CreateFrame("EditBox", nil, SKC_UICSV[name].SF)
	SKC_UICSV[name].EditBox:SetMultiLine(true)
	SKC_UICSV[name].EditBox:SetFontObject(ChatFontNormal)
	SKC_UICSV[name].EditBox:SetSize(UI_DIMENSIONS.CSV_EB_WIDTH,1000)
	SKC_UICSV[name].SF:SetScrollChild(SKC_UICSV[name].EditBox)

	-- Add import button
	if import_btn then
		SKC_UICSV[name].ImportBtn = CreateFrame("Button", nil, SKC_UICSV[name], "GameMenuButtonTemplate");
		SKC_UICSV[name].ImportBtn:SetPoint("BOTTOM",SKC_UICSV[name],"BOTTOM",0,15);
		SKC_UICSV[name].ImportBtn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
		SKC_UICSV[name].ImportBtn:SetText("Import");
		SKC_UICSV[name].ImportBtn:SetNormalFontObject("GameFontNormal");
		SKC_UICSV[name].ImportBtn:SetHighlightFontObject("GameFontHighlight");
	end

	-- set framel level and hide
	SKC_UICSV[name]:SetFrameLevel(4);
	SKC_UICSV[name]:Hide();

	-- make closable with esc
	table.insert(UISpecialFrames, name);

	return SKC_UICSV[name];
end

local function GetLootIdx(lootName)
	local lootIdx = nil;
	for idx,tmp in ipairs(pending_loot) do
		if tmp.lootName == lootName then return idx end
	end
	if lootIdx == nil then SKC_Main:Print("ERROR",lootName.." not found in pending list") end
	return nil;
end

local function DeepCopy(obj, seen)
	-- credit: https://gist.github.com/tylerneylon/81333721109155b2d244
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
  
    -- New table; mark it as seen and copy recursively.
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[DeepCopy(k, s)] = DeepCopy(v, s) end
    return setmetatable(res, getmetatable(obj))
end

local function SyncPushRead(msg)
	-- Write data to tmp_sync_var first, then given datbase
	local part, db_name, msg_rem = strsplit(",",msg,3);
	if part == "INIT" then
		if COMM_VERBOSE then SKC_Main:Print("WARN","Synchronizing "..db_name.."...") end
		event_states.SyncCompleted[db_name] = false;
	elseif part ~= "INIT" and event_states.SyncCompleted[db_name] then
		-- getting data mid sync, ignore these
		if COMM_VERBOSE then SKC_Main:Print("ERROR","Rejected synchronization, already in progress for "..db_name) end
		return;
	end
	-- If last part, deep copy to actual database
	if part == "END" then
		SKC_DB[db_name] = DeepCopy(tmp_sync_var)
	end
	if db_name == "MSK" or db_name == "TSK" then
		if part == "INIT" then
			local ts_generic, ts_raid = strsplit(",",msg_rem,2);
			ts_generic = NumOut(ts_generic);
			ts_raid = NumOut(ts_raid);
			tmp_sync_var = SK_List:new(nil);
			tmp_sync_var.edit_ts_generic = ts_generic;
			tmp_sync_var.edit_ts_raid = ts_raid;
		elseif part == "META" then
			local top, bottom, live_bottom = strsplit(",",msg_rem,3);
			tmp_sync_var.top = StrOut(top);
			tmp_sync_var.bottom = StrOut(bottom);
			tmp_sync_var.live_bottom = StrOut(live_bottom);
		elseif part == "DATA" then
			local name, above, below, abs_pos, live = strsplit(",",msg_rem,7);
			name = StrOut(name);
			tmp_sync_var.list[name] = SK_Node:new(nil,nil,nil);
			tmp_sync_var.list[name].above = StrOut(above);
			tmp_sync_var.list[name].below = StrOut(below);
			tmp_sync_var.list[name].abs_pos = NumOut(abs_pos);
			tmp_sync_var.list[name].live = BoolOut(live);		
		end
	elseif db_name == "GuildData" then
		if part == "INIT" then
			local ts_generic, ts_raid, activity_thresh = strsplit(",",msg_rem,3);
			ts_generic = NumOut(ts_generic);
			ts_raid = NumOut(ts_raid);
			tmp_sync_var = GuildData:new(nil);
			tmp_sync_var.edit_ts_generic = ts_generic;
			tmp_sync_var.edit_ts_raid = ts_raid;
			tmp_sync_var.activity_thresh = NumOut(activity_thresh);
		elseif part == "META" then
			-- nothing to do
		elseif part == "DATA" then
			local name, class, spec, rr, gr, status, activity, last_live_time = strsplit(",",msg_rem,8);
			name = StrOut(name);
			class = StrOut(class);
			tmp_sync_var.data[name] = CharacterData:new(nil,name,class);
			tmp_sync_var.data[name].Spec = NumOut(spec);
			tmp_sync_var.data[name]["Raid Role"] = NumOut(rr);
			tmp_sync_var.data[name]["Guild Role"] = NumOut(gr);
			tmp_sync_var.data[name].Status = NumOut(status);
			tmp_sync_var.data[name].Activity = NumOut(activity);
			tmp_sync_var.data[name].last_live_time = NumOut(last_live_time);
		end
	elseif db_name == "LootPrio" then
		if part == "INIT" then
			local ts_generic, ts_raid = strsplit(",",msg_rem,2);
			ts_generic = NumOut(ts_generic);
			ts_raid = NumOut(ts_raid);
			tmp_sync_var = LootPrio:new(nil);
			tmp_sync_var.edit_ts_generic = ts_generic;
			tmp_sync_var.edit_ts_raid = ts_raid;
		elseif part == "META" then
			local item, sk_list, res, de, open_roll = strsplit(",",msg_rem,5);
			item = StrOut(item);
			tmp_sync_var.items[item] = Prio:new(nil);
			tmp_sync_var.items[item].sk_list = StrOut(sk_list);
			tmp_sync_var.items[item].reserved = BoolOut(res);
			tmp_sync_var.items[item].DE = BoolOut(de);
			tmp_sync_var.items[item].open_roll = BoolOut(open_roll);
		elseif part == "DATA" then
			local item, msg_rem = strsplit(",",msg_rem,2);
			item = StrOut(item);
			local plvl = nil;
			for idx,spec_class in ipairs(SPEC_CLASS) do
				plvl, msg_rem = strsplit(",",msg_rem,2);
				tmp_sync_var.items[item].prio[idx] = NumOut(plvl);
			end
		end
	elseif db_name == "Bench" then
		if part == "INIT" then
			tmp_sync_var = {};
		elseif part == "DATA" then
			while msg_rem ~= nil do
				char_name, msg_rem = strsplit(",",msg_rem,2);
				tmp_sync_var[#tmp_sync_var + 1] = char_name;
			end
		elseif part == "END" then
			UpdateLiveList();
		end
	end
	if part == "END" then
		if COMM_VERBOSE then SKC_Main:Print("WARN","Synchronization for "..db_name.." complete") end
		event_states.SyncCompleted[db_name] = true;
		SKC_Main:ReloadUIMain();
	end
	return;
end

local function LoginSyncCheckRead(db_name,their_edit_ts_raid,their_edit_ts_generic,name,addon_channel)
	-- Arbitrate based on timestamp to push or pull database
	if not event_states.SyncCompleted[db_name] then
		if COMM_VERBOSE then SKC_Main:Print("ERROR","LoginSyncCheckRead rejected (incomplete sync) for "..db_name) end
		return;
	end
	local my_edit_ts_raid = SKC_DB[db_name].edit_ts_raid;
	local my_edit_ts_generic = SKC_DB[db_name].edit_ts_generic;
	if (my_edit_ts_raid > their_edit_ts_raid) or ( (my_edit_ts_raid == their_edit_ts_raid) and (my_edit_ts_generic > their_edit_ts_generic) ) then
		-- I have newer RAID data
		-- OR I have the same RAID data but newer generic data
		-- --> send them my data
		if COMM_VERBOSE then SKC_Main:Print("WARN","Pushing "..db_name.." to "..name) end
		SyncPushSend(db_name,addon_channel,"WHISPER",name);
	elseif (my_edit_ts_raid < their_edit_ts_raid) or ( (my_edit_ts_raid == their_edit_ts_raid) and (my_edit_ts_generic < their_edit_ts_generic) ) then
		-- I have older RAID data
		-- OR I have the same RAID data but older generic data
		-- --> request their data
		if COMM_VERBOSE then SKC_Main:Print("WARN","Requesting "..db_name.." from "..name) end
		ChatThrottleLib:SendAddonMessage("NORMAL",CHANNELS.LOGIN_SYNC_PUSH_RQST,db_name,"WHISPER",name,"main_queue");
	else
		if COMM_VERBOSE then SKC_Main:Print("NORMAL","Already synchronized "..db_name.." with "..name) end
	end
	return;
end

local function AddonMessageRead(prefix,msg,channel,sender)
	sender = StripRealmName(sender);
	if prefix == CHANNELS.LOGIN_SYNC_CHECK then
		--[[ 
			Send (LoginSyncCheckSend): Upon login character requests sync for each database
			Read (LoginSyncCheckRead): Arbitrate based on timestamp to push or pull database
		--]]
		if sender ~= UnitName("player") then
			local db_name, edit_ts_raid, edit_ts_generic = strsplit(",",msg,3);
			edit_ts_raid = NumOut(edit_ts_raid);
			edit_ts_generic = NumOut(edit_ts_generic);
			LoginSyncCheckRead(db_name,edit_ts_raid,edit_ts_generic,sender,CHANNELS.LOGIN_SYNC_PUSH);
		end
	elseif prefix == CHANNELS.LOGIN_SYNC_PUSH then
		--[[ 
			Send (SyncPushSend): Push given database to target player
			Read (SyncPushRead): Write given database to player (only accept first push)
		--]]
		local part, db_name, msg_rem = strsplit(",",msg,3);
		if (event_states.LoginSyncName[db_name] == nil or event_states.LoginSyncName[db_name] == sender) and sender ~= UnitName("player") then
			event_states.LoginSyncName[db_name] = sender;
			SyncPushRead(msg);
		end
	elseif prefix == CHANNELS.LOGIN_SYNC_PUSH_RQST then
		--[[ 
			Send (LoginSyncCheckRead): Request a push for given database from target player
			Read (SyncPushSend): Respond with push for given database
		--]]
		SyncPushSend(msg,CHANNELS.SYNC_PUSH,"WHISPER",sender);
	elseif prefix == CHANNELS.SYNC_PUSH then
		--[[ 
			Send (SyncPushSend): Push given database to target player
			Read (SyncPushRead): Write given datbase to player (accepts as many as possible)
		--]]
		-- Reject if message was from self
		if sender ~= UnitName("player") then
			SyncPushRead(msg);
		end
	elseif prefix == CHANNELS.LOOT then
		--[[ 
			Send (SendLootMsgs): Send loot items for which each player is elligible to make a decision on
			Read (ReadLootMsg): Initiate loot decision GUI for player
		--]]
		-- read loot message and save to LootManager
		SKC_DB.LootManager:ReadLootMsg(msg,sender);
	elseif prefix == CHANNELS.LOOT_DECISION then
		--[[ 
			Send (SendLootDecision): Send loot decision to ML
			Read (ReadLootDecision): Determine loot winner
		--]]
		-- read message, determine winner, award loot, start next loot decision
		SKC_DB.LootManager:ReadLootDecision(msg,sender);
	elseif prefix == CHANNELS.LOOT_OUTCOME then
		SKC_Main:Print("NORMAL",msg);
	end
	return;
end

local function LoginSyncCheckSend()
	if event_states.SyncRequestSent then return end -- sync check already performed
	if COMM_VERBOSE then SKC_Main:Print("IMPORTANT","LoginSyncCheckSend()") end
	-- Send timestamps of each database to each online member of GuildData (will sync with first response)
	local db_lsit = {"GuildData","LootPrio","MSK","TSK"}
	local msg = nil;
	for _,db_name in ipairs(db_lsit) do
		msg = db_name..","..NilToStr(SKC_DB[db_name].edit_ts_raid)..","..NilToStr(SKC_DB[db_name].edit_ts_generic);
		ChatThrottleLib:SendAddonMessage("NORMAL",CHANNELS.LOGIN_SYNC_CHECK,msg,"GUILD",nil,"main_queue");
		if COMM_VERBOSE then 
			SKC_Main:Print("WARN",db_name.." Edit Timestamp:");
			SKC_Main:Print("WARN","     GENERIC: "..date(DATE_FORMAT,SKC_DB[db_name].edit_ts_generic));
			SKC_Main:Print("WARN","            RAID: "..date(DATE_FORMAT,SKC_DB[db_name].edit_ts_raid));
		end
	end
	event_states.SyncRequestSent = true;
	return;
end

local function SaveLoot()
	-- Scans items / characters and stores loot in LootManager
	-- For Reference: local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i_loot)

	if LOOT_SAFE_MODE then 
		SKC_Main:Print("WARN","Loot Safe Mode");
		return;
	end

	-- Check that player is ML
	if not SKC_Main:isML() then return end

	-- Check if loot decision already pending
	if SKC_DB.LootManager:LootDecisionPending() then return end

	-- Update SKC Active flag
	ActivateSKC();
	
	-- Reset LootManager
	SKC_DB.LootManager:Reset();
	
	-- Scan all items and save each item / elligible player
	if LOOT_VERBOSE then SKC_Main:Print("IMPORTANT","Starting Loot Distribution") end
	local loot_cnt = 1;
	for i_loot = 1, GetNumLootItems() do
		-- get item data
		-- local lootType = GetLootSlotType(i_loot); -- 1 for items, 2 for money, 3 for archeology(and other currencies?)
		local _, lootName, _, _, lootRarity, _, _, _, _ = GetLootSlotInfo(i_loot);
		if lootName ~= nil then
			-- Only perform SK for items if they are found in loot prio
			if SKC_Active and SKC_DB.LootPrio:Exists(lootName) then
				-- Valid item
				local lootLink = GetLootSlotLink(i_loot);
				-- Store item
				local loot_idx = SKC_DB.LootManager:AddLoot(lootName,lootLink,loot_option,sk_list);
				-- Alert raid of new item
				local msg = "["..loot_cnt.."] "..lootLink;
				SendChatMessage(msg,"RAID_WARNING");
				loot_cnt = loot_cnt + 1;
				-- Scan all possible characters to determine elligible
				for i_char = 1,40 do
					local char_name = GetMasterLootCandidate(i_loot,i_char);
					if char_name ~= nil then
						if SKC_DB.LootPrio:IsElligible(lootName,char_name) then SKC_DB.LootManager:AddCharacter(char_name,loot_idx) end
					end
				end
			else
				if LOOT_VERBOSE then SKC_Main:Print("NORMAL","Giving directly to ML") end
				-- give directly to ML
				SKC_DB.LootManager:GiveLoot(lootName,GetLootSlotLink(i_loot),UnitName("player"));
			end
		end
	end

	-- Kick off loot decison
	SKC_DB.LootManager:KickOff();
	return;
end

local function CreateUIBorder(title,width,height)
	-- Create Border
	local border_key = title.."_border";
	SKC_UIMain[border_key] = CreateFrame("Frame",border_key,SKC_UIMain,"TranslucentFrameTemplate");
	SKC_UIMain[border_key]:SetSize(width,height);
	SKC_UIMain[border_key].Bg:SetAlpha(0.0);
	-- Create Title
	local title_key = "title";
	SKC_UIMain[border_key][title_key] = CreateFrame("Frame",title_key,SKC_UIMain[border_key],"TranslucentFrameTemplate");
	SKC_UIMain[border_key][title_key]:SetSize(UI_DIMENSIONS.SK_TAB_TITLE_CARD_WIDTH,UI_DIMENSIONS.SK_TAB_TITLE_CARD_HEIGHT);
	SKC_UIMain[border_key][title_key]:SetPoint("BOTTOM",SKC_UIMain[border_key],"TOP",0,-20);
	SKC_UIMain[border_key][title_key].Text = SKC_UIMain[border_key][title_key]:CreateFontString(nil,"ARTWORK")
	SKC_UIMain[border_key][title_key].Text:SetFontObject("GameFontNormal")
	SKC_UIMain[border_key][title_key].Text:SetPoint("CENTER",0,0)
	SKC_UIMain[border_key][title_key].Text:SetText(title)

	return border_key
end

local function OnClick_SKListCycle()
	-- cycle through SK lists
	local sk_list = SKC_UIMain["sk_list_border"].Title.Text:GetText();
	if sk_list == "MSK" then
		SKC_UIMain["sk_list_border"].Title.Text:SetText("TSK");
	else
		SKC_UIMain["sk_list_border"].Title.Text:SetText("MSK");
	end
	-- populate data
	PopulateData();
end
--------------------------------------
-- SHARED FUNCTIONS
--------------------------------------
function SKC_Main:ToggleUIMain(force_show)
	local menu = SKC_UIMain or SKC_Main:CreateUIMain();
	-- Refresh Data
	PopulateData();
	menu:SetShown(force_show or not menu:IsShown());
end

function SKC_Main:Enable(enable_flag)
	SKC_DB.SKC_Enable = enable_flag;
	if SKC_DB.SKC_Enable then
		SKC_Main:Print("IMPORTANT","Enabled");
	else
		SKC_Main:Print("IMPORTANT","Disabled");
	end
	ActivateSKC(true);
	return;
end

function SKC_Main:ReloadUIMain()
	if VERBOSE then SKC_Main:Print("NORMAL","Reloading UI Main") end
	local is_shown = false;
	if SKC_UIMain ~= nil then is_shown = SKC_UIMain:IsShown() end
	if SKC_UIMain == nil then
		if VERBOSE then SKC_Main:Print("NORMAL","ReloadUIMain: SKC_UIMain not created yet") end
		return;
	end
	-- Refresh Data
	PopulateData();
	SKC_UIMain:SetShown(is_shown);
end

function SKC_Main:ResetData()
	-- Reset data
	HARD_DB_RESET = true;
	OnAddonLoad("SKC");
	HARD_DB_RESET = false;
	-- re populate guild data
	InitGuildSync = true;
	event_states.SyncCompleted.GuildData = true;
	SyncGuildData();
	-- TODO, uncomment
	-- event_states.SyncRequestSent = false;
	-- LoginSyncCheckSend(); 
	-- Refresh Data
	SKC_Main:ReloadUIMain();
end

function SKC_Main:GetThemeColor(type)
	local c = THEME.PRINT[type];
	return c.r, c.g, c.b, c.hex;
end

function SKC_Main:Print(type,...)
    local hex = select(4, SKC_Main:GetThemeColor(type));
	local prefix = string.format("|cff%s%s|r", hex:upper(), "SKC:");
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

function SKC_Main:isML()
	-- Check if current player is master looter
	return(UnitName("player") == ML_OVRD or IsMasterLooter());
end

function SKC_Main:isGL()
	-- Check if current player is guild leader
	return(UnitName("player") == GL_OVRD or IsGuildLeader());
end

function SKC_Main:BenchShow()
	-- prints the current bench
	if #SKC_DB.Bench == 0 then
		SKC_Main:Print("NORMAL","Bench is empty");
	else
		SKC_Main:Print("NORMAL","Bench:");
		for idx,name in ipairs(SKC_DB.Bench) do
			SKC_Main:Print("NORMAL",name);
		end
	end
	return;
end

function SKC_Main:BenchAdd(name)
	-- add name to Bench if they exist in the guild DB
	if name == nil then
		SKC_Main:Print("ERROR","You must give a character name")
		return false;
	elseif not SKC_Main:isGL() and not SKC_Main:isML() then
		SKC_Main:Print("ERROR","You must be master looter or guild leader to do that")
		return false;
	end
	if not SKC_DB.GuildData:Exists(name) then
		SKC_Main:Print("ERROR",name.." not in guild database");
		return false;
	elseif (#SKC_DB.Bench == 19) then
		-- 19 names x 13 characters (12 + comma) = 247 < 250 character limit for msg
		SKC_Main:Print("ERROR","The bench can only contain 15 characters");
		return false;
	else
		-- check if already in bench
		for _,bench_name in ipairs(SKC_DB.Bench) do
			if name == bench_name then
				SKC_Main:Print("ERROR",name.." already in bench");
				return false;
			end
		end
		SKC_DB.Bench[#SKC_DB.Bench + 1] = name;
		SKC_Main:Print("NORMAL",name.." added to bench");
		UpdateLiveList();
		SyncPushSend("Bench",CHANNELS.SYNC_PUSH,"GUILD",nil);
		return true;
	end
end

function SKC_Main:BenchClear()
	-- prints the current bench
	if not SKC_Main:isGL() and not SKC_Main:isML() then
		SKC_Main:Print("ERROR","You must be master looter or guild leader to do that.")
		return;
	end
	SKC_DB.Bench = {};
	SKC_Main:Print("NORMAL","Bench cleared");
	UpdateLiveList();
	SyncPushSend("Bench",CHANNELS.SYNC_PUSH,"GUILD",nil);
	return;
end

function SKC_Main:ExportLog()
	local name = "Log Export";
	-- instantiate frame
	local menu = SKC_UICSV[name] or CreateUICSV(name,false);
	menu:SetShown(true);
	-- Add log data
	local log_data = "";
	for idx1,log_entry in ipairs(SKC_DB.RaidLog) do
		for idx2,data in ipairs(log_entry) do
			log_data = log_data..tostring(data);
			log_data = log_data..",";
		end
		log_data = log_data.."\n";
	end
	SKC_UICSV[name].EditBox:SetText(log_data);
	SKC_UICSV[name].EditBox:HighlightText();
end

function SKC_Main:ExportSK()
	local name = "SK List Export";
	-- instantiate frame
	local menu = SKC_UICSV[name] or CreateUICSV(name,false);
	menu:SetShown(true);
	-- get sk list data
	local msk = SKC_DB.MSK:ReturnList();
	local tsk = SKC_DB.TSK:ReturnList();
	if #msk ~= #tsk then
		SKC_Main:Print("ERROR","MSK and TSK lists are different lengths. That's bad.");
		return;
	end
	-- construct data
	local data = "MSK,TSK,\n";
	for i = 1,#msk do
		data = data..msk[i]..","..tsk[i].."\n";
	end
	-- add data to export
	SKC_UICSV[name].EditBox:SetText(data);
	SKC_UICSV[name].EditBox:HighlightText();
end

local function OnClick_ImportLootPrio()
	-- imports loot prio CSV to database
	-- reset database
	SKC_DB.LootPrio = LootPrio:new(nil);
	-- get text
	local name = "Loot Priority Import";
	local txt = SKC_UICSV[name].EditBox:GetText();
	-- skip first 3 rows
	local skip_cnt = 0;
	local line = nil;
	local txt_rem = txt;
	while skip_cnt < 3 do
		line, txt_rem = strsplit("\n",txt_rem,2);
		skip_cnt = skip_cnt + 1;
	end
	-- read data
	local valid = true;
	while txt_rem ~= nil do
		line, txt_rem = strsplit("\n",txt_rem,2);
		local item, sk_list, res, de, open_roll, prios_txt = strsplit(",",line,6);
		item = StrOut(item);
		sk_list = StrOut(sk_list);
		-- check validity
		valid = sk_list == "MSK" or sk_list == "TSK";
		if not valid then
			SKC_Main:Print("ERROR","Invalid SK List for "..item);
			break;
		end
		-- write meta data for item
		SKC_DB.LootPrio.items[item] = Prio:new(nil);
		SKC_DB.LootPrio.items[item].sk_list = sk_list;
		SKC_DB.LootPrio.items[item].reserved = BoolOut(res);
		SKC_DB.LootPrio.items[item].DE = BoolOut(de);
		SKC_DB.LootPrio.items[item].open_roll = BoolOut(open_roll);
		-- read prios
		local idx = 1;
		while prios_txt ~= nil do
			valid = idx <= 22;
			if not valid then
				SKC_Main:Print("ERROR","Too many Class/Spec combinations");
				break;
			end
			-- split off next value
			val, prios_txt = strsplit(",",prios_txt,2);
			valid = false;
			if val == "" then
				-- Inelligible for loot --> permanent pass prio tier
				val = PRIO_TIERS.PASS;
				valid = true;
			elseif val == "OS" then
				val = PRIO_TIERS.SK.Main.OS;
				valid = true;
			else
				val = NumOut(val);
				valid = (val ~= nil and (val >= 1) and (val <= 5));
			end 
			if not valid then
				SKC_Main:Print("ERROR","Invalid prio level for "..item.." and Class/Spec index "..idx);
				break;
			end
			-- write prio value
			SKC_DB.LootPrio.items[item].prio[idx] = val;
			idx = idx + 1;
		end
		-- check that all expected columns were scanned
		if (idx ~= 23) then
			valid = false;
			SKC_Main:Print("ERROR","Not enough Class/Spec combinations. Got "..idx);
			break;
		end
		if not valid then break end
	end
	if not valid then
		SKC_DB.LootPrio = LootPrio:new(nil);
		return;
	end
	-- update edit timestamp
	local ts = time();
	SKC_DB.LootPrio.edit_ts_raid = ts;
	SKC_DB.LootPrio.edit_ts_generic = ts;
	SKC_Main:Print("NORMAL","Loot Priority Import Complete");
	SKC_Main:Print("NORMAL",SKC_DB.LootPrio:length().." items added");
	-- push new loot prio to guild
	SyncPushSend("LootPrio",CHANNELS.SYNC_PUSH,"GUILD",nil);
	SKC_UICSV[name]:Hide();
	return;
end

local function OnClick_ImportSKList(sk_list)
	-- imports SK list CSV into database
	-- get text
	local name = "SK List Import";
	local txt = SKC_UICSV[name].EditBox:GetText();
	-- check that every name in text is in GuildData
	local txt_rem = txt;
	local valid = true;
	local char_name = nil;
	local new_sk_list = {};
	local new_chars_map = {};
	while txt_rem ~= nil do
		char_name, txt_rem = strsplit("\n",txt_rem,2);
		if SKC_DB.GuildData:Exists(char_name) then
			new_sk_list[#new_sk_list + 1] = char_name;
			new_chars_map[char_name] = (new_chars_map[char_name] or 0) + 1;
		else
			-- character not in GuildData
			SKC_Main:Print("ERROR",char_name.." not in GuildData");
			valid = false;
		end
	end
	if not valid then
		SKC_Main:Print("ERROR","SK list not imported");
		return;
	end;
	-- check that every name in GuildData is in text
	valid = true;
	for guild_member,_ in pairs(SKC_DB.GuildData.data) do
		if new_chars_map[guild_member] == nil then
			-- guild member not in list
			SKC_Main:Print("ERROR",guild_member.." not in your SK list");
			valid = false;
		elseif new_chars_map[guild_member] == 1 then
			-- guild member is in list exactly once
		elseif new_chars_map[guild_member] > 1 then
			-- guild member is in list more than once
			SKC_Main:Print("ERROR",guild_member.." is in your SK list more than once");
			valid = false;
		else
			-- guild member not in list
			SKC_Main:Print("ERROR","DUNNO");
			valid = false;
		end
	end
	if not valid then
		SKC_Main:Print("ERROR","SK list not imported");
		return;
	end;
	-- reset database
	SKC_DB[sk_list] = SK_List:new(nil);
	-- write new database
	for idx,val in ipairs(new_sk_list) do
		SKC_DB[sk_list]:PushBack(val);
	end
	SKC_DB[sk_list].edit_ts_generic = 0;
	SKC_DB[sk_list].edit_ts_raid = 0;
	SKC_Main:Print("NORMAL",sk_list.." imported");
	-- push new loot prio to guild
	SyncPushSend(sk_list,CHANNELS.SYNC_PUSH,"GUILD",nil);
	SKC_UICSV[name]:Hide();
	return;
end

function SKC_Main:CSVImport(name,sk_list)
	-- error checking + bind function for import button
	if name == "Loot Priority Import" then
		-- instantiate frame
		local menu = SKC_UICSV[name] or CreateUICSV(name,true);
		menu:SetShown(true);
		SKC_UICSV[name].ImportBtn:SetScript("OnMouseDown",OnClick_ImportLootPrio);
	elseif name == "SK List Import" then
		if sk_list ~= "MSK" and sk_list ~= "TSK" then
			if sk_list == nil then
				SKC_Main:Print("ERROR","No SK list name given")
			else
				SKC_Main:Print("ERROR",sk_list.." is not a list name");
			end
			return;
		end
		-- instantiate frame
		local menu = SKC_UICSV[name] or CreateUICSV(name,true);
		menu:SetShown(true);
		SKC_UICSV[name].ImportBtn:SetScript("OnMouseDown",function() OnClick_ImportSKList(sk_list) end);
	end
	return;
end

function SKC_Main:DisplayLootDecisionGUI(loot_option,sk_list)
	-- Starts loot decision GUI
	SKC_Main:ToggleUIMain(true);
	-- Enable correct buttons
	SKC_UIMain["Decision_border"].Pass_Btn:Enable(); -- OnClick_PASS
	if loot_option == "SK" then
		SKC_UIMain["Decision_border"].SK_Btn:Enable();
	else
		SKC_UIMain["Decision_border"].SK_Btn:Disable(); -- OnClick_SK
	end
	SKC_UIMain["Decision_border"].Roll_Btn:Enable(); -- OnClick_ROLL
	-- Set item (in GUI)
	SetSKItem();
	-- populate correct SK list
	SKC_UIMain["sk_list_border"].Title.Text:SetText(sk_list);
	-- Reload UI
	SKC_Main:ReloadUIMain();
	-- Initiate timer
	StartLootTimer();
	return;
end

function SKC_Main:CreateUIMain()
	-- If addon not yet loaded, reject
	if not event_states.AddonLoaded then return end

	-- Sync data with guild if not already done
	LoginSyncCheckSend();

    SKC_UIMain = CreateFrame("Frame", "SKC_UIMain", UIParent, "UIPanelDialogTemplate");
	SKC_UIMain:SetSize(UI_DIMENSIONS.MAIN_WIDTH,UI_DIMENSIONS.MAIN_HEIGHT);
	SKC_UIMain:SetPoint("CENTER");
	SKC_UIMain:SetMovable(true)
	SKC_UIMain:EnableMouse(true)
	SKC_UIMain:RegisterForDrag("LeftButton")
	SKC_UIMain:SetScript("OnDragStart", SKC_UIMain.StartMoving)
	SKC_UIMain:SetScript("OnDragStop", SKC_UIMain.StopMovingOrSizing)
	SKC_UIMain:SetAlpha(0.8);
	
	-- Add title
    SKC_UIMain.Title:ClearAllPoints();
	SKC_UIMain.Title:SetPoint("LEFT", SKC_UIMainTitleBG, "LEFT", 6, 0);
	SKC_UIMain.Title:SetText("SKC");

	-- Create filter panel
	local filter_border_key = CreateUIBorder("Filters",UI_DIMENSIONS.SK_FILTER_WIDTH,UI_DIMENSIONS.SK_FILTER_HEIGHT)
	-- set position
	SKC_UIMain[filter_border_key]:SetPoint("TOPLEFT", SKC_UIMainTitleBG, "TOPLEFT", UI_DIMENSIONS.MAIN_BORDER_PADDING, UI_DIMENSIONS.MAIN_BORDER_Y_TOP);
	-- create details fields
	local faction_class;
	if UnitFactionGroup("player") == "Horde" then faction_class="Shaman" else faction_class="Paladin" end
	local filter_roles = {"DPS","Healer","Tank","Live","Main","Alt","Inactive","Active","Druid","Hunter","Mage","Priest","Rogue","Warlock","Warrior",faction_class};
	for idx,value in ipairs(filter_roles) do
		if value ~= "SKIP" then
			local row = math.floor((idx - 1) / 4); -- zero based
			local col = (idx - 1) % 4; -- zero based
			SKC_UIMain[filter_border_key][value] = CreateFrame("CheckButton", nil, SKC_UIMain[filter_border_key], "UICheckButtonTemplate");
			SKC_UIMain[filter_border_key][value]:SetSize(25,25);
			SKC_UIMain[filter_border_key][value]:SetChecked(SKC_DB.FilterStates[value]);
			SKC_UIMain[filter_border_key][value]:SetScript("OnClick",OnCheck_FilterFunction)
			SKC_UIMain[filter_border_key][value]:SetPoint("TOPLEFT", SKC_UIMain[filter_border_key], "TOPLEFT", 22 + 73*col , -20 + -24*row);
			SKC_UIMain[filter_border_key][value].text:SetFontObject("GameFontNormalSmall");
			SKC_UIMain[filter_border_key][value].text:SetText(value);
			if idx > 8 then
				-- assign class colors
				SKC_UIMain[filter_border_key][value].text:SetTextColor(CLASSES[value].color.r,CLASSES[value].color.g,CLASSES[value].color.b,1.0);
			end
		end
	end

	-- SK List border
	-- Create Border
	local sk_list_border_key = "sk_list_border";
	SKC_UIMain[sk_list_border_key] = CreateFrame("Frame",sk_list_border_key,SKC_UIMain,"TranslucentFrameTemplate");
	SKC_UIMain[sk_list_border_key]:SetSize(UI_DIMENSIONS.SK_LIST_WIDTH + 2*UI_DIMENSIONS.SK_LIST_BORDER_OFFST,UI_DIMENSIONS.SK_LIST_HEIGHT + 2*UI_DIMENSIONS.SK_LIST_BORDER_OFFST);
	SKC_UIMain[sk_list_border_key].Bg:SetAlpha(0.0);
	-- Create Title
	SKC_UIMain[sk_list_border_key].Title = CreateFrame("Frame",title_key,SKC_UIMain[sk_list_border_key],"TranslucentFrameTemplate");
	SKC_UIMain[sk_list_border_key].Title:SetSize(UI_DIMENSIONS.SK_TAB_TITLE_CARD_WIDTH,UI_DIMENSIONS.SK_TAB_TITLE_CARD_HEIGHT);
	SKC_UIMain[sk_list_border_key].Title:SetPoint("BOTTOM",SKC_UIMain[sk_list_border_key],"TOP",0,-20);
	SKC_UIMain[sk_list_border_key].Title.Text = SKC_UIMain[sk_list_border_key].Title:CreateFontString(nil,"ARTWORK")
	SKC_UIMain[sk_list_border_key].Title.Text:SetFontObject("GameFontNormal")
	SKC_UIMain[sk_list_border_key].Title.Text:SetPoint("CENTER",0,0)
	SKC_UIMain[sk_list_border_key].Title.Text:SetText("MSK")
	SKC_UIMain[sk_list_border_key].Title:SetScript("OnMouseDown",OnClick_SKListCycle);
	-- set position
	SKC_UIMain[sk_list_border_key]:SetPoint("TOPLEFT", SKC_UIMain[filter_border_key], "TOPRIGHT", UI_DIMENSIONS.MAIN_BORDER_PADDING, 0);

	-- Create SK list panel
	SKC_UIMain.sk_list = CreateFrame("Frame",sk_list,SKC_UIMain,"InsetFrameTemplate");
	SKC_UIMain.sk_list:SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,UI_DIMENSIONS.SK_LIST_HEIGHT);
	SKC_UIMain.sk_list:SetPoint("TOP",SKC_UIMain[sk_list_border_key],"TOP",0,-UI_DIMENSIONS.SK_LIST_BORDER_OFFST);

	-- Create scroll frame on SK list
	SKC_UIMain.sk_list.SK_List_SF = CreateFrame("ScrollFrame","SK_List_SF",SKC_UIMain.sk_list,"UIPanelScrollFrameTemplate2");
	SKC_UIMain.sk_list.SK_List_SF:SetPoint("TOPLEFT",SKC_UIMain.sk_list,"TOPLEFT",0,-2);
	SKC_UIMain.sk_list.SK_List_SF:SetPoint("BOTTOMRIGHT",SKC_UIMain.sk_list,"BOTTOMRIGHT",0,2);
	SKC_UIMain.sk_list.SK_List_SF:SetClipsChildren(true);
	SKC_UIMain.sk_list.SK_List_SF:SetScript("OnMouseWheel",OnMouseWheel_ScrollFrame);
	SKC_UIMain.sk_list.SK_List_SF.ScrollBar:SetPoint("TOPLEFT",SKC_UIMain.sk_list.SK_List_SF,"TOPRIGHT",-22,-21);

	-- Create scroll child
	local scroll_child = CreateFrame("Frame",nil,SKC_UIMain.sk_list.SK_List_SF);
	scroll_child:SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,GetScrollMax());
	SKC_UIMain.sk_list.SK_List_SF:SetScrollChild(scroll_child);

	-- Create SK cards
	SKC_UIMain.sk_list.NumberFrame = {};
	SKC_UIMain.sk_list.NameFrame = {};
	for idx = 1, GetNumGuildMembers() do
		-- Create number frames
		SKC_UIMain.sk_list.NumberFrame[idx] = CreateFrame("Frame",nil,SKC_UIMain.sk_list.SK_List_SF,"InsetFrameTemplate");
		SKC_UIMain.sk_list.NumberFrame[idx]:SetSize(30,UI_DIMENSIONS.SK_CARD_HEIGHT);
		SKC_UIMain.sk_list.NumberFrame[idx]:SetPoint("TOPLEFT",SKC_UIMain.sk_list.SK_List_SF:GetScrollChild(),"TOPLEFT",8,-1*((idx-1)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING) + UI_DIMENSIONS.SK_CARD_SPACING));
		SKC_UIMain.sk_list.NumberFrame[idx].Text = SKC_UIMain.sk_list.NumberFrame[idx]:CreateFontString(nil,"ARTWORK")
		SKC_UIMain.sk_list.NumberFrame[idx].Text:SetFontObject("GameFontHighlightSmall")
		SKC_UIMain.sk_list.NumberFrame[idx].Text:SetPoint("CENTER",0,0)
		SKC_UIMain.sk_list.NumberFrame[idx]:SetScript("OnMouseDown",OnClick_NumberCard);
		SKC_UIMain.sk_list.NumberFrame[idx]:Hide();
		-- Create named card frames
		SKC_UIMain.sk_list.NameFrame[idx] = CreateFrame("Frame",nil,SKC_UIMain.sk_list.SK_List_SF,"InsetFrameTemplate");
		SKC_UIMain.sk_list.NameFrame[idx]:SetSize(UI_DIMENSIONS.SK_CARD_WIDTH,UI_DIMENSIONS.SK_CARD_HEIGHT);
		SKC_UIMain.sk_list.NameFrame[idx]:SetPoint("TOPLEFT",SKC_UIMain.sk_list.SK_List_SF:GetScrollChild(),"TOPLEFT",43,-1*((idx-1)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING) + UI_DIMENSIONS.SK_CARD_SPACING));
		SKC_UIMain.sk_list.NameFrame[idx].Text = SKC_UIMain.sk_list.NameFrame[idx]:CreateFontString(nil,"ARTWORK")
		SKC_UIMain.sk_list.NameFrame[idx].Text:SetFontObject("GameFontHighlightSmall")
		SKC_UIMain.sk_list.NameFrame[idx].Text:SetPoint("CENTER",0,0)
		-- Add texture for color
		SKC_UIMain.sk_list.NameFrame[idx].bg = SKC_UIMain.sk_list.NameFrame[idx]:CreateTexture(nil,"BACKGROUND");
		SKC_UIMain.sk_list.NameFrame[idx].bg:SetAllPoints(true);
		-- Bind function for click event
		SKC_UIMain.sk_list.NameFrame[idx]:SetScript("OnMouseDown",OnClick_SK_Card);
		SKC_UIMain.sk_list.NameFrame[idx]:Hide();
	end

	-- Create details panel
	DD_State = 0; -- reset drop down options state
	local details_border_key = CreateUIBorder("Details",UI_DIMENSIONS.SK_DETAILS_WIDTH,UI_DIMENSIONS.SK_DETAILS_HEIGHT);
	-- set position
	SKC_UIMain[details_border_key]:SetPoint("TOPLEFT", SKC_UIMain[sk_list_border_key], "TOPRIGHT", UI_DIMENSIONS.MAIN_BORDER_PADDING, 0);
	-- create details fields
	local details_fields = {"Name","Class","Spec","Raid Role","Guild Role","Status","Activity","Last Raid"};
	for idx,value in ipairs(details_fields) do
		-- fields
		SKC_UIMain[details_border_key][value] = CreateFrame("Frame",SKC_UIMain[details_border_key])
		SKC_UIMain[details_border_key][value].Field = SKC_UIMain[details_border_key]:CreateFontString(nil,"ARTWORK");
		SKC_UIMain[details_border_key][value].Field:SetFontObject("GameFontNormal");
		SKC_UIMain[details_border_key][value].Field:SetPoint("RIGHT",SKC_UIMain[details_border_key],"TOPLEFT",100,-20*idx-10);
		SKC_UIMain[details_border_key][value].Field:SetText(value..":");
		-- data
		SKC_UIMain[details_border_key][value].Data = SKC_UIMain[details_border_key]:CreateFontString(nil,"ARTWORK");
		SKC_UIMain[details_border_key][value].Data:SetFontObject("GameFontHighlight");
		SKC_UIMain[details_border_key][value].Data:SetPoint("CENTER",SKC_UIMain[details_border_key][value].Field,"RIGHT",45,0);
		if idx == 3 or 
		   idx == 5 or
		   idx == 6 or
		   idx == 7 then
			-- edit buttons
			SKC_UIMain[details_border_key][value].Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
			SKC_UIMain[details_border_key][value].Btn:SetID(idx);
			SKC_UIMain[details_border_key][value].Btn:SetPoint("LEFT",SKC_UIMain[details_border_key][value].Field,"RIGHT",95,0);
			SKC_UIMain[details_border_key][value].Btn:SetSize(40, 20);
			SKC_UIMain[details_border_key][value].Btn:SetText("Edit");
			SKC_UIMain[details_border_key][value].Btn:SetNormalFontObject("GameFontNormalSmall");
			SKC_UIMain[details_border_key][value].Btn:SetHighlightFontObject("GameFontHighlightSmall");
			SKC_UIMain[details_border_key][value].Btn:SetScript("OnMouseDown",OnClick_EditDetails);
			SKC_UIMain[details_border_key][value].Btn:Disable();
			-- associated drop down menu
			SKC_UIMain[details_border_key][value].DD = CreateFrame("Frame",nil, SKC_UIMain, "UIDropDownMenuTemplate");
			UIDropDownMenu_SetAnchor(SKC_UIMain[details_border_key][value].DD, 0, 0, "TOPLEFT", SKC_UIMain[details_border_key][value].Btn, "TOPRIGHT");
		end
	end

	-- Add SK buttons
	-- full SK
	SKC_UIMain[details_border_key].FullSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].FullSK_Btn:SetPoint("BOTTOM",SKC_UIMain[details_border_key],"BOTTOM",0,15);
	SKC_UIMain[details_border_key].FullSK_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[details_border_key].FullSK_Btn:SetText("Full SK");
	SKC_UIMain[details_border_key].FullSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].FullSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].FullSK_Btn:SetScript("OnMouseDown",OnClick_FullSK);
	SKC_UIMain[details_border_key].FullSK_Btn:Disable();
	-- single SK
	SKC_UIMain[details_border_key].SingleSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetPoint("RIGHT",SKC_UIMain[details_border_key].FullSK_Btn,"LEFT",-5,0);
	SKC_UIMain[details_border_key].SingleSK_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[details_border_key].SingleSK_Btn:SetText("Single SK");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetScript("OnMouseDown",OnClick_SingleSK);
	SKC_UIMain[details_border_key].SingleSK_Btn:Disable();
	-- set SK
	SKC_UIMain[details_border_key].SetSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].SetSK_Btn:SetPoint("LEFT",SKC_UIMain[details_border_key].FullSK_Btn,"RIGHT",5,0);
	SKC_UIMain[details_border_key].SetSK_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[details_border_key].SetSK_Btn:SetText("Set SK");
	SKC_UIMain[details_border_key].SetSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].SetSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].SetSK_Btn:SetScript("OnMouseDown",OnClick_SetSK);
	SKC_UIMain[details_border_key].SetSK_Btn:Disable();


	-- Decision region
	local decision_border_key = CreateUIBorder("Decision",UI_DIMENSIONS.DECISION_WIDTH,UI_DIMENSIONS.DECISION_HEIGHT)
	-- set position
	SKC_UIMain[decision_border_key]:SetPoint("TOPLEFT", SKC_UIMain[filter_border_key], "TOPLEFT", 0, -UI_DIMENSIONS.SK_FILTER_HEIGHT - UI_DIMENSIONS.MAIN_BORDER_PADDING);

	-- set texture / hidden frame for button click
	SKC_UIMain[decision_border_key].ItemTexture = SKC_UIMain[decision_border_key]:CreateTexture(nil, "ARTWORK");
	SKC_UIMain[decision_border_key].ItemTexture:SetSize(UI_DIMENSIONS.ITEM_WIDTH,UI_DIMENSIONS.ITEM_HEIGHT);
	SKC_UIMain[decision_border_key].ItemTexture:SetPoint("TOP",SKC_UIMain[decision_border_key],"TOP",0,-45)
	SKC_UIMain[decision_border_key].ItemClickBox = CreateFrame("Frame", nil, SKC_UIMain);
	SKC_UIMain[decision_border_key].ItemClickBox:SetSize(UI_DIMENSIONS.ITEM_WIDTH,UI_DIMENSIONS.ITEM_HEIGHT);
	SKC_UIMain[decision_border_key].ItemClickBox:SetPoint("CENTER",SKC_UIMain[decision_border_key].ItemTexture,"CENTER");
	SKC_UIMain[decision_border_key].ItemClickBox:SetScript("OnMouseDown",OnMouseDown_ShowItemTooltip);
	-- set name / link
	SKC_UIMain[decision_border_key].lootLink = SKC_UIMain[decision_border_key]:CreateFontString(nil,"ARTWORK");
	SKC_UIMain[decision_border_key].lootLink:SetFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].lootLink:SetPoint("TOP",SKC_UIMain[decision_border_key],"TOP",0,-25);
	SKC_UIMain[decision_border_key]:SetHyperlinksEnabled(true)
	SKC_UIMain[decision_border_key]:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	-- set decision buttons
	-- SK 
	SKC_UIMain[decision_border_key].SK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].SK_Btn:SetPoint("TOPRIGHT",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",-60,-10);
	SKC_UIMain[decision_border_key].SK_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[decision_border_key].SK_Btn:SetText("SK");
	SKC_UIMain[decision_border_key].SK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].SK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].SK_Btn:SetScript("OnMouseDown",OnClick_SK);
	SKC_UIMain[decision_border_key].SK_Btn:Disable();
	-- Roll 
	SKC_UIMain[decision_border_key].Roll_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].Roll_Btn:SetPoint("TOP",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",0,-10);
	SKC_UIMain[decision_border_key].Roll_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[decision_border_key].Roll_Btn:SetText("Roll");
	SKC_UIMain[decision_border_key].Roll_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].Roll_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].Roll_Btn:SetScript("OnMouseDown",OnClick_ROLL);
	SKC_UIMain[decision_border_key].Roll_Btn:Disable();
	-- Pass
	SKC_UIMain[decision_border_key].Pass_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].Pass_Btn:SetPoint("TOPLEFT",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",60,-10);
	SKC_UIMain[decision_border_key].Pass_Btn:SetSize(UI_DIMENSIONS.BTN_WIDTH, UI_DIMENSIONS.BTN_HEIGHT);
	SKC_UIMain[decision_border_key].Pass_Btn:SetText("Pass");
	SKC_UIMain[decision_border_key].Pass_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].Pass_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].Pass_Btn:SetScript("OnMouseDown",OnClick_PASS);
	SKC_UIMain[decision_border_key].Pass_Btn:Disable();
	-- timer bar
	SKC_UIMain[decision_border_key].TimerBorder = CreateFrame("Frame",nil,SKC_UIMain,"TranslucentFrameTemplate");
	SKC_UIMain[decision_border_key].TimerBorder:SetSize(UI_DIMENSIONS.STATUS_BAR_BRDR_WIDTH,UI_DIMENSIONS.STATUS_BAR_BRDR_HEIGHT);
	SKC_UIMain[decision_border_key].TimerBorder:SetPoint("TOP",SKC_UIMain[decision_border_key].Roll_Btn,"BOTTOM",0,-7);
	SKC_UIMain[decision_border_key].TimerBorder.Bg:SetAlpha(1.0);
	-- status bar
	SKC_UIMain[decision_border_key].TimerBar = CreateFrame("StatusBar",nil,SKC_UIMain);
	SKC_UIMain[decision_border_key].TimerBar:SetSize(UI_DIMENSIONS.STATUS_BAR_BRDR_WIDTH - UI_DIMENSIONS.STATUS_BAR_WIDTH_OFFST,UI_DIMENSIONS.STATUS_BAR_BRDR_HEIGHT - UI_DIMENSIONS.STATUS_BAR_HEIGHT_OFFST);
	SKC_UIMain[decision_border_key].TimerBar:SetPoint("CENTER",SKC_UIMain[decision_border_key].TimerBorder,"CENTER",0,-1);
	-- background texture
	SKC_UIMain[decision_border_key].TimerBar.bg = SKC_UIMain[decision_border_key].TimerBar:CreateTexture(nil,"BACKGROUND",nil,-7);
	SKC_UIMain[decision_border_key].TimerBar.bg:SetAllPoints(SKC_UIMain[decision_border_key].TimerBar);
	SKC_UIMain[decision_border_key].TimerBar.bg:SetColorTexture(unpack(THEME.STATUS_BAR_COLOR));
	SKC_UIMain[decision_border_key].TimerBar.bg:SetAlpha(0.8);
	-- bar texture
	SKC_UIMain[decision_border_key].TimerBar.Bar = SKC_UIMain[decision_border_key].TimerBar:CreateTexture(nil,"BACKGROUND",nil,-6);
	SKC_UIMain[decision_border_key].TimerBar.Bar:SetColorTexture(0,0,0);
	SKC_UIMain[decision_border_key].TimerBar.Bar:SetAlpha(1.0);
	-- set status texture
	SKC_UIMain[decision_border_key].TimerBar:SetStatusBarTexture(SKC_UIMain[decision_border_key].TimerBar.Bar);
	-- add text
	SKC_UIMain[decision_border_key].TimerText = SKC_UIMain[decision_border_key]:CreateFontString(nil,"ARTWORK")
	SKC_UIMain[decision_border_key].TimerText:SetFontObject("GameFontHighlightSmall")
	SKC_UIMain[decision_border_key].TimerText:SetPoint("CENTER",SKC_UIMain[decision_border_key].TimerBar,"CENTER")
	SKC_UIMain[decision_border_key].TimerText:SetText(LOOT_DECISION.OPTIONS.MAX_TIME)
	-- values
	SKC_UIMain[decision_border_key].TimerBar:SetMinMaxValues(0,LOOT_DECISION.OPTIONS.MAX_TIME);
	SKC_UIMain[decision_border_key].TimerBar:SetValue(0);

	-- Populate Data
	PopulateData();

	-- Make frame closable with esc
	table.insert(UISpecialFrames, "SKC_UIMain");
    
	SKC_UIMain:Hide();
	return SKC_UIMain;
end

--------------------------------------
-- EVENTS
--------------------------------------
local function EventHandler(self,event,...)
	if event == "CHAT_MSG_ADDON" then
		AddonMessageRead(...);
	elseif event == "ADDON_LOADED" then
		OnAddonLoad(...);
	elseif event == "GUILD_ROSTER_UPDATE" then
		-- Kick off timer to perform guild update and send sync request
		C_Timer.After(1.0,SyncGuildData);
		C_Timer.After(1.1,LoginSyncCheckSend);
	elseif event == "RAID_ROSTER_UPDATE" then
		UpdateLiveList();
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		UpdateLiveList();
	elseif event == "OPEN_MASTER_LOOT_LIST" then
		SaveLoot();
	elseif event == "RAID_INSTANCE_WELCOME" then
		if not event_states.RaidLoggingActive then
			event_states.RaidLoggingActive = true;
			ResetRaidLogging();
		end
	end
	
	return;
end

local events = CreateFrame("Frame");
events:RegisterEvent("CHAT_MSG_ADDON");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("GUILD_ROSTER_UPDATE");
events:RegisterEvent("RAID_ROSTER_UPDATE");
events:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
events:RegisterEvent("OPEN_MASTER_LOOT_LIST");
events:RegisterEvent("RAID_INSTANCE_WELCOME");
events:SetScript("OnEvent", EventHandler);