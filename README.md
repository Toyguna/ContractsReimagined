# ContractsReimagined - DEV

## - TO DO -
- More API features
- CSTRIKE and TF2 support with seperate plugins ( with the API )

## - PATCH NOTES -

### b0.0.3
- Completed the database
- Added contract completion.
- Added admin command: ``sm_completecontract``
    - Usage: sm_completecontract <target_name>
    - Completes a client's contract

### b0.0.2
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

### b0.0.1
- Initial commit.
