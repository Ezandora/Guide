
void SAftercoreGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    
    if (!__misc_state["In aftercore"])
        return;
    //Campground items:
    int [item] campground_items = get_campground();
    
    if (campground_items[$item[clockwork maid]] == 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item sprocket", "", ChecklistSubentryMake("Install a clockwork maid", "", listMake("+8 adventures/day.", "Buy from mall."))));
    }
    if (campground_items[$item[pagoda plans]] == 0)
    {
        string url;
        string [int] details;
        details.listAppend("+3 adventures/day.");
        
        if ($item[hey deze nuts].available_amount() == 0)
        {
            if ($item[hey deze map].available_amount() == 0)
            {
                url = "pandamonium.php";
                details.listAppend("Adventure in Pandamonium Slums for Hey Deze Map. (25% superlikely)");
            }
            else
            {
                string [int] things_to_do;
                string [int] things_to_buy;
                if ($item[heavy metal sonata].available_amount() == 0)
                    things_to_buy.listAppend("heavy metal sonata");
                if ($item[heavy metal thunderrr guitarrr].available_amount() == 0)
                    things_to_buy.listAppend("heavy metal thunderrr guitarrr");
                if ($item[guitar pick].available_amount() == 0)
                    things_to_buy.listAppend("guitar pick");
                if (things_to_buy.count() > 0)
                    things_to_do.listAppend("buy " + things_to_buy.listJoinComponents(", ", "and") + " in mall, ");
                things_to_do.listAppend("use hey deze map");
				details.listAppend(things_to_do.listJoinComponents("", "then").capitalizeFirstLetter() + ".");
            }
        }
        if ($item[pagoda plans].available_amount() == 0)
        {
            if ($item[Elf Farm Raffle ticket].available_amount() == 0)
            {
                details.listAppend("Buy a Elf Farm Raffle ticket from the mall.");
            }
            else
            {
                if (in_bad_moon()) //Does bad moon aftercore require a clover?
                {
                    details.listAppend("Use Elf Farm Raffle ticket.");
                }
                else
                {
                    details.listAppend("Acquire ten-leaf clover, then use Elf Farm Raffle ticket.");
                }
            }
        }
        if ($item[ketchup hound].available_amount() == 0)
            details.listAppend("Buy a ketchup hound from the mall.");
        if ($item[ketchup hound].available_amount() > 0 && $item[hey deze nuts].available_amount() > 0 && $item[pagoda plans].available_amount() > 0)
            details.listAppend("Use a ketchup hound to install pagoda.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item pagoda plans", url, ChecklistSubentryMake("Install a pagoda", "", details)));
    }
    
    
    if (knoll_available() && !have_mushroom_plot() && get_property("plantingScript") != "")
    {
        //They can plant a mushroom plot, and they have a planting script. But they haven't yet, so let's suggest it:
        optional_task_entries.listAppend(ChecklistEntryMake("__item knob mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Plant a mushroom plot", "", "Degrassi Knoll")));
    }
}