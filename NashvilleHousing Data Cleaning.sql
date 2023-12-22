--Standardize date format
SELECT SaleDateConverted, CONVERT(DATE,SaleDate) 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Breaking out Address into indivdual colums (Address, City)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing

SELECT *
FROM PortfolioProject..NashvilleHousing

--Using PARSENAME to breakout address, city, state
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)	
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

SELECT *
FROM PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END

--Remove duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHeRE row_num >1

--Delete unused colums
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN	OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN	SaleDate