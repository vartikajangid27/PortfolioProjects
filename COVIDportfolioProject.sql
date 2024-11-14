
USE PortfolioProject;
select count(*) from coviddeaths1;
select count(*) from covidvaccinations1;
select * from covidvaccinations1;
SELECT * FROM covidvaccinations1 ;


SELECT * FROM coviddeaths1
ORDER BY 3,4;


SELECT * FROM covidvaccinations1
ORDER BY 3,4;

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT * 
FROM coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
ORDER BY 3,4;

SELECT location, `date`, total_cases, new_cases,total_deaths, population
FROM coviddeaths1
ORDER BY 1,2;

/*SELECT location, YEAR(`date`),SUM(total_cases) AS total_cases_sum
FROM coviddeaths1
GROUP BY location, YEAR(`date`);*/

-- LOOKING AT SUM OF TOTAL DEATH LOCATION -- 
SELECT location,SUM(total_cases) AS total_cases_sum
FROM coviddeaths1
GROUP BY location
order by total_cases_sum desc;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS -- 

SELECT location,`date`,total_cases ,total_deaths, (total_deaths/total_cases)*100 as percent_of_death
FROM coviddeaths1;


-- Looking at toal cases vs population 
-- shows what percentage of population got covid
SELECT location,`date`,total_cases ,population,  (total_cases/population)*100 as percent_of_death
FROM coviddeaths1
WHERE location LIKE 'India'
ORDER BY 1,2;

SELECT location,`date`,total_cases ,population,  (total_cases/population)*100 as percent_of_death
FROM coviddeaths1
-- WHERE location LIKE 'India'
ORDER BY 1,2;


-- LOOKING AT COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,population,MAX(total_cases) AS total_cases_max, (MAX(total_cases)/population)*100 as percent_of_infected
FROM coviddeaths1
GROUP BY location,population
ORDER BY percent_of_infected desc;

-- SHOWING COUNTRIES WITH HIGHEST DEADTH COUNT PER POPULATION
SELECT location,MAX(cast(total_deaths as UNSIGNED)) AS total_death_count
FROM coviddeaths1
GROUP BY location
ORDER BY total_death_count desc;

-- BREAK THINGS DOWN BY CONTINENT -- 

SELECT continent,MAX(cast(total_deaths as UNSIGNED)) AS total_death_count
FROM coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count desc;


SELECT location,MAX(cast(total_deaths as UNSIGNED)) AS total_death_count
FROM coviddeaths1
-- WHERE continent != '' or  continent IS NOT NULL 
GROUP BY location
ORDER BY total_death_count desc;
 
-- SHOWING CONTINENTS WITH THW HIGHEST DEATH COUNT PER POPUALTION

SELECT continent,MAX(cast(total_deaths as UNSIGNED)) AS total_death_count
FROM coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count desc;

-- GLOBAL NUMBERS 
SELECT `date`,total_cases ,total_deaths, (total_deaths/total_cases)*100 as percent_of_death
FROM coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
GROUP BY `date`
ORDER BY 1,2;

SELECT  `date`, SUM(new_cases) AS total_new_cases, SUM(new_deaths ) as total_new_deaths, SUM(new_deaths)/SUM(new_cases) *100 as Deathpercentage
from coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
GROUP BY `date`
ORDER BY 1,2;

-- overall world --
SELECT  SUM(new_cases) AS total_new_cases, SUM(new_deaths) as total_new_deaths, SUM(new_deaths)/SUM(new_cases) *100 as Deathpercentage
from coviddeaths1
WHERE continent != '' AND continent IS NOT NULL 
-- GROUP BY `date`
ORDER BY 1,2;

-- COVID CACCINATION --
-- JOINING 2 TABLES -- 

SELECT * 
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date;

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT cdea.continent, cdea.location, cdea.date, cdea.population, avac.new_vaccinations
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date
ORDER BY 1,2,3;

SELECT cdea.continent, cdea.location, cdea.date, cdea.population, avac.new_vaccinations,
SUM(avac.new_vaccinations) OVER(PARTITION BY cdea.location order by cdea.location, cdea.date) AS Rolling_vacinnation
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date
WHERE cdea.continent != '' AND cdea.continent IS NOT NULL 
ORDER BY 2,3;

-- USE CTE --
WITH populationvsvasci  (Continent, Location, Date, Population, New_vaccinations, Rolling_vacinnation) AS
(
	SELECT cdea.continent, cdea.location, cdea.date, cdea.population, avac.new_vaccinations,
SUM(avac.new_vaccinations) OVER(PARTITION BY cdea.location order by cdea.location, cdea.date) AS Rolling_vacinnation
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date
WHERE cdea.continent != '' AND cdea.continent IS NOT NULL 
-- ORDER BY 2,3
)
SELECT *, (Rolling_vacinnation/Population)*100
FROM populationvsvasci;

-- TEMP TABLE -- 

CREATE TABLE PopulationVaccinatedPercentage
(
	continent varchar(255),
    Location varchar(255),
    Date TEXT,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO PopulationVaccinatedPercentage 
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, avac.new_vaccinations,
SUM(avac.new_vaccinations) OVER(PARTITION BY cdea.location order by cdea.location, cdea.date) AS RollingPeopleVaccinated
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date
 ;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopulationVaccinatedPercentage;

-- CREATING  VIEW  TO STORE DATA FOR VISUALISATIONS-- 

CREATE VIEW PercentagePopulationVaccinated AS
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, avac.new_vaccinations,
SUM(avac.new_vaccinations) OVER(PARTITION BY cdea.location order by cdea.location, cdea.date) AS Rolling_vacinnation
FROM coviddeaths1 cdea
JOIN covidvaccinations1 avac 
	ON cdea.location = avac.location
    AND cdea.date = avac.date
WHERE cdea.continent != '' AND cdea.continent IS NOT NULL ;

SELECT * 
FROM PercentagePopulationVaccinated;


/* OTHER findings
SELECT location,SUM(total_cases) AS total_cases_sum, SUM(total_deaths) AS total_death_sum, (SUM(total_deaths)/SUM(total_cases))*100 as percent_of_death
FROM coviddeaths1
GROUP BY location;
*/








