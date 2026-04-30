/* 

Cleaning data using SQL queries

*/

Select *
From portfolio_project..Nashville_housing

--------------------------------------------------------------------------------------------------------------

-- Standardize the data format

Select SaleDate, CONVERT(date, SaleDate)
From portfolio_project..Nashville_housing

ALTER TABLE Nashville_housing 
ALTER COLUMN SaleDate DATE --Alter datatype from datetime to date

--------------------------------------------------------------------------------------------------------------

-- Populate property address data

Select *
From portfolio_project..Nashville_housing
--Where PropertyAddress is null
Order by ParcelID

--Join the table to itself to find nulls and their property address
	ON a.ParcelID = b.ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..Nashville_housing a
JOIN portfolio_project..Nashville_housing b 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--populate null with its property address
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From portfolio_project..Nashville_housing a
JOIN portfolio_project..Nashville_housing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--double check to ensure there are no more nulls
Select *
From portfolio_project..Nashville_housing
Where PropertyAddress is null

--------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

--Property address
Select PropertyAddress
From portfolio_project..Nashville_housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- Take the string before the comma as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address --take the string after comma as city
From portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing --add new column for address
Add property_split_address Nvarchar(255);

Update portfolio_project..Nashville_housing -- insert the address
Set property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE portfolio_project..Nashville_housing --add new column for city
Add property_split_city Nvarchar(255);

Update portfolio_project..Nashville_housing -- insert the city
Set property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- check the new columns
Select *
From portfolio_project..Nashville_housing


-- Owner address

Select OwnerAddress
From portfolio_project..Nashville_housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) --parsename only look for period. change all commas to periods.
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) --parsename has reverse index for object, so 1 is actually -1
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing --add new column for address
Add owner_split_address Nvarchar(255);

Update portfolio_project..Nashville_housing -- insert the address
Set owner_split_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE portfolio_project..Nashville_housing --add new column for city
Add owner_split_city Nvarchar(255);

Update portfolio_project..Nashville_housing -- insert the city
Set owner_split_city= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE portfolio_project..Nashville_housing --add new column for state
Add owner_split_state Nvarchar(255);

Update portfolio_project..Nashville_housing -- insert the state
Set owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--check new columns
Select *
From portfolio_project..Nashville_housing

--------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant) --we can see there are more yes and no compared to Y and N. lets change all to yes and no
From portfolio_project..Nashville_housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolio_project..Nashville_housing

Update portfolio_project..Nashville_housing --make the changes
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------

-- Remove duplicates


-- find duplicates and assign number to them. Use CTE then delete the duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From portfolio_project..Nashville_housing
)
Delete
From RowNumCTE
Where row_num > 1




--------------------------------------------------------------------------------------------------------------

-- Delete unused columns

Select *
From portfolio_project..Nashville_housing


Alter table portfolio_project..Nashville_housing
Drop column PropertyAddress, TaxDistrict, OwnerAddress
