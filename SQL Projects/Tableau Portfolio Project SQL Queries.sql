/*

Queries used for Tableau Project

*/


-- 1. Global Numbers
Select SUM(CONVERT(int, new_cases)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where not continent = ''
--Group By date
order by 1,2


-- 2. Total Death Count Per Continet
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent = ''
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Percent Population Infected Per Country
Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount,  
Max((cast(total_cases as int)/NULLIF(cast(population as float), 0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Percent Population Infected
Select Location, Population,date, MAX(cast(total_cases as int)) as HighestInfectionCount, 
Max((cast(total_cases as int)/NULLIF(cast(population as float), 0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc