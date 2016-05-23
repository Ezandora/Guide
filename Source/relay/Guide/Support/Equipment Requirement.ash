import "relay/Guide/Support/Library.ash";

Record EquipmentStatRequirement
{
    stat requirement_stat;
    int requirement_amount;
};
static
{
    EquipmentStatRequirement [item] __equipment_stat_requirements;
}

void initialiseEquipmentRequirements()
{
    if (__equipment_stat_requirements.count() > 0)
        return;
    Record equipment_txt_entry
    {
        int power;
        string requirement;
        string weapon_description;
    };
    equipment_txt_entry [item] entries;
    file_to_map("data/equipment.txt", entries);
    
    foreach it, entry in entries
    {
        if (entry.requirement == "" || entry.requirement == "none")
            continue;
        int requirement_integer = entry.requirement.split_string(" ")[1].to_int_silent();
        if (requirement_integer <= 0)
            continue;
        stat known_stat = $stat[none];
        if (entry.requirement.contains_text("Mus: "))
        {
            known_stat = $stat[muscle];
        }
        else if (entry.requirement.contains_text("Mys: "))
        {
            known_stat = $stat[mysticality];
        }
        else if (entry.requirement.contains_text("Mox: "))
        {
            known_stat = $stat[moxie];
        }
        if (known_stat != $stat[none])
        {
            EquipmentStatRequirement requirement;
            requirement.requirement_stat = known_stat;
            requirement.requirement_amount = requirement_integer;
            
            __equipment_stat_requirements[it] = requirement;
            //__equipment_stat_requirements[it][known_stat] = requirement_integer;
        }
    }
}
EquipmentStatRequirement StatRequirementForEquipment(item it)
{
    initialiseEquipmentRequirements();
    return __equipment_stat_requirements[it];
}