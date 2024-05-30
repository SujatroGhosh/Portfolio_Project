/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From portfolio.coviddeaths
-- Where continent is not null 
-- order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio.coviddeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio.coviddeaths
Where location like 'India'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolio.coviddeaths
Where location like 'India'
order by 1,2  


Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio.coviddeaths
Where location like 'India'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From portfolio.coviddeaths
-- Where location like 'India' 
Where continent is not null 
Group by location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From portfolio.coviddeaths
-- Where location like 'India'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From portfolio.coviddeaths

where continent is not null 

order by 1,2 



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

-- ,(RollingPeopleVaccinated/population)*100
From portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    portfolio.coviddeaths dea
JOIN 
    portfolio.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    dea.location, dea.date;





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

-- , (RollingPeopleVaccinated/population)*100
From portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- my table 

-- Drop the temporary table if it exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(15, 2),
    New_vaccinations DECIMAL(15, 2),
    RollingPeopleVaccinated DECIMAL(15, 2)
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CASE 
        WHEN vac.new_vaccinations REGEXP '^[0-9]+(\.[0-9]+)?$' 
        THEN CAST(vac.new_vaccinations AS DECIMAL(15, 2)) 
        ELSE 0 
    END AS new_vaccinations,
    SUM(CAST(CASE 
        WHEN vac.new_vaccinations REGEXP '^[0-9]+(\.[0-9]+)?$' 
        THEN vac.new_vaccinations 
        ELSE 0 
    END AS DECIMAL(15, 2))) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    portfolio.coviddeaths dea
JOIN 
    portfolio.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

-- Select data from the temporary table and calculate the percentage
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as


SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CASE 
        WHEN vac.new_vaccinations REGEXP '^[0-9]+(\.[0-9]+)?$' 
        THEN CAST(vac.new_vaccinations AS DECIMAL(15, 2)) 
        ELSE 0 
    END AS new_vaccinations,
    SUM(CAST(CASE 
        WHEN vac.new_vaccinations REGEXP '^[0-9]+(\.[0-9]+)?$' 
        THEN vac.new_vaccinations 
        ELSE 0 
    END AS DECIMAL(15, 2))) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    portfolio.coviddeaths dea
JOIN 
    portfolio.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;



