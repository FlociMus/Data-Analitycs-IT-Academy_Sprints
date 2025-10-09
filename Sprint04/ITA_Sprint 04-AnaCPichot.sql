use marketplace;


/* ========================================================NIVELL 1 ========================================================
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
almenys 4 taules de les quals puguis realitzar les següents consultes:
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/

CALL SP_Crear_MarketPlace_BBDD();

SHOW PROCEDURE STATUS;

-- ========================================================================================== UPLOAD DATA IN TABLES =============================================================================

-- SHOW VARIABLES LIKE 'secure_file_priv'; CHECK IF FILES FOLDER HAS SUFICIENT RIGHTS .
-- TRUNCATE TABLE all_users
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_users.txt'
INTO TABLE all_users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE companies
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies_clean.csv'
INTO TABLE companies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE credit_cards
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE transactions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE products
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_clean.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


-- ============================================================================== DATA CLEANING ================================================================
-- MAKE SURE DATA CONTAINED IN THE FILES IS CORRECT BEFORE UPLOAD IT, IF IT'S NOT CLEAN IT AND THEN UPLOAD FILES.
-- DATA SHOULD BE CORRECT IN THE YOUR CUSTOMER ORIGIN SOURCE. AVOID MANIPULATING DATA YOURSELF.
-- IN CASE YOU NEED TO CLEAN DATA MAKE SURE TO KEEP RECORD OF YOUR CLEANING PROCESS.

-- 1.- CLEANING PRODUCTS 
SELECT * FROM products; -- CHECKING DATA

UPDATE products 
SET price = 
SUBSTRING(price, 2);

-- Step 2.- Transform data field price into a number so you can use afterwards in your calculations.
ALTER TABLE products
MODIFY price DEC(10,4);

ALTER TABLE credit_cards
MODIFY expiring_date DATE NOT NULL;

UPDATE products pro
-- SELECT 
	-- pro.warehouse_id,
SET pro.warehouse_id =
	REPLACE(pro.warehouse_id, '--', '-')
-- FROM products pro
WHERE pro.warehouse_id LIKE 'WH--%';

-- =========================================================- CREATE NEW DATA - NOT asked.====================================================================================0

-- TRUNCATE TABLE inventory;

UPDATE inventory AS inv
JOIN products AS pro 
  ON inv.product_id = pro.product_id
SET inv.warehouse_id = pro.warehouse_id;

UPDATE inventory AS inv
JOIN products AS pro 
  ON inv.product_id = pro.product_id
SET inv.product_id = pro.product_id;

-- TRUNCATE TABLE geography;
INSERT into geography VALUES 
('United Kingdom',NULL),
('Spain',NULL),
('Netherlands',NULL),
('Sweden',NULL),
('France',NULL),
('Poland',NULL),
('Germany',NULL),
('Italy',NULL),
('Portugal',NULL),
('United States',NULL),
('Canada',NULL);

UPDATE geography AS geo
SET geo.continent=
	CASE WHEN country IN ('United States','Canada') THEN 'North_America'
	ELSE 'Europe' END;


/* ========================================================NIVELL 1 ========================================================
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
almenys 4 taules de les quals puguis realitzar les següents consultes:
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/
	
           
    WITH Transaccions_Completed AS -- STEP. 1 USE ONLY COMPLETED TRANSACTIONS , so not declined
		(SELECT														
		COUNT(tran.id_parent)
		FROM transactions tran 
		WHERE tran.declined=0
		)     
     (SELECT						-- STEP 2.- FIND TOTAL THE NUMBER OF TRANSACTIONS POR EACH USER aka TOTAL SALES PER USER.										
		tran.user_id,
        usu.name,
		usu.surname,
        COUNT(tran.id_parent) AS Num_transaccions
        		FROM transactions tran
                INNER JOIN all_users usu
                on tran.user_id = usu.user_id
       GROUP BY 
		tran.user_id,
        usu.name,
        usu.surname
       HAVING Num_transaccions >=80 -- STEP 3.- FILTER RESULTS - we only want to know the user's names who have bought us more/= than 80 times.
       ORDER BY Num_transaccions ASC);
        
                    
-- ===========================================================================
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules

SELECT
	card.iban,
	AVG(tran.amount) AS Promig_Amount -- STEP 2.- We want to know the average amount 
FROM transactions tran
	INNER JOIN companies com
	ON tran.company_id = com.company_id
	INNER JOIN credit_cards card
	ON tran.card_id = card.card_id -- STEP 4.- We need to link our sales information with our credit cards information
WHERE com.company_name ='Donec Ltd' AND tran.declined=0 -- STEP 1.- We want to filter per company name and use only completed transactions
GROUP BY card.iban ; -- STEP 3.- And the average should be calculated for each different IBAN.




/* =======================================================NIVELL 2 ==========================================================
 Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
Quantes targetes estan actives?*/


