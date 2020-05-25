RegisterResourceGenerationFunction("IOTMPocketProfessorResource");
void IOTMPocketProfessorResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getLecture() {
        int lecturesAtWeight(int weight, boolean chipEquipped) {
            return floor(sqrt(weight - 1)) + 1 + (chipEquipped ? 2 : 0);
        }

        // Title
        int lecturesUsed = get_property_int("_pocketProfessorLectures");
        int potentialWeight = familiar_weight($familiar[Pocket Professor]) + weight_adjustment();
        int potentialWeightChip = potentialWeight - round(equipped_item($slot[familiar]).numeric_modifier('familiar weight'));
        boolean chipEquipped = lookupItem("pocket professor memory chip").have_equipped();

        int availableLectures = lecturesAtWeight(potentialWeight, chipEquipped) - lecturesUsed;
        int nextLectureWeight = lecturesUsed ** 2 + 1;
        int nextLectureWeightChip = (lecturesUsed - 2) ** 2 + 1;

        string main_title = (availableLectures > 0 ? pluralise(availableLectures, "lecture", "lectures") : "No lectures") + " available";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (availableLectures > 0) {
            description.listAppend(HTMLGenerateSpanOfClass("Relativity:", "r_bold") + " Fight monster again.");
            description.listAppend(HTMLGenerateSpanOfClass("Mass:", "r_bold") + " 3 chances for item drops.");
            description.listAppend(HTMLGenerateSpanOfClass("Velocity:", "r_bold") + " Delevel and substats.");
        } else {
            string noChipMessage = nextLectureWeight + " lbs (+" + (nextLectureWeight - potentialWeight) + " lbs)";
            string chipMessage = nextLectureWeightChip + " lbs (+" + (nextLectureWeightChip - potentialWeightChip) + " lbs)";
            if (!chipEquipped) {
                if (nextLectureWeightChip <= potentialWeightChip) {
                    description.listAppend("Next lecture at " + noChipMessage + ", or now with chip.");
                } else {
                    description.listAppend("Next lecture at " + noChipMessage + ", " + chipMessage + " with chip.");
                }
            } else {
                description.listAppend("Next lecture at " + chipMessage + ".");
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    string scalerMessage(string name, int add, int cap) {
        int thesisAdventures(int hp) {
            return clampi(2 * floor(hp ** .25), 0, 11);
        }

        int ml = numeric_modifier('monster level');
        int muscle = my_buffedstat($stat[muscle]);
        int defense = clampi(muscle + add, 0, cap) + ml;
        int hp = floor(0.75 * defense);
        int adventures = thesisAdventures(hp);
        string description = name + " (" + adventures + " advs";
        if (adventures < 11 && cap + ml >= 1296 / .75) {
            int nextAdventures = adventures + 2;
            int nextThreshhold = (nextAdventures / 2) ** 4;
            int muscleToCap = ceil(nextThreshhold / .75 - ml - add);
            description += ", +" + (muscleToCap - muscle) + " mus for " + clampi(nextAdventures, 0, 11) + " advs";
        }
        description += ")";
        return description;
    }

    ChecklistSubentry getDeliverYourThesis() {
        int experience = $familiar[Pocket Professor].experience;
        int experienceLeft = 400 - experience;

        // Title
        string main_title = "Deliver thesis";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (!get_property_boolean("_thesisDelivered")) {
            if (experience >= 400) {
                description.listAppend(HTMLGenerateSpanOfClass("1 instakill", "r_bold") + " but lose 200 familiar xp.");
            } else {
                description.listAppend("Need " + experienceLeft + " more experience.");
            }

            string [int] potential_targets;
            if (lookupItem("kramco sausage-o-matic").available_amount() > 0)
            {
                potential_targets.listAppend(scalerMessage("Sausage goblin", 11, 10000));
            }
            if (get_property_boolean("neverendingPartyAlways") || get_property_boolean("_neverendingPartyToday"))
            {
                potential_targets.listAppend(scalerMessage("Neverending Party monster", 0, 20000));
            }
            if (potential_targets.count() > 0) {
                description.listAppend("Could use it on a:" + HTMLGenerateIndentedText(potential_targets));
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    if (!lookupFamiliar("Pocket Professor").familiar_is_usable()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__familiar pocket professor";

    ChecklistSubentry lectures = getLecture();
    if (lectures.entries.count() > 0) {
        entry.subentries.listAppend(lectures);
    }

    ChecklistSubentry thesis = getDeliverYourThesis();
    if (thesis.entries.count() > 0) {
        entry.subentries.listAppend(thesis);
    }

    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}
