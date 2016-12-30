RegisterResourceGenerationFunction("IOTMGingerbreadCityGenerateResource");
void IOTMGingerbreadCityGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupSkill("Ceci N'Est Pas Un Chapeau").have_skill() && !get_property_boolean("_ceciHatUsed") && my_basestat($stat[moxie]) >= 150 && __misc_state["in run"])
    {
        //Umm... I guess?
        //It doesn't seem amazing in aftercore, so we're not displaying it? Is that the right decision?
        //Almost all of its enchantments are better on other hats. And you can't choose which one you get, so it'd just be annoying the user.
        resource_entries.listAppend(ChecklistEntryMake("__skill Ceci N'Est Pas Un Chapeau", "skillz.php", ChecklistSubentryMake("Ceci N'Est Pas Un Chapeau", "", "Random enchantment hat, 300MP."), 10));
    }
}