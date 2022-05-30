use PortfolioProject_1;

select * from CovidDeaths
where continent is not null
order by location,date;

select * from CovidVaccinations
where continent is not null
order by location,date;

---select data that we are going to be using
select location,date, total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by location,date;

---looking at total case/total deaths
select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%' and continent is not null
order by location,date;

---looking at total case/population
---Shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
from CovidDeaths
where location like '%states%' and continent is not null
order by location,date;

---looking at countries with highest infection rate compared to population
select location,MAX(total_cases) as maxtotalcases,population,MAX(total_cases/population)*100 as MaxCasePercentage
from CovidDeaths
where continent is not null
group by location, population
order by MaxCasePercentage desc;


---looking at countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as maxtotaldeaths
from CovidDeaths
where continent is not null
group by location
order by maxtotaldeaths desc;


---lets break down and filter with continent
select continent,MAX(cast(total_deaths as int)) as maxtotaldeaths
from CovidDeaths
where continent is not null
group by continent
order by maxtotaldeaths desc;

---let's break down with location, while continent is null
select location,MAX(cast(total_deaths as int)) as maxtotaldeaths
from CovidDeaths
where continent is null
group by location
order by maxtotaldeaths desc;

---Showing contients with highest death count per population
select continent,MAX(cast(total_deaths as int)) as maxtotaldeaths
from CovidDeaths
where continent is not null
group by location
order by maxtotaldeaths desc;

---global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by total_cases,total_deaths;


---Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,
dea. Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac. location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated;

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac

	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

