/*
	Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

---------------------------------------------------------------


/*
	Standarize Data Format
*/

-- Add Updated Column
ALTER TABLE NashvilleHousing
ADD SaleDateModified date 

-- Update the new Column with the converted value
Update NashvilleHousing
SET SaleDateModified = CONVERT(date, SaleDate)


SELECT 
SaleDate , SaleDateModified
From NashvilleHousing

---------------------------------------------------------------

/*
	Populate Property Address data
*/


SELECT 
*
From NashvilleHousing
-- WHERE PropertyAddress IS NULL
order by ParcelID


SELECT 
	a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress, 
	isnull(a.PropertyAddress, b .PropertyAddress)
From 
	NashvilleHousing as a
Join
	NashvilleHousing as b 
	ON  a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Update Property Address 
Update a
SET PropertyAddress   
	= ISNULL(a.PropertyAddress, b .PropertyAddress)
From 
	NashvilleHousing as a
Join
	NashvilleHousing as b 
	ON  a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------

-- Breaking out Address into Individual Columns ( Address, City, State )
 
SELECT PropertyAddress
FROM NashvilleHousing

Order By ParcelID

SELECT 
		SUBSTRING(PropertyAddress, CHARINDEX(' ',PropertyAddress) + 1, CHARINDEX(',',PropertyAddress) -1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address nvarchar(255),
	State nvarchar(255)

-- Updating Values in new Columns
Update NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

-- Show Results
SELECT PropertyAddress,Address, State
FROM NashvilleHousing

---------------------------------

-- Breaking out OwnerAddress into Individual Columns ( Address, City, State )

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ', ', '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ', ', '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ', ', '.'),1) as State
FROM NashvilleHousing

-- ADDING a new Columns to recieve splited DATA
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

-- Updating the new columns with new splited data
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ', ', '.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ', ', '.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ', ', '.'),1)

-- Check if everything is OKAY
SELECT OwnerSplitAddress,OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

/*
	CHANGE Y AND N IN "Sold As Vacant" to Yes and No
*/

-- Show Data in Columns  
SELECT 
    distinct(SoldAsVacant)
FROM NashvilleHousing
   

-- update data in table with replacement Values
Update NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN  'Yes'
		WHEN SoldAsVacant = 'N' THEN  'NO'
	END 
WHERE SoldAsVacant = 'N' OR SoldAsVacant = 'Y';

-- check if the updated is right
SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)as Count
FROM NashvilleHousing
group by SoldAsVacant ;

-----------------------------------------------------

-- Remove Duplicates

with ShowDublicated as 
(SELECT * , ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID 
) as RowNum

FROM NashvilleHousing

)

DELETE FROM ShowDublicated
Where RowNum > 1

--------------------------------------------------------------
/*
	Deleting Unused Columns
*/

SELECT * FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
