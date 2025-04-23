# crea la base de datos con el nombre winemag-data si la misma no existe
CREATE DATABASE IF NOT EXISTS WinemagData;
# usa la base de datos creada
use WinemagData;

# crea la tabla Country 
CREATE TABLE Country (
    Country_id INT NOT NULL AUTO_INCREMENT,  -- Código de país, clave primaria y autoincremental
    CountryName VARCHAR(100) NOT NULL,       -- Nombre del país
    PRIMARY KEY (Country_id)                 -- Define Country_id como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla Province
CREATE TABLE Province (
    Province_id INT NOT NULL AUTO_INCREMENT,  -- Código de provincia, clave primaria y autoincremental
    ProvinceName VARCHAR(100) NOT NULL,       -- Nombre de la provincia
    Country_id INT NOT NULL,                  -- Código del país, clave foránea
    PRIMARY KEY (Province_id),                -- Define Province_id como clave primaria
    FOREIGN KEY (Country_id) REFERENCES Country(Country_id)  -- Define Country_id como clave foránea
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla Region
CREATE TABLE Region (
    Region_id INT NOT NULL AUTO_INCREMENT,  -- Código de la región, clave primaria y autoincremental
    RegionName1 VARCHAR(100) NOT NULL,            -- Nombre de la región_1
    RegionName2 VARCHAR(100) NULL,            -- Nombre de la región_2
    Province_id INT NOT NULL,                   -- Código de la provincia, clave foránea
    PRIMARY KEY (Region_id),                 -- Define Region_id como clave primaria
    FOREIGN KEY (Province_id) REFERENCES Province(Province_id)  -- Define Province_id como clave foránea
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla Taster
CREATE TABLE Taster (
    Taster_id INT NOT NULL AUTO_INCREMENT,      -- Código del catador, clave primaria y autoincremental
    TasterName VARCHAR(100) NOT NULL,           -- Nombre del catador
    TasterTwitterHandle VARCHAR(100),           -- Twitter del catador (opcional)
    PRIMARY KEY (Taster_id)                     -- Define CodTaster como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla Variety
CREATE TABLE Variety (
    Variety_id INT NOT NULL AUTO_INCREMENT,    -- Código de la variedad, clave primaria y autoincremental
    VarietyName VARCHAR(100) NOT NULL,         -- Nombre de la variedad de uva
    PRIMARY KEY (Variety_id)                   -- Define CodVariety como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla Winery
CREATE TABLE Winery (
    Winery_id INT NOT NULL AUTO_INCREMENT,    -- Código de la bodega, clave primaria y autoincremental
    WineryName VARCHAR(100) NOT NULL,         -- Nombre de la bodega
    PRIMARY KEY (Winery_id)                   -- Define CodWinery como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla principal WineReview para guardar las reseñas de los vinos 
CREATE TABLE WineReview (
    WineReview_id INT NOT NULL AUTO_INCREMENT,  -- Código de reseña, clave primaria y autoincremental
    Country_id INT NOT NULL,                    -- Código del país, clave foránea (FK)
    Province_id INT NOT NULL,                   -- Código de provincia, FK
    Region_id INT NOT NULL,  					-- Código de region, FK
	Taster_id INT NOT NULL,  					-- Código de catador, FK
    Variety_id INT NOT NULL,  					-- Código de variedad de la uva, FK
    Winery_id INT NOT NULL,  					-- Código de bodega que produjo el vino, FK
    DescriptionName VARCHAR(1000) NOT NULL,     -- Descripción (detalle de las notas de cata que utiliza el sommelier para evaluar)
    DesignationName VARCHAR(400) NOT NULL,      -- Designation (viñedo específico dentro de la bogeda)
    Points DECIMAL(5, 2) NOT NULL,   			-- Puntuación (calidad percibida del vino)
    Price DECIMAL(10, 2) NOT NULL,   			-- Precio de una botella de vino
    Title VARCHAR(255) NOT NULL,    			-- Título de la reseña del vino
    PRIMARY KEY (WineReview_id),                -- Define CodWineReview como clave primaria
    FOREIGN KEY (Country_id) REFERENCES Country(Country_id),  -- Define CodCountry como FK
    FOREIGN KEY (Province_id) REFERENCES Province(Province_id),  -- Define CodProvince como FK
    FOREIGN KEY (Region_id) REFERENCES Region(Region_id),  -- Define CodRegion como FK
	FOREIGN KEY (Taster_id) REFERENCES Taster(Taster_id),  -- Define CodTaster como FK
    FOREIGN KEY (Variety_id) REFERENCES Variety(Variety_id),  -- Define CodVariety como FK
    FOREIGN KEY (Winery_id) REFERENCES Winery(Winery_id)  -- Define CodWinery como FK
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# crea la tabla temporal TmpWineData donde se guardan las reseñas recibidas en el dataset 
CREATE TABLE TmpWineData (
    ID INT NOT NULL,                       -- ID del vino
    country VARCHAR(100),                  -- País de origen
    description TEXT,                      -- Descripción del vino
    designation VARCHAR(255),              -- Designación del vino
    points DECIMAL(5, 2), 				   -- Puntuación del vino
    price DECIMAL(10, 2),                  -- Precio del vino
    province VARCHAR(255),                 -- Provincia de origen
    region_1 VARCHAR(255),                 -- Región principal
    region_2 VARCHAR(255),                 -- Región secundaria
    taster_name VARCHAR(100),              -- Nombre del catador
    taster_twitter_handle VARCHAR(100),    -- Twitter del catador
    title VARCHAR(255),                    -- Título del vino
    variety VARCHAR(255),                  -- Variedad de uva
    winery VARCHAR(255),                   -- Nombre de la bodega
    PRIMARY KEY (ID)                       -- Definimos ID como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# IMPORTANTE: los datos recibidos en el dataset se migraron a la tabla temporal TmpWineData 
# mediante el script "1.1 Script_TmpWineData.sql" incluido en otro archivo.

# Inserta los países de la tabla temporal TmpWineData en la tabla Country 
INSERT INTO Country (CountryName)
SELECT DISTINCT Country
FROM TmpWineData 
WHERE Country IS NOT NULL
  AND Country NOT IN (SELECT CountryName FROM Country)
  order by TmpWineData.country;

# Inserta las provincias de la tabla temporal TmpWineData en la tabla Province 
INSERT INTO Province (ProvinceName, Country_id)
  SELECT DISTINCT
    p.Province, 
    c.Country_id
FROM 
    TmpWineData AS p
JOIN 
    Country AS c ON p.Country = c.CountryName 
WHERE p.province IS NOT NULL
  AND p.province NOT IN (SELECT ProvinceName FROM Province);
  
# Inserta las regiones (region_1, region_2) de la tabla temporal TmpWineData en la tabla Region  
INSERT INTO Region (RegionName1, RegionName2, Province_id)
SELECT DISTINCT 
	t.region_1 as regionName1, 
    t_region_2 as regionName2,
    p.Province_id
FROM 
    TmpWineData AS t
JOIN 
    Province AS p ON t.province = p.ProvinceName  -- Relaciona la provincia en TmpWineData con Province
WHERE 
    COALESCE(t.region_1, t.region_2) IS NOT NULL
	AND t.region_1 NOT IN (SELECT RegionName1 FROM Region)
    AND t.region_2 NOT IN (SELECT RegionName2 FROM Region);

# Inserta los catadores desde la tabla temporal TmpWineData a la tabla Taster
INSERT INTO Taster (TasterName, TasterTwitterHandle)
SELECT DISTINCT 
    t.taster_name AS TasterName,
    t.taster_twitter_handle AS TasterTwitterHandle
FROM 
    TmpWineData AS t
WHERE 
    t.taster_name IS NOT NULL OR t.taster_twitter_handle IS NOT NULL; -- Evita registros nulos 

# Inserta la variedad desde la tabla temporal TmpWineData a la tabla Variety
INSERT INTO Variety (VarietyName)
SELECT DISTINCT 
    t.variety AS variety
FROM 
    TmpWineData AS t
WHERE 
    t.variety IS NOT NULL; -- Evita registros nulos 
  
# Inserta la bodega desde la tabla temporal TmpWineData a la tabla Winery
INSERT INTO Winery (WineryName)
SELECT DISTINCT 
    t.winery AS winery
FROM 
    TmpWineData AS t
WHERE 
    t.winery IS NOT NULL; -- Evita registros nulos 
  
# crea la tabla TmpDesignation
CREATE TABLE TmpDesignation (
    Designation_id INT NOT NULL,   -- Código de país, clave primaria y autoincremental
    DesignationName VARCHAR(100) NOT NULL,       -- Viñedo especificó dentro de la bodega 
    PRIMARY KEY (Designation_id)                 -- Define Designation_id como clave primaria
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

##IMPORTANTE: se utilizó el script "1.2 Inserta_Designation.sql" incluido en otro archivo 
## para guardar los datos en la tabla TmpDesignation 

## Actualiza el campo Designation en la tabla TmpWineData utilizando el campo DesignationName de la tabla TmpDesignation 
UPDATE TmpWineData AS w
JOIN TmpDesignation AS d ON d.Designation_id = w.ID
SET w.Designation = d.DesignationName;

## inserto los datos en la tabla maestra WineReview considerando la tabla TmpWineData (dataset) y las tablas creadas 
## para hacer referencia mediante clave foránea. 
INSERT INTO WineReview (Country_id, Province_id, Region_id, Taster_id, Variety_id, Winery_id, 
                        DescriptionName, DesignationName, Points, Price, Title)
SELECT DISTINCT 
	c.country_id,
    p.Province_id, 
	r.Region_id,
    ta.Taster_id,
    v.Variety_id,
    w.Winery_id,
    t.description, 
    t.designation,
    COALESCE(t.points, 0) AS points,
    COALESCE(t.price, 0) AS price,
    t.title
FROM 
    TmpWineData AS t
LEFT JOIN 
    Country AS c ON t.Country = c.CountryName 
LEFT JOIN 
    Province AS p ON t.province = p.ProvinceName 
LEFT JOIN 
    Region AS r ON (t.region_1 = r.RegionName1 AND t.region_2 = r.RegionName2)
LEFT JOIN 
    Taster AS ta ON t.taster_name = ta.TasterName 
LEFT JOIN 
    Variety AS v ON t.variety = v.VarietyName 
LEFT JOIN 
    Winery AS w ON t.winery = w.WineryName; 
    
## CONSULTAS SQL 
-- cantidad de vinos por país 
SELECT c.CountryName as Pais, COUNT(*) AS cantidad_vinos
FROM WineReview wr		-- tabla principal desde donde obtenemos las reseñas
JOIN Country c 			-- realiza join con la tabla desde donde obtenemos los países
on wr.Country_id=c.Country_id	-- relaciona las dos tablas mediante el campo Country_id
GROUP BY c.CountryName			-- agurpa por el nombre del país
ORDER BY cantidad_vinos DESC;   -- ordena por la cantidad de vinos de cada país de forma descendente 

-- variedades de uva más comunes para una región en particular
SELECT vr.VarietyName AS variedad, COUNT(*) AS cantidad
FROM WineReview wr					-- tabla principal con reseñas		
JOIN Variety vr ON wr.Variety_id = vr.Variety_id -- join con tabla Variety mediante Variety_id
JOIN Region r ON wr.Region_id = r.Region_id  -- join con tabla Region mediante Region_id
WHERE r.RegionName1 = 'California'  -- filtra por región igual a California
GROUP BY vr.VarietyName     -- agrupa por la variedad
ORDER BY cantidad DESC;  -- Ordena de mayor a menor cantidad

-- precio promedio de la botella según la calificación obtenida
SELECT wr.points AS calificacion, -- selecciona el puntaje obtenido
format(AVG(wr.Price),2) AS precio_promedio	-- calcula el precio promedio 
FROM WineReview wr
GROUP BY wr.points
ORDER BY calificacion;  -- ordena por calificación

## OTRAS SQL (MULTIDIMENSIONAL)
-- Permite conocer la cantidad de reseñas publicadas (con puntaje 80 o mayor)
SELECT count(*) as CantResPublicadas FROM 
    WineReview AS wr
WHERE WR.POINTS>= 80;

-- Esta consulta extrae 10 reseñas con puntuaje 100, incluyendo información como el país, provincia, región, catador, 
-- variedad de uva, bodega, y detalles de la reseña.
SELECT 
    wr.WineReview_id,              -- ID único de la reseña
    c.CountryName,                 -- Nombre del país
    p.ProvinceName,                -- Nombre de la provincia
    r.RegionName1,                 -- Nombre de la región 
    ta.TasterName,                 -- Nombre del catador
    ta.TasterTwitterHandle,        -- Twitter del catador (si existe)
    v.VarietyName,                 -- Nombre de la variedad de uva
    w.WineryName,                  -- Nombre de la bodega
    wr.DescriptionName,            -- Descripción del vino
    wr.DesignationName,            -- Designación del vino
    wr.Points,                     -- Puntos asignados al vino
    wr.Price,                      -- Precio del vino
    wr.Title                       -- Título de la reseña
FROM 
    WineReview AS wr
LEFT JOIN 
    Country AS c ON wr.Country_id = c.Country_id
LEFT JOIN 
    Province AS p ON wr.Province_id = p.Province_id
LEFT JOIN 
    Region AS r ON wr.Region_id = r.Region_id
LEFT JOIN 
    Taster AS ta ON wr.Taster_id = ta.Taster_id
LEFT JOIN 
    Variety AS v ON wr.Variety_id = v.Variety_id
LEFT JOIN  
    Winery AS w ON wr.Winery_id = w.Winery_id
WHERE WR.POINTS>= 100	-- solo considera aquellos con puntaje igual a 100
limit 10;  -- muestra 10 registros 

-- Calcula el puntaje promedio de los vinos para cada bodega
SELECT 
    w.WineryName as Bodega,                  -- Nombre de la bodega
    FORMAT(AVG(wr.Points), 2) AS PuntajePromedio -- Puntaje promedio de las reseñas
FROM 
    WineReview AS wr
JOIN 
    Winery AS w ON wr.Winery_id = w.Winery_id
GROUP BY 
    w.WineryName;                  -- Agrupa los resultados por bodega

-- Devuelve los 10 catadores que tienen más de 8000 reseñas ordenados por mayor a menor cantidad de reseñas
SELECT 
    ta.TasterName as Catador,                 -- Nombre del catador
    COUNT(wr.WineReview_id) AS TotalResenas   -- Total de reseñas del enólogo
FROM 
    WineReview AS wr
JOIN 
    Taster AS ta ON wr.Taster_id = ta.Taster_id
GROUP BY 
    ta.TasterName                  -- Agrupa los resultados por catador
HAVING 
    TotalResenas > 8000		 -- Filtra para mostrar solo catadores con más de 8000 reseñas
    order by TotalResenas desc -- ordena el resultado de mayor a menor
    limit 10;             -- visualiza solo 10 registros que cumplen con la condición

-- Lista las regiones de un país específico (por ejemplo Argentina)
SELECT 
    r.RegionName1                 -- Nombre de la región
FROM 
    Region AS r
JOIN 
    Province AS p ON r.Province_id = p.Province_id -- join con provincia para unir ambas tablas por Province_id
JOIN 
    Country AS c ON p.Country_id = c.Country_id   -- join con país para unir ambas tablas por Country_id
WHERE 
    c.CountryName = 'Argentina'   -- Filtra para el país Argentina
order by r.RegionName1; -- ordena alfabeticamente

-- Selecciona información detallada de las bodegas, países, regiones y provincias 
-- para los 10 vinos con mayor puntaje
SELECT 
    w.WineryName AS Bodega,              -- Nombre de la bodega
    c.CountryName AS País,               -- Nombre del país
    r.RegionName1 AS Región,             -- Nombre de la región principal
    p.ProvinceName AS Provincia,         -- Nombre de la provincia
    wr.Title AS Título,                  -- Título de la reseña del vino
	FORMAT(wr.Points, 2) AS Puntaje,     --  Puntos asignados al vino
	FORMAT(wr.Price, 2) AS Precio  		 -- Precio de una botella de vino 
FROM 
    WineReview AS wr
JOIN 
    Winery AS w ON wr.Winery_id = w.Winery_id
JOIN 
    Country AS c ON wr.Country_id = c.Country_id
JOIN 
    Province AS p ON wr.Province_id = p.Province_id
JOIN 
    Region AS r ON wr.Region_id = r.Region_id
ORDER BY 
    wr.Points DESC                      -- Ordena por puntaje de mayor a menor
LIMIT 10;                               -- Limita los resultados a los 10 vinos con mayor puntaje

-- Muestra las regiones con al menos 100 bodegas
SELECT 
    r.RegionName1 AS Región,               -- Nombre de la región
    p.ProvinceName AS Provincia,           -- Nombre de la provincia
    c.CountryName AS País,                 -- Nombre del país
    COUNT(DISTINCT w.Winery_id) AS TotalBodegas -- Total de bodegas en la región
FROM 
    Region AS r
JOIN 
    Province AS p ON r.Province_id = p.Province_id
JOIN 
    Country AS c ON p.Country_id = c.Country_id
JOIN 
    WineReview AS wr ON wr.Region_id = r.Region_id
JOIN 
    Winery AS w ON wr.Winery_id = w.Winery_id
GROUP BY 
    r.RegionName1, p.ProvinceName, c.CountryName  -- Agrupa por región, provincia y país
HAVING 
    TotalBodegas >= 100                    -- Filtra para mostrar regiones con 100 o más bodegas
order by totalbodegas desc;

-- Muestra los vinos con precios superiores al promedio
SELECT 
    wr.Title AS Título,                   -- Título de la reseña
    w.WineryName AS Bodega,               -- Nombre de la bodega
    c.CountryName AS País,                -- País del vino
    v.VarietyName AS Variedad,            -- Variedad de uva
    wr.Points AS Puntaje,                 -- Puntos asignados
    wr.Price AS Precio                    -- Precio del vino
FROM 
    WineReview AS wr
JOIN 
    Winery AS w ON wr.Winery_id = w.Winery_id
JOIN 
    Country AS c ON wr.Country_id = c.Country_id
JOIN 
    Variety AS v ON wr.Variety_id = v.Variety_id
WHERE 
    wr.Price > (SELECT AVG(Price) FROM WineReview)  -- Filtra vinos cuyo precio está por encima del promedio
ORDER BY 
    wr.Price DESC;                         -- Ordena de mayor a menor precio

-- muestra 10 reseñas en donde aparecen ciertas notas de cata en el campo Description
-- y el puntaje obtenido es mayor a 95
SELECT wr.WineReview_id, w.WineryName, wr.DescriptionName, wr.DesignationName, wr.points, wr.price, wr.title
FROM WineReview wr
join Winery w 	-- join con la tabla Winery para obtener el nombre de la bodega
on wr.Winery_id=w.Winery_id -- une ambas tablas por el campo Winery_id
WHERE 
   wr.points>95 -- considera solo puntaje mayor a 95
   AND (wr.DescriptionName LIKE '%tasting notes%' -- cita algunas notas de cata para considerar en la búsqueda
   OR wr.DescriptionName LIKE '%fruity%'
   OR wr.DescriptionName LIKE '%floral%'
   OR wr.DescriptionName LIKE '%earthy%'
   OR wr.DescriptionName LIKE '%spicy%'
   OR wr.DescriptionName LIKE '%toasted%'
   OR wr.DescriptionName LIKE '%acidic%'
   OR wr.DescriptionName LIKE '%sweet%'
   OR wr.DescriptionName LIKE '%complex%')
order by wr.price desc
limit 10; -- ordena por precio