RegisterResourceGenerationFunction("PathAvatarOfWestOfLoathingGenerateResource");
void PathAvatarOfWestOfLoathingGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_WEST_OF_LOATHING)
		return;
    
    //Oils:
    
    string image_name = "";
    ChecklistSubentry [int] subentries;
    float [int] subentries_sort_value;
    
    string [item] tonic_descriptions;
    tonic_descriptions[lookupItem("Eldritch oil")] = "craftable";
    tonic_descriptions[lookupItem("Unusual oil")] = "+50% item (20 turns), craftable";
    tonic_descriptions[lookupItem("Skin oil")] = "+100% moxie (20 turns), craftable";
    tonic_descriptions[lookupItem("Snake oil")] = "+venom/medicine, craftable";
    
    tonic_descriptions[lookupItem("patent alacrity tonic")] = "+100% init (20 turns)"; //eldritch + unusual
    tonic_descriptions[lookupItem("patent sallowness tonic")] = "+30 ML (50 turns)"; //eldritch + skin
    tonic_descriptions[lookupItem("patent avarice tonic")] = "+50% meat (30 turns)"; //skin + unusual
    tonic_descriptions[lookupItem("patent invisibility tonic")] = "-15% combat (30 turns)"; //eldritch + snake
    tonic_descriptions[lookupItem("patent aggression tonic")] = "+15% combat (30 turns)"; //unusual + snake
    tonic_descriptions[lookupItem("patent preventative tonic")] = "+3 all res (30 turns)"; //skin + snake
    
    foreach it in tonic_descriptions
    {
        if (it.available_amount() == 0 && it.creatable_amount() == 0)
            continue;
        
        string description = tonic_descriptions[it];
        if (image_name == "")
            image_name = "__item " + it;
        string name;
        if (it.available_amount() > 0)
            name = pluralise(it);
        if (it.creatable_amount() > 0)
        {
            if (it.available_amount() != 0)
                name += " (" + it.creatable_amount() + " craftable)";
            else
                name = pluralise(it.creatable_amount(), "craftable " + it, "craftable " + it.plural);
        }
        if (it.available_amount() == 0)
        {
            subentries_sort_value[subentries.count()] = 1.0;
            name = HTMLGenerateSpanFont(name, "grey");
            description = HTMLGenerateSpanFont(description, "grey");
        }
        else
        {
            subentries_sort_value[subentries.count()] = 0.0;
        }
        subentries.listAppend(ChecklistSubentryMake(name, "", description));
    }
    sort subentries by subentries_sort_value[index];
    if (subentries.count() > 0)
        resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 8));
}


RegisterTaskGenerationFunction("PathAvatarOfWestOfLoathingGenerateTasks");
void PathAvatarOfWestOfLoathingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    
}