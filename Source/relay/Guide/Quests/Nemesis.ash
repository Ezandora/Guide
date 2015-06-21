
//"started", "finished" observed for questG04Nemesis

void QNemesisInit()
{
    if (!($classes[seal clubber, turtle tamer, pastamancer, sauceror, disco bandit, accordion thief] contains my_class()))
        return;
	//questG04Nemesis
	QuestState state;
    
	
	QuestStateParseMafiaQuestProperty(state, "questG04Nemesis");
	
	state.quest_name = "Nemesis Quest";
	state.image_name = "__half Nemesis";
	
	if (my_basestat(my_primestat()) >= 12)
		state.startable = true;
    if (!mafiaIsPastRevision(15935) && state.mafia_internal_step > 1)
        state.mafia_internal_step += 4; //hack to support old versions, probably won't work
	
	__quest_state["Nemesis"] = state;
}

void QNemesisGenerateIslandTasks(ChecklistSubentry subentry)
{
    if (my_class() == $class[disco bandit])
    {
        skill [int] rave_skills_needed;
        if (!$skill[Break It On Down].skill_is_usable())
            rave_skills_needed.listAppend($skill[Break It On Down]);
        if (!$skill[Pop and Lock It].skill_is_usable())
            rave_skills_needed.listAppend($skill[Pop and Lock It]);
        if (!$skill[Run Like the Wind].skill_is_usable())
            rave_skills_needed.listAppend($skill[Run Like the Wind]);
        
        monster [skill] rave_skills_to_monster;
        rave_skills_to_monster[$skill[Break It On Down]] = $monster[breakdancing raver];
        rave_skills_to_monster[$skill[Pop and Lock It]] = $monster[pop-and-lock raver];
        rave_skills_to_monster[$skill[run like the wind]] = $monster[running man];
        
        boolean have_all_rave_skills = (rave_skills_needed.count() == 0);
        if (!$skill[gothy handwave].skill_is_usable())
        {
            subentry.entries.listAppend("Talk to the girl in a black dress.");
        }
        else if (!have_all_rave_skills)
        {
            //Learn dance moves.
            string [int] monsters_to_fight;
            foreach key in rave_skills_needed
            {
                skill rave_skill = rave_skills_needed[key];
                monsters_to_fight.listAppend(rave_skills_to_monster[rave_skill].to_string());
            }
            subentry.entries.listAppend("Learn dance moves from the " + monsters_to_fight.listJoinComponents(", ", "and") + ".");
        }
        else
        {
            //Acquire ravosity.
            if (numeric_modifier("raveosity") >= 7)
            {
                subentry.entries.listAppend("Talk to the guard.");
            }
            else
            {
                int extra_raveosity_from_equip = 0;
                item [int] items_have_but_unequipped;
                foreach it in $items[rave visor,baggy rave pants,pacifier necklace,teddybear backpack,glowstick on a string,candy necklace,rave whistle,blue glowstick,green glowstick,purple glowstick,pink glowstick,orange glowstick,yellow glowstick]
                {
                    if (it.available_amount() > 0 && it.equipped_amount() == 0)
                    {
                        items_have_but_unequipped.listAppend(it);
                        extra_raveosity_from_equip += numeric_modifier(it, "raveosity").to_int();
                    }
                }
                
                int raveosity_needed = (7 - (extra_raveosity_from_equip + numeric_modifier("raveosity").to_int()));
                
                if (raveosity_needed > 0)
                {
                    string line = "Rave steal to find ";
                    
                    if (raveosity_needed == 1)
                        line += "One More Raveosity.";
                    else
                        line += raveosity_needed.int_to_wordy() + " more raveosity.";
                    subentry.entries.listAppend(line);
                }
                
                if (items_have_but_unequipped.count() > 0)
                    subentry.entries.listAppend("Wear " + items_have_but_unequipped.listJoinComponents(", ", "and") + ".");
            }
        }
    }
    else if (my_class() == $class[accordion thief])
    {
        if ($item[hacienda key].available_amount() >= 5)
            subentry.entries.listAppend("All keys found. Fight in the Hacienda.");
        else
        {
            subentry.modifiers.listAppend("-combat");
            int keys_needed = MAX(0, 5 - $item[hacienda key].available_amount());
            subentry.entries.listAppend(pluralizeWordy(keys_needed, "key", "keys").capitalizeFirstLetter() + " to go.");
            subentry.entries.listAppend("Four are from the non-combat; one is from pick-pocketing a mariachi.");
        }
    }
    else if (my_class() == $class[pastamancer])
    {
        if ($item[spaghetti cult robe].available_amount() > 0)
        {
            if ($item[spaghetti cult robe].equipped_amount() == 0)
                subentry.entries.listAppend("Equip spaghetti cult robe, then enter the lair.");
            else
                subentry.entries.listAppend("Enter the lair.");
        }
        else if (my_thrall() == $thrall[spaghetti elemental])
        {
            string [int] tasks;
            if ($thrall[spaghetti elemental].level <3)
            {
                string line = "level your cute and adorable spaghetti elemental to 3";
                if ($item[experimental carbon fiber pasta additive].available_amount() > 0)
                {
                    line += " (use the experimental carbon fiber pasta additive)";
                }
                tasks.listAppend(line);
            }
            tasks.listAppend("defeat a cult member");
            
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if ($skill[Bind Spaghetti Elemental].skill_is_usable())
        {
            subentry.entries.listAppend("Cast Bind Spaghetti Elemental.");
        }
        else
        {
            if ($item[decoded cult documents].available_amount() > 0)
            {
                subentry.entries.listAppend("Use decoded cult documents.");
            }
            else
            {
                if ($item[encoded cult documents].available_amount() == 0)
                    subentry.entries.listAppend("Acquire encoded cult documents from a protestor.");
                
                int missing_cult_memos = MAX(0, 5 - $item[cult memo].available_amount());
                if (missing_cult_memos > 0)
                {
                    subentry.entries.listAppend("Acquire " + pluralize(missing_cult_memos, $item[cult memo]) + " more from middle-managers.");
                }
                else if ($item[encoded cult documents].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use cult memos.");
                }
            }
        }
    }
    else if (my_class() == $class[turtle tamer])
    {
        if ($item[Fouet de tortue-dressage].available_amount() == 0)
            subentry.entries.listAppend("Talk to a guy in the bushes.");
        else
        {
            if ($item[Fouet de tortue-dressage].equipped_amount() == 0)
                subentry.entries.listAppend("Equip Fouet de tortue-dressage.");
            subentry.entries.listAppend("Use Apprivoisez la tortue on french turtles a bunch, save them!|Then talk to the guy in the bushes.");
        }
    }
    else if (my_class() == $class[sauceror])
    {
        if ($item[bottle of G&uuml;-Gone].available_amount() == 0)
            subentry.entries.listAppend("Visit the boat.");
        else
        {
            /*
            lastSlimeVial3891(user, now 'intensity', default )
            lastSlimeVial3892(user, now 'moxiousness', default )
            lastSlimeVial3893(user, now 'eyesight', default )
            lastSlimeVial3894(user, now 'mentalism', default )
            lastSlimeVial3895(user, now 'muscle', default )
            lastSlimeVial3896(user, now 'slimeform', default )
            */
            if ($effect[slimeform].have_effect() > 0)
                subentry.entries.listAppend("Wiggle into the lair.|Also, go visit your mom in the slimetube.");
            else
            {
                
                boolean [item] tertiary_potions = $items[vial of vermilion slime,vial of amber slime,vial of chartreuse slime,vial of teal slime,vial of purple slime,vial of indigo slime];
                
                item slimeform_potion = $item[none];
                item [int] creatable_unknown_potions;
                foreach potion in tertiary_potions
                {
                    string property_value = get_property("lastSlimeVial" + potion.to_int());
                    if (property_value.length() == 0)
                    {
                        if (potion.available_amount() + potion.creatable_amount() > 0)
                            creatable_unknown_potions.listAppend(potion);
                    }
                    else if (property_value == "slimeform")
                        slimeform_potion = potion;
                }
                if (slimeform_potion != $item[none] && slimeform_potion.creatable_amount() + slimeform_potion.available_amount() > 0)
                {
                    subentry.entries.listAppend("Use a " + slimeform_potion + " to gain slimeform.");
                    //FIXME URL
                }
                else
                {
                    subentry.entries.listAppend("Use the " + $item[bottle of G&uuml;-Gone] + " on slime, make potions to get slimeform.");
                    if (creatable_unknown_potions.count() > 0 && slimeform_potion == $item[none])
                    {
                        boolean need_to_make = false;
                        foreach key, it in creatable_unknown_potions
                        {
                            if (it.available_amount() == 0 && it.creatable_amount() > 0)
                                need_to_make = true;
                        }
                        
                        string line = "Try";
                        if (need_to_make)
                            line += " making and";
                        line += " using " + creatable_unknown_potions.listJoinComponents(", ", "or") + ".";
                        subentry.entries.listAppend(line);
                    }
                }
            }
        }
    }
    else if (my_class() == $class[seal clubber])
    {
        if ($item[hellseal disguise].available_amount() > 0)
        {
            subentry.entries.listAppend("Approach the dark cave.");
        }
        else if ($item[hellseal hide].available_amount() >= 6 && $item[hellseal sinew].available_amount() >= 6 && $item[hellseal brain].available_amount() >= 6)
        {
            subentry.entries.listAppend("Speak with Phineas.");
        }
        else
        {
            int seal_screeches = get_property_int("_sealScreeches");
            string screech_name = "screech";
            if (my_path_id() == PATH_KOLHS) //KOLHS support
                screech_name = "samuel powers";
            if ($item[seal tooth].available_amount() == 0)
            {
                subentry.entries.listAppend("Acquire a seal tooth from the hermit.");
            }
            else
                subentry.entries.listAppend("Use a seal tooth to damage the hellseal pups until they screech, once each.");
            if ($skill[lunging thrust-smack].have_skill())
            {
                subentry.entries.listAppend("Use lunging thrust-smack against the mother hell seals.");
            }
            else
            {
                subentry.entries.listAppend("Buy lunging thrust-smack from your guild.");
            }
            subentry.entries.listAppend(pluralizeWordy(seal_screeches, "seal " + screech_name, "seal " + screech_name + "es").capitalizeFirstLetter() + ".");
            
            
            int sinew_need = clampi(6 - $item[hellseal sinew].available_amount(), 0, 6);
            int brains_have = clampi(6 - $item[hellseal brain].available_amount(), 0, 6);
            int hides_have = clampi(6 - $item[hellseal hide].available_amount(), 0, 6);
            
            string [int] items_needed_list;
            foreach it in $items[hellseal sinew,hellseal brain,hellseal hide]
            {
                int remaining = clampi(6 - it.available_amount(), 0, 6);
                if (remaining == 0) continue;
                string name_short = it.to_string().replace_string("hellseal ", "");
                string name_short_plural = it.plural.to_string().replace_string("hellseal ", "");
                items_needed_list.listAppend(pluralizeWordy(remaining, "more " + name_short, "more " + name_short_plural));
            }
            if (items_needed_list.count() == 0)
            {
            }
            else
            {
                subentry.entries.listAppend("Need " + items_needed_list.listJoinComponents(", ", "and") + ".");
            }
            
            
            string [int] passive_uneffect_description = PDSGenerateDescriptionToUneffectPassives();
            if (passive_uneffect_description.count() > 0)
                subentry.entries.listAppend(HTMLGenerateSpanFont(passive_uneffect_description.listJoinComponents("|"), "red"));
                
            if (!$slot[weapon].equipped_item().weapon_is_club())
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Equip a club" + ($effect[Iron Palms].have_effect() > 0 ? " or sword" : "") + " first.", "red"));
            }
        }
    }
}


