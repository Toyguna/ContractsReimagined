#if defined _contractsreimagined_included_
    #endinput
#endif
#define _contractsreimagined_included_


/**
 * Colours:
 *  - #F5B54B = Chat Prefix (\x0A because of CS:GO !!!!)
 * 
 */

// ============== [ CONSTANTS ] ============== //

#define PLUGIN_VERSION "b0.4"
#define CHAT_PREFIX "\x05[Contracts]\x01"
#define CONSOLE_PREFIX "[Contracts]"

#define MAX_TASK_ID 32
#define MAX_TASK_NAME 64
#define MAX_TASK_STRTYPE 32
#define MAX_TASK_STRDETAIL 64

#define MAX_CONTRACT_ID 32
#define MAX_CONTRACT_NAME 64

// ============== [ ENUMS ] ============== //

enum Contracts_TaskType
{
    Type_Unknown = 0,

    // General
    Type_Kill,
    Type_HeadshotKill,


    // TF2
    Type_TF2Uber,
    Type_TF2Cap,
    Type_TF2WinRound,
    Type_TF2WinMatch,
    Type_TF2CastSpell,
    Type_TF2KillBySpell,


    // CSTRIKE
    Type_CSPlant,
    Type_CSDefuse,
    Type_CSWinRound,
    Type_CSWinMatch,
    Type_CSGrenadeKill,
    Type_CSBombKill,
    Type_CSFireKill
}

enum Contracts_TaskDetail
{
    Detail_Unknown = 0,

    // General
    Detail_Any,

    // TF2
    Detail_TF2Scout,
    Detail_TF2Soldier,
    Detail_TF2Pyro,
    Detail_TF2Demoman,
    Detail_TF2Heavy,
    Detail_TF2Engineer,
    Detail_TF2Medic,
    Detail_TF2Sniper,
    Detail_TF2Spy,

    // CSTRIKE
    Detail_CSCounterTerrorist,
    Detail_CSTerrorist
}

// ============== [ STURCTS ] ============== //

enum struct Contracts_Contract
{
    char id[MAX_CONTRACT_ID];
    char name[MAX_CONTRACT_NAME];

    // ``owner = -1`` means that the struct is a blueprint
    int owner;

    ArrayList tasks;

    void Init()
    {
        this.tasks = new ArrayList(sizeof(Contracts_Task));
    }

    void AddTask(Contracts_Task task)
    {
        this.tasks.PushArray(task, sizeof(task));
    }
}   

enum struct Contracts_Task 
{
    char id[MAX_TASK_ID];
    char name[MAX_TASK_NAME];

    // ``goal = -1`` means that the struct is a blueprint
    int goal;
    int progress;
    int index; // index in contract; -1 means blueprint

    Contracts_TaskType type;
    Contracts_TaskDetail detail_as;
    Contracts_TaskDetail detail_target;

    bool IsCompleted()
    {
        return this.progress >= this.goal;
    }

    int GetCompletion()
    {
        return this.progress * 100 / this.goal;
    }
}


// ============== [ NATIVES ] ============== //

/*
 * Check if client has an active contract.
 *
 * @param client Client index
 * @return true if client has an active contract, false otherwise
 */
native bool Contracts_ClientHasContract(int client);

/*
 * Get a player's contract
 *
 * @param client Client index
 * @param buffer Buffer to store contract
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
native bool Contracts_GetClientContract(int client, any[] buffer, int size);

/*
 * Set a player's contract
 *
 * @param client Client index
 * @param contract Contract 
 * @param size Size of contract
 * @return true if success, false otherwise
 */
native bool Contracts_SetClientContract(int client, any[] contract, int size);


/*
 * Removes a player's contract
 *
 * @param client Client index
 * @return false if client does not have contract
 */
native bool Contracts_RemoveClientContract(int client);

/**
 * Progress a task by a specificed amount.
 * 
 * @param client        Client index
 * @param amount        Amount to progress
 * @param task_index    Task's index in contract
 */
native void Contracts_ProgressTask(int client, int amount, int task_index);


/*
 * Converts string value to ``Contracts_TaskType``
 *
 * @param string String
 * @param size Size of string
 * @return Converted task; Type_Unknown if fails.
 */
native Contracts_TaskType Contracts_TaskTypeFromString(const char[] string, int size);

/*
 * Converts ``Contracts_TaskType`` value to string
 *
 * @param type TaskType to convert
 * @param buffer Buffer to store string
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
native bool Contracts_StringFromTaskType(Contracts_TaskType type, const char[] buffer, int size);

/*
 * Converts string value to ``Contracts_TaskDetail``
 *
 * @param string String
 * @param size Size of string
 * @return Converted task; Detail_Unknown if fails.
 */
native Contracts_TaskDetail Contracts_TaskDetailFromString(const char[] string, int size);

/*
 * Converts ``Contracts_TaskDetail`` value to string
 *
 * @param type TaskDetail to convert
 * @param buffer Buffer to store string
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
native bool Contracts_StringFromTaskDetail(Contracts_TaskDetail type, const char[] buffer, int size);

/*
 * Creates a task from given id.
 *
 * @param id Id of task to create
 * @param buffer Buffer to store task
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
native bool Contracts_CreateTaskFromId(const char[] id, any[] buffer, int size);

/*
 * Creates a contract from given id.
 *
 * @param id Id of contract to create
 * @param buffer Buffer to store contract
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
native bool Contracts_CreateContractFromId(const char[] id, any[] buffer, int size);


// ============== [ FORWARDS ] ============== //

/*
 * Called when a client completes a contract.
 *
 * @param client Client Index
 * @param contract_id Contract Id
 */
forward void Contracts_OnContractCompletion(int client, const char[] contract_id);

/*
 * Called when a client completes a task.
 *
 * @param client Client Index
 * @param task_id Task Id
 * @param goal Task Goal
 */
forward void Contracts_OnTaskCompletion(int client, const char[] task_id, int goal)