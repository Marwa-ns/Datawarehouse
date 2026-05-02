-- ==========================================================
-- 1. CRÉATION DES DIMENSIONS
-- ==========================================================

CREATE TABLE DIM_TEMPS (
    ID_Temps INT PRIMARY KEY,
    Jour INT, Mois INT, Trimestre INT, Annee INT
);

CREATE TABLE DIM_PRODUIT (
    ID_Produit INT PRIMARY KEY,
    Reference VARCHAR2(50), Categorie VARCHAR2(50), Famille VARCHAR2(50)
);

CREATE TABLE DIM_MACHINE (
    ID_Machine INT PRIMARY KEY,
    Ligne VARCHAR2(20), Type VARCHAR2(20), Date_Maint DATE
);

CREATE TABLE DIM_CAUSE (
    ID_Cause INT PRIMARY KEY,
    Matiere VARCHAR2(20), Milieu VARCHAR2(20), Materiel VARCHAR2(20),
    Main_d_oeuvre VARCHAR2(20), Methode VARCHAR2(20)
);

-- ==========================================================
-- 2. CRÉATION DE LA TABLE DE FAITS
-- ==========================================================

CREATE TABLE FACT_INSPECTION (
    ID_Machine INT,
    ID_Produit INT,
    ID_Temps INT,
    ID_Cause INT,
    Qte_Controlee INT,
    Qte_Defectueuse INT,
    Cout_Perte NUMBER(10,2),
    Duree_Reparation INT,
    CONSTRAINT pk_fact PRIMARY KEY (ID_Machine, ID_Produit, ID_Temps, ID_Cause),
    CONSTRAINT fk_machine FOREIGN KEY (ID_Machine) REFERENCES DIM_MACHINE(ID_Machine),
    CONSTRAINT fk_produit FOREIGN KEY (ID_Produit) REFERENCES DIM_PRODUIT(ID_Produit),
    CONSTRAINT fk_temps FOREIGN KEY (ID_Temps) REFERENCES DIM_TEMPS(ID_Temps),
    CONSTRAINT fk_cause FOREIGN KEY (ID_Cause) REFERENCES DIM_CAUSE(ID_Cause)
);

-- ==========================================================
-- 3. INSERTION DES DONNÉES (Un INSERT par ligne pour Oracle)
-- ==========================================================

-- Dimensions
INSERT INTO DIM_PRODUIT (ID_Produit, Reference, Categorie) VALUES (1, 'Carte_A', 'Electronique');
INSERT INTO DIM_PRODUIT (ID_Produit, Reference, Categorie) VALUES (2, 'Carte_B', 'Electronique');

INSERT INTO DIM_MACHINE (ID_Machine, Ligne, Type) VALUES (1, 'SMT_01', 'Pose');
INSERT INTO DIM_MACHINE (ID_Machine, Ligne, Type) VALUES (2, 'SMT_02', 'Pose');

INSERT INTO DIM_TEMPS (ID_Temps, Jour, Mois, Annee) VALUES (1, 15, 04, 2026);

INSERT INTO DIM_CAUSE (ID_Cause, Methode) VALUES (1, 'Soudure');
INSERT INTO DIM_CAUSE (ID_Cause, Methode) VALUES (2, 'Calibrage');
INSERT INTO DIM_CAUSE (ID_Cause, Methode) VALUES (3, 'Composant HS');

-- Faits
INSERT INTO FACT_INSPECTION (ID_Temps, ID_Produit, ID_Machine, ID_Cause, Qte_Controlee, Qte_Defectueuse, Cout_Perte, Duree_Reparation) 
VALUES (1, 1, 1, 1, 500, 10, 200.00, 30);
INSERT INTO FACT_INSPECTION (ID_Temps, ID_Produit, ID_Machine, ID_Cause, Qte_Controlee, Qte_Defectueuse, Cout_Perte, Duree_Reparation) 
VALUES (1, 1, 1, 2, 500, 5, 100.00, 20);
INSERT INTO FACT_INSPECTION (ID_Temps, ID_Produit, ID_Machine, ID_Cause, Qte_Controlee, Qte_Defectueuse, Cout_Perte, Duree_Reparation) 
VALUES (1, 2, 2, 3, 1000, 50, 1500.00, 120);

COMMIT; -- Obligatoire sur Oracle pour sauvegarder les données

-- ==========================================================
-- 4. TOUS LES CALCULS DE KPIs
-- ==========================================================

-- KPI 1 : Taux de Rebut (Scrap Rate)
SELECT (SUM(Qte_Defectueuse) * 100.0 / SUM(Qte_Controlee)) AS Taux_Rebut_Pct 
FROM FACT_INSPECTION;

-- KPI 2 : Coût total de Non-Qualité (CNQ)
SELECT SUM(Cout_Perte) AS Impact_Financier_Total 
FROM FACT_INSPECTION;

-- KPI 3 : Temps moyen de réparation (MTTR)
SELECT AVG(Duree_Reparation) AS MTTR_Moyen_Minutes 
FROM FACT_INSPECTION;

-- KPI 4 : First Pass Yield (FPY)
SELECT ((SUM(Qte_Controlee) - SUM(Qte_Defectueuse)) * 100.0 / SUM(Qte_Controlee)) AS FPY_Global_Pct 
FROM FACT_INSPECTION;

-- ANALYSE CROISÉE : Pertes par Machine et Référence
SELECT 
    M.Ligne, P.Reference, 
    SUM(F.Cout_Perte) AS Perte_Totale
FROM FACT_INSPECTION F
JOIN DIM_MACHINE M ON F.ID_Machine = M.ID_Machine
JOIN DIM_PRODUIT P ON F.ID_Produit = P.ID_Produit
GROUP BY M.Ligne, P.Reference;
