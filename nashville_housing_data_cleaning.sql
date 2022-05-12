/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM `bold-vial-345717.nashville_data_cleaning.housing_data` 

-- Standardize Date Format

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN SaleDateConverted Date;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET SaleDateConverted = PARSE_DATE("%B %e, %Y", SaleDate)
WHERE TRUE

-- Populate Property Address data

SELECT *
FROM `bold-vial-345717.nashville_data_cleaning.housing_data`
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `bold-vial-345717.nashville_data_cleaning.housing_data` a
JOIN `bold-vial-345717.nashville_data_cleaning.housing_data` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
  WHERE a.PropertyAddress is null

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data` a
SET PropertyAddress = b.PropertyAddress
FROM (
  SELECT ParcelID, MIN(PropertyAddress) PropertyAddress
  FROM `bold-vial-345717.nashville_data_cleaning.housing_data` 
  WHERE NOT PropertyAddress IS NULL
  GROUP BY ParcelID
) b
WHERE a.ParcelID = b.ParcelID
AND a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM `bold-vial-345717.nashville_data_cleaning.housing_data`
--WHERE PropertyAdress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress,",")-1) as Address
,SUBSTRING(PropertyAddress, STRPOS(PropertyAddress,",")+1, LENGTH(PropertyAddress)) as Address
FROM `bold-vial-345717.nashville_data_cleaning.housing_data`

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN PropertySplitAddress STRING;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress,",")-1)
WHERE TRUE

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN PropertySplitCity2 STRING;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET PropertySplitCity2 = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ",") +1, LENGTH(PropertyAddress))
WHERE TRUE

SELECT 
SPLIT(OwnerAddress, ",") [OFFSET(0)] AS A,
SPLIT(OwnerAddress, ',')[OFFSET(1)] AS B,
SPLIT(OwnerAddress, ',')[OFFSET(2)] AS C
FROM `bold-vial-345717.nashville_data_cleaning.housing_data`

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN OwnerSplitAddress STRING;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET OwnerSplitAddress = SPLIT(OwnerAddress, ",") [OFFSET(0)] 
WHERE TRUE

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN OwnerSplitCity2 STRING;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET OwnerSplitCity2 = SPLIT(OwnerAddress, ',')[OFFSET(1)] 
WHERE TRUE

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data`
ADD COLUMN OwnerSplitState STRING;

UPDATE `bold-vial-345717.nashville_data_cleaning.housing_data`
SET OwnerSplitState = SPLIT(OwnerAddress, ',')[OFFSET(2)]
WHERE TRUE

--Remove Duplicates

CREATE OR REPLACE TABLE `bold-vial-345717.nashville_data_cleaning.housing_data` AS
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID_
    ) AS row_num
FROM `bold-vial-345717.nashville_data_cleaning.housing_data`

--Delete Unused Columns

SELECT * 
FROM `bold-vial-345717.nashville_data_cleaning.housing_data` 

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data` 
DROP COLUMN PropertyAddress

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data` 
DROP COLUMN OwnerAddress

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data` 
DROP COLUMN TaxDistrict

ALTER TABLE `bold-vial-345717.nashville_data_cleaning.housing_data` 
DROP COLUMN row_numSELECT * FROM demo;