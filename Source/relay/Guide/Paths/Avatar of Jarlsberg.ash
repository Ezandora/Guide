boolean PathJarlsbergGenerateStaff(ChecklistEntry entry, item staff, string property_name, string description, boolean always_output)
{
    if (staff.available_amount() == 0)
        return false;
    
    
    int uses_remaining = MAX(0, 5 - get_property_int(property_name));
    if (uses_remaining > 0 || always_output)
    {
        string title;
        title = staff;
        if (uses_remaining != 0)
        {
            title = uses_remaining + " " + staff.to_string().replace_string("Staff of the ", "");
            if (staff == $item[Staff of the Standalone Cheese])
            {
                if (uses_remaining == 1)
                    title += " staff banish";
                else
                    title += " staff banishes";
            }
            else
            {
                if (uses_remaining == 1)
                    title += " use";
                else
                    title += " uses";
            }
        }
            //description = pluraliseWordy(uses_remaining, "use remains", "uses remain").capitaliseFirstLetter() + ".|" + description;
        entry.subentries.listAppend(ChecklistSubentryMake(title, "", description));
        if (entry.image_lookup_name == "")
            entry.image_lookup_name = "__item " + staff;
        return true;
    }
    return false;
}


RegisterResourceGenerationFunction("PathJarlsbergGenerateResource");
void PathJarlsbergGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (myPathId() != PATH_AVATAR_OF_JARLSBERG)
		return;
    
	ChecklistEntry entry;
	entry.url = "";
	entry.image_lookup_name = "";
    
    
    //wizard staff:
    //Show uses:
    //_jiggleCheesedMonsters split by |
    
    PathJarlsbergGenerateStaff(entry, $item[Staff of the All-Steak], "_jiggleSteak", "+300% items.", false);
    
    if (true)
    {
        string olfacted_monster = get_property("_jiggleCreamedMonster");
        boolean always_output = false;
        string cream_line = "Monster olfaction";
        if (olfacted_monster != "")
        {
            always_output = true;
            cream_line += "|Following a " + olfacted_monster.HTMLEscapeString() + ".";
        }
        PathJarlsbergGenerateStaff(entry, $item[Staff of the Cream of the Cream], "_jiggleCream", cream_line, always_output);
    }
    if (true)
    {
        //I must capture the avatar (of jarlsberg) to regain my honor
        string [int] banished_monsters = split_string_alternate(get_property("_jiggleCheesedMonsters"), "\\|");
        boolean always_output = false;
        string cheese_line = "";
        if (get_property("_jiggleCheesedMonsters") != "")
        {
            cheese_line += "Monsters banished: " + banished_monsters.listJoinComponents(", ", "and").HTMLEscapeString() + ".";
            always_output = true;
        }
        
    	ChecklistEntry entry2;
        boolean should_add = PathJarlsbergGenerateStaff(entry2, $item[Staff of the Standalone Cheese], "_jiggleCheese", cheese_line, always_output);
        entry2.ChecklistEntryTagEntry("banish");
        if (should_add)
	        resource_entries.listAppend(entry2);
    }
    PathJarlsbergGenerateStaff(entry, $item[Staff of the Staff of Life], "_jiggleLife", "Restores all HP.", false);
    
    if (entry.subentries.count() > 0)
        resource_entries.listAppend(entry);
}
