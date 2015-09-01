
void SKOLHSGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_KOLHS)
		return;
    
    item [string][int] items_wanted_in_classes;
    effect [string] relevant_intrinsic;
    items_wanted_in_classes["Art Class"] = listMakeBlankItem();
    relevant_intrinsic["Art Class"] = $effect[greaser lightnin'];
    items_wanted_in_classes["Art Class"].listAppend($item[quasireligious sculpture]);
    items_wanted_in_classes["Art Class"].listAppend($item[Sticky clay homunculus]);
    items_wanted_in_classes["Art Class"].listAppend($item[Modeling claymore]);
    items_wanted_in_classes["Art Class"].listAppend($item[Giant eraser]);
    
    items_wanted_in_classes["Shop Class"] = listMakeBlankItem();
    relevant_intrinsic["Shop Class"] = $effect[Jamming with the Jocks];
    items_wanted_in_classes["Shop Class"].listAppend($item[miniature suspension bridge]);
    items_wanted_in_classes["Shop Class"].listAppend($item[world's most dangerous birdhouse]);
    
    string [item] class_item_description;
    class_item_description[$item[giant eraser]] = "free runaway";
        
    ChecklistSubentry subentry;
    subentry.header = "Kingdom of Loathing High School";
    
    int adventures_used = get_property_int("_kolhsAdventures");
    int adventures_remaining = 40 - adventures_used;
    int bell_ring_ring_ring = get_property_int("_kolhsSavedByTheBell");
    int ring_ring_ring_ring_left = 3 - bell_ring_ring_ring;
    int priority = 0;
    if (adventures_remaining > 0)
    {
        priority = -11;
        if ($effect[jamming with the jocks].have_effect() == 0 && $effect[greaser lightnin'].have_effect() == 0 && $effect[Nerd is the Word].have_effect() == 0)
            subentry.entries.listAppend("Acquire intrinsic in halls - use a moxie, muscle, or mysticality combat skill.");
        if ($effect[jamming with the jocks].have_effect() > 0)
            subentry.entries.listAppend("Adventure in shop class.");
        if ($effect[greaser lightnin'].have_effect() > 0)
            subentry.entries.listAppend("Adventure in art class.");
        if ($effect[Nerd is the Word].have_effect() > 0)
            subentry.entries.listAppend("Adventure in chemistry class.");
        subentry.entries.listAppend(pluralise(adventures_remaining, "adventure", "adventures") + " left in school.");
    }
    else if (ring_ring_ring_ring_left > 0)
    {
        subentry.entries.listAppend(pluralise(ring_ring_ring_ring_left, "bell ring", "bell rings") + " left.");
        if ($item[Yearbook Club Camera].available_amount() == 0)
            subentry.entries.listAppend("Could acquire a yearbook camera. (Yearbook Club)");
        else if (get_property_boolean("yearbookCameraPending") && my_daycount() > 1)
            subentry.entries.listAppend("Could turn yesterday's photograph... if you took it yesterday...");
        
        subentry.entries.listAppend("Choir club for a +100% meat, +50% item buff.|It's important to sing every day!");
        
        if (__misc_state["need to level"])
        {
            if (my_primestat() == $stat[muscle])
            {
                subentry.entries.listAppend("Gym - 50 turns of +2 mainstat/fight.");
            }
            else if (my_primestat() == $stat[mysticality])
            {
                subentry.entries.listAppend("Undead Poets Society - 50 turns of +2 mainstat/fight.");
            }
            else if (my_primestat() == $stat[moxie])
            {
                subentry.entries.listAppend("Bleachers - 50 turns of +2 mainstat/fight.");
            }
        }
        
        string class_can_make_things_in;
        boolean [item] potential_items_creatable;
        string [item] creatable_item_descriptions;
        if ($effect[jamming with the jocks].have_effect() > 0)
        {
            class_can_make_things_in = "Shop Class";
        }
        if ($effect[greaser lightnin'].have_effect() > 0)
        {
            class_can_make_things_in = "Art Class";
        }
        if ($effect[Nerd is the Word].have_effect() > 0)
        {
            class_can_make_things_in = "Chemistry Class";
        }
        if (class_can_make_things_in != "")
        {
            string [int] sorts_of_things;
            foreach key, it in items_wanted_in_classes[class_can_make_things_in]
            {
                if (it.creatable_amount() > 0)
                {
                    string line = pluralise(it.creatable_amount(), it);
                    if (class_item_description contains it)
                        line += " - " + class_item_description[it] + ".";
                    sorts_of_things.listAppend(line);
                }
            }
            string line = class_can_make_things_in + " - make all sorts of things";
            if (sorts_of_things.count() > 0)
                line += ":|*" + sorts_of_things.listJoinComponents("|*");
            else
                line += ".";
            subentry.entries.listAppend(line);
        }
    }
    
    if (adventures_remaining <= 0)
    {
        if ($item[Yearbook Club Camera].available_amount() > 0 && !get_property_boolean("yearbookCameraPending") && get_property("yearbookCameraTarget") != "")
        {
            string line = "Could take a picture of a " + get_property_monster("yearbookCameraTarget") + ".";
            if ($item[Yearbook Club Camera].equipped_amount() == 0)
                line += "|Equip the yearbook club camera first.";
            subentry.entries.listAppend(line);
        }
    }
    
    if (subentry.entries.count() > 0)
        task_entries.listAppend(ChecklistEntryMake("high school", "place.php?whichplace=KOLHS", listMake(subentry), priority, $locations[the hallowed halls, shop class, chemistry class, art class]));
    
    
    foreach it in $items[can of the cheapest beer,bottle of fruity &quot;wine&quot;,single swig of vodka]
    {
        if (it.available_amount() > 0 && my_inebriety() < 8) //is this eight or nine or
        {
            task_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake("Drink " + it, "", "Next one won't show up until you do."), -11));
            break;
        }
    }
}
