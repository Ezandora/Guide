
RegisterResourceGenerationFunction("PathExplosionsGenerateResource");
void PathExplosionsGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (myPathId() != PATH_EXPLOSIONS)
        return;
    item isotopes = lookupItem("rare Meat isotope");
    if (isotopes.have())
    {
    	string [int] description;
        int isotope_amount = isotopes.available_amount();
        if (isotope_amount >= 5)
        {
        	description.listAppend("<strong>Space chowder</strong> - for eating or hippy-fighting war.");
            description.listAppend("<strong>Space wine</strong> - for drinking or frat-fighting war.");
        }
        if (isotope_amount >= 10 && !$item[antique accordion].have() && my_class() != $class[accordion thief])
            description.listAppend("<strong>antique accordion</strong> - casting AT buffs.");
        if (isotope_amount >= 20 && availableSpleen() > $item[lucky pill].available_amount())
            description.listAppend("<strong>lucky pill</strong> - extra clovers, super useful.");
        if (isotope_amount >= 25 && !lookupItem("signal jammer").have())
            description.listAppend("<strong>signal jammer</strong> - deals with those troublesome wandering skeletons. Equipped this in non-delay-burning areas.");
        if (isotope_amount >= 25 && !lookupItem("space shield").have() && ($item[digital key].have() || $item[white pixel].available_amount() >= 30))
            description.listAppend("<strong>space shield</strong> - wear this everywhere that is adventure.php, prevents invader bullets");
            
        
        //if (isotope_amount >= 10 && !lookupItem("low-pressure oxygen tank").have())
            //description.listAppend("<strong>low-pressure oxygen tank</strong> - prevents HP damage at end of fight, but you probably want to ignore this.");
            
        resource_entries.listAppend(ChecklistEntryMake("__item rare Meat isotope", "shop.php?whichshop=exploathing", ChecklistSubentryMake(pluralise(isotopes), "", description), 5));
    }
}
