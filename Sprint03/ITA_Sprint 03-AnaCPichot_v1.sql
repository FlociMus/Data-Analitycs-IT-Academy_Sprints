USE TRANSACTIONS;


/* =================================================================================================NIVELL 1 ===============================================================================================================================
Exercici 1.- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

Exercici 2.- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

Exercici 3.- En la taula "transaction" ingressa un nou usuari amb la següent informació:

Exercici 4.- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat. 

*/

-- CREACIÓ DEL DISSENY I DE LES RELACIONS =================================================================================================================

 
-- Exercici 1.- 

DROP TABLE IF EXISTS credit_card; 														-- Step. 1 Drop table before creating a new one
CREATE TABLE credit_card (                 												-- Step. 2 Create a new table
		id VARCHAR(255) NOT NULL PRIMARY KEY,
		iban VARCHAR(255) NOT NULL,
		pan VARCHAR(255) NOT NULL,
		pin INT,
		cvv INT,
		expiring_date NVARCHAR(255) NOT NULL )
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ==========================================================================
-- insertar les dades a la taula a partir de l'arxiu que ens han proporcionat.
-- ==========================================================================

-- CREAR clau foranea de credit_card en la taula transaction . 
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id )
ON UPDATE CASCADE;

-- ==========================================================================
-- preparar camps dates de la taula credit_card. No es demana explicitament.
-- ==========================================================================

SELECT expiring_date
FROM credit_card cc;

-- USE TRANSACTIONS;
UPDATE credit_card cc																	-- Step. 3 Update values from type varchar to date so we can use them for data analysis.
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%Y');

SELECT expiring_date
FROM credit_card cc;

ALTER TABLE credit_card -- Nota no és possible utilitzar un aliès amb alter table. 		-- Setp 4.- Prepare table for data analysis.
MODIFY expiring_date DATE;

SELECT expiring_date, DATE_FORMAT(cc.expiring_date, '%m/%d/%Y') AS exp_date				-- Set 5.- make sure it works properly
FROM credit_card cc;


-- ==========================================================================

--  Nivell 1 - Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

-- Step 1.- Check if id exists
SELECT
	cc.iban AS OLD
FROM credit_card cc
	WHERE cc.id='CcU-2938'; 
    
-- Step 2.- Update value.
UPDATE credit_card cc
SET cc.iban = 'TR32345631221357681769999'
	WHERE cc.id='CcU-2938' AND cc.iban='TR301950312213576817638661' ;
    
-- Step 3.- Check it worked
SELECT
	cc.iban AS NEW
FROM credit_card cc
	WHERE cc.id='CcU-2938'; 

--  Nivell 1 - Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
-- Insert values because it is just one row, otherwise maybe it's better to use a temp table or csv file.
-- make sure foreign key are not null in other tables otherwise won't be possible to insert the information.

SELECT id -- ID MUST EXIST IN COMPANY
FROM company com
WHERE ID='b-9999';

INSERT INTO company -- make sure the company existis company id is a foreign key.
	(id	,company_name,phone,email,country,website) 
    VALUES ('b-9999','name_unknown','phone_unknown','email_unknown','country_unknown','website_unknown');
    
SELECT id   -- ID MUST EXIST IN CREDIT CARD
FROM credit_card Car
WHERE id = 'CcU-9999';
    
INSERT INTO credit_card
	(id ,iban , pan , pin , cvv ,expiring_date )
    VALUES ('CcU-9999',9999999999,999999999999999,NULL,NULL,'2025-10-08');    
    
INSERT INTO transaction -- Insert data. Timestamp unknown so we insert it as default value, null.
	(id	,credit_card_id,company_id,	user_id,lat,longitude,timestamp,amount,declined) 
    VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,829.999,-117.999,NULL,111.11,0);

SELECT *   -- CHECK RESULT
FROM credit_card Car
WHERE id = 'CcU-9999';

SELECT *  -- CHECK RESULT
FROM company com
WHERE ID='b-9999';



-- Nivell 1 - Exercici 4 
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.

-- Step 1.- Check if column exists
SELECT
	cc.pan AS OLD
FROM credit_card cc;

-- Step 2 .- Delete Column
ALTER TABLE credit_card 
DROP COLUMN pan;

