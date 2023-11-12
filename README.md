# ContractsReimagined - DEV

## - TO DO -
- More API features (done for now)
- CSGO support (UHHHHHHHHHHhh CS2??, postponed for now)
- TF2 Support (sorta done)
- !! A CFG FILE!! and more ConVars for more customization like chat prefix, colors!
- !! REWARDS, REWARDS AND REWARDS! Must create extentions rewards (credits, backpack items)

## - PATCH NOTES -

### b0.4
- Fixed a critical error while reading task cfgs. "as" and "target" parameters were mixed (Oops!)
- Fixed forwards not being pushed. (I forgot to implement pushing; Oops!)
- Also changed the prefix color to \x05 (idek the color)
- Dev Note: The plugin is almost ready for launch, some more QoL and fully complete extentions, then voila!

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
