RegisterResourceGenerationFunction("IOTMPocketProfessorResource");
void IOTMPocketProfessorResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getLecture() {
        int [int] WEIGHT_REQUIREMENTS = { 1, 2, 5, 10, 17, 26, 37, 50, 65, 82, 101, 122, 145, 170, 197 };

        int calculateMaxLectures() {
            int currentWeight = familiar_weight($familiar[Pocket Professor]) + numeric_modifier("familiar weight");

            foreach index, weightRequirement in WEIGHT_REQUIREMENTS {
                if (currentWeight < weightRequirement) {
                    return index;
                }
            }

            return 0;
        }

        // Title
        int lecturesUsed = get_property_int("_pocketProfessorLectures");
        int numOfLectures = calculateMaxLectures() - lecturesUsed;

        string main_title = numOfLectures + " lectures";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (numOfLectures > 0) {
            description.listAppend(HTMLGenerateSpanOfClass("Relativity:", "r_bold") + " Instant copy");
            description.listAppend(HTMLGenerateSpanOfClass("Mass:", "r_bold") + " 3 chances for item drops");
            description.listAppend(HTMLGenerateSpanOfClass("Velocity:", "r_bold") + " Delevel");
        } else {
            description.listAppend("Next lecture at " + WEIGHT_REQUIREMENTS[lecturesUsed] + " pounds");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    ChecklistSubentry getDeliverYourThesis() {
        // Title
        string main_title = "Deliver thesis";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (!get_property_boolean("_thesisDelivered")) {
            description.listAppend(HTMLGenerateSpanOfClass("1 instakill", "r_bold") + " but lose 200 familiar xp");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupFamiliar("Pocket Professor").familiar_is_usable()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__familiar pocket professor";
    entry.url = "main.php?eowkeeper=1";

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
