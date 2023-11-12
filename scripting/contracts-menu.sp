#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

// ============== [ MENUS ] ============== //

public Menu MenuConstructor_Contract(int client)
{
    Menu menu = new Menu(MenuCallback_Contract);
    
    Contracts_Contract contract;

    if (
        !Contracts_GetClientContract(client, contract, sizeof(contract))
    ) return null;

    menu.SetTitle("  ✎ Contract: %s  ", contract.name);

    ArrayList tasks = contract.tasks;
    Contracts_Task task;

    char str_index[3];
    char item[256];

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

    return menu;
}

public int MenuCallback_Contract(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            Contracts_Contract contract;
            if (Contracts_GetClientContract(param1, contract, sizeof(contract)))
            {
                Contracts_Task task;
                contract.tasks.GetArray(param2, task, sizeof(task));

                Menu detail = MenuConstructor_Task(task.name, task.goal, task.progress);
                detail.Display(param1, 60);
            }
        }

        case MenuAction_End:
        {
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

    char progress_bar[64] = "[ ";

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
    
    Format(progress_str, sizeof(progress_str), "Progress: %d / %d", progress, goal);

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
                Menu main = MenuConstructor_Contract(param1);
                main.Display(param1, 60);
            }
        }

        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}