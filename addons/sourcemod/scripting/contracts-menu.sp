#include <sdkhooks>
#include <sdktools>

#include <contracts>

// ============== [ VARIABLES ] ============== //
bool g_bTrackContract[MAXPLAYERS + 1] = { false, ... };
bool g_bMenuOpen[MAXPLAYERS + 1] = { false, ... };

// ============== [ FUNCTIONS ] ============== //
public void SetPlayerTracking(int client, bool tracking)
{
    if (!IsClientValid(client)) return;
    g_bTrackContract[client] = tracking;
}

// ============== [ MENUS ] ============== //

public void MenuConstructor_Contract(int client)
{
    Menu menu = new Menu(MenuCallback_Contract);
    
    Contracts_Contract contract;
    
    if (
        !Contracts_GetClientContract(client, contract, sizeof(contract))
    ) return;

    menu.SetTitle("  ✎ Contract: %s  ", contract.name);

    ArrayList tasks = contract.tasks;
    Contracts_Task task;

    char str_index[3];
    char item[256];
    char contract_progress[100];

    menu.AddItem("track", " [  Track Contract  ] ");
    if (contract.IsCompleted())
    {
        menu.AddItem("complete", " [ ===== TURN-IN ===== ] ");
    } else
    {
        ContractProgressBar(contract, contract_progress);
        menu.AddItem("progress", contract_progress);
    }

    char clientstr[8];
    IntToString(client, clientstr, sizeof(clientstr));
    menu.AddItem("", clientstr, ITEMDRAW_SPACER);

    for (int i = 0; i < tasks.Length; i++)
    {
        tasks.GetArray(i, task, sizeof(task));
        IntToString(i, str_index, sizeof(str_index));

        bool completed = task.IsCompleted();

        int drawstyle;

        if (completed)
        {
            drawstyle = ITEMDRAW_DISABLED;
            Format(item, sizeof(item), "  L  %s - Completed", task.name);
        }
        else
        {
            drawstyle = ITEMDRAW_DEFAULT;
            Format(item, sizeof(item), "  L  %s - %d%", task.name, task.GetCompletion());
        }

        menu.AddItem(str_index, item, drawstyle)

    }

    menu.Display(client, 60);
    g_bMenuOpen[client] = true;
}

public int MenuCallback_Contract(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char id[128];
            Contracts_Contract contract;
            if (Contracts_GetClientContract(param1, contract, sizeof(contract)))
            {
                GetMenuItem(menu, param2, id, sizeof(id));
                
                if (StrEqual(id, "complete"))
                {
                    CompleteClientContract(param1);
                    return 0;
                }
                else if (StrEqual(id, "track"))
                {
                    return 0;
                }
                else if (StrEqual(id, "progress"))
                {
                    return 0;
                }

                int index = StringToInt(id);


                Contracts_Task task;
                contract.tasks.GetArray(index, task, sizeof(task));

                Menu detail = MenuConstructor_Task(task.name, task.goal, task.progress);
                detail.Display(param1, 60);
            }
        }

        case MenuAction_End:
        {
            char clientstr[8];
            char temp[1];
            GetMenuItem(menu, 2, temp, 1, _, clientstr, sizeof(clientstr));
            int client = StringToInt(clientstr);

            g_bMenuOpen[client] = false;

            delete menu;
        }
    }

    return 0;
}

public Menu MenuConstructor_Task(const char[] name, int goal, int progress)
{
    Menu menu = new Menu(MenuCallback_Task);
    SetMenuExitBackButton(menu, true);

    menu.SetTitle("  ✎ Task: %s", name);

    char progress_bar[64] = " [ ";

    int amount = 10 * progress / goal;

    for (int i = 0; i < 10; i++)
    {
        if (i < amount)
        {
            StrCat(progress_bar, sizeof(progress_bar), "⬛ ")
        }
        else
        {
            StrCat(progress_bar, sizeof(progress_bar), "=")
        }
    }

    StrCat(progress_bar, sizeof(progress_bar), " ]")

    menu.AddItem("1", "", ITEMDRAW_SPACER);
    menu.AddItem("2", progress_bar);

    char progress_str[128];
    
    Format(progress_str, sizeof(progress_str), " Progress: %d / %d", progress, goal);

    menu.AddItem("3", "", ITEMDRAW_SPACER);
    menu.AddItem("4", progress_str)
    menu.AddItem("5", "", ITEMDRAW_SPACER);

    return menu;
}

public int MenuCallback_Task(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Cancel:
        {
            if (param2 == MenuCancel_ExitBack)
            {
                MenuConstructor_Contract(param1);
            }
        }

        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}

public void ContractProgressBar(Contracts_Contract contract, const char buffer[100])
{
    char progress_bar[100] = " [ ";

    int progress = contract.GetCompletion();

    int amount = 12 * progress / 100;

    for (int i = 0; i < 12; i++)
    {
        if (i < amount)
        {
            StrCat(progress_bar, sizeof(progress_bar), "⬛ ");
        }
        else
        {
            StrCat(progress_bar, sizeof(progress_bar), "=");
        }
    }

    StrCat(progress_bar, sizeof(progress_bar), " ] ");

    buffer = progress_bar;
}

public void HudText_Contract(int client)
{
    Contracts_Contract contract;
    Contracts_GetClientContract(client, contract, sizeof(contract))
}

public bool Menu_GetClientOpen(int client)
{
    if (!IsClientValid(client)) return false;

    return g_bMenuOpen[client];
}