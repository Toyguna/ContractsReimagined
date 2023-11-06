CREATE TABLE IF NOT EXISTS contracts_users (
	userid int NOT NULL auto_increment PRIMARY KEY,
    authid varchar(64) NOT NULL UNIQUE,
    contractid varchar(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS contracts_tasks (
	userid int NOT NULL,
	taskid varchar(32) NOT NULL,
    goal int NOT NULL,
    progress int NOT NULL,
    contractid varchar(32) NOT NULL
);