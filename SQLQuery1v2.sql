select location, date, total_cases, new_cases, total_deaths, population
from portofolioproject..CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portofolioproject..CovidDeaths$
order by 1,2

select location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
from portofolioproject..CovidDeaths$ 
order by 1,2

select location, population, max(total_cases) as HighestinfectionCount, max((total_deaths/population))*100 as PercentPopulationInfected
from portofolioproject..CovidDeaths$ 
group by location, population
order by PercentPopulationInfected desc

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from portofolioproject..CovidDeaths$ 
where continent is not null
group by location
order by TotalDeathsCount desc

select *
from portofolioproject..CovidDeaths$
where continent is not null


select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from portofolioproject..CovidDeaths$ 
where continent is not null
group by continent
order by TotalDeathsCount desc

select date , sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from portofolioproject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from portofolioproject..CovidDeaths$
where continent is not null
order by 1,2

select *
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date)
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select 
from PopvsVac



create table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated


create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from portofolioproject..CovidDeaths$ as dea
join portofolioproject..CovidVaccinations$ as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentpopulationvaccinated