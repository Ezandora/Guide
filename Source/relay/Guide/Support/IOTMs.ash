boolean [item] __iotms_usable;

void initialiseIOTMsUsable()
{
    foreach key in __iotms_usable
        remove __iotms_usable[key];
    if (in_bad_moon())
        return;
    
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        int [item] campground = get_campground();
        //Campground items:
        if (campground[$item[source terminal]] > 0)
            __iotms_usable[$item[source terminal]] = true;
        if (campground[$item[haunted doghouse]] > 0)
            __iotms_usable[$item[haunted doghouse]] = true;
        if (campground[$item[Witchess Set]] > 0)
            __iotms_usable[$item[Witchess Set]] = true;
        if (campground[$item[potted tea tree]] > 0)
            __iotms_usable[$item[potted tea tree]] = true;
    }
    if (get_property_boolean("hasDetectiveSchool"))
        __iotms_usable[$item[detective school application]] = true;
    if (get_property_boolean("chateauAvailable"))
        __iotms_usable[$item[Chateau Mantegna room key]] = true;
    if (get_property_boolean("barrelShrineUnlocked"))
        __iotms_usable[$item[shrine to the Barrel god]] = true;
    if (get_property_boolean("snojoAvailable"))
        __iotms_usable[$item[X-32-F snowman crate]] = true;
    if (get_property_boolean("telegraphOfficeAvailable"))
        __iotms_usable[$item[LT&T telegraph office deed]] = true;
    if (get_property_boolean("loveTunnelAvailable"))
        __iotms_usable[lookupItem("heart-shaped crate")] = true;
    if (get_property_boolean("spacegateAlways") || get_property_boolean("_spacegateToday"))
        __iotms_usable[lookupItem("Spacegate access badge")] = true;
    //Remove non-standard:
    foreach it in __iotms_usable
    {
        if (!it.is_unrestricted())
            remove __iotms_usable[it];
    }
}

initialiseIOTMsUsable();