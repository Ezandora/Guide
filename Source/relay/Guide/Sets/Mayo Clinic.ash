void SMayoClinicGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!mafiaIsPastRevision(15790)) //minimum supported version
        return;
    if (__misc_state["campground unavailable"])
        return;
    if (get_campground()[lookupItem("portable Mayo Clinic")] == 0)
        return;
    
    //mayoLevel
    
    if (availableFullness() > 0)
    {
        //stuff:
        //Mayonex - food adventures -> blood mayo (???)
        //Mayodiol -> one fullness becomes one drunkenness
        //Mayostat -> one-fullness same quality restore
        //Mayozapine -> increased stat gains
        //Mayoflex -> +1 adventure
        //Mayo Minder™ -> um... I guess it uses the above things for you. reminds me of buying the autorefueler in EV..
    }
    
    if (!get_property_boolean("_mayoDeviceRented"))
    {
        //sphygmayomanometer - +X% stats (mayo level)
        //tomayohawk-style reflex hammer - stagger, mayo-level sleaze damage
        //mayo lance - YR combat item
        //miracle whip - nice day two/three equip. +50% init, +50% item, +100% meat, +100% wait, I only get one of these a run?
        
        if (!get_property_boolean("mayoWhipRented"))
        {
        }
    }
    if (!get_property_boolean("_mayoTankSoaked") && __misc_state["in run"])
    {
        string [int] description;
        string [int] benefits;
        if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
            benefits.listAppend("HP restore");
        benefits.listAppend("+2 all resistance");
        description.listAppend("Gives " + benefits.listJoinComponents(", ", "and") + ".");
        resource_entries.listAppend(ChecklistEntryMake("__item bubblin' chemistry solution", "campground.php?action=workshed", ChecklistSubentryMake("Mayo Tank Soak", "", description), 8));
    }
}