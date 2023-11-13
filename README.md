# ContractsReimagined - DEV

## - TO DO -
- More API features (done for now)
- CSGO support (postponed for now)
- TF2 Support (sorta done)
- !! A CFG FILE!! and more ConVars for more customization like chat prefix, colors!
- !! REWARDS! Must create extentions for rewards (credits, backpack items)
- !! SFX

## - PATCH NOTES -

### b0.5
- Added real-time contract menu updating.
- Added contract turning in.
    - Contracts now have to be turned in to be completed.
- Revamped contract menu.
    - Added a progress bar (also a turn-in button)
    - Tracking button (WIP)
- Added a new forward ``#Contracts_OnContractTurnIn``

### b0.4
- Fixed a critical error while reading task cfgs. "as" and "target" parameters were mixed (Oops!)
- Fixed forwards not being pushed.
- Also changed the prefix color.

### b0.3
- Completed the database
- Added contract completion.
- Added admin command: ``sm_completecontract``
    - Usage: sm_completecontract <target_name>
    - Completes a client's contract

### b0.2
- Fixed native ``#Contracts_SetClientContract``
- Added admin command: ``sm_givecontract``
    - Usage: sm_givecontract <target_name> <contract_id>
    - Sets a client's contract to given contract id
- Added console command: ``sm_contract``
    - Opens a contract menu listing the contract and it's tasks.
- Added ConVar ``contracts_database_cfg``
    - Database configuration for MySQL.
- Added database connection.
- Created sql-init file.

### b0.1
- Initial commit.
