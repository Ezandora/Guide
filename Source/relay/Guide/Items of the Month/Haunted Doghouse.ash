RegisterResourceGenerationFunction("IOTMHauntedDoghouseGenerateResource");
void IOTMHauntedDoghouseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["in run"])
        return;
    if ($item[tennis ball].available_amount() > 0 && in_ronin() && $item[tennis ball].item_is_usable())
    {
        resource_entries.listAppend(ChecklistEntryMake("__item tennis ball", "", ChecklistSubentryMake(pluralise($item[tennis ball]), "", "Free run/banish."), 6).ChecklistEntryTagEntry("banish"));
    }
    //I, um, hmm. I guess there's not much to say. Poor lonely file, nearly empty.
}



