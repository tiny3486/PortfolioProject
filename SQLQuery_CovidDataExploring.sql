

--1. Table CovidDeaths

select *
from [Portfolio Project]..CovidDeath
order by 3,4




select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeath
where continent is not null
order by 1,2

-- Death percentage of Vietnam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeath
where location like 'vietnam'
order by 1,2

-- Total cases vs the poplulation 
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as imfected_percentage, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeath
where location like 'vietnam'
and continent is not null


-- Countries with the highest imfection rate
select location, date, population, total_cases,(total_cases/population)*100 as imfected_percentage
from [Portfolio Project]..CovidDeath
where continent is not null
order by 5



-- Countries with the highest imfection rate
select location, population, max(total_cases) as highest_imfection_count, max((total_cases/population)*100) as highest_imfected_percentage, max((total_deaths/total_cases)*100) as highest_deathvsimfection
from [Portfolio Project]..CovidDeath
where continent is not null
group by location, population 
order by 3 desc

-- Convert nvarchar into integer
select location, population, max(cast (total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeath
where continent is not null
group by location, population 
order by 3 desc



-- EXPLORE NUMBER OF CONTINENT
select location, max(cast (total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeath
where continent is null
group by location
order by 2 desc

select continent, max(cast (total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeath
where continent is not null
group by continent

--EXPLORE THE GLOBAL DATA

select date sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
from [Portfolio Project]..CovidDeath
where continent is not null
group by date 
order by date

-- 2. Table CovidVaccinations
select *
from [Portfolio Project]..CovidVaccinations

select *
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--total population have vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2 



--ROOLING PEOPLE VACCINATED (update the number of vaccinated people by date)
--USING CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.date) 
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100 
from PopVsVac

--TEMP TABLE
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as numeric)) over (partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/population)*100 
from #PercentPeopleVaccinated






-- CREATING A VIEW TO STORE DATA

CREATE VIEW PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(numeric, vac.new_vaccinations)) over 
(partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPeopleVaccinated
