/* Cleaning Data in SQL Project */

Select * from PortfolioProjects.dbo.NashvilleHousing
--Standardizing the SaleDate Format
Select SaleDate,CONVERT(Date, SaleDate) from PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Property Address Data Population

--Select * from PortfolioProjects..NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID
--This gives the insight that certain data can be same parcel ID hence have same address

--Keeping that in mind, we can do is join the table on to itself
--based on its parcel id and then check address


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- This query joins the table to itself, identifies the property address that is missing and checks for common parcelID

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking Address into Individual Colummms Address, City and State

Select PropertyAddress From NashvilleHousing

--this is selecting the substring that is in property address until the comma is spotted
SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select * from NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Doing the above process to the owner address using a different parse way

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--2 things to take note off
--1. PARSENAME ONLY WORKS ON PERIOD hence we converted our ',' to '.'
--2 It works left to right, so 1 would last thing in that line

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select * from NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------------------------------
--Converting the data into Uniform
--SoldasVacant Field has 4 options Yes, Y, No and N
--We will try to make it uniform by making it 2 answers only

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by 2


--Select SoldAsVacant,
--CASE When SoldAsVacant = 'Y' THEN 'YES'
--	 When SoldAsVacant = 'N' THEN 'NO'
--	 ELSE SoldAsVacant
--	 END
--from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates 
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
PropertyAddress, 
SalePrice, 
SaleDate, 
LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
DELETE from RowNumCTE 
where row_num > 1
--order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------
--Deleting the Data that is repetitive and columns that were added.
SELECT * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

---------------------------------------------------------------------------------------------------------------------------------------------------