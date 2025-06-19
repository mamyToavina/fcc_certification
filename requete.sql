-- 1. Renommer les colonnes
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

-- 2. Empêcher les NULL sur les points de fusion et ébullition
ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

-- 3. Contraintes sur les colonnes de elements
ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;
ALTER TABLE elements ADD CONSTRAINT unique_symbol UNIQUE(symbol);
ALTER TABLE elements ADD CONSTRAINT unique_name UNIQUE(name);

-- 4. Clé étrangère sur atomic_number
ALTER TABLE properties ADD CONSTRAINT fk_atomic_number FOREIGN KEY(atomic_number) REFERENCES elements(atomic_number);

-- 5. Créer la table types
CREATE TABLE types (
  type_id SERIAL PRIMARY KEY,
  type VARCHAR(30) NOT NULL
);

-- 6. Insérer les types distincts
INSERT INTO types(type)
SELECT DISTINCT type FROM properties;

-- 7. Ajouter type_id à properties
ALTER TABLE properties ADD COLUMN type_id INT;

-- 8. Mettre à jour les lignes existantes
UPDATE properties
SET type_id = t.type_id
FROM types t
WHERE properties.type = t.type;

-- 9. Empêcher NULL + ajout contrainte FK
ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;
ALTER TABLE properties ADD CONSTRAINT fk_type_id FOREIGN KEY(type_id) REFERENCES types(type_id);

-- 10. Supprimer l'ancienne colonne type
ALTER TABLE properties DROP COLUMN type;

-- 11. Corriger capitalisation des symboles
UPDATE elements
SET symbol = INITCAP(symbol);

-- 12. Supprimer l’élément fictif (1000)
DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;

-- 13. Corriger les masses atomiques (remise à jour)
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL(6,4);

UPDATE properties SET atomic_mass = 1.008 WHERE atomic_number = 1;
UPDATE properties SET atomic_mass = 4.0026 WHERE atomic_number = 2;
UPDATE properties SET atomic_mass = 6.94 WHERE atomic_number = 3;
UPDATE properties SET atomic_mass = 9.0122 WHERE atomic_number = 4;
UPDATE properties SET atomic_mass = 10.81 WHERE atomic_number = 5;
UPDATE properties SET atomic_mass = 12.011 WHERE atomic_number = 6;
UPDATE properties SET atomic_mass = 14.007 WHERE atomic_number = 7;
UPDATE properties SET atomic_mass = 15.999 WHERE atomic_number = 8;

-- 14. Ajouter Fluorine (9) et Neon (10)
INSERT INTO elements(atomic_number, symbol, name) VALUES
(9, 'F', 'Fluorine'),
(10, 'Ne', 'Neon');

INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
VALUES
(9, 18.998, -220, -188.1, (SELECT type_id FROM types WHERE type = 'nonmetal')),
(10, 20.18, -248.6, -246.1, (SELECT type_id FROM types WHERE type = 'nonmetal'));

touch element.sh
chmod +x element.sh
