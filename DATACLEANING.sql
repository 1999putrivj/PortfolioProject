select * 
from portofolioproject..NashvilleHousing


select SaleDate, convert(Date,SaleDate)
from portofolioproject..NashvilleHousing

update NashvilleHousing
set SaleDate - convert(Date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted Date;


update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)


select SaleDateConverted, convert(Date,SaleDate)
from portofolioproject..NashvilleHousing


select *
from portofolioproject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from portofolioproject..NashvilleHousing as a
join portofolioproject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from portofolioproject..NashvilleHousing as a
join portofolioproject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


select PropertyAddress
from portofolioproject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as address
from portofolioproject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);


update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 


select *
from portofolioproject..NashvilleHousing


select owneraddress
from portofolioproject..NashvilleHousing


select
PARSENAME(replace(owneraddress, ',','.'), 3)
,PARSENAME(replace(owneraddress, ',','.'), 2)
,PARSENAME(replace(owneraddress, ',','.'), 1)
from portofolioproject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',','.'), 3) 


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);


update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',','.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);


update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',','.'), 1)


select *
from portofolioproject..NashvilleHousing


select distinct (soldasvacant), count(soldasvacant)
from portofolioproject..NashvilleHousing
group by soldasvacant 
order by 2


select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
	   else soldasvacant
	   end
from portofolioproject..NashvilleHousing


update NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
	   else soldasvacant
	   end



with rownumCTE AS(
select *,
	row_number() over (
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueid
					) row_num

from portofolioproject..NashvilleHousing)

select *
from rownumCTE
where row_num > 1
order by PropertyAddress


select *
from portofolioproject..NashvilleHousing


alter table portofolioproject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table portofolioproject..NashvilleHousing
drop column SaleDate