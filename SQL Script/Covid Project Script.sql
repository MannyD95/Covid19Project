
/* COVID-19 EDA AND DATA VISUALIZATION PROJECT QUERY INDEX 
   CONCEPTS COVERED INCLUDE: Joins, Windows, Aggregating Data, CTE, Data Conversion */

/* 

Testing that the TABLES were successfully uploaded 
SELECT * FROM vidproject.covidvaccinations
SELECT * FROM vidproject.coviddeaths 

*/

-- Looking at Total Cases, Total Deaths, as well as likelihood that you would have been infected in your country over the its lifetime.

SELECT location, continent, date, population, total_cases, new_cases, total_deaths, (total_cases/population)*100 AS percent_infected
FROM vidproject.coviddeaths
WHERE continent <> ''
ORDER BY LOCATION, date

-- Focusing on Infection Rate Specifically

SELECT location, max((total_cases/population)*100) AS percent_infected
FROM VidProject.coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY location

-- Being More Specific and Getting Parameters Related to Map Visualization (DATA VIZ 3/4)

WITH KeyIndicators (Location, Population, TotalCases, InfectionRate, DeathCount, TotalVaccinated, TotalFullyVaccinated)
AS
(
SELECT cd.location, population, max(total_cases), Max((total_cases/population))*100 AS percent_pop_infected, max(total_deaths),
	max(cv.people_vaccinated), max(cv.people_fully_vaccinated)
FROM vidproject.coviddeaths cd
JOIN VidProject.covidvaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> ''
GROUP BY cd.location, population
)
SELECT *
FROM  KeyIndicators



/*  DATA VIZ: Stacked Bar Chart for Daily Value Comparsion of: New Cases, Deaths, People Vaccinated, Fully Vaccinated. 
	Total Number of New Vaccinations Will be Line Graph Following The Bar Charts) */
	

SELECT cd.location, cd.date, cd.new_deaths, cd.new_cases, cv.people_fully_vaccinated, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)  AS RollingVaxxTotal
FROM VidProject.coviddeaths cd
JOIN VidProject.covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
-- WHERE cd.location = 'World'
WHERE cd.continent <> ''
ORDER BY cd.location, cd.date

-- Above for Continents

SELECT cd.location, cd.date, cd.new_deaths, cd.new_cases, cv.people_fully_vaccinated, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)  AS RollingVaxxTotal
FROM VidProject.coviddeaths cd
JOIN VidProject.covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
-- WHERE cd.location = 'World'
WHERE cd.continent = ''
ORDER BY cd.location, cd.date


/* GETTING AGGREGRATE DATA TO POTENTIALLY COMPARSION AGAINST BASELINE VALUES */

-- Summed Values on a Global Scale 

SELECT Max(population), SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as UNSIGNED)) as DeathTotal, SUM(CAST(new_deaths as UNSIGNED))/SUM(New_Cases)*100 as DeathRate,
	 max(cv.people_vaccinated) AS VaccinatedPopulation, max(cv.people_fully_vaccinated) AS FullyVaccinatedPopulaton
FROM VidProject.coviddeaths cd
JOIN VidProject.covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.location = 'World'
ORDER BY 1,2 

-- Values on a Country by Country Scale (Above but not summed)

SELECT cd.location, Max(cd.population), SUM(cd.new_cases) AS TotalCases, SUM(CAST(cd.new_deaths as UNSIGNED)) as DeathTotal, 
	SUM(CAST(cd.new_deaths as UNSIGNED))/SUM(cd.New_Cases)*100 as DeathRate, max(cv.people_vaccinated) AS VaccinatedPopulation , max(cv.people_fully_vaccinated) AS FullyVaccinatedPopulaton
FROM VidProject.coviddeaths cd
JOIN VidProject.covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
WHERE cd.continent <> ''
GROUP BY 1
ORDER BY 1,2 


/* EXPLORATORY QUERIES THAT MAY OR MAY NOT BE USED FOR VISUALIZING */

-- Indicators on Continental Scale

SELECT cd.location, population, max(total_cases), Max((total_cases/population))*100 AS percent_pop_infected, max(total_deaths),
	max(cv.people_vaccinated), max(cv.people_fully_vaccinated)
FROM vidproject.coviddeaths cd
JOIN VidProject.covidvaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent = ''
GROUP BY cd.location, population

-- Calc Percent of Population That Has been Vaccinated Based on Total Vaccinations with a CTE

With HerdImmunity (Location, Date, Population, NewVaccinations, TotalVaccinations)
AS
(
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)  AS RollingVaxxTotal
FROM VidProject.coviddeaths cd
JOIN VidProject.covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
-- WHERE cd.location = 'World'
WHERE cd.continent <> ''
ORDER BY cd.location, cd.date
)
SELECT *, (TotalVaccinations/Population)*100 AS PercentVaccinated
FROM HerdImmunity




