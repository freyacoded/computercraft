local config = {
	monitor = "monitor_0",
	itemBarScale = math.log,
	chests = {
		valuables     = "minecraft:ironchest_gold_0",
		stone         = "minecraft:ironchest_iron_1",
		components    = "minecraft:ironchest_gold_1",
		organic       = "minecraft:ironchest_iron_3",
		miscellaneous = "minecraft:ironchest_iron_4"
	},
	chestColors = {
		valuables     = colors.orange,
		stone         = colors.lightGray,
		components    = colors.cyan,
		organic       = colors.green,
		miscellaneous = colors.pink,
		intake        = colors.red
	},
	views = {
		"total",
		"valuables",
		"stone",
		"components",
		"organic",
		"miscellaneous",
		"intake"
	},
	intakes = {
		"minecraft:ironchest_iron_5"
	},
	sort = {
		coal = "valuables",
		certus_quartz = "valuables",
		ore = "valuables",
		redstone = "valuables",

		flint = "stone",
		gravel = "stone",
		clay_ball = "stone"
	},
	humanName = {
		["minecraft:log/0"] = "oak_log",
		["minecraft:log/2"] = "birch_log",
		["minecraft:stone/0"] = "stone",
		["minecraft:stone/5"] = "stone_andesite",
		["minecraft:dye/4"] = "lapis_lazuli",

		["thermalfoundation:ore/0"] = "copper_ore",
		["thermalfoundation:ore/1"] = "tin_ore",
		["thermalfoundation:ore/2"] = "silver_ore",
		["thermalfoundation:ore/3"] = "lead_ore",
		["thermalfoundation:ore/4"] = "aluminum_ore",
		["thermalfoundation:ore/5"] = "nickel_ore",
		["thermalfoundation:material/128"] = "copper_ingot",
		["thermalfoundation:material/129"] = "tin_ingot",
		["thermalfoundation:material/130"] = "silver_ingot",
		["thermalfoundation:material/163"] = "bronze_ingot",
		["thermalfoundation:material/893"] = "destabilised_cathrate",
		["thermalfoundation:material/32"] = "iron_plate",

		["ic2:resource/4"] = "uranium_ore",

		["mekanism:oreblock/0"] = "osmium_ore",
		["mekanism:ingot/1"] = "osmium_ingot",

		["appliedenergistics2:material/0"] = "certus_quartz",
		["appliedenergistics2:material/1"] = "charged_certus_quartz",

		["galacticraftcore:basic_item/2"] = "raw_silicon"
	},
	mustHaveLookup = {
		ore = true, 
		resource = true,
		ingot = true, 
		material = true,
		materials = true,
		oreblock = true, 
		orepart = true, 
		ingredients = true,
		basic_item = true,
		crafting = true,
		log = true,
		stone = true,
		food = true
	},
	blit = {
		[1] = "0",
		[2] = "1",
		[4] = "2",
		[8] = "3",
		[16] = "4",
		[32] = "5",
		[64] = "6",
		[128] = "7",
		[256] = "8",
		[512] = "9",
		[1024] = "a",
		[2048] = "b",
		[4096] = "c",
		[8192] = "d",
		[16384] = "e",
		[32768] = "f"
	}
}

return config