void QNemesisGenerateClownTasks(ChecklistSubentry subentry)
{
    item [class] legendary_epic_weapon_craftable_source;
    legendary_epic_weapon_craftable_source[$class[seal clubber]] = $item[distilled seal blood];
    legendary_epic_weapon_craftable_source[$class[turtle tamer]] = $item[turtle chain];
    legendary_epic_weapon_craftable_source[$class[pastamancer]] = $item[high-octane olive oil];
    legendary_epic_weapon_craftable_source[$class[sauceror]] = $item[peppercorns of power];
    legendary_epic_weapon_craftable_source[$class[disco bandit]] = $item[vial of mojo];
    legendary_epic_weapon_craftable_source[$class[accordion thief]] = $item[golden reeds];
    
    subentry.modifiers.listAppend("-combat");
    subentry.entries.listAppend("Search in the Fun House.");
    int clownosity = numeric_modifier("Clownosity").floor();
    int clownosity_needed = MAX(4 - clownosity, 0);
    
    if (clownosity_needed > 0)
    {
        string [int] available_clown_sources;
        string [int] missing_sources;
        
        item [slot] possible_outfit;
        foreach it in $items[clown wig,clown whip,clownskin buckler,clownskin belt,clownskin harness,polka-dot bow tie,balloon sword,balloon helmet,foolscap fool's cap,bloody clown pants,clown shoes,big red clown nose]
        {
            int clownosity = numeric_modifier(it, "clownosity").floor();
            string description = it + " (" + clownosity + ")";
            if (it.available_amount() > 0 && it.equipped_amount() == 0 && it.can_equip())
            {
                available_clown_sources.listAppend(description);
                if (possible_outfit[it.to_slot()].numeric_modifier("clownosity").floor() < clownosity)
                    possible_outfit[it.to_slot()] = it;
            }
            if (it.available_amount() == 0)
                missing_sources.listAppend(description);
        }
        
        item [int] suggested_outfit;
        int clownosity_possible = 0;
        foreach key in possible_outfit
        {
            clownosity_possible += possible_outfit[key].numeric_modifier("clownosity").floor();
            suggested_outfit.listAppend(possible_outfit[key]);
            if (clownosity_possible >= clownosity_needed)
                break;
        }
        //Remove extraneous pieces:
        foreach key in suggested_outfit
        {
            int clownosity = suggested_outfit[key].numeric_modifier("clownosity").floor();
            if (clownosity_possible - clownosity >= clownosity_needed)
            {
                clownosity_possible -= clownosity;
                remove suggested_outfit[key];
            }
            
        }
        string line = "Need " + clownosity_needed + " more clownosity.";
        
        if (available_clown_sources.count() > 0)
        {
            if (clownosity_possible >= clownosity_needed)
            {
                string line2 = "Equip " + suggested_outfit.listJoinComponents(", ", "and") + ".";
                if (__last_adventure_location == $location[The "Fun" House])
                    line2 = HTMLGenerateSpanFont(line2, "red");
                line += "|" + line2;
            }
            else
                line += "|Equip " + available_clown_sources.listJoinComponents(", ", "or") + ".";
        }
        if (missing_sources.count() > 0 && clownosity_possible < clownosity_needed)
        {
            if (!in_ronin())
                line += "|Could buy " + missing_sources.listJoinComponents(", ", "or") + ".";
            else
                line += "|Find sources in the Fun House.";
        }
        
        subentry.entries.listAppend(line);
        
    }
}

void QNemesisGenerateCaveTasks(ChecklistSubentry subentry, item legendary_epic_weapon)
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questG05Dark", true);
    
    subentry.entries.listAppend("Visit the sinister cave.");
    int paper_strips_found = 0;
    
    if (state.mafia_internal_step == 0)
        state.mafia_internal_step = 1;
    foreach it in $items[a torn paper strip,a rumpled paper strip,a creased paper strip,a folded paper strip,a crinkled paper strip,a crumpled paper strip,a ragged paper strip,a ripped paper strip]
    {
        if (it.available_amount() > 0)
            paper_strips_found += 1;
    }
    if (true)
    {
        //FIXME temporary code
        if (state.mafia_internal_step < 4 && paper_strips_found > 0)
            state.mafia_internal_step = 4;
        if (state.mafia_internal_step < 4 && $location[nemesis cave].turnsAttemptedInLocation() > 0)
            state.mafia_internal_step = 4;
    }
        
        
    if (state.mafia_internal_step == 1 || state.mafia_internal_step == 2 || state.mafia_internal_step == 3)
    {
        //1	Finally it's time to meet this Nemesis you've been hearing so much about! The guy at your guild has marked your map with the location of a cave in the Big Mountains, where your Nemesis is supposedly hiding.
        //2	Having opened the first door in your Nemesis' cave, you are now faced with a second one. Go figure
        //3	Having opened the second door in your Nemesis' cave, you are now
        //First door:
        string [int] door_unlockers;
        
        //First door:
        if (state.mafia_internal_step <= 1)
        {
            if (my_primestat() == $stat[muscle])
                door_unlockers.listAppend("viking helmet");
            else if (my_primestat() == $stat[mysticality])
                door_unlockers.listAppend("stalk of asparagus");
            else if (my_primestat() == $stat[moxie])
                door_unlockers.listAppend("dirty hobo gloves");
        }
        
        //Second door:
        if (state.mafia_internal_step <= 2)
        {
            if (my_primestat() == $stat[muscle])
                door_unlockers.listAppend("insanely spicy bean burrito");
            else if (my_primestat() == $stat[mysticality])
                door_unlockers.listAppend("insanely spicy enchanted bean burrito");
            else if (my_primestat() == $stat[moxie])
                door_unlockers.listAppend("insanely spicy jumping bean burrito");
        }
            
        //Third door:
        
        if (state.mafia_internal_step <= 3)
        {
            if (my_class() == $class[seal clubber])
                door_unlockers.listAppend("clown whip");
            else if (my_class() == $class[turtle tamer])
                door_unlockers.listAppend("clownskin buckler");
            else if (my_class() == $class[pastamancer])
                door_unlockers.listAppend("boring spaghetti");
            else if (my_class() == $class[sauceror])
                door_unlockers.listAppend("tomato juice of powerful power");
            else if (my_class() == $class[disco bandit])
            {
                //suggest:
                
                string suggested_drink = "pink pony";
                int suggested_drink_amount = 0;
                
                foreach it in $items[a little sump'm sump'm,bungle in the jungle,calle de miel,ducha de oro,fuzzbump,horizontal tango,ocean motion,perpendicular hula,pink pony,rockin' wagon,roll in the hay,slap and tickle,slip 'n' slide] //NOT tropical swill
                {
                    if (it.available_amount() > suggested_drink_amount)
                    {
                        suggested_drink_amount = it.available_amount();
                        suggested_drink = it;
                    }
                    if (suggested_drink_amount == 0 && it.creatable_amount() > 0)
                    {
                        suggested_drink = it + " (make first)";
                    }
                }
                door_unlockers.listAppend(suggested_drink);
            }
            else if (my_class() == $class[accordion thief])
                door_unlockers.listAppend("polka of plenty buffed on you");
        }
        
        foreach key, v in door_unlockers
        {
            item it = v.to_item();
            if (it == $item[none]) continue;
            if (it.to_string().to_lower_case() != v.to_lower_case())
                continue;
            if (it.item_amount() == 0)
                door_unlockers[key] = HTMLGenerateSpanFont(door_unlockers[key], "grey");
        }
        
        subentry.entries.listAppend("Open doors via " + door_unlockers.listJoinComponents(", then ") + ".");
    }
    else if (state.mafia_internal_step == 4 || state.mafia_internal_step == 5)
    {
        //4	Woo! You're past the doors and it's time to stab some bastards
        //5	The door to your Nemesis' inner sanctum didn't seem to care for the password you tried earlier
        
        if (paper_strips_found >= 8)
        {
            string line = "Speak the password, then fight your nemesis.";
            if (!mafiaIsPastRevision(14330))
                line += "|Then wait for assassins.";
            subentry.entries.listAppend(line);
            if (legendary_epic_weapon.equipped_amount() == 0)
                subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
        }
        else
        {
            subentry.modifiers.listAppend("+234% item");
            subentry.entries.listAppend("Run +234% item in the large chamber.");
            int strips_needed = MAX(8 - paper_strips_found, 0);
            float average_turns = clampNormalf(0.3 * (1.0 + $location[nemesis cave].item_drop_modifier_for_location() / 100.0));
            if (average_turns != 0.0)
                average_turns = strips_needed / average_turns;
            else
                average_turns = -1.0;
            subentry.entries.listAppend("Find " + pluralizeWordy(strips_needed, "paper strip", "paper strips") + ". ~" + average_turns.roundForOutput(1) + " turns left.");
        }
    }
    else if (state.mafia_internal_step == 6)
    {
        //6	Hear how the background music got all exciting? It's because you opened the door to your Nemesis' inner sanctum
        subentry.entries.listAppend("Fight your nemesis.");
        if (legendary_epic_weapon.equipped_amount() == 0)
            subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
    }
}

void QNemesisGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{

    
    /*
    mafia ordering:
    1 -> acquire disco banjo
    2 -> defeat the clown prince
    3 -> make shagadelic disco banjo, talk to your guild
    4 -> wait for guild to find out where your nemesis is hiding
    5 -> time to visit the dark and dank and sinister cave
    6 -> defeated nemesis in cave, let's go talk to the guild
    7 -> they aren't impressed, wait for assassins
    8 -> first assassin appeared
    9 -> first assassin defeated
    10 -> second assassin appeared
    11 -> second assassin defeated
    12 -> third assassin appeared
    13 -> third assassin defeated
    14 -> final assassin appeared
    15 -> final assassin defeated, go find the lair
    16 -> we're at the island, do island stuff
    17 -> "got away. Again."
    18 -> lava maze solved
    19 -> final form [cue music]

    (same ordering we use)
    */
    
    
	QuestState base_quest_state = __quest_state["Nemesis"];
	if (base_quest_state.finished)
		return;
    if (!($classes[seal clubber,turtle tamer,pastamancer,sauceror,disco bandit,accordion thief] contains my_class()))
        return;
    if (!__misc_state["guild open"])
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    string url = "";
    
    //volcanoMaze1 through volcanoMaze5 is relevant, blank when not available
    
    boolean have_legendary_epic_weapon = false;
    boolean have_epic_weapon = false;
    
    item [class] class_epic_weapons;
    item [class] class_legendary_epic_weapons;
    item [class] class_ultimate_legendary_epic_weapons;
    
    class_epic_weapons[$class[seal clubber]] = $item[bjorn's hammer];
    class_epic_weapons[$class[turtle tamer]] = $item[mace of the tortoise];
    class_epic_weapons[$class[pastamancer]] = lookupItem("pasta spoon of peril");
    class_epic_weapons[$class[sauceror]] = $item[5-alarm saucepan];
    class_epic_weapons[$class[disco bandit]] = $item[disco banjo];
    class_epic_weapons[$class[accordion thief]] = $item[rock and roll legend];
    item epic_weapon = class_epic_weapons[my_class()];
    
    
    class_legendary_epic_weapons[$class[seal clubber]] = $item[hammer of smiting];
    class_legendary_epic_weapons[$class[turtle tamer]] = $item[chelonian morningstar];
    class_legendary_epic_weapons[$class[pastamancer]] = lookupItem("greek pasta spoon of peril");
    class_legendary_epic_weapons[$class[sauceror]] = $item[17-alarm saucepan];
    class_legendary_epic_weapons[$class[disco bandit]] = $item[shagadelic disco banjo];
    class_legendary_epic_weapons[$class[accordion thief]] = $item[squeezebox of the ages];
    item legendary_epic_weapon = class_legendary_epic_weapons[my_class()];
    
    
    
    class_ultimate_legendary_epic_weapons[$class[seal clubber]] = $item[Sledgehammer of the V&aelig;lkyr];
    class_ultimate_legendary_epic_weapons[$class[turtle tamer]] = $item[Flail of the Seven Aspects];
    class_ultimate_legendary_epic_weapons[$class[pastamancer]] = $item[Wrath of the Capsaician Pastalords];
    class_ultimate_legendary_epic_weapons[$class[sauceror]] = $item[Windsor Pan of the Source];
    class_ultimate_legendary_epic_weapons[$class[disco bandit]] = $item[Seeger's Unstoppable Banjo];
    class_ultimate_legendary_epic_weapons[$class[accordion thief]] = $item[The Trickster's Trikitixa];
    item ultimate_legendary_epic_weapon = class_ultimate_legendary_epic_weapons[my_class()];
    
    if (epic_weapon.available_amount_ignoring_storage() > 0)
        have_epic_weapon = true;
    if (legendary_epic_weapon.available_amount_ignoring_storage() > 0)
        have_legendary_epic_weapon = true;
        
	if (!__misc_state["In aftercore"] && !have_legendary_epic_weapon && $location[the "fun" house].turns_spent == 0)
		return;
        
        
    string [class] first_boss_name;
    first_boss_name[$class[Seal Clubber]] = "Gorgolok, the Infernal Seal";
    first_boss_name[$class[Turtle Tamer]] = "Stella, the Turtle Poacher";
    first_boss_name[$class[Pastamancer]] = "Spaghetti Elemental";
    first_boss_name[$class[Sauceror]] = "Lumpy, the Sinister Sauceblob";
    first_boss_name[$class[Disco Bandit]] = "The Spirit of New Wave";
    first_boss_name[$class[Accordion Thief]] = "Somerset Lopez, Dread Mariachi";
    
    if (!base_quest_state.started)
    {
        subentry.entries.listAppend("Speak to your guild to start the quest.|Then adventure in the Unquiet Garves until you unlock the tomb of the unknown, and solve the puzzle.");
        url = "guild.php";
    }
    else if (base_quest_state.mafia_internal_step <= 4)
    {
        //1	One of your guild leaders has tasked you to recover a mysterious and unnamed artifact stolen by your Nemesis. Your first step is to smith an Epic Weapon
        
        //1 can be when Tomb of the Unknown Your Class Here is unlocked (think there's a missing quest step here?)
        //2 can be fighting ghost
        //4 can be nearing end
        //5 -> return it
        //6 -> returning
        if (have_epic_weapon)
        {
            subentry.entries.listAppend("Speak to your guild.");
            url = "guild.php";
        }
        else
        {
            subentry.entries.listAppend("Acquire " + epic_weapon + ".");
            subentry.entries.listAppend("Adventure in the Unquiet Garves until you unlock the tomb of the unknown, then solve the three puzzles.");
            url = "place.php?whichplace=cemetery";
        }
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        subentry.entries.listAppend("Speak to your guild.");
        url = "guild.php";
    }
    else if (base_quest_state.mafia_internal_step <= 2 + 4)
    {
        //2	To unlock the full power of the Legendary Epic Weapon, you must defeat Beelzebozo, the Clown Prince of Darkness,
        QNemesisGenerateClownTasks(subentry);
        url = "place.php?whichplace=plains";
    }
    else if (base_quest_state.mafia_internal_step == 3 + 4 || base_quest_state.mafia_internal_step == 4 + 4)
    {
        //3	You've finally killed the clownlord Beelzebozo
        //4	You've successfully defeated Beelzebozo and claimed the last piece of the Legendary Epic Weapon
        if (have_legendary_epic_weapon)
        {
            subentry.entries.listAppend("Speak to your guild.");
            url = "guild.php";
        }
        else
        {
            subentry.entries.listAppend("Make " + legendary_epic_weapon + ".");
        }
    }
    else if (base_quest_state.mafia_internal_step == 5 + 4)
    {
        //5	discovered where your Nemesis is hiding. It took long enough, jeez! Anyway, turns out it's a Dark and
        url = "cave.php";
        QNemesisGenerateCaveTasks(subentry,legendary_epic_weapon);
    }
    else if (base_quest_state.mafia_internal_step >= 6 + 4 && base_quest_state.mafia_internal_step < 15 + 4)
    {
        //6	You have successfully shown your Nemesis what for, and claimed an ancient hat of power. It's pretty sweet
        //7	You showed the Epic Hat to the class leader back at your guild, but they didn't seem much impressed. I guess all this Nemesis nonsense isn't quite finished yet, but at least with your Nemesis in hiding again you won't have to worry about it for a while.
        //8	It appears as though some nefarious ne'er-do-well has put a contract on your head
        //9	You handily dispatched some thugs who were trying to collect on your bounty, but something tells you they won't be the last ones to try
        
        //10	Whoever put this hit out on you (like you haven't guessed already) has sent Mob Penguins to do their dirty work. Do you know any polar bears you could hire as bodyguards
        //11	So much for those mob penguins that were after your head! If whoever put this hit out on you wants you killed (which, presumably, they do) they'll have to find some much more competent thugs
        //12	have been confirmed: your Nemesis has put the order out for you to be hunted down and killed, and now they're sending their own guys instead of contracting out
        //13	Bam! So much for your Nemesis' assassins! If that's the best they've got, you have nothing at all to worry about
        //14	You had a run-in with some crazy mercenary or assassin or... thing that your Nemesis sent to do you in once and for all. A run-in followed by a run-out, evidently,
        string assassin_up_next = "";
        int assassins_left = -1;
        
        if (mafiaIsPastRevision(14330))
        {
            if (base_quest_state.mafia_internal_step < 9 + 4)
            {
                assassin_up_next = "menacing thug";
                assassins_left = 4;
            }
            else if (base_quest_state.mafia_internal_step < 11 + 4)
            {
                assassin_up_next = "Mob Penguin hitman";
                assassins_left = 3;
            }
            else if (base_quest_state.mafia_internal_step < 13 + 4)
            {
                if (my_class() == $class[seal clubber])
                    assassin_up_next = "hunting seal";
                else if (my_class() == $class[turtle tamer])
                    assassin_up_next = "turtle trapper";
                else if (my_class() == $class[pastamancer])
                    assassin_up_next = "evil spaghetti cult assassin";
                else if (my_class() == $class[sauceror])
                    assassin_up_next = "béarnaise zombie";
                else if (my_class() == $class[disco bandit])
                    assassin_up_next = "flock of seagulls";
                else if (my_class() == $class[accordion thief])
                    assassin_up_next = "mariachi bandolero";
                
                assassins_left = 2;
            }
            else
            {
                if (my_class() == $class[seal clubber])
                    assassin_up_next = "Argarggagarg the Dire Hellseal";
                else if (my_class() == $class[turtle tamer])
                    assassin_up_next = "Safari Jack, Small-Game Hunter";
                else if (my_class() == $class[pastamancer])
                    assassin_up_next = "Yakisoba the Executioner";
                else if (my_class() == $class[sauceror])
                    assassin_up_next = "Heimandatz, Nacho Golem";
                else if (my_class() == $class[disco bandit])
                    assassin_up_next = "Jocko Homo";
                else if (my_class() == $class[accordion thief])
                    assassin_up_next = "The Mariachi With No Name";
                assassins_left = 1;
            }
        }
        
        if (assassins_left != -1)
        {
            string line = "Wait for " + pluralizeWordy(assassins_left, "more assassin", "more assassins");
            
            //int min_turns_left = 0;
            //int max_turns_left = 0;
            float average_turns_left = 0;
            
            int effective_assassins_left = assassins_left;
            //35 to 50
            Counter nemesis_assassin_window = CounterLookup("Nemesis Assassin");
            if (nemesis_assassin_window.CounterExists() && nemesis_assassin_window.CounterIsRange())
            {
                //min_turns_left += nemesis_assassin_window.range_start_turn;
                //max_turns_left += nemesis_assassin_window.range_end_turn;
                average_turns_left += (nemesis_assassin_window.range_start_turn + nemesis_assassin_window.range_end_turn).to_float() / 2.0;
                effective_assassins_left -= 1;
            }
            
            
            effective_assassins_left = clampi(effective_assassins_left, 0, 4);
            //min_turns_left += 35 * effective_assassins_left;
            //max_turns_left += 50 * effective_assassins_left;
            average_turns_left += 42.5 * effective_assassins_left.to_float();
            
            //I wonder if showing max_turns_left would be less confusing here...
            line += " over ~" + average_turns_left.roundForOutput(0) + " turns.";
            subentry.entries.listAppend(line);
        }
        else
            subentry.entries.listAppend("Wait for assassins.");
            
            
        if (assassin_up_next.length() > 0)
            subentry.entries.listAppend(assassin_up_next.capitalizeFirstLetter() + " up next.");
            
        if (my_basestat(my_primestat()) < 90)
            subentry.entries.listAppend("Level to 90 " + my_primestat().to_lower_case() + ".");
        
        if (my_class() == $class[pastamancer] && my_thrall() != $thrall[spaghetti elemental] && $skill[bind spaghetti elemental].have_skill() && $thrall[spaghetti elemental].level < 3)
        {
            subentry.entries.listAppend("Cast Bind Spaghetti Elemental to level up your spaghetti elemental to three in advance.");
        }
        
    }
    else if (base_quest_state.mafia_internal_step == 15 && false)
    {
        //15	Now that you've dealt with your Nemesis' assassins and found a map to the secret tropical island volcano lair, it's time to take the fight to your foe. Booyah
        //find island
        url = "inventory.php?which=3";
        subentry.entries.listAppend("Use the secret tropical island volcano lair map.");
    }
    else if (base_quest_state.mafia_internal_step == 16 + 4 || base_quest_state.mafia_internal_step == 15 + 4) //mafia bug - doesn't advance properly
    {
        //16	You've arrived at the secret tropical island volcano lair, and it's time to finally put a stop to this Nemesis nonsense once and for all. As soon as you can find where they're hiding. Maybe you can find someone to ask
        if ($location[The Nemesis' Lair].turnsAttemptedInLocation() > 0)
        {
            if (my_class() == $class[disco bandit])
                subentry.entries.listAppend("Fight daft punk, then your nemesis face to face.|Then solve the volcano maze.");
            else
                subentry.entries.listAppend("Fight goons, then your nemesis.|Then solve the volcano maze.");
        }
        else
            QNemesisGenerateIslandTasks(subentry);
        url = "volcanoisland.php";
    }
    else if (base_quest_state.mafia_internal_step >= 17 + 4 && base_quest_state.mafia_internal_step <= 19 + 4)
    {
        //17	Congratulations on solving the lava maze, which is probably the biggest pain-in-the-ass puzzle in the entire game! Hooray! (Unless you cheated, in which case
        if (base_quest_state.mafia_internal_step == 17 + 4)
            subentry.entries.listAppend("Solve the volcano maze, then fight your nemesis.");
        else
            subentry.entries.listAppend("Fight your nemesis.");
        url = "volcanomaze.php";
        if (legendary_epic_weapon.equipped_amount() == 0 && ultimate_legendary_epic_weapon.equipped_amount() == 0)
            subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
        if (my_class() == $class[sauceror])
        {
            string [int] missing_saucespheres;
            foreach s in $skills[elemental saucesphere,Jalape&ntilde;o Saucesphere,antibiotic saucesphere,scarysauce]
            {
                effect e = s.to_effect();
                if (e.have_effect() > 0)
                    continue;
                string line = s.to_string();
                
                if (!s.skill_is_usable())
                    line = HTMLGenerateSpanFont(line, "grey");
                
                missing_saucespheres.listAppend(line);
            }
            if (missing_saucespheres.count() > 0)
            {
                subentry.entries.listAppend("Acquire saucespheres: " + missing_saucespheres.listJoinComponents(", ", "and") + ".");
            }
        }
        if (my_class() == $class[pastamancer])
        {
            subentry.entries.listAppend("Run a potato familiar, and alternate casting entangling noodles twice/some sort of attack to keep the demon blocked.");
        }
    }
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the "fun" house, nemesis cave, the nemesis' lair, the broodling grounds, the outer compound, the temple portico, convention hall lobby, outside the club, the island barracks, the poop deck]));
}