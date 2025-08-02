MySQL.ready(function ()

    local queries = {
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_IBAN (
            IBAN VARCHAR(34) NOT NULL PRIMARY KEY,
            BALANCE BIGINT DEFAULT 0,
            CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INTRATE INT(100) DEFAULT 0.0,
            TYPE VARCHAR(10) DEFAULT 'normal',
            SOCIETY VARCHAR(10) DEFAULT NULL,
            `PRIMARY` TINYINT(1) DEFAULT 0
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_IBAN_ACCESS (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN VARCHAR(34) NOT NULL,
            NICKNAME VARCHAR(100) DEFAULT NULL,
            IDENTIFIER VARCHAR(100) NOT NULL,
            ROLE ENUM('owner', 'co-owner', 'user') DEFAULT 'user',
            FOREIGN KEY (IBAN) REFERENCES TC_BANKING_IBAN(IBAN) ON DELETE CASCADE,
            UNIQUE (IBAN, IDENTIFIER) -- Ensures no duplicate IBAN-Identifier pairs
            );
        ]] },
        { query = [[
            CREATE TRIGGER IF NOT EXISTS delete_iban_after_owner_delete
            AFTER DELETE ON TC_BANKING_IBAN_ACCESS
            FOR EACH ROW
            BEGIN
            IF OLD.ROLE = 'owner' THEN
                DELETE FROM TC_BANKING_IBAN WHERE IBAN = OLD.IBAN;
            END IF;
            END;
        ]] },
        { query = [[
            CREATE TRIGGER IF NOT EXISTS delete_card_after_iban_delete
            AFTER DELETE ON TC_BANKING_IBAN
            FOR EACH ROW
            BEGIN
                DELETE FROM TC_BANKING_CARDS WHERE IBAN = OLD.IBAN;
            END;
        ]] },
        { query = [[
            CREATE TRIGGER IF NOT EXISTS delete_iban_access_after_iban_delete
            AFTER DELETE ON TC_BANKING_IBAN
            FOR EACH ROW
            BEGIN
                DELETE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = OLD.IBAN;
            END;
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_TRANSACTION_HISTORY (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN VARCHAR(34),
            AMOUNT INT(100),
            DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
            DESCRIPTION VARCHAR(255) DEFAULT '',
            STATUS VARCHAR(10) DEFAULT 'pending',
            ISSUER VARCHAR(255) DEFAULT '',
            ADDITIVE INT(1) DEFAULT 0
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_TRANSFER_HISTORY (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN_FROM VARCHAR(34),
            IBAN_TO VARCHAR(34),
            AMOUNT INT(100),
            DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
            DESCRIPTION VARCHAR(255) DEFAULT ''
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_BILLINGS (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN VARCHAR(34),
            BILL_AMOUNT INT(100),
            ISSUE_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
            PAYMENT_DATE DATETIME,
            DESCRIPTION VARCHAR(255) DEFAULT '',
            ISSUER VARCHAR(255) DEFAULT ''
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_LOANS (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN VARCHAR(34),
            LOAN_AMOUNT INT(100),
            INTEREST_RATE INT(100),
            DURATION_DAYS INT,
            REPAYMENT_DATE DATETIME
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_CARDS (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            IBAN VARCHAR(34),
            CARD_NUMBER VARCHAR(16),
            PIN VARCHAR(4) DEFAULT '0000',
            LOCKED TINYINT(1) DEFAULT 0,
            EXPIRATION_DATE DATE,
            MWPH INT(100) DEFAULT 1000
            );
        ]] },
        { query = [[
            CREATE TABLE IF NOT EXISTS TC_BANKING_SOCIETIES (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            JOB VARCHAR(100),
            SOCIETY VARCHAR(100),
            OWNER VARCHAR(100)
            );
        ]] }
    }

    MySQL.transaction(queries, function(success)
        if success then
            lib.print.info("Tables created successfully.")
        else
            lib.print.warn("Failed to create tables.")
        end
    end)
    
end)

