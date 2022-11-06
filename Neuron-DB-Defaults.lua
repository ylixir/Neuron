-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...

local Array = addonTable.utilities.Array
local Table = addonTable.utilities.Table

---**NOTE** values assigned with empty quotes, i.e. name = "", basically don't exist. Lua treats them as nil

local function genericSpecData()
  return {
		['**'] = {
			actionID = false,

			macro_Text = "",
			macro_Icon = false,
			macro_Name = "",
			macro_Note = "",
			macro_UseNote = false,
			macro_BlizzMacro = false,
			macro_EquipmentSet = false,
		},
		homestate = {}
	}
end

local genericKeyData = {
	keys = {
		hotKeyLock = false,
		hotKeyPri = false,
		hotKeyText = ":",
		hotKeys = ":"
	}
}


--- Button fields
-- indexes refer to a table of pairs which include a function to
-- generate the button data
--@field cIndex center text index
--@field lIndex left text index
--@field rIndex right text index
--@field mIndex mouse over text index. hides other text
--@field tIndex tooltip index

local genericXPBtnData= Table.spread(genericKeyData){
	config = {
		curXPType = "player_xp",

		width = 450,
		height = 18,
		texture = 7,
		border = 1,

		orientation = 1,

		cIndex = 2,
		cColor = {1,1,1},

		lIndex = 6,
		lColor = {1,1,1},

		rIndex = 4,
		rColor = {1,1,1},

		mIndex = 3,
		mColor = {1,1,1},

		tIndex = 1,
		tColor = {1,1,1},

		bordercolor = {1,1,1},
	}
}

local genericRepBtnData= Table.spread(genericKeyData){
	config = {
		repID = 2,
		autoWatch = 2,

		width = 450,
		height = 18,
		texture = 7,
		border = 1,

		orientation = 1,

		cIndex = 3,
		cColor = {1,1,1},

		lIndex = 2,
		lColor = {1,1,1},

		rIndex = 4,
		rColor = {1,1,1},

		mIndex = 6,
		mColor = {1,1,1},

		tIndex = 1,
		tColor = {1,1,1},

		bordercolor = {1,1,1},
	}
}

local genericCastBtnData= Table.spread(genericKeyData){
	config = {
		width = 250,
		height = 18,
		texture = 7,
		border = 1,

		orientation = 1,

		cIndex = 1,
		cColor = {1,1,1},

		lIndex = 2,
		lColor = {1,1,1},

		rIndex = 3,
		rColor = {1,1,1},

		mIndex = 1,
		mColor = {1,1,1},

		tIndex = 1,
		tColor = {1,1,1},

		bordercolor = {1,1,1},

		castColor = {1,0.7,0},
		channelColor = {0,1,0},
		successColor = {0,1,0},
		failColor = {1,0,0},

		unit = "player",
		showIcon = true,
	}
}

local genericMirrorBtnData= Table.spread(genericKeyData){
	config = {
		width = 250,
		height = 18,
		texture = 7,
		border = 1,

		orientation = 1,

		cIndex = 1,
		cColor = {1,1,1},

		lIndex = 2,
		lColor = {1,1,1},

		rIndex = 3,
		rColor = {1,1,1},

		mIndex = 1,
		mColor = {1,1,1},

		tIndex = 1,
		tColor = {1,1,1},

		bordercolor = {1,1,1},
	}
}


local genericBarData = {
	name = ":",

	buttons = {
		['*'] = Table.spread(genericKeyData){
			config = { btnType = "macro" },
			data = {},
		}
	},

	hidestates = ":",

	point = "BOTTOM",
	x = 0,
	y = 190,

	scale = 1,
	shape = "linear",
	columns = 0,

	alpha = 1,
	alphaUp = "off",
	alphaMax = 1,
	fadeSpeed = 0.5,

	strata = 3,

	padH = 3,
	padV = 3,
	arcStart = 0,
	arcLength = 359,

	snapTo = false,
	snapToPad = 0,
	snapToPoint = false,
	snapToFrame = false,

	autoHide = false,
	showGrid = true,

	bindColor = {1,1,1},
	macroColor = {1,1,1},
	countColor = {1,1,1},
	cdcolor1 = {1,0.82,0},
	cdcolor2 = {1,0.1,0.1},
	rangecolor = {0.7,0.15,0.15},
	manacolor = {0.5,0.5,1.0},

	border = true,

	clickMode = "UpClick",

	conceal = false,

	multiSpec = false,

	spellGlow = "default",

	barLock = false,

	tooltips = "normal",
	tooltipsCombat = true,

	bindText = true,
	buttonText = true,
	countText = true,
	rangeInd = true,

	cdText = false,
	cdAlpha = false,

	showBorderStyle = true,

	homestate = true,
	paged = false,
	stance = false,
	stealth = false,
	reaction = false,
	combat = false,
	group = false,
	pet = false,
	fishing = false,
	vehicle = false,
	possess = false,
	override = false,
	extrabar = false,
	alt = false,
	ctrl = false,
	shift = false,
	target = false,

	selfCast = false,
	focusCast = false,
	rightClickTarget = false,
	mouseOverCast = false,

	custom = false,
	customRange = false,
	customNames = false,

	remap = false,
}



------------------------------------------------------------------------
----------------------MAIN TABLE----------------------------------------
------------------------------------------------------------------------

addonTable.databaseDefaults = {
	profile = {
		blizzbar = false,

		mouseOverMod= "NONE",

		firstRun = true,

		NeuronItemCache = {},
		NeuronSpellCache = {},

		NeuronIcon = {hide = false,},

		ActionBar = {
			['*'] = Table.spread(genericBarData) {
				buttons = {
					['*'] = Table.spread(
						{ config = { btnType = "macro" }, },
						genericKeyData,

						--any time a player is without spec, it is now treated as spec 5
						--so we need 5 specs or we will error out on new character creation
						Array.initialize(5,genericSpecData)
					)
				}
			}
		},

		ExtraBar = {
			['*'] = Table.spread(genericBarData){}
		},

		ExitBar ={
			['*'] = Table.spread(genericBarData){}
		},

		BagBar = {
			['*'] = Table.spread(genericBarData){}
		},

		ZoneAbilityBar = {
			['*'] = Table.spread(genericBarData){}
		},

		MenuBar = {
			['*'] = Table.spread(genericBarData){}
		},

		PetBar = {
			['*'] = Table.spread(genericBarData){}
		},

		XPBar = {
			['*'] = Table.spread(genericBarData){
				buttons ={
					['*'] = Table.spread(genericXPBtnData){},
				}
			}
		},

		RepBar = {
			['*'] = Table.spread(genericBarData){
				buttons ={
					['*'] = Table.spread(genericRepBtnData){},
				}
			}
		},

		CastBar = {
			['*'] = Table.spread(genericBarData){
				buttons ={
					['*'] = Table.spread(genericCastBtnData){},
				}
			}
		},

		-- breath/fatigue, etc
		MirrorBar = {
			['*'] = Table.spread(genericBarData){
				buttons ={
					['*'] = Table.spread(genericMirrorBtnData){},
				}
			}
		},
	}
}
