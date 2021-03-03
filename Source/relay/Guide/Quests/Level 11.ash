import "relay/Guide/Quests/Level 11 - Copperhead.ash";
import "relay/Guide/Quests/Level 11 - Pyramid.ash";
import "relay/Guide/Quests/Level 11 - Desert.ash";
import "relay/Guide/Quests/Level 11 - Palindome.ash";
import "relay/Guide/Quests/Level 11 - Manor.ash";
import "relay/Guide/Quests/Level 11 - Hidden City.ash";
import "relay/Guide/Quests/Level 11 - Hidden Temple.ash";

void QLevel11Init()
{
	//questL11MacGuffin, questL11Manor, questL11Palindome, questL11Pyramid, questL11Worship
	//hiddenApartmentProgress, hiddenBowlingAlleyProgress, hiddenHospitalProgress, hiddenOfficeProgress, hiddenTavernUnlock
	//relocatePygmyJanitor, relocatePygmyLawyer
	
	
	/*
	gnasirProgress is a bitmap of things you've done with Gnasir to advance desert exploration:

	stone rose = 1
	black paint = 2
	killing jar = 4
	worm-riding manual pages (15) = 8
	successful wormride = 16
	*/
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11MacGuffin");
    	if (my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_GREY_GOO) QuestStateParseMafiaQuestPropertyValue(state, "finished");
		state.quest_name = "MacGuffin Quest";
		state.image_name = "MacGuffin";
		state.council_quest = true;
        
		if (my_level() >= 11 || my_path_id() == PATH_EXPLOSIONS)
			state.startable = true;
        
		__quest_state["Level 11"] = state;
		__quest_state["MacGuffin"] = state;
	}

    QLevel11CopperheadInit();
    QLevel11PyramidInit();
    QLevel11DesertInit();
    QLevel11PalindomeInit();
    QLevel11ManorInit();
    QLevel11HiddenCityInit();
    QLevel11HiddenTempleInit();
}

