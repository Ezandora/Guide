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
        if (campground[lookupItem("source terminal")] > 0)
            __iotms_usable[lookupItem("source terminal")] = true;
        if (campground[lookupItem("haunted doghouse")] > 0)
            __iotms_usable[lookupItem("haunted doghouse")] = true;
        if (campground[lookupItem("Witchess Set")] > 0)
            __iotms_usable[lookupItem("Witchess Set")] = true;
    }
    if (get_property_boolean("hasDetectiveSchool"))
            __iotms_usable[lookupItem("detective school application")] = true;
}

initialiseIOTMsUsable();