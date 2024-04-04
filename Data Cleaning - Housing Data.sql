CREATE DATABASE housing;

CREATE TABLE housing (
  UniqueID INT NOT NULL,
  ParcelID VARCHAR(255) DEFAULT NULL,
  LandUse VARCHAR(255) DEFAULT NULL,
  PropertyAddress VARCHAR(255) DEFAULT '0',
  SaleDate DATE DEFAULT NULL,
  SalePrice BIGINT NOT NULL,
  LegalReference VARCHAR(255) DEFAULT NULL,
  SoldAsVacant VARCHAR(255) DEFAULT NULL,
  OwnerName VARCHAR(255) DEFAULT NULL,
  OwnerAddress VARCHAR(255) DEFAULT NULL,
  Acreage DECIMAL(5,2)  DEFAULT '0.00',
  TaxDistrict VARCHAR(255) DEFAULT NULL,
  LandValue INT DEFAULT NULL,
  BuildingValue INT DEFAULT NULL,
  TotalValue INT DEFAULT NULL,
  YearBuilt INT DEFAULT '0',
  Bedrooms VARCHAR(5) DEFAULT NULL,
  FullBath VARCHAR(100) DEFAULT NULL,
  HalfBath VARCHAR(100) DEFAULT NULL,
  Street VARCHAR(100) DEFAULT NULL,
  City VARCHAR(100) DEFAULT NULL,
  State VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (UniqueID)
);




-- Incorrect date format so I would convert to default format.------------------------
UPDATE housing 
SET 
    SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'),'%Y-%m-%d');





-- Change SaleDate format to date---------------------------------
ALTER TABLE housing
MODIFY SaleDate DATE;




-- PropertyAddresses are missing--------------------------------
SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
CASE
 WHEN TRIM(a.PropertyAddress) = '' THEN b.PropertyAddress
 ELSE a.PropertyAddress
END AS address_populate
FROM 
    housing a
JOIN 
    housing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE 
     TRIM(a.PropertyAddress) = '';
     
     
     
     

-- Update PropertyAddress where it is empty.--------------------------------
UPDATE housing a
JOIN housing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = CASE
 WHEN TRIM(a.PropertyAddress) = '' THEN b.PropertyAddress
 ELSE a.PropertyAddress
END
WHERE TRIM(a.PropertyAddress) = '';

-- Break address into individual columns.---------------------------------
SELECT
SUBSTRING_INDEX(OwnerAddress, ',',1) AS street,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2), ',',-1) AS City,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',3), ',',-1) AS State
FROM housing;

ALTER TABLE housing
ADD COLUMN Street VARCHAR(100);

UPDATE housing
SET Street = SUBSTRING_INDEX(OwnerAddress, ',',1);

ALTER TABLE housing
ADD COLUMN City  VARCHAR(100),
ADD COLUMN State VARCHAR(100);

UPDATE housing
SET City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2), ',',-1);

UPDATE housing
SET State = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',3), ',',-1);

SELECT * FROM housing;

-- Change abbreviation to word.-------------------------------------------
UPDATE housing
SET SoldAsVacant= (CASE 
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'YES'
ELSE SoldAsVacant
END);

-- Remove Duplicates JUST FOR PRACTICE.
WITH RowNum AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelId,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY
                UniqueID) AS row_num  FROM housing
 )
SELECT * 
FROM RowNum
WHERE row_num > 1;
                
DELETE FROM housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelId,
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num  
        FROM housing
    ) AS RowNum
    WHERE row_num > 1
);
               
-- Now that duplicates are removed, UniqueId can be set as Primary Key.------------------------------------            
ALTER TABLE housing
MODIFY UniqueID INT NOT NULL PRIMARY KEY;

-- Conversion of other columns to their proper data types.-------------------------------------------------

-- SalePrice column.----------------------------------------------------
UPDATE housing
SET SalePrice = REPLACE(SalePrice, ',', '');

UPDATE housing
SET SalePrice = REPLACE(SalePrice, '$', '');

ALTER TABLE housing
MODIFY SalePrice BIGINT NOT NULL;

-- Acreage.--------------------------
UPDATE housing
SET Acreage = NULLIF(TRIM(REPLACE(Acreage, ',', '')), '');

ALTER TABLE housing
MODIFY Acreage DECIMAL(5,2) DEFAULT 0 ;

-- YearBuilt.--------------------------
UPDATE housing
SET YearBuilt = NULLIF(TRIM(REPLACE(YearBuilt, ',', '')), '');

ALTER TABLE housing
MODIFY COLUMN YearBuilt INT DEFAULT 0000;

-- LandValue.--------------------------------
UPDATE housing
SET LandValue = NULLIF(TRIM(REPLACE(LandValue, ',', '')), '');

ALTER TABLE housing
MODIFY COLUMN LandValue INT;

-- BuildingValue-------------------------------------
UPDATE housing
SET BuildingValue = NULLIF(TRIM(REPLACE(BuildingValue, ',', '')), '');

ALTER TABLE housing
MODIFY COLUMN BuildingValue INT;

-- TotalValue------------------------------


UPDATE housing
SET TotalValue = NULLIF(TRIM(REPLACE(TotalValue, ',', '')), '');

alter table housing
modify COLUMN TotalValue int;

select * from housing
order by UniqueID;