#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required


// ============== [ NATIVES ] ============== //

/*
 * Check if client has an active contract.
 *
 * @param client Client index
 * @return true if client has an active contract, false otherwise
 */
any Native_ClientHasContract(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    return ClientHasContract(client);
}

/*
 * Get a player's contract
 *
 * @param client Client index
 * @param buffer Buffer to store contract
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
any Native_GetClientContract(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int size = GetNativeCell(3);
    any[] buffer = new any[size];

    bool success = GetClientContract(client, buffer, size);

    if (!success) return false;

    SetNativeArray(2, buffer, size);
    return true;
}

/*
 * Set a player's contract
 *
 * @param client Client index
 * @param contract Contract 
 * @param size Size of contract
 * @return true if success, false otherwise
 */
any Native_SetClientContract(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int size = GetNativeCell(3);
    any[] contract = new any[size];
    GetNativeArray(2, contract, size);

    SetClientContract(client, contract, size);

    return 1;
}


/*
 * Converts string value to ``Contracts_TaskType``
 *
 * @param string String
 * @param size Size of string
 * @return Converted task; Type_Unknown if fails.
 */
any Native_TaskTypeFromString(Handle plugin, int numParams)
{
    int size = GetNativeCell(2);

    if (size < 1) return Type_Unknown;

    char[] string = new char[size];
    GetNativeString(1, string, size);

    Contracts_TaskType type = Type_Unknown;

    // General
    if (StrEqual(string, "Kill"))
    {
        type = Type_Kill;
    }
    // TF2
    else if (StrEqual(string, "TF2Uber"))
    {
        type = Type_TF2Uber;
    }
    else if (StrEqual(string, "TF2Cap"))
    {
        type = Type_TF2Cap;
    }
    // CSTRIKE
    else if (StrEqual(string, "CSPlant"))
    {
        type = Type_CSPlant;
    }
    else if (StrEqual(string, "CSDefuse"))
    {
        type = Type_CSDefuse;
    }

    return type;
}

/*
 * Converts ``Contracts_TaskType`` value to string
 *
 * @param type TaskType to convert
 * @param buffer Buffer to store string
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
any Native_StringFromTaskType(Handle plugin, int numParams)
{
    int size = GetNativeCell(3);
    if (size < 0) return false;

    Contracts_TaskType type = GetNativeCell(1);
    char buffer[MAX_TASK_STRTYPE];

    switch (type)
    {
        case Type_Unknown:
        {
            return false;
        }
        // General
        case Type_Kill:
        {
            buffer = "Kill";
        }
        // TF2
        case Type_TF2Uber:
        {
            buffer = "TF2Uber";
        }
        case Type_TF2Cap:
        {
            buffer = "TF2Cap";
        }
        // CSTRIKE
        case Type_CSPlant:
        {
            buffer = "CSPlant";
        }
        case Type_CSDefuse:
        {
            buffer = "CSDefuse";
        }
        default:
        {
            return false;
        }
    }

    SetNativeString(2, buffer, size);

    return true;
}

/*
 * Converts string value to ``Contracts_TaskDetail``
 *
 * @param string String
 * @param size Size of string
 * @return Converted task; Detail_Unknown if fails.
 */
