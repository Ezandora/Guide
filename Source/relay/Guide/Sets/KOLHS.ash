
void SKOLHSGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_KOLHS)
		return;
    
    
    ChecklistSubentry subentry;
    subentry.header = "Kingdom of Loathing High School";
    
    int adventures_used = get_property_int("_kolhsAdventures");
    int adventures_remaining = 40 - adventures_used;
    int bell_ring_ring_ring = get_property_int("_kolhsSavedByTheBell");
    int ring_ring_ring_ring_left = 3 - bell_ring_ring_ring;
    
    if (adventures_remaining > 0)
    {
        if ($effect[jamming with the jocks].have_effect() == 0 && $effect[greaser lightnin'].have_effect() == 0 && $effect[Nerd is the Word].have_effect() == 0)
            subentry.entries.listAppend("Acquire intrinsic in halls - use moxie, muscle, or mysticality combat skill.");
        subentry.entries.listAppend(adventures_remaining + " adventures left in school.");
    }
    else if (ring_ring_ring_ring_left > 0)
        subentry.entries.listAppend(pluralise(ring_ring_ring_ring_left, "bell ring", "bell rings") + " left.");
    
    
    if (subentry.entries.count() > 0)
        task_entries.listAppend(ChecklistEntryMake("high school", "", subentry, $locations[the hallowed halls, shop class, chemistry class, art class]));
    
    
    foreach it in $items[can of the cheapest beer,bottle of fruity &quot;wine&quot;,single swig of vodka]
    {
        if (it.available_amount() > 0 && my_inebriety() < 8) //is this eight or nine or
        {
            task_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake("Drink " + it, "", "Next one won't show up until you do."), -11));
            break;
        }
    }
}
