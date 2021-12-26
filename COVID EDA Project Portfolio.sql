-- Looking at the entire dataset.
select *
from covid_deaths
order by 3, 4

select *
from covid_vaccinations
order by 3, 4


--1-- Total deaths VS. Total cases [This gives a rough estimate of the chances of dying if you contract COVID across regions].
SELECT location,
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
--WHERE location = 'Nigeria' or location like '%states%' -- We can use the WHERE clause to filter our view, we can filter by various parameters and rows.


--2-- Total cases VS. Population [Shows the percentage of the population that caught the VID]

SELECT location, 
		date, 
		population, 
		total_cases, 
		(total_cases/population)*100 as infection_rate
FROM covid_deaths
-- WHERE location like '%states%'
ORDER BY 2


--3-- Looking at Contries with the Highest deaths recorded.

SELECT continent, location, MAX(CAST(total_deaths AS int)) as total_death_count
FROM covid_deaths
WHERE continent is not null
GROUP BY continent, location
ORDER BY continent, total_death_count desc


--4-- Cummulative Vaccinations VS. Total Population [Using a Common Table Expression]

WITH VaccVsPop (continent, location, date, population, new_vaccinations, cummulative_new_vaccinations)
AS
(
SELECT dea.continent,
		dea.location,
		vac.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(new_vaccinations AS bigint)) OVER	
			(Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_new_vaccinations

FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)

SELECT *, (cummulative_new_vaccinations/population)*100 AS rate_of_vaccination
FROM VaccVsPop


--5-- Creating views for visualizations.

--5a 
CREATE VIEW DeathLikelihood AS
SELECT location,
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths

--5b
CREATE VIEW InfectionRate AS 
SELECT location, 
		date, 
		population, 
		total_cases, 
		(total_cases/population)*100 as infection_rate
FROM covid_deaths
-- WHERE location like '%states%'
--ORDER BY 2 --The ORDER BY clause is invalid in views

--5c
CREATE VIEW TotalDeathCount AS
SELECT continent, location, MAX(CAST(total_deaths AS int)) as total_death_count
FROM covid_deaths
WHERE continent is not null
GROUP BY continent, location
--ORDER BY continent, total_death_count desc

--5d
CREATE VIEW vwVaccVsPop AS

WITH VaccVsPop (continent, location, date, population, new_vaccinations, cummulative_new_vaccinations)
AS
(
	SELECT dea.continent,
		dea.location,
		vac.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(new_vaccinations AS bigint)) OVER	
			(Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_new_vaccinations

	FROM covid_deaths dea
	JOIN covid_vaccinations vac
		ON dea.location = vac.location
		AND	dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)


SELECT *
FROM VaccVsPop