any Native_TaskDetailFromString(Handle plugin, int numParams)
{
    int size = GetNativeCell(2);

    if (size < 1) return Type_Unknown;

    char[] string = new char[size];
    GetNativeString(1, string, size);

    Contracts_TaskDetail detail = Detail_Unknown;

    // General
    if (StrEqual(string, "Any"))
    {
        detail = Detail_Any;
    }
    // TF2
    else if (StrEqual(string, "TF2Scout"))
    {
        detail = Detail_TF2Scout;
    }
    else if (StrEqual(string, "TF2Soldier"))
    {
        detail = Detail_TF2Soldier;
    }
    else if (StrEqual(string, "TF2Pyro"))
    {
        detail = Detail_TF2Pyro;
    }
    else if (StrEqual(string, "TF2Demoman"))
    {
        detail = Detail_TF2Demoman;
    }
    else if (StrEqual(string, "TF2Heavy"))
    {
        detail = Detail_TF2Heavy;
    }
    else if (StrEqual(string, "TF2Engineer"))
    {
        detail = Detail_TF2Engineer;
    }
    else if (StrEqual(string, "TF2Medic"))
    {
        detail = Detail_TF2Medic;
    }
    else if (StrEqual(string, "TF2Sniper"))
    {
        detail = Detail_TF2Sniper;
    }
    else if (StrEqual(string, "TF2Spy"))
    {
        detail = Detail_TF2Spy;
    }
    // CSTRIKE
    else if (StrEqual(string, "CSCounterTerrorist"))
    {
        detail = Detail_CSCounterTerrorist;
    }
    else if (StrEqual(string, "CSTerrorist"))
    {
        detail = Detail_CSTerrorist;
    }

    return detail;
}

/*
 * Converts ``Contracts_TaskDetail`` value to string
 *
 * @param type TaskDetail to convert
 * @param buffer Buffer to store string
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
any Native_StringFromTaskDetail(Handle plugin, int numParams)
{
    int size = GetNativeCell(3);
    if (size < 0) return false;

    Contracts_TaskDetail detail = GetNativeCell(1);
    char buffer[MAX_TASK_STRTYPE];

    switch (detail)
    {
        case Detail_Unknown:
        {
            return false;
        }
        // General
        case Detail_Any:
        {
            buffer = "Any";
        }
        // TF2
        case Detail_TF2Scout:
        {
            buffer = "TF2Scout";
        }
        case Detail_TF2Soldier:
        {
            buffer = "TF2Soldier";
        }
        case Detail_TF2Pyro:
        {
            buffer = "TF2Pyro";
        }
        case Detail_TF2Demoman:
        {
            buffer = "TF2Demoman";
        }
        case Detail_TF2Heavy:
        {
            buffer = "TF2Heavy";
        }
        case Detail_TF2Engineer:
        {
            buffer = "TF2Engineer";
        }
        case Detail_TF2Medic:
        {
            buffer = "TF2Medic";
        }
        case Detail_TF2Sniper:
        {
            buffer = "TF2Sniper";
        }
        case Detail_TF2Spy:
        {
            buffer = "TF2Spy";
        }
        // CSTRIKE
        case Detail_CSCounterTerrorist:
        {
            buffer = "CSCounterTerrorist";
        }
        case Detail_CSTerrorist:
        {
            buffer = "CSTerrorist";
        }
        default:
        {
            return false;
        }
    }

    SetNativeString(2, buffer, size);

    return true;
}


/*
 * Creates a task from given id.
 *
 * @param id Id of task to create
 * @param buffer Buffer to store task
 * @param size Size of buffer
 */
any Native_CreateTaskFromId(Handle plugin, int numParams)
{
    int size = GetNativeCell(3);
    if (size < 1) return false;

    int string_len;
    GetNativeStringLength(1, string_len);
    char[] id = new char[string_len];
    GetNativeString(1, id, string_len);

    Contracts_Task template;

    bool success = GetTaskTemplate(id, template, sizeof(template));

    if (!success) return false;

    SetNativeArray(2, template, size);

    return true;
}

/*
 * Creates a contract from given id.
 *
 * @param id Id of contract to create
 * @param buffer Buffer to store contract
 * @param size Size of buffer
 */
any Native_CreateContractFromId(Handle plugin, int numParams)
{
    int size = GetNativeCell(3);
    if (size < 1) return false;

    int string_len;
    GetNativeStringLength(1, string_len);
    char[] id = new char[string_len];
    GetNativeString(1, id, string_len);

    Contracts_Contract template;

    bool success = GetContractTemplate(id, template, sizeof(template));

    if (!success) return false;

    SetNativeArray(2, template, size);

    return true;
}