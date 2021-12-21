select *
from portfolioproject..NashvillHousing

--std sales date-------------------------------------------------------------

select SaleDate, CONVERT(date,SaleDate)
from portfolioproject..NashvillHousing

UPDATE NashvillHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvillHousing
Add SaleDateCon Date;
UPDATE NashvillHousing
SET SaleDateCon = CONVERT(date,SaleDate) -- Final update

-- Property Address ----------------------------------------------------------

SELECT PropertyAddress
from portfolioproject..NashvillHousing

SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID,nh2.PropertyAddress,ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
from portfolioproject..NashvillHousing nh1
--ORDER BY ParcelID
JOIN portfolioproject..NashvillHousing nh2
    on nh1.ParcelID = nh2.ParcelID AND nh1.[UniqueID ] <> nh2.[UniqueID ]
	where nh1.PropertyAddress is null

UPDATE nh1
SET PropertyAddress= ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
from portfolioproject..NashvillHousing nh1
JOIN portfolioproject..NashvillHousing nh2
    on nh1.ParcelID = nh2.ParcelID AND nh1.[UniqueID ] <> nh2.[UniqueID ]
	where nh1.PropertyAddress is null

-- splitting property adress--

SELECT PropertyAddress
from portfolioproject..NashvillHousing

SELECT PARSENAME(REPLACE(PropertyAddress,',','.'),1)
from portfolioproject..NashvillHousing


ALTER TABLE NashvillHousing
Add PropertyAddressSplit Nvarchar(255);
UPDATE NashvillHousing
SET PropertyAddressSplit = PARSENAME(REPLACE(PropertyAddress,',','.'),2)

ALTER TABLE NashvillHousing
Add PropertyAddressCity Nvarchar(255);
UPDATE NashvillHousing
SET PropertyAddressCity = PARSENAME(REPLACE(PropertyAddress,',','.'),1)

SELECT PropertyAddress,PropertyAddressSplit,PropertyAddressCity  --Final update
from portfolioproject..NashvillHousing

--Splitting ownwer address----------------------------------------------------

SELECT OwnerAddress
from portfolioproject..NashvillHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
from portfolioproject..NashvillHousing

ALTER TABLE portfolioproject..NashvillHousing                 --Final update
Add OwnerAddressState Nvarchar(255);
UPDATE portfolioproject..NashvillHousing
SET OwnerAddressState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE portfolioproject..NashvillHousing
Add OwnerAddressCity Nvarchar(255);
UPDATE portfolioproject..NashvillHousing
SET OwnerAddressCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE portfolioproject..NashvillHousing
Add OwnerAddressPlace Nvarchar(255);
UPDATE portfolioproject..NashvillHousing
SET OwnerAddressPlace = PARSENAME (REPLACE(OwnerAddress,',','.'),3) 

--CHANGING Y AND N IN SOLD AS VACANT--------------------------------------------

SELECT DISTINCT (SoldAsVacant)
from portfolioproject..NashvillHousing

SELECT SoldAsVacant
,CASE When SoldAsVacant='Y' Then 'Yes'
      When SoldAsVacant='N' Then 'No'
      ELSE SoldAsVacant
 END
from portfolioproject..NashvillHousing

UPDATE portfolioproject..NashvillHousing                       --Final update
SET SoldAsVacant = CASE When SoldAsVacant='Y' Then 'Yes'
                        When SoldAsVacant='N' Then 'No'
                        ELSE SoldAsVacant
                        END
from portfolioproject..NashvillHousing

--REMOVE DUPLICATE-----------------------------------------------------------------

SELECT *,
		ROW_NUMBER() over (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
		)row_no
from portfolioproject..NashvillHousing
ORDER BY ParcelID

--CREATING CTE
WITH RowNumCte AS (
	SELECT *,
		ROW_NUMBER() over (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
		)row_no
from portfolioproject..NashvillHousing
--ORDER BY ParcelID
)
DELETE
from RowNumCte
where row_no > 1
ORDER BY PropertyAddress   
-- VERIFICATION--
SELECT *
from RowNumCte
where row_no > 1

--DELETE UNUSED COLUMN---------------------------------------------------------------

select *
from portfolioproject..NashvillHousing

ALTER TABLE portfolioproject..NashvillHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate  -- final update