-- Step 3 .- Check it works.
SELECT
	cc.pan AS NEW
FROM credit_card cc;

/* ========================================================================================Nivell 2==========================================================================================================================
Exercici 1
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany" */
-- =============================================================================================================================================================================================================================

-- Nivell 2 Exercici 1 
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.


-- SELECT 											Step 1.- Check before you delete any thing by using a select statment.
-- *
DELETE 
FROM transaction tt
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Nivell 2 Exercici 2 Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT
	co.company_name AS Companyia,
	co.phone AS Telèfon,
	co.country AS País,
	ROUND(AVG(tt.amount), 2 ) AS PromigCompra			
FROM company co
	INNER JOIN transaction tt
	ON co.id=tt.company_id
GROUP BY 
	tt.company_id
ORDER BY 
	PromigCompra DESC;

-- Nivell 2 Exercici 3. Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT
	co.company_name AS Companyia,
	co.phone AS Telèfon,
	co.country AS País,
	ROUND(AVG(tt.amount), 2 ) AS PromigCompra			
FROM company co
	INNER JOIN transaction tt
	ON co.id=tt.company_id
WHERE co.country='Germany'
GROUP BY 
	tt.company_id
ORDER BY 
	PromigCompra DESC;

/* =============================================================================================NIVELL 3 ===========================================================================================================
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.*/


-- Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:


-- ==========================================================================
-- Crear la taula USERS 
-- Relacionar aquesta nova taula amb la resta de taules que ja existeixen a la base de dades.
-- Insertar les dades a la taula a partir de l'arxiu que ens han proporcionat.
-- Insertar l'usuari 9999
-- ================================================================================
-- DROP TABLE user;

-- 1.- create table user
CREATE TABLE IF NOT EXISTS user (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2.- INSERT VALUES FROM FILE

-- 3.-  AFEGIR USUARI 99999 A LA TAULA USERS JA QUE SERÀ FOREIGN KEY
SELECT *
FROM user 
where id = '9999';
-- INSERT USER 9999.
INSERT INTO user
	(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
    VALUES (9999,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    
-- 4.- CREATE A FOREIGN KEY TO CONNECT USER WITH THE FACTS TABLE TRANSACTION. 
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) 
REFERENCES user(id)
ON UPDATE CASCADE;

-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

-- RENAME A TABLEe from user to data_user
ALTER TABLE user 
	RENAME TO data_user;
   
-- RENAME A COLUMN from email to personal_email
ALTER TABLE data_user
    RENAME COLUMN email TO personal_email;   

-- DELETE A COLUMN
ALTER TABLE company
	DROP COLUMN website;

-- Add a column
ALTER TABLE credit_card
ADD fecha_actual DATE DEFAULT(CURRENT_DATE);

-- CHANGE DATA TYPES
-- we want to change a data type of a foreign key so we need to delete it before.
ALTER TABLE transaction 
DROP FOREIGN KEY fk_transaction_card;

ALTER TABLE transaction
MODIFY credit_card_id VARCHAR(20) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

ALTER TABLE credit_card
MODIFY id VARCHAR(20) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

-- WE CREATE OUR FOREIGN KEY AGAIN
ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_card 
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id) 
ON UPDATE CASCADE;

ALTER TABLE credit_card
MODIFY iban VARCHAR(50) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;
    
ALTER TABLE credit_card
MODIFY pin VARCHAR(4) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

ALTER TABLE credit_card
MODIFY expiring_date VARCHAR(20) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;
              
-- Exercici 2
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
-- Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.

-- DROP VIEW InformeTecnico ;
CREATE VIEW InformeTecnico 
AS
SELECT 
	tt.id AS ID_Transacció,
    uu.name AS Nom_Usuari,
    uu.surname AS Cognom_Usuari,
    cc.iban AS Num_Compte,
    co.company_name AS Nom_Companyia   
FROM transactions.transaction tt  -- des de transactions
	INNER JOIN transactions.data_user uu  -- busco usuaris
	ON tt.user_id=uu.id
    INNER JOIN transactions.company co  -- busco companyies
	ON tt.company_id=co.id
    INNER JOIN transactions.credit_card cc  -- busco iban
	ON tt.credit_card_id=cc.id;
   
    
SELECT
*
FROM InformeTecnico;











