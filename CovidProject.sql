
--Select * from ProtfolioProject..CovidVaccinations
--order by 3,4



--Select data

--Select Location, date, total_cases, new_cases, total_deaths, population  from ProtfolioProject..CovidDeaths
--order by 1,2




--Looking at total cases vs total deaths
--i cant do it direct totaldeaths/totalcases cuz both are navchar so i should do casting
SELECT Location,date,  total_cases,total_deaths,
       CASE WHEN total_cases <> 0 THEN CAST(total_deaths AS decimal(18,2)) / CAST(total_cases AS decimal(18,2))
            ELSE NULL
       END AS DeathPercentage
FROM ProtfolioProject..CovidDeaths
ORDER BY 1, 2;



-- Looking at total cases vs population
-- Shows what precentage of population get covid
Select Location, date, total_cases,  population, (total_cases/population)*100 as CovidPercentage from ProtfolioProject..CovidDeaths
 order by 1,2



-- Looking at countries with highest infection rate compared with population

Select Location, population, Max(total_cases) as HighestinfectionCount,  Max((total_cases/population))*100 as infectedPercentage from ProtfolioProject..CovidDeaths
group by location,population 
order by  HighestinfectionCount desc



-- See total deaths by the continent


Select location,  Max(cast(total_deaths as int)) as TotalDeathCount from ProtfolioProject..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc


-- showing Countries with highest death count per population
-- where continent is not null because if we remove it, it will show the continent with locations
Select  continent, Max(cast(total_deaths as int)) as TotalDeathCount from ProtfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc



-- Global numbers

SELECT
  SUM(cast(NEW_deaths as int)) AS totaldeaths,
  SUM(new_cases) AS totalcases,
  CASE WHEN SUM(new_cases) = 0 THEN 0
       ELSE (SUM(cast(NEW_deaths as int)) / SUM(new_cases)) * 100
  END AS Deathpercentage
FROM ProtfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(cast(NEW_deaths as int)) > 0 AND SUM(new_cases) > 0  -- I dont want to show zeros in the data
ORDER BY 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as Bigint )) OVER (PARtition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3




-- USE CTE
WITH PopVsVac (Continent, location, date, population,New_Vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as Bigint )) OVER (PARtition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select *,(RollingpeopleVaccinated/population)*100 as percentageVac
from PopVsVac





--Creating View to store data for visualization
Create VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as Bigint )) OVER (PARtition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
