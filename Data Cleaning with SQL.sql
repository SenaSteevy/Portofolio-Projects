/*

CLEANING DATA IN SQL QUERIES

*/

------------------------------------------------------------------------------------

--Standardize Date Format


SELECT SaleDate FROM PortfolioProject.dbo.NashvilleHousing$;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ALTER COLUMN  SaleDate  Date;

SELECT TOP(10) * FROM PortfolioProject.dbo.NashvilleHousing$;

------------------------------------------------------------------------------------

-- Populate Property Address data : Some propertyAddress are NULL and have same ParcelID with non null PropertyAddress value 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.uniqueID <> b.uniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.uniqueID <> b.uniqueID
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------

--Breaking out Address into individual columnw (Address, City, State)

SELECT PropertyAddress FROM PortfolioProject.dbo.NashvilleHousing$;

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing$;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD  PropertySplitAddress Nvarchar(255), PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1 ),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT* FROM PortfolioProject.dbo.NashvilleHousing$


SELECT OwnerAddress FROM PortfolioProject.dbo.NashvilleHousing$

--For OwnerAddress we will use PARSENAME function : it split the given string by period (.)
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject.dbo.NashvilleHousing$


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD OwnerSplitAddress Nvarchar(255), OwnerSplitCity Nvarchar(255), OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM PortfolioProject.dbo.NashvilleHousing$


------------------------------------------------------------------------------------

--Change  Y and N to Yes and No in "Sold as Vacant" field

SELECt DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing$

SELECT SoldAsVacant,  
(CASE WHEN SoldAsVacant  LIKE 'Y' THEN 'Yes'
	WHEN SoldAsVacant  LIKE 'N' THEN 'No' 
	END) AS SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing$
WHERE SoldAsVacant IN ('Y', 'N')

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET SoldAsVacant = (CASE WHEN SoldAsVacant  LIKE 'Y' THEN 'Yes' WHEN SoldAsVacant  LIKE 'N' THEN 'No'  END)
FROM PortfolioProject.dbo.NashvilleHousing$
WHERE SoldAsVacant IN ('Y', 'N')

SELECt DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing$


------------------------------------------------------------------------------------

-- Remove duplicate rows 

WITH RowOccurenceCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing$ )
SELECT * FROM RowOccurenceCTE
WHERE row_num > 1

-- With that done above we just need to delete those multiple occurence 
WITH RowOccurenceCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing$ )
DELETE
FROM RowOccurenceCTE
WHERE row_num > 1


------------------------------------------------------------------------------------

-- Delete unused columns
SELECT * FROM PortfolioProject.dbo.NashvilleHousing$ ;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress
