Select * from PortfolioProject..CovidDeaths

Select * from PortfolioProject..CovidVaccinations

Select Location, Date, CONVERT(float, total_cases) AS Total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
--where not continent = '' 
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
where Location = 'United States'
order by 1,2


--Looking at the Total Cases vs Population
-- Shows what percentage of population got covid
Select Location, Date, Population, total_cases,  
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(CONVERT(float,total_cases)) AS HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc


--Showing countries with the Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where not continent = '' 
group by location
order by TotalDeathCount desc


--Breaking things down by the Continent 
--Showing the continents with the Total Death Count
Select Continent, SUM(cast(new_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where not continent = '' 
group by Continent
order by TotalDeathCount desc


--Global numbers
--Total cases each day across the world
Select Date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  
SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where not continent = '' 
group by Date
order by 1,2


--Total cases overall across the world
Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  
SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where not continent = '' 
--group by Date
order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where not dea.continent = '' 
order by 2,3


--Rolling People Vaccinated Count for every location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where not dea.continent = '' 
order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where not dea.continent = '' 
)
Select * , (RollingPeopleVaccinated/NULLIF(CONVERT(float, population), 0))*100
from PopvsVac


--Use Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
Select dea.Continent,  dea.Location, dea.Date, CONVERT(bigint, dea.Population), CONVERT(bigint, vac.new_vaccinations),
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where not dea.continent = '' 

Select * , (RollingPeopleVaccinated/NULLIF(population, 0))*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where not dea.continent = ''

Select * from PercentPopulationVaccinated