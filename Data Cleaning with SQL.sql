/*

CLEANING DATA IN SQL QUERIES

*/

------------------------------------------------------------------------------------

--Standardize Date Format


SELECT SaleDate FROM PortfolioProject.dbo.NashvilleHousing$;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN IF EXISTS SaleDate;

--Can't rename column with alter Table in Sql Server. Instead we use a store procedure in SSMS called 'sp_rename'
EXEC sp_rename 'SaleDateConverted', 'SaleDate', 'COLUMN';

SELECT SaleDate FROM  PortfolioProject.dbo.NashvilleHousing;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS