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
    bool success = GetContractTemplate(contract_id, contract, sizeof(contract));
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

public Action Command_ShowContract(int client, int args)
{
    if (!Contracts_ClientHasContract(client))
    {
        ReplyToCommand(client, "[Contracts] %T", "Err_NoActiveContract", client);
        return Plugin_Handled;
    }

    Menu menu = MenuConstructor_Contract(client);

    menu.Display(client, 60);

    return Plugin_Handled;
}