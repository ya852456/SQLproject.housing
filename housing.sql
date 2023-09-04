#Name:Tsungyen Chen
#Dataset:nashville_housing
#purpose:organize, standarize and clean the dataset in MySQL


#Standarize the Date in column'SaleDate'

SELECT DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d') FROM project.nashville_housing;

UPDATE project.nashville_housing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d')

#Fill in null value in column'PropertyAddress'

SELECT nullif(PropertyAddress,'') a FROM project.nashville_housing

UPDATE project.nashville_housing
SET PropertyAddress = nullif(PropertyAddress,'')

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IFNULL(a.PropertyAddress,b.PropertyAddress) 
FROM project.nashville_housing a JOIN project.nashville_housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE project.nashville_housing a
JOIN project.nashville_housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL

#Split the PropertyAddress into two columns 'PropertySplitAddress' and 'PropertySplitCity'

SELECT PropertyAddress FROM project.nashville_housing

SELECT substring(PropertyAddress,1,locate(',',PropertyAddress)-1) ,
substring(PropertyAddress,locate(',',PropertyAddress)+1,LENGTH(PropertyAddress)) 
FROM project.nashville_housing

ALTER TABLE project.nashville_housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE project.nashville_housing
SET PropertySplitAddress = substring(PropertyAddress,1,locate(',',PropertyAddress)-1)

ALTER TABLE project.nashville_housing
ADD PropertySplitCity Nvarchar(255)

UPDATE project.nashville_housing
SET PropertySplitCity = substring(PropertyAddress,locate(',',PropertyAddress)+1,LENGTH(PropertyAddress))

#Split the OwnerAddress into three columns 'OwnerSplitAddress','OwnerSplitCity' and 'OwnerSplitState'

SELECT SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state, OwnerAddress
FROM project.nashville_housing;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS city
FROM project.nashville_housing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address
,SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS city
,SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state
FROM project.nashville_housing;

ALTER TABLE project.nashville_housing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE project.nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE project.nashville_housing
ADD OwnerSplitCity Nvarchar(255)

UPDATE project.nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)

ALTER TABLE project.nashville_housing
ADD OwnerSplitState Nvarchar(255)

UPDATE project.nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1)

#Covert 'Y', 'N' to 'Yes' and 'No' in SoldAsVacant column

SELECT DISTINCT SoldAsVacant,COUNT(*) FROM project.nashville_housing GROUP BY SoldAsVacant

SELECT CASE WHEN SoldAsVacant='Y' THEN 'Yes' 
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant END AS SoldAsVacant 
FROM project.nashville_housing

UPDATE project.nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes' 
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant END

#Delete the duplicate rows from the table

DELETE FROM project.nashville_housing
WHERE UniqueID NOT IN (SELECT minID FROM 
(SELECT MIN(UniqueID) AS minID FROM project.nashville_housing GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) AS subquery)

#Drop useless columns

ALTER TABLE project.nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict;

#Select all the data and check if it is clean
SELECT * FROM project.nashville_housing



