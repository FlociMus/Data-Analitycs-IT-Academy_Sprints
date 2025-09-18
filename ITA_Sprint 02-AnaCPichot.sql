
-- CHECK INICIAL DE DATOS

-- select count(*) from transactions.transaction; TRANSACCIONES DE venTA
-- select count(*) from transactions.company; MAESTRO DE CLIENTES

-- SELECT *
-- FROM transactions.transaction
-- WHERE ID IS NULL;

-- SELECT distinct ID
-- FROM transactions.company;
-- -- 100 registros sin duplicados;

-- SELECT DISTINCT declined
-- FROM transactions.transaction
-- valores 1 y 0.

-- SELECT *
-- FROM transactions.transaction
-- WHERE DECLINED=1

-- SELECT *
-- FROM transactions.transaction
-- WHERE AMOUNT<0

-- ============================================================================- EXERCICI 2 ===============================================================================================================
/* Utilitzant JOIN realitzaràs les següents consultes:
o	Llistat dels països que estan generant vendes. NOMS DEL PAÏSSOS
o	Des de quants països es generen les vendes. NÚMERO PAÏSSOS
o	Identifica la companyia amb la mitjana més gran de vendes. PROMIG DE venDES I SELECCIONAR EL NÚMERO MÉS ALT*/
-- ========================================================================================================================================================================================================
-- USE TRANSACTIONS;
-- COM= TAULA 1 Companyies o mestre de clients
-- VEN= TAULA 2 Transaccions de vendes gravades al sistema. Incloses i excloses.(declined 0/1)


-- CHECK : número de païssos que existeixen a la taula de mestre de companyies: 15.
SELECT DISTINCT com.country
FROM transactions.company com;

-- 1.- Llistat de paissos que tenen vendes
SELECT DISTINCT 										-- Step 2.- Select and visualise fields
		com.country
FROM transactions.company com
		INNER JOIN transactions.transaction ven
		ON com.ID=ven.company_id
WHERE ven.amount>0.00  AND declined=0; 					-- Step 1.- Filter companies with sales and transactions completed

-- 15 paises en total.
   
-- 2.- Des de quants paissos es generen vendes / Números de paissos que generen vendes.

SELECT													-- Step 2.- Select and visualise fields
	 COUNT(DISTINCT com.country)
FROM transactions.company com
	INNER JOIN transactions.transaction ven
	ON com.ID=ven.company_id
WHERE ven.amount>0.00 AND ven.declined=0; 				-- Step 1.- Filter companies with sales and transactions completed

-- 15 paises en total.
          
-- 3.- Identifica la companyia amb la mitjana més gran de vendes

SELECT DISTINCT 							-- Step 5.- Select and visualise fields
	ven.company_id,
    com.company_name,
    com.country,
    ROUND(AVG(amount),2) AS ventas 			-- Step 1.- Cáculate average sales 
FROM transactions.transaction ven
	INNER JOIN transactions.company com
    ON com.ID=ven.company_id
    WHERE ven.declined=0 					-- Step 2.- Filter transactions completed
GROUP BY 
	company_id								-- Step 3.- Aggregatte sales per company id/customer
ORDER BY ventas DESC
LIMIT 1; 									-- Step 4.- View TOP 1


-- ============================================================================- Exercici 3 ===============================================================================================================
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- o	Mostra totes les transaccions realitzades per empreses d'Alemanya.
-- o	Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- o	Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- ===================================================================================================================================================================================================

-- CHECK INICIAL 15 paises en total.

SELECT DISTINCT country
FROM transactions.company com;

-- 1.- Mostra totes les transactions realitzades per empreses d'Alemanya.
SELECT * 									-- Step 2.- Visualise fields
FROM transactions.transaction ven
WHERE 
	company_id IN (
			SELECT 
            ID
			FROM transactions.company com
            WHERE country='Germany'); 		-- Step 1.- Filter country using subquery
   
