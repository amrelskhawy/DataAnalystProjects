-- Select Data We will be Using 

SELECT *
FROM CovidDeaths
where continent is not null
order by 1, 2;

-- Looking at total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,
(total_deaths / total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location  like '%states%' and continent is not null
order by 1, 2;


-- Looking at total Cases Vs Population
-- Shows that percentage of population got covid 

SELECT location, date, population, total_cases,
(total_cases / population) * 100 As InfectionPercentage
From CovidDeaths
where continent is not null

-- Looking Countries Highest Infection Rate Compared To Population

SELECT location,  population,
MAX(total_cases) As Highest,
MAX((total_cases / population) * 100) as InfectionPercentage
FROM CovidDeaths
where continent is not null
GROUP BY location , population
order by InfectionPercentage desc;

-- showing Countries whith Highest Death Count per Population

SELECT location,
MAX(cast(total_deaths as int)) As TotalDeathCount
FROM CovidDeaths 
where continent is not null 
GROUP BY location 
order by TotalDeathCount desc;

-- Break Things Down by Continent


-- Show the continent by the highest total death count
SELECT continent,
max(cast(total_deaths as int)) As TotalDeathCount
FROM CovidDeaths 
where continent is  null 
GROUP BY continent 
order by TotalDeathCount desc;

-- Global Numbers

SELECT  
	--date,
	sum(new_cases) AS New_Cases,
	sum(cast(new_deaths as int)) AS New_Deaths,
	sum(cast(new_deaths as int)) / sum(new_cases) * 100  AS DeathPercentage
FROM 
	CovidDeaths
WHERE 
	continent is not null
--GROUP BY
--	date
order by
	1, 2


-- USE CTE

With PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacinated )
as
-- Looking At Total Population VS Vacinations
(
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location
	order by d.location, d.date
	) as RollingPeopleVacinated
FROM
	PortfolioProject..CovidDeaths d
INNER JOIN
	PortfolioProject..CovidVaccinations v
ON
	d.location = v.location AND d.date = v.date
WHERE 
	d.continent is not null
--ORDER BY
	--2,3
)

Select * , (RollingPeopleVacinated / population ) *100
From PopvsVac;


--TEMP TABLE 

Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVacinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location
	order by d.location, d.date
	) as RollingPeopleVacinated
FROM
	PortfolioProject..CovidDeaths d
INNER JOIN
	PortfolioProject..CovidVaccinations v
ON
	d.location = v.location AND d.date = v.date
WHERE 
	d.continent is not null
--ORDER BY
	--2,3


Select * , (RollingPeopleVacinated / population ) *100
From #PercentPopulationVaccinated;


-- Creating View of store data for later  visualization


Create View PercentPopulationVaccinated as
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location
	order by d.location, d.date
	) as RollingPeopleVacinated
FROM
	PortfolioProject..CovidDeaths d
INNER JOIN
	PortfolioProject..CovidVaccinations v
ON
	d.location = v.location AND d.date = v.date
WHERE 
	d.continent is not null
-- ORDER BY 2,3


Select * FROM PercentPopulationVaccinated;