
RegisterResourceGenerationFunction("PathDarkGiftGenerateResource");
void PathDarkGiftGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_path_id() != PATH_VAMPIRE)
        return;

    int banishes_left = clampi(10 - get_property_int("_balefulHowlUses"), 0, 10);
    if (banishes_left > 0 && lookupSkill("Baleful Howl").skill_is_usable())
    {
        string url;
        string [int] description;
        description.listAppend("Free run/banish.");
        description.listAppend("There's a lot of them, so you might just want to use them as a free run?");
        Banish banish_entry = BanishByName("Baleful Howl");
        int turns_left_of_banish = banish_entry.BanishTurnsLeft();
        if (turns_left_of_banish > 0)
        {
            //is this relevant? we don't describe this for pantsgiving
            description.listAppend("Currently used on " + banish_entry.banished_monster + " for " + pluralise(turns_left_of_banish, "more turn", "more turns") + ".");
        }
        resource_entries.listAppend(ChecklistEntryMake("__skill Baleful Howl", url, ChecklistSubentryMake(pluralise(banishes_left, "baleful howl", "baleful howls"), "", description), 0).ChecklistEntryTagEntry("banish"));
    }
