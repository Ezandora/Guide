void SJarlsbergGenerateStaff(ChecklistEntry entry, item staff, string property_name, string description, boolean always_output)
{
    if (staff.available_amount() == 0)
        return;
    
    
    int uses_remaining = MAX(0, 5 - get_property_int(property_name));
    if (uses_remaining > 0 || always_output)
    {
        string title;
        title = staff;
        if (uses_remaining != 0)
        {
            title = uses_remaining + " " + staff.to_string().replace_string("Staff of the ", "");
            if (uses_remaining == 1)
                title += " use";
            else
                title += " uses";
        }
            //description = pluralizeWordy(uses_remaining, "use remains", "uses remain").capitalizeFirstLetter() + ".|" + description;
        entry.subentries.listAppend(ChecklistSubentryMake(title, "", description));
        if (entry.image_lookup_name == "")
            entry.image_lookup_name = "__item " + staff;
    }
}


void SJarlsbergGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path() != "Avatar of Jarlsberg")
		return;
    
	ChecklistEntry entry;
	entry.target_location = "";
	entry.image_lookup_name = "";
    
    
    //wizard staff:
    //Show uses:
    //_jiggleCheesedMonsters split by |
    
    SJarlsbergGenerateStaff(entry, $item[Staff of the All-Steak], "_jiggleSteak", "+300% items.", false);
    
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
        SJarlsbergGenerateStaff(entry, $item[Staff of the Cream of the Cream], "_jiggleCream", cream_line, always_output);
    }
    if (true)
    {
        //I must capture the avatar (of jarlsberg) to regain my honor
        string [int] banished_monsters = split_string_mutable(get_property("_jiggleCheesedMonsters"), "|");
        boolean always_output = false;
        string cheese_line = "Banish monsters.";
        if (get_property("_jiggleCheesedMonsters").length() > 0)
        {
            cheese_line += "|Monsters banished: " + banished_monsters.listJoinComponents(", ", "and").HTMLEscapeString() + ".";
            always_output = true;
        }
        
        SJarlsbergGenerateStaff(entry, $item[Staff of the Standalone Cheese], "_jiggleCheese", cheese_line, always_output);
    }
    SJarlsbergGenerateStaff(entry, $item[Staff of the Staff of Life], "_jiggleLife", "Restores all HP.", false);
    
    if (entry.subentries.count() > 0)
        available_resources_entries.listAppend(entry);
}