CREATE TABLE IF NOT EXISTS contracts_users (
	id int(11) NOT NULL auto_increment PRIMARY KEY,
    authid varchar(64) NOT NULL,
    contractid varchar(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS contracts_tasks (
	id int(11) NOT NULL auto_increment PRIMARY KEY,
	taskid varchar(32) NOT NULL,
    goal int NOT NULL,
    progress int NOT NULL,
    contractid varchar(32) NOT NULL
);