
//I dislike using boolean [int] here, since order isn't really supposed to be guaranteed, but ASH won't let you use {} list syntax outside of variable declarations. I think?
int CargoSelectUnusedPocket(boolean [int] pocket_ids, boolean [int] pockets_emptied)
{
    foreach id in pocket_ids
    {
        if (!pockets_emptied[id])
        {
            return id;
        }
    }
    return -1;
}


void CargoHandleStats(boolean [int] pockets_emptied, string [string][int] pocket_options)
{
    if (!__misc_state["need to level"])
    {
    	return;
    }
    //stats:
    stat mainstat = my_primestat();
    
    int mainstat_pocket = -1;
    if (mainstat == $stat[muscle] || true)
    {
        int pocket_id = CargoSelectUnusedPocket($ints[161,52,545,40,468,291,515,358,454,225,69], pockets_emptied);
        //what outfits need muscle...?
        if (mainstat == $stat[muscle])
        {
            mainstat_pocket = pocket_id;
        }
        else
        {
            pocket_options["Statgain"][pocket_id] = "muscle";
        }
    }
    if (mainstat == $stat[mysticality] || true)//my_basestat($stat[mysticality] < 70)
    {
        int pocket_id = CargoSelectUnusedPocket($ints[37,183,176,210,133,283,103,358,194,585,459], pockets_emptied);
        if (mainstat == $stat[mysticality])
        {
            mainstat_pocket = pocket_id;
        }
        else
        {
            pocket_options["Statgain"][pocket_id] = "mysticality";
        }
    }
    if (mainstat == $stat[moxie] || true)//my_basestat($stat[moxie] < 70)
    {
        int pocket_id = CargoSelectUnusedPocket($ints[277,606,182,89,378,421,205,454,194,500,12], pockets_emptied);
        if (mainstat == $stat[moxie])
        {
            mainstat_pocket = pocket_id;
        }
        else
        {
            pocket_options["Statgain"][pocket_id] = "moxie";
        }
    }
    if (mainstat_pocket != -1)
        pocket_options["Statgain"][mainstat_pocket] = "mainstat";
    pocket_options["Statgain"][1] = "Every stat";
}

void CargoHandleFreeFights(boolean [int] pockets_emptied, string [string][int] pocket_options)
{
	//Fight table:
/*
pocket id	name	useful?	usefulness rating	notes	YR?
√317	Camel's Toe	very	1	stars + lines, 30% drop
√565	mountain man	yes	1	ore	yes
√383	Skinflute	very	1	stars + lines, 30% drop
√666	smut orc pervert	very	1	smut orc keepsake box
√589	Green Ops Soldier	kinda, smoke + (war progress?)	2		yes
√220	lobsterfrogman	yes	2
√235	modern zmobie	kinda	2
√452	pygmy shaman	yes	2	silly shaman things - ONLY during quest
√443	War Hippy (space) cadet	very	2	hippy war outfit	yes
√568	War Pledge	very	2	frat war outfit	yes
√136	Knob Goblin Elite Guardsman	yes	3	must YR for outfit	yes
490	Booze Giant	ya kinda, booze	4		yes
402	Fruit Golem	vaguely, fruit	4	cherry + lime + orange, 15% drop	yes
363	pufferfish	probably	4	pufferfish spines for silly things
250	Blooper	not really	5
191	batrat	I mean… could YR?	6		yes
612	bugbear-in-the-box	vaguely	7	drops a box	yes
47	dairy goat	vaguely	8	you can olfact this
143	dirty old lihc	vaguely	8	you can olfact this
279	Hellion	only in a vague sense	8	hellion cube for hell ramen
299	Knob Goblin Harem Girl	kinda	8	you can meet this	yes (20%)
646	1335 HaXx0r	don’t think so
306	big creepy spider	nope
30	bookbat	nope
448	completely different spider	nope
267	creepy clown	don’t think so
425	eXtreme Orcish snowboarder	I don’t think so
428	Mob Penguin Thug	don’t think so
 */
	if (__misc_state["in run"])
	{
        //these tests really need to be unified
		if ($item[richard's star key].available_amount() + $item[richard's star key].creatable_amount() == 0 && !__quest_state["Level 13"].state_boolean["Richard's star key used"] && !($item[star].available_amount() >= 8 && $item[line].available_amount() >= 7))
        {
        	if (!pockets_emptied[317])
            {
            	pocket_options["Free Fights"][317] = "Camel's Toe for stars and lines";
            }
            else
            {
            	pocket_options["Free Fights"][383] = "Skinflute for stars and lines";
            }
        }
        int missing_ore = MAX(0, 3 - __quest_state["Level 8"].state_string["ore needed"].to_item().available_amount());
        if (!__quest_state["Level 8"].state_boolean["Past mine"] && missing_ore > 0)
        {
            pocket_options["Free Fights"][565] = "Mountain man for ore (YR)";
        }
        if (!__quest_state["Level 9"].state_boolean["bridge complete"] && (__quest_state["Level 9"].state_int["bridge fasteners needed"] > 1 || __quest_state["Level 9"].state_int["bridge lumber needed"] > 1))
        {
            pocket_options["Free Fights"][666] = "Smut orc pervert for bridge parts";
        }
        if (!__quest_state["Level 12"].finished) //FIXME improve to be more precise
        {
            pocket_options["Free Fights"][589] = "Green Ops Soldier for smoke bombs + war progress (YR)";
        }
        if (!(__quest_state["Level 12"].finished || __quest_state["Level 12"].state_boolean["Lighthouse Finished"] || $item[barrel of gunpowder].available_amount() == 5))
        {
            pocket_options["Free Fights"][220] = "lobsterfrogman for barrels" + ($item[barrel of gunpowder].available_amount() < 4 ? " (copy)" : "");
        }
        if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
        {
        	int evilness = get_property_int("cyrptAlcoveEvilness");
            pocket_options["Free Fights"][235] = "modern zmobie for faster alcove" + (evilness >= 31 ? " (copy)" : "");
        }
        if (!__quest_state["Level 11 Hidden City"].state_boolean["Apartment finished"] && $effect[thrice-cursed].have_effect() == 0)
        {
        	string description = "pygmy shaman for hidden apartment ";
            boolean should_copy = false;
            if ($effect[twice-cursed].have_effect() > 0)
            {
            	description += "thrice-cursed";
            }
            else if ($effect[once-cursed].have_effect() > 0)
            {
            	description += "twice-cursed";
                should_copy = true;
            }
            else
            {
            	description += "once-cursed";
             	should_copy = true;
            }
            description += " effect";
            if (should_copy)
            	description += " (copy)";
            pocket_options["Free Fights"][452] = description;
        }
        if (!(__quest_state["Level 12"].finished || have_outfit_components("War Hippy Fatigues")))
        {
            pocket_options["Free Fights"][443] = "War Hippy (space) cadet for hippy war outfit (YR)";
        }
        if (!(__quest_state["Level 12"].finished || have_outfit_components("Frat Warrior Fatigues")))
        {
            pocket_options["Free Fights"][568] = "War Pledge for frat war outfit (YR)";
        }
        if (!have_outfit_components("Knob Goblin Elite Guard Uniform") && !have_outfit_components("Knob Goblin Harem Girl Disguise") && !__quest_state["Level 5"].finished)
        {
            pocket_options["Free Fights"][136] = "Knob Goblin Elite Guardsman for Knob Goblin Elite Guard Uniform outfit";
        }
        /*if (some_test)
        {
            pocket_options["Free Fights"][490] = "Booze Giant for booze (YR)";
        }
        if (some_test)
        {
            pocket_options["Free Fights"][402] = "Fruit Golem for fruit (YR)";
        }*/
	}
}

