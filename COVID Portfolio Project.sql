USE portfolioproject;

SELECT *
FROM coviddeathscsv;

SELECT *
FROM covidvaccinationscsv
ORDER BY 3,4;

/* selection of data to use */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeathscsv
ORDER BY 1,2;

/* Checking out Total Cases vs Total Deaths */
/*Likelihood of dying if you get infected in your country*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeathscsv
WHERE location like '%spain%'
ORDER BY 1,2;


/* Checking out Total Cases vs Population */
/* Shows what percentage of population got Covid */
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPoPulationInfected
FROM coviddeathscsv
/* WHERE location like '%spain%' */
ORDER BY 1,2;

/* Looking at countries with highest infection rate compared to population */

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 AS PercentPoPulationInfected
FROM coviddeathscsv
GROUP BY location, population
ORDER BY PercentPoPulationInfected DESC;

/* Showing countries with highest death count per population */

SELECT location, max(cast(total_deaths as unsigned)) as TotalDeathCount
FROM coviddeathscsv
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


/* Breaking things down by continent */
/* Showing continents with the highest death count per population */
SELECT continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
FROM coviddeathscsv
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

/* GLOBAL NUMBERS */
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, 
sum(cast(new_deaths as unsigned))/sum(new_cases)*100 AS DeathPercentage
FROM coviddeathscsv
WHERE continent is not null
/*GROUP BY date*/  
ORDER BY 1,2;


/*Looking at Total Poulation vs Vaccinations*/

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as unsigned))OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
/* (RollingPeopleVaccinated/population)*100 */
FROM coviddeathscsv dea
INNER JOIN covidvaccinationscsv vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT null
ORDER BY 2,3;


/* USE CTE */

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as unsigned))OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
/* (RollingPeopleVaccinated/population)*100 */
FROM coviddeathscsv dea
INNER JOIN covidvaccinationscsv vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT null)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

/* Creating View to store data for later visualizations */

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as unsigned))OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
/* (RollingPeopleVaccinated/population)*100 */
FROM coviddeathscsv dea
INNER JOIN covidvaccinationscsv vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT null;

SELECT *
FROM PercentPopulationVaccinated;





