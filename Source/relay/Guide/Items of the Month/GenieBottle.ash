RegisterResourceGenerationFunction("IOTMGenieBottleGenerateResource");
void IOTMGenieBottleGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[genie bottle].item_amount() + $item[pocket wish].item_amount() == 0) return;
    
    int wishes_left = 0;
    if (__misc_state["in run"] && in_ronin())
        wishes_left += $item[pocket wish].item_amount();
    if ($item[genie bottle].item_amount() > 0 && my_path_id() != PATH_BEES_HATE_YOU)
        wishes_left += clampi(3 - get_property_int("_genieWishesUsed"), 0, 3);
    string [int] description;
    
    if (wishes_left > 0)
    {
        string url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9529";
        if ($item[genie bottle].item_amount() == 0 || get_property_int("_genieWishesUsed") >= 3)
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9537";
        
        string potential_monsters = SFaxGeneratePotentialFaxes(true, $monsters[ninja snowman assassin,modern zmobie,giant swarm of ghuol whelps, screambat]).listJoinComponents("|<hr>");
        if (potential_monsters != "")
	        description.listAppend("Could fight a monster:<br>" + potential_monsters);
        resource_entries.listAppend(ChecklistEntryMake("__item genie bottle", url, ChecklistSubentryMake(pluralise(wishes_left, "wish", "wishes"), "", description), 1));
    }
}
