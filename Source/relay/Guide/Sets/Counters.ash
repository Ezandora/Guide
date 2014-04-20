import "relay/Guide/Support/Counter.ash"

void SCountersInit()
{
    CountersInit();
}

void SCountersGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
    string [string] window_image_names;
    window_image_names["Nemesis Assassin"] = "__familiar Penguin Goodfella"; //technically not always a penguin, but..
    window_image_names["Bee"] = "__effect Float Like a Butterfly, Smell Like a Bee"; //bzzz!
    window_image_names["Holiday Monster"] = "__familiar hand turkey";
    //window_image_names["Event Monster"] = ""; //no idea
    
    boolean [string] counter_blacklist = $strings[Romantic Monster,Semi-rare];
    
    string [int] all_counter_names = CounterGetAllNames();
    
    foreach key in all_counter_names
    {
        string window_name = all_counter_names[key];
        if (window_name == "")
            continue;
        if (counter_blacklist contains window_name)
            continue;
        
        Counter c = CounterLookup(window_name);
        if (!c.CounterIsRange())
            continue;
        
        Vec2i turn_range = c.CounterGetWindowRange();
        
        if (!(turn_range.x <= 10 && from_task) && !(turn_range.x > 10 && !from_task))
            continue;
        
        
        
        boolean very_important = false;
        if (turn_range.x <= 0)
            very_important = true;
        
        
        
        ChecklistSubentry subentry;
        subentry.header = window_name;
        
        
        if (turn_range.y <= 0)
            subentry.header += " now or soon";
        else if (turn_range.x <= 0)
            subentry.header += " between now and " + turn_range.y + " turns.";
        else
            subentry.header += " in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        string image_name = "__item Pok&euml;mann figurine: Frank"; //default - some person
        if (window_image_names contains window_name)
            image_name = window_image_names[window_name];
        
        int importance = 10;
        if (very_important)
            importance = -11;
        ChecklistEntry entry = ChecklistEntryMake(image_name, "", subentry, importance);
        
        if (very_important)
            task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
        
    }
}

void SCountersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (true)
    {
        //dance card:
        int turns_until_dance_card = CounterLookup("Dance Card").CounterGetNextExactTurn();
        
        if (turns_until_dance_card >= 0)
        {
            string stats = "Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstats.";
            if (turns_until_dance_card == 0)
            {
                task_entries.listAppend(ChecklistEntryMake("__item dance card", $location[the haunted ballroom].getClickableURLForLocation(), ChecklistSubentryMake("Dance card up now.", "", "Adventure in haunted ballroom. " + stats), -11));
            }
            else
            {
                optional_task_entries.listAppend(ChecklistEntryMake("__item dance card", "", ChecklistSubentryMake("Dance card up after " + pluralize(turns_until_dance_card, "adventure", "adventures") + ".", "", "Haunted ballroom. " + stats)));
            }
        }
    }
    
	SCountersGenerateEntry(task_entries, optional_task_entries, true);
}

void SCountersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SCountersGenerateEntry(available_resources_entries, available_resources_entries, false);
}