void CargoHandleEffects(boolean [int] pockets_emptied, string [string][int] pocket_options)
{
	//pocket_options["Effects"][777] = "To be added";
}

void CargoHandleItems(boolean [int] pockets_emptied, string [string][int] pocket_options)
{
	//pocket_options["Items"][777] = "To be added";
}

RegisterGenerationFunction("IOTMCargoCultistShortsGenerate");
void IOTMCargoCultistShortsGenerate(ChecklistCollection checklists)
{
	item cultist_shorts = lookupItem("Cargo Cultist Shorts");
	if (!cultist_shorts.have()) return;
	
	if (!get_property_boolean("_cargoPocketEmptied"))
	{
		string [int] description;
        
        boolean [int] pockets_emptied = get_property("cargoPocketsEmptied").stringToIntIntList(",").listInvert();
        
        
        string [string][int] pocket_options; //pocket_options["Category Name"][pocket_id] = "description";
        
        CargoHandleStats(pockets_emptied, pocket_options);
        CargoHandleFreeFights(pockets_emptied, pocket_options);
        CargoHandleEffects(pockets_emptied, pocket_options);
        CargoHandleItems(pockets_emptied, pocket_options);
        

        foreach category_name in pocket_options
        {
        	buffer category_description;
            category_description.append(category_name);
            category_description.append(": |*");
            boolean should_add = false;
        	foreach pocket_id in pocket_options[category_name]
            {
            	if (pocket_id == -1)
                {
                	continue;
                }
            	if (pockets_emptied[pocket_id])
                {
                	continue;
                }
                should_add = true;
                string description = pocket_options[category_name][pocket_id];
                category_description.append("<span style=\"min-width:33%;display:inline-block;\">");
                category_description.append("<strong>");
                category_description.append(pocket_id);
                category_description.append("</strong>: ");
                category_description.append(description);
                category_description.append("</span>");
            }
            if (should_add)
            {
            	description.listAppend(category_description.to_string());
            }
        }
        
        
        checklists.add(C_RESOURCES, ChecklistEntryMake(546, "__item Cargo Cultist Shorts", "inventory.php?action=pocket", ChecklistSubentryMake("Cargo Cultist Shorts pocket", "", description), 1));
	}
}
