import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/LocationAvailable.ash"
import "relay/Guide/Quests/Quest import.ash"


void QuestsInit()
{
	QPirateInit();
	QLevel2Init();
	QLevel3Init();
	QLevel4Init();
	QLevel5Init();
	QLevel6Init();
	QLevel7Init();
	QLevel8Init();
	QLevel9Init();
	QLevel10Init();
	QLevel11Init();
	QLevel12Init();
	QLevel13Init();
	QNemesisInit();
	QSeaInit();
	QSpaceElvesInit();
	QAzazelInit();
	QUntinkerInit();
	QArtistInit();
	QLegendaryBeatInit();
	QMemoriesInit();
	QWhiteCitadelInit();
	QWizardOfEgoInit();
    QFeloniaInit();
    QGuildInit();
    
    //has to happen after level 13 init... or not?
	QManorInit();
}


void QuestsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QLevel2GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel3GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel4GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel5GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel6GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel7GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel8GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel9GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel10GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel11GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel12GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel13GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	QManorGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QPirateGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QNemesisGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QSeaGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QSpaceElvesGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QAzazelGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QGuildGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    
	QUntinkerGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QArtistGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLegendaryBeatGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QMemoriesGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QWhiteCitadelGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QWizardOfEgoGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QSpookyravenLightsOutGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QFeloniaGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    
    QAirportGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}

void QuestsGenerateResources(ChecklistEntry [int] available_resources_entries)
{
    QSpookyravenLightsOutGenerateResource(available_resources_entries);
}