void QLevel11BaseGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11"].in_progress)
        return;

    QuestState base_quest_state = __quest_state["Level 11"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    string image_name = base_quest_state.image_name;
    boolean make_entry_future = false;
    
    if (base_quest_state.mafia_internal_step < 2)
    {
        subentry.header = "Unlock the Black Market";
        image_name = "Black Forest";
        //This needs better spading.
        //Side info: in the livestream, the flag [blackforestexplore] => 55 was visible, as well as [blackforestprogress] => 5
        
        //Unlock black market:
        url = "place.php?whichplace=woods";
        
        string combat_rate_string = "+5% combat";
        
        subentry.modifiers.listAppend(combat_rate_string);
        subentry.entries.listAppend("Adventure in the Black Forest with " + combat_rate_string + ".");
        
        if ($item[blackberry galoshes].available_amount() > 0)
        {
            if ($item[blackberry galoshes].equipped_amount() == 0)
            {
                string line = HTMLGenerateSpanFont("Equip blackberry galoshes", "red") + " to speed up exploration";
                
                if (!$item[blackberry galoshes].can_equip())
                {
                    make_entry_future = true;
                    line += ", once you can equip them";
                }
                line += ".";
                subentry.entries.listAppend(line);
            }
        }
        else
        {
            if (!in_hardcore())
                subentry.entries.listAppend("Possibly pull and wear the blackberry galoshes?");
            //it seems unlikely finding the galoshes in HC would be worth it? maaaybe in no-familiar paths, but probably not? sneaky pete, perhaps
            //subentry.entries.listAppend("Possibly make the blackberry galoshes via NC, if you get three blackberries.");
        }
        
        boolean [familiar] relevant_familiars = $familiars[reassembled blackbird,reconstituted crow];
        familiar bird_needed_familiar;
        item bird_needed;
        if (my_path_id() == PATH_BEES_HATE_YOU)
        {
            bird_needed_familiar = $familiar[reconstituted crow];
            bird_needed = $item[reconstituted crow];
        }
        else
        {
            bird_needed_familiar = $familiar[reassembled blackbird];
            bird_needed = $item[reassembled blackbird];
        }
        item [int] missing_components = missingComponentsToMakeItem(bird_needed);
        
        //FIXME clean this up:
        //FIXME test if having a reassembled blackbird in your inventory is more than enough in any path?
        //FIXME handle both reassembled blackbird and reconstituted crow as familiar
        
        if (missing_components.count() > 0 && bird_needed.available_amount() == 0)
        {
            subentry.modifiers.listAppend("+100% item"); //FIXME what is the drop rate for bees hate you items? we don't know...
        }
        
        if (bird_needed_familiar.familiar_is_usable())
        {
            if (bird_needed.available_amount() == 0 && missing_components.count() == 0)
            {
                subentry.entries.listAppend("Make a " + bird_needed + ".");
            }
            else if (!(relevant_familiars contains my_familiar()) && bird_needed.available_amount() == 0)
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Bring along " + bird_needed_familiar + " to speed up quest.", "red"));
            }
            else if ((relevant_familiars contains my_familiar()) && bird_needed.available_amount() > 0)
            {
                subentry.entries.listAppend("Bring along another familiar, you don't need to use the bird anymore.");
            }
        }
        if (bird_needed.available_amount() == 0)
        {
            string line = "";
            line = "Acquire " + bird_needed + ".";
        
            if (missing_components.count() == 0)
                line += " You have all the parts, make it.";
            else
                line += " Parts needed: " + missing_components.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
        }
        int black_forest_progress = get_property_int("blackForestProgress");
        if (black_forest_progress >= 1 && __quest_state["Level 13"].state_boolean["wall of skin will need to be defeated"] && $item[beehive].available_amount() == 0)
        {
            subentry.entries.listAppend("Find a beehive for the tower, from the non-combat.|*" + listMake("Head toward the blackberry patch", "Head toward the buzzing sound", "Keep going", "Almost... there...").listJoinComponents(__html_right_arrow_character) + "|*Costs two extra turns. Skip if you're towerkilling.");
        }
        //if (black_forest_progress > 0)
        subentry.entries.listAppend("~" + (black_forest_progress * 20) + "% finished.");
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        //Vacation:
        if ($item[forged identification documents].available_amount() == 0)
        {
            subentry.header = "Buy forged identification documents";
            image_name = "__item forged identification documents";
            url = "shop.php?whichshop=blackmarket";
            subentry.entries.listAppend("From the black market.");
            if ($item[can of black paint].available_amount() == 0)
                subentry.entries.listAppend("Also buy a can of black paint while you're there, for the desert quest.");
        }
        else
        {
            if (CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(0,2))
            {
                image_name = "__item fortune cookie";
                subentry.header = HTMLGenerateSpanFont("Avoid vacationing at the shore", "red");
                subentry.entries.listAppend("Will override semi-rare.");
                //subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid vacationing; will override semi-rare.", "red"));
            }
            else
            {
                url = "place.php?whichplace=desertbeach";
                subentry.header = "Vacation at the shore";
                image_name = "__item your father's MacGuffin diary";
                string diary_owner = "your father's";
                if (my_path_id() == PATH_GELATINOUS_NOOB)
                    diary_owner = "an archeologist's";
                subentry.entries.listAppend("To acquire " + diary_owner + " diary.");
            }
        }
    }
    else if (base_quest_state.mafia_internal_step < 4)
    {
        //Have diary:
        if (to_item("2334").available_amount() == 0) //$item[holy macguffin] has shadow aliasing problem
        {
            //nothing to say
            //subentry.entries.listAppend("Retrieve the MacGuffin.");
            return;
        }
        else
        {
            url = "place.php?whichplace=town";
            subentry.entries.listAppend("Speak to the council.");
        }
    }
    if (make_entry_future)
        future_task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the black forest]));
    else
        task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the black forest]));
}

void QLevel11GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() == PATH_COMMUNITY_SERVICE)
        return;
    QLevel11RonGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11ShenGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (!__misc_state["in run"])
        return;
    //Such a complicated quest.
    QLevel11BaseGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11ManorGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PalindomeGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11DesertGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PyramidGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenCityGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenTempleGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}
