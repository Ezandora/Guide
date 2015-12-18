RegisterResourceGenerationFunction("IOTMHauntedDoghouseGenerateResource");
void IOTMHauntedDoghouseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["in run"])
        return;
    if (lookupItem("tennis ball").available_amount() > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item tennis ball", "", ChecklistSubentryMake(pluralise(lookupItem("tennis ball")), "", "Free run/banish."), 6));
    }
    //I, um, hmm. I guess there's not much to say. Poor lonely file, nearly empty.
}