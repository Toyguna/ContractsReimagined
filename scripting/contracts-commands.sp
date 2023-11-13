#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required

/**
 * Gets the client of id from given pattern.
 * 
 * @param admin Client Id of admin
 * @param pattern Pattern to look for
 * @return Client id of found user; -1 if no players match the pattern; -2 if there are multiple matching clients.
 */
public int ParseClientName(int admin, const char[] pattern)
{
    char target_name[MAX_TARGET_LENGTH];
    int target_list[1];

    bool temp;

    int found = ProcessTargetString(
        pattern,
        admin,
        target_list,
        1,
        COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_BOTS,
        target_name,
        sizeof(target_name),
        temp
    );

    if (found == 1)
    {
        return target_list[0]
    }
    else if (found > 1)
    {
        return -2
    }

    return -1;
}

public Action Command_GiveContract(int client, int args)
{
    if (args < 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_givecontract <name> <contract_id>");
        return Plugin_Handled;
    }

    char pattern[64];
    char contract_id[MAX_CONTRACT_ID];
    GetCmdArg(1, pattern, sizeof(pattern));
    GetCmdArg(2, contract_id, sizeof(contract_id));

    int target = ParseClientName(client, pattern);

    if (target == -1)
    {
        ReplyToCommand(client, "[SM] No players found.");
        return Plugin_Handled;
    }
    else if (target == -2)
    {
        ReplyToCommand(client, "[SM] Multiple matching players.");
        return Plugin_Handled;
    }

    Contracts_Contract contract;
    bool success = GetContractTemplate(contract_id, contract);
    if (!success)
    {
        ReplyToCommand(client, "[SM] Error while fetching contract.");
        return Plugin_Handled;
    }

    contract.owner = target;
    Contracts_SetClientContract(client, contract, sizeof(contract));

    ReplyToCommand(client, "[SM] Gave client '%d', contract '%s'.", target, contract_id);


    return Plugin_Handled;
}

public Action Command_CompleteContract(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_completecontract <name>");
        return Plugin_Handled;
    }

    char pattern[64];
    GetCmdArg(1, pattern, sizeof(pattern));

    int target = ParseClientName(client, pattern);

    if (target == -1)
    {
        ReplyToCommand(client, "[SM] No players found.");
        return Plugin_Handled;
    }
    else if (target == -2)
    {
        ReplyToCommand(client, "[SM] Multiple matching players.");
        return Plugin_Handled;
    }
    
    CompleteClientContract(client);

    return Plugin_Handled;
}

public Action Command_ShowContract(int client, int args)
{
    if (!Contracts_ClientHasContract(client))
    {
        ReplyToCommand(client, "%s %T", CHAT_PREFIX, "Err_NoActiveContract", client);
        return Plugin_Handled;
    }

    MenuConstructor_Contract(client);

    return Plugin_Handled;
}