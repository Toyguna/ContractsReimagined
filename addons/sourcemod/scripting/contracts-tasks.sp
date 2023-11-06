#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required

// ============== [ GLOBAL VARIABLES ] ============== //

StringMap g_smTasks;
StringMap g_smContracts;

char CFG_TASKS[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/ContractsReimagined/tasks.cfg";
char CFG_CONTRACTS[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/ContractsReimagined/contracts.cfg";

// ============== [ FUNCTIONS ] ============== //

public void FileTasks_Initialize()
{
    g_smTasks = new StringMap();
    g_smContracts = new StringMap();
}

public void ReadTasks()
{
    g_smTasks.Clear();

    KeyValues kv = new KeyValues("Tasks");

    kv.ImportFromFile(CFG_TASKS);

    char id[MAX_TASK_ID];

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(id, sizeof(id));

        Contracts_Task task;
        task.id = id;
        task.index = -1;

        ReadTaskKey(kv, task)

        g_smTasks.SetArray(id, task, sizeof(task), true);
    } while(kv.GotoNextKey(false))

    delete kv;
}

void ReadTaskKey(KeyValues kv, Contracts_Task task)
{
    char section[255];

    char name[MAX_TASK_NAME];
    char str_type[MAX_TASK_STRTYPE];
    char str_detail_as[MAX_TASK_STRDETAIL];
    char str_detail_target[MAX_TASK_STRDETAIL];

    Contracts_TaskType type;
    Contracts_TaskDetail detail_as;
    Contracts_TaskDetail detail_target;

    kv.GetString("display_name", name, sizeof(name));
    kv.GetString("type", str_type, sizeof(str_type));

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(section, sizeof(section));

        if (StrEqual(section, "details"))
        {
            kv.GetString("target", str_detail_as, sizeof(str_detail_as));
            kv.GetString("as", str_detail_target, sizeof(str_detail_target));

            break;
        }
    } while(kv.GotoNextKey(false))

    type = Contracts_TaskTypeFromString(str_type, sizeof(str_type));
    detail_as = Contracts_TaskDetailFromString(str_detail_as, sizeof(str_detail_as));
    detail_target = Contracts_TaskDetailFromString(str_detail_target, sizeof(str_detail_target));

    task.name = name;
    task.type = type;
    task.detail_as = detail_as;
    task.detail_target = detail_target;
    task.progress = 0;
    task.goal = -1;

    kv.GoBack();
}

public void ReadContracts()
{
    g_smContracts.Clear();

    KeyValues kv = new KeyValues("Contracts");

    kv.ImportFromFile(CFG_CONTRACTS);

    char id[MAX_CONTRACT_ID];

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(id, sizeof(id));

        Contracts_Contract contract;
        contract.Init();

        contract.id = id;

        ReadContractKey(kv, contract);

        g_smContracts.SetArray(id, contract, sizeof(contract), true);
    } while(kv.GotoNextKey(false))

    delete kv;

}

void ReadContractKey(KeyValues kv, Contracts_Contract contract)
{
    char id[MAX_TASK_ID];

    char name[MAX_CONTRACT_NAME];

    kv.GetString("display_name", name, sizeof(name));
    
    kv.GotoFirstSubKey(false);
    kv.GotoNextKey(false);
    kv.GotoFirstSubKey(false); // go

    contract.name = name;

    Contracts_Task task;
    int index = 0;

    do {
        kv.GetSectionName(id, sizeof(id));

        int goal = kv.GetNum(NULL_STRING, -1);

        Contracts_CreateTaskFromId(id, task, sizeof(task));
        task.goal = goal;
        task.index = index;

        contract.AddTask(task);
        index++;

    } while(kv.GotoNextKey(false))

    kv.GoBack();
    kv.GoBack();
}

/**
 * @param client        Client index
 * @param amount        Amount to progress
 * @param task_index    Task's index in contract
 */
public void ProgressTask(int client, int amount, int task_index)
{
    Contracts_Contract contract;
    Contracts_GetClientContract(client, contract, sizeof(contract));

    Contracts_Task task;
    contract.tasks.GetArray(task_index, task, sizeof(task));

    task.progress += amount;
    if (task.IsCompleted()){ 
        task.progress = task.goal;
        TryCompleteClientContract(client);
    }
    contract.tasks.SetArray(task.index, task, sizeof(task));
}

public void CompleteClientContract(int client)
{
    Contracts_Contract contract;
    Contracts_GetClientContract(client, contract, sizeof(contract));

    char username[MAX_NAME_LENGTH];
    GetClientName(client, username, sizeof(username));

    if (true) // announce
    {
        PrintToChatAll("%s %T", CHAT_PREFIX, "Contract_CompletedAnnounce", LANG_SERVER, username, contract.name);
    }
    else
    {
        PrintToChat(client, "%s %T", CHAT_PREFIX, "Contract_Completed", LANG_SERVER, contract.name);
    }

    Contracts_RemoveClientContract(client);
}

public void TryCompleteClientContract(int client)
{
    if (!CheckContractCompletion(client)) return;

    CompleteClientContract(client);
}

public bool CheckContractCompletion(int client)
{
    Contracts_Contract contract;
    Contracts_GetClientContract(client, contract, sizeof(contract));
    
    Contracts_Task task;

    int counter = 0;

    for (int i = 0; i < contract.tasks.Length; i++)
    {
        contract.tasks.GetArray(i, task, sizeof(task));

        if (task.IsCompleted()) counter++;
    }

    return counter >= contract.tasks.Length;
}


// ============== [ UTILITY ] ============== //

/*
 * @return true on success, false otherwise
 */
public bool GetTaskTemplate(const char[] id, any[] buffer, int size)
{
    return g_smTasks.GetArray(id, buffer, size);
}

/*
 * @return true on success, false otherwise
 */
public bool GetContractTemplate(const char[] id, Contracts_Contract buffer)
{
    bool success = g_smContracts.GetArray(id, buffer, sizeof(buffer));
    if (!success) return false;

    buffer.tasks = buffer.tasks.Clone();

    return true;
}