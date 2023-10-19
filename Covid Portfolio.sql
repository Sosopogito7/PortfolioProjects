Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..[Covid Vaccinations 2019-2021]
--order by 3,4

--select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

Select Location,date, total_cases,total_deaths,
(CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2



-- Looking at the Total Cases vs Populations

Select Location, date, Population, total_cases,(total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
--Where location like '%philippines%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Popluation

Select Location, Population, Max(total_cases) as HighestInfectionCount,MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
--Where location like '%philippines%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Displaying Countries with Highest Death Count per Population

Select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
--Where location like '%philippines%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent 
-- Showing continents with the highest death count per population

Select location, Max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
--Where location like '%philippines%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking down Global Numbers

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
 Where continent is not null
 Group by date
order by 1,2

--Global Cases from 2019-2021

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
 Where continent is not null
--Group by date
order by 1,2

-- Continue at 51:20
Select*
from PortfolioProject..[Covid Vaccinations 2019-2021]
Join PortfolioProject..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..[Covid Vaccinations 2019-2021] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..[Covid Vaccinations 2019-2021] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVAC (Continent, location, date, population, New_vaccination, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..[Covid Vaccinations 2019-2021] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVacinated/population)*100
from PopvsVAC

-- Temp Table 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..[Covid Vaccinations 2019-2021] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating Visualizaion 

Use PortfolioProject
Go
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..[Covid Vaccinations 2019-2021] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 

Select*
from PercentPopulationVaccinated 
