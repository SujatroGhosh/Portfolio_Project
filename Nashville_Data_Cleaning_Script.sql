/*

Cleaning Data in SQL Queries

*/


Select *
From portfolio.nashville 

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedSaleDate
FROM portfolio.nashville
LIMIT 0, 200;

ALTER TABLE portfolio.nashville DROP COLUMN SaleDateConverted;

-- Add the new column to hold the converted dates
ALTER TABLE portfolio.nashville ADD SaleDateConverted DATE;

-- Update the new column with the converted dates
UPDATE portfolio.nashville
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d, %Y');


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From portfolio.nashville
Where PropertyAddress is null
order by ParcelID

Select PropertyAddress
From portfolio.nashville
Where PropertyAddress is null




Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio.nashville a
JOIN portfolio.nashville b
	on a.ParcelID = b.ParcelID
	AND a.[Unique_ID] <> b.[Unique_ID]
Where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio.nashville a
JOIN portfolio.nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From portfolio.nashville
-- Where PropertyAddress is null
order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address1,
    SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1) AS Address2
FROM portfolio.nashville;

ALTER TABLE portfolio.nashville DROP COLUMN PropertySplitAddress;

ALTER TABLE nashville
Add PropertySplitAddress varchar(255);

Update nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)

ALTER TABLE portfolio.nashville DROP COLUMN PropertySplitCity;
ALTER TABLE nashville
Add PropertySplitCity varchar(255);

Update nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1)




Select *
From portfolio.nashville





Select OwnerAddress
From portfolio.nashville



-- mysql implem
SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Part1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Part2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS Part3
FROM portfolio.nashville;



ALTER TABLE nashville
Add OwnerSplitAddress varchar(255);

Update nashville
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)


ALTER TABLE nashville
Add OwnerSplitCity varchar(255);

Update nashville
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)



ALTER TABLE nashville
Add OwnerSplitState varchar(255);

Update nashville
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)



Select *
From portfolio.nashville




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio.nashville
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolio.nashville


Update nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					Unique_ID
					) row_num

From portfolio.nashville
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From portfolio.nashville




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From portfolio.nashville


ALTER TABLE portfolio.nashville
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;


ALTER TABLE portfolio.nashville
DROP COLUMN SaleDateTemp;

































