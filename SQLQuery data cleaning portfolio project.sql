--select everything to look at the data

select *
from PortfolioProject.dbo.NashvilleHousing

--converting the SaleDate datetime format to date format

select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

	-- updating the SaleDate column

--update NashvilleHousing
--set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing 
add SaleDateConverted Date 

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--populate property address data 

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

-- the ParcelId field can be used to populate empty address data when to where the parcel id is the same for an entry with address and one without it 

--self join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress --, isnull(a.PropertyAddress, b.PropertyAddress) will be used to update null property addresses
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
-- if the parcels id are equal but the unique ids are different 
where a.PropertyAddress is null 

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- separating the address data in columns (address, city)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

--taking the coma as a delimiter

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(225)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(225)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

-- chekcing if the changes took place 

select PropertySplitAddress, PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing

-- separating the owner address data in columns (address, city and state)

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(225)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(225)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(225)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

-- chekcing if the changes took place 

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject.dbo.NashvilleHousing

-- change Y and N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end 
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end 

-- removing the duplicates 
-- identifying identical rows

WITH DuplicateCheckCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
select *
from DuplicateCheckCTE
where row_num > 1

-- Remove unused columns

select * 
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddres, TaxDistrict, PropertyAddress, SaleDate