CREATE TABLE IF NOT EXISTS active_cards(
		card_id				NVARCHAR(10), 
		user_id				INT ,
		expiring_date		DATE,		
		Active				INT 
        )
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- les últimes tres transaccions van ser declinades 
-- AS an example this what we want:
-- CARD_ID ======= DATE ====== DECLINED TRANSACTION = 1
-- ID_1  --------- 01/10/2025 ------- 1 ------ RANK1 the most recent
-- ID_1  --------- 02/09/2025 ------- 1 ------ RANK2 the second most recent
-- ID_1  --------- 15/08/2025 ------- 1 ------ RANK3 the third most recent
-- ID_1  --------- 01/07/2025 ------- 0
-- ID_1  --------- 01/05/2025 ------- 0
-- TOTAL NUMBER OF TRANSACTIONS = 5
-- TOTAL NUMBER OF DECLINED TRANSACTIONS = 3
-- TOTAL NUMBER OF COMPLETED TRANSSACTIONS = 2

-- SELECT DATA
SELECT
    tran.card_id,
    tran.timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY tran.card_id
        ORDER BY tran.timestamp DESC
    ) AS num_posición_fechas
FROM transactions tran
WHERE tran.declined = 1
ORDER BY tran.card_id;

-- SELECT DATA AND FILTER THE LAST 3 DATES/CARDS 
SELECT tran_ordenadas.card_id, tran_ordenadas.timestamp
FROM (
    SELECT
        tran.card_id,
        tran.timestamp,
        ROW_NUMBER() OVER (										
        PARTITION BY tran.card_id      
		ORDER BY tran.timestamp DESC 
        ) AS num_posición_fechas  
FROM transactions tran
WHERE tran.declined = 1											
) AS tran_ordenadas
WHERE num_posición_fechas >=3
ORDER BY tran_ordenadas.card_id, timestamp DESC;

-- quantes targetes estan actives

-- ACTIVES
SELECT COUNT(tran_ordenadas.card_id)
FROM (
    SELECT
        tran.card_id,
        tran.timestamp,
        ROW_NUMBER() OVER (										
        PARTITION BY tran.card_id      
		ORDER BY tran.timestamp DESC 
        ) AS num_posición_fechas  
FROM transactions tran
WHERE tran.declined = 1											
) AS tran_ordenadas
WHERE num_posición_fechas < 3
ORDER BY tran_ordenadas.card_id, timestamp DESC;


/* ==============================================================================NIVELL 3 ====================================================
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 
Genera la següent consulta:
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
*/

-- DROP TABLE transactions_products;
-- DROP table posiciones;

-- STEP 1.- CREATE NEW TABLE . For each transaction id and product_id on transactions table (parent table)  we need to create a new transaccion (child table)
CREATE TABLE IF NOT EXISTS transactions_products(
		id_child		NVARCHAR(255) ,
		product_id		NVARCHAR(40) 
		)        
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- STEP 2.- SPLIT PRODUCT ID'S IN MORE THAN ONE COLUMN

CREATE TABLE IF NOT EXISTS posiciones (pos INT); --  MAKE A BULLET POINTS LIST SO WE CAN ORDER THE ORDER THE PRODUCT_ID's

INSERT INTO posiciones (pos) VALUES -- GIVE A NUMBER TO EACH ROW 
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);


-- STEP 3.- CHECK WHAT WE WANT TO DO.
SELECT  
	*,
    tran.id_parent,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(tran.product_ids, ',', pos.pos), ',', -1)) AS Product_id -- FOR EACH POSITION ON OUR BULLET POINTS LIST EXTRACT A PRODUCT ID. MAKE SURE THERE ARE NO LEADING OR TRAINLING SPACES
FROM transactions tran
JOIN posiciones pos 
		ON pos.pos <= 1 + LENGTH(tran.product_ids) - LENGTH(REPLACE(tran.product_ids, ',', ''));
 
-- STEP 4.- OUR SELECT WORKS SO NOW WE CAN INSERT THE VALUES INTO THE TABLE
INSERT INTO transactions_products (   
    id_child,
    product_id
)
SELECT 
	tran.id_parent  AS id_child, 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(tran.product_ids, ',', pos.pos), ',', -1)) AS product_id 
FROM transactions tran
INNER JOIN posiciones pos 
    ON pos.pos <= 1 + LENGTH(tran.product_ids) - LENGTH(REPLACE(tran.product_ids, ',', ''));
    
    
 SELECT * FROM transactions_products tran_pro;   
           
    -- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT
	tran_pro.product_id AS Products,
	count(tran_pro.id_child) AS Num_Sales
FROM transactions_products tran_pro
	INNER JOIN transactions tran
	ON tran.id_parent = tran_pro.id_child
WHERE tran.declined=0
GROUP BY tran_pro.product_id
ORDER BY Num_Sales DESC;



