

void SDispensaryGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	//Not sure how I feel about this. The dispensary is very useful, but not necessary to complete an ascension.
	if (dispensary_available())
		return;
	if (!__misc_state["can equip just about any weapon"]) //need to wear KGE to learn the password
		return;
	
	if (!__quest_state["Level 5"].started || !$location[cobb's knob barracks].locationAvailable())
		return;
    if (__quest_state["Level 5"].finished && !have_outfit_components("Knob Goblin Elite Guard Uniform")) //level 5 quest completed, but they don't have KGE - I think we'll close the suggestion here, as they probably don't want to go back? maybe? it'll still show up in semi-rare if they care to
        return;
	
	ChecklistSubentry subentry;
	subentry.header = "Unlock Cobb's Knob Dispensary";
	
	string [int] dispensary_advantages;
	if (!black_market_available() && !__misc_state["MMJs buyable"])
		dispensary_advantages.listAppend("MP Restorative");
	dispensary_advantages.listAppend("+30% meat");
	dispensary_advantages.listAppend("+15% items");
	if (my_path_id() != PATH_BEES_HATE_YOU && !__misc_state["familiars temporarily blocked"])
		dispensary_advantages.listAppend("+5 familiar weight");
	dispensary_advantages.listAppend("+1 mainstat/fight");
	
	if (dispensary_advantages.count() > 0)
		subentry.entries.listAppend("Access to " + dispensary_advantages.listJoinComponents(", ", "and") + " buff items");
		
	if ($item[Cobb's Knob lab key].available_amount() == 0)
		subentry.entries.listAppend("Find the cobb's knob lab key either laying around, or defeat the goblin king.");
	else
	{
		if (have_outfit_components("Knob Goblin Elite Guard Uniform"))
		{
			if (!is_wearing_outfit("Knob Goblin Elite Guard Uniform"))
				subentry.entries.listAppend("Wear KGE outfit, adventure in Cobb's Knob Barracks.");
			else
				subentry.entries.listAppend("Adventure in Cobb's Knob Barracks.");
		}
		else
			subentry.entries.listAppend("Acquire KGE outfit");
	}
	optional_task_entries.listAppend(ChecklistEntryMake("Dispensary", "cobbsknob.php", subentry, 10));
}