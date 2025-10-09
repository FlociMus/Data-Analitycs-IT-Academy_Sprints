

/* ========================================================NIVELL 1 ========================================================
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
almenys 4 taules de les quals puguis realitzar les següents consultes:
*/

-- DROP PROCEDURE IF EXISTS SP_Crear_MarketPlace_BBDD

DELIMITER //

 -- Step 1.- CREATE PROCEDURE TO CREATE DATABASE AND TABLES
 CREATE PROCEDURE SP_Crear_MarketPlace_BBDD ()
 
 BEGIN
 
 
CREATE DATABASE IF NOT EXISTS Marketplace;

-- USE Marketplace;

/* Design a new database and upload data from given csv.

table 1 .- All_users join table for european users and american users.
table 2.- Companies- Customer data
table 3.- credit_cards
table 3.- transactions - Facts table
table 4.- products
table 5.- geography new nice to have table
table 6.- inventory new nice to have table
table 7.- warehouses new nice to have table
*/

CREATE TABLE IF NOT EXISTS all_users (
		user_id	INT PRIMARY KEY,
		name		NVARCHAR(150),      
		surname		NVARCHAR(150),
		phone		NVARCHAR(150),
		email		NVARCHAR(150),
		birth_date	NVARCHAR(150),
		country		NVARCHAR(150),
		city		NVARCHAR(150),
		postal_code	NVARCHAR(150),
		address		NVARCHAR(255),
		continent	NVARCHAR(20) ,
        UNIQUE INDEX idx_email (email)
		);
-- Unique Index over email so user are fully identified. For example, it could not be possible to have a company email in a user email field.

CREATE TABLE IF NOT EXISTS companies (
		company_id		NVARCHAR(10) PRIMARY KEY,
		company_name	NVARCHAR(255) NOT NULL,
		phone			NVARCHAR(15),
		email			NVARCHAR(100),
		country			NVARCHAR(150),
		website			NVARCHAR(255),
		continent		NVARCHAR(20)
		);

CREATE TABLE IF NOT EXISTS credit_cards (
		card_id			NVARCHAR(10) PRIMARY KEY,
		user_id			INT NOT NULL,
		iban			NVARCHAR(40) NOT NULL,
		pan 			NVARCHAR(20) NOT NULL,
		pin				NVARCHAR(4) ,
		cvv				NVARCHAR(3),
		track1			NVARCHAR(60),
		track2			NVARCHAR(40),
		-- expiring_date	DATE NOT NULLtransactions
        expiring_date	NVARCHAR(10) NOT NULL )
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE IF NOT EXISTS transactions(
		id				NVARCHAR(255) PRIMARY KEY,
		card_id			NVARCHAR(10),
		company_id		NVARCHAR(10),
		date			DATE default (CURRENT_DATE),
		amount			DEC(10,4),
		declined		INT,
		product_ids		NVARCHAR(40),
		user_id			INT NOT NULL,
		lat				NVARCHAR(20),
		longitude		NVARCHAR(20)	)	
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE IF NOT EXISTS products(
		product_id			NVARCHAR(40) PRIMARY KEY,
		product_name		NVARCHAR(255),
		-- price			DEC(10,4),
        price				NVARCHAR(20) NOT NULL,
		currency			NVARCHAR(4),
		colour				NVARCHAR(7),
		weight				DEC(10,4),
		warehouse_id		NVARCHAR(20),
		product_category	NVARCHAR(40)
		)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- NICE TO HAVE tables ==============================================

CREATE TABLE IF NOT EXISTS inventory(
		warehouse_id	NVARCHAR(20),
		product_id	NVARCHAR(40),
		inventory	DEC(10,4)
		)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
        
CREATE TABLE IF NOT EXISTS warehouses (
		warehouse_id		NVARCHAR(20),
		warehouse_name		NVARCHAR(150),
		warehouse_type		NVARCHAR(40),
		products_category	NVARCHAR(40),
		country				NVARCHAR(150),
		lat					NVARCHAR(20),
		longitude			NVARCHAR(20)
		)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS geography(
		country	NVARCHAR(150),
		continent	NVARCHAR(20)
		)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- WE CREATE TKE FOREIGN KEYS

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_card
FOREIGN KEY (card_id) 
REFERENCES credit_cards(card_id)
ON UPDATE CASCADE;

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_users
FOREIGN KEY (user_id) 
REFERENCES all_users(user_id )
ON UPDATE CASCADE;

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_companies
FOREIGN KEY (company_id) 
REFERENCES companies(company_id )
ON UPDATE CASCADE;


END //
DELIMITER ;

