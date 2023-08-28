
select *
from [portfolio Projects]..CovidDeaths
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio Projects]..CovidDeaths
Where continent is not null 
order by 1,2

Select Location,date,total_cases,total_deaths,(CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS Deathpercentage
From [portfolio Projects]..CovidDeaths
Where location like '%states%'
order by 1,2


Select Location,date,total_cases,population,(CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0))*100 AS Deathpercentage
From [portfolio Projects]..CovidDeaths
Where location like '%states%'
order by 1,2


Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0)))*100 AS PercentPopulationInfected
From [portfolio Projects]..CovidDeaths
Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio Projects]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


select *
from [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 --Creating View to store data for later visualizations

 Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio Projects]..CovidDeaths dea
Join [portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated 




