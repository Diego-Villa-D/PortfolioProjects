-- Data exploration using BigQuery

-- Dataset overview

SELECT * 
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
ORDER BY 1, 2


-- Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
WHERE location = 'Mexico'
AND continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
--WHERE location = 'Mexico'
ORDER BY 1, 2


-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 AS percent_population_infected
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
--WHERE location = 'Mexico'
GROUP BY location, population
ORDER BY percent_population_infected DESC


-- Countries with highest death count per population

SELECT location, population, MAX(total_deaths) AS highest_death_count,  MAX((total_deaths/population))*100 AS percent_population_dead
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_dead DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with highest death count per population

SELECT continent, MAX(total_deaths) AS highest_death_count,  MAX((total_deaths/population))*100 AS percent_population_dead
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY percent_population_dead DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` 
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_new_v
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` AS dea
JOIN `covid-project-434023.COVID_Datasets.COVID_Vaccination` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  AS rolling_count_new_v
  FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` AS dea
  JOIN `covid-project-434023.COVID_Datasets.COVID_Vaccination` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_count_new_v/population)*100 AS percentage_pop_vaccinated
FROM pop_vs_vac;


-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE TEMPORARY TABLE Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_new_v
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` AS dea
JOIN `covid-project-434023.COVID_Datasets.COVID_Vaccination` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (rolling_count_new_v/population)*100 AS percentage_pop_vaccinated
FROM Percent_Population_Vaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW `covid-project-434023.COVID_Datasets.Percent_Population_Vaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_new_v
FROM `covid-project-434023.COVID_Datasets.COVID_Deaths` AS dea
JOIN `covid-project-434023.COVID_Datasets.COVID_Vaccination` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM `covid-project-434023.COVID_Datasets.Percent_Population_Vaccinated`