-- 2.- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- VALOR INDIVIDUAL DE LA TRANSACCIÓ > PROMIG DEL TOTAL DE VENDES A LA BASE DE DADES :   AMOUNT_ti > ( SUMA VENDES/ # TOTAL TRANSACCIONS)

SELECT DISTINCT 																-- Step 4.- Visualise results
		company_name       
FROM   transactions.company com 												-- Step 3.- Translate ID's into name.
WHERE ID IN (
			SELECT
			company_id
			FROM   transactions.TRANSACTION ven 								-- Step 2.- Select those customer ID's that meet requirements
WHERE  declined=0 AND amount > (	
								SELECT ROUND(AVG(amount),2) AS Promig_Total
								FROM   transactions.TRANSACTION ven
								WHERE declined=0)); 							-- Step 1.- Calculate average sales including only completed transactions.

-- check promig Total = '259.015312'

-- 3.- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT DISTINCT									 	-- Step 3.- Visualise results
		com.id,
        com.company_name
FROM   transactions.company com
WHERE id NOT IN 								  	-- Step 2.- Filter those not in the set
		(	
			SELECT DISTINCT ven.company_id
			FROM   transactions.TRANSACTION ven); 	-- Step 1.- Create a set with all unique company ID's

-- ============================================================================- NIVELL 2 ===============================================================================================================
/*
Exercici 1 
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant JOIN i subconsultes.
Mostra el llistat aplicant solament subconsultes.*/
-- ===================================================================================================================================================================================================


-- 1.- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
	
SELECT 												-- Step 6.- Visualise results
	CAST(timestamp AS date) AS Data_Transaccio,
    SUM(amount) AS Total_Vendes_Diàries    			-- Step 1.- Sum up amounts to get daily sales 
FROM transactions.transaction ven
WHERE amount>0.00 AND declined=0 					-- Step 2.- Filter customers genereting sales and completed transactions
GROUP BY 
	CAST(timestamp AS date) 						-- Step 3.- Agreggate sales per day 
ORDER BY  Total_Vendes_Diàries DESC 				-- Step 4.- order the results, daily sales per date, top down
LIMIT 5; 											-- Step 5.- Select only the top 5 dates 

-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT 
	com.country,
    AVG(ven.amount) AS Promig_Vendes    
FROM transactions.transaction ven
	INNER JOIN transactions.company com
	ON ven.company_id=com.ID
GROUP BY 
	com.country
ORDER BY Promig_Vendes  DESC;
   
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.


-- Mostra el llistat aplicant JOIN i subconsultes
SELECT 												-- Step 3.- Visualise results
	*,
	com.COUNTRY
FROM transactions.transaction ven
	INNER JOIN transactions.company com 			-- Step 2.- Filter country using where and join
	ON ven.company_id=com.id
WHERE com.COUNTRY IN   								
	(SELECT com.COUNTRY
	FROM transactions.company com
	WHERE com.company_name='Non Institute'  		-- Step 1.- Filter company name using first subquery
    );



-- Mostra el llistat aplicant solament subconsultes
SELECT 	*											-- Step 3.- Visualise results
FROM transactions.transaction ven
WHERE ven.company_id IN
	(SELECT 										
    com.id
	FROM transactions.company com
	WHERE com.country IN 						  	-- Step 2.- Filter country using second subquery
		(SELECT com.country
        FROM transactions.company com
		WHERE com.company_name='Non Institute'));  	-- Step 1.- Filter company name using first subquery
    
 
-- ============================================================================- NIVELL 3 ===============================================================================================================
/* Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
Ordena els resultats de major a menor quantitat.

Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.*/
-- ======================================================================================================================================================================================================

/*1.- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
Ordena els resultats de major a menor quantitat.*/
         
             
SELECT 																			-- Step 6.-Visualise results
		com.company_name,
		com.phone,
		com.country,
        ven.timestamp,
        ven.amount        
FROM transactions.company com													-- Step 1.- Select fields from table companies/customers
		INNER JOIN transactions.transaction ven									-- Step 2.- Select fields from table transaccions 
        ON com.ID=ven.company_id
WHERE ven.amount BETWEEN 350 AND 400 										 	-- Step 3.- Filter the amount of each unique transaction where the amount is between two given values. 
		AND CAST(timestamp AS DATE) IN ('2015-04-29','2018-07-20','2024-03-13') -- Step 4.- Filter those transactions recorded on the given dates.
ORDER BY ven.amount DESC;														-- Step 5.- Order the results by amount top down.
             
             
             
 /* 2.- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
 per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.*/                   
                           

SELECT DISTINCT 									-- Step 5.-Visualise results
	ven.company_id AS ID_Companyia,    
   (CASE 
	WHEN COUNT(DISTINCT ven.id) >400 THEN 'Above 400'
    ELSE 'Below 400'
	END ) AS 'Results' 								-- Step 1.- Create a temporary column in which we can type above o below the values depending on the value of the total count of unique transactions.
FROM transactions.transaction ven
WHERE ven.declined=0 								-- Setp 2.- Filter only those transaction completed
GROUP BY ven.company_id 							-- Step 3.- Sum up the total quantity of unique transactions per company
ORDER BY Results DESC; 								-- Step 4.- Order the results Top Down


-- ============================================================================- FIN ========================================================================================================================                    
                    
                    
                    