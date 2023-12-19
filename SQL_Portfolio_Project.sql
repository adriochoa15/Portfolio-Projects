
select * from
coviddeaths d
where continent is not null
order by d.location, d.date


--select * from
--CovidVaccinations v
--order by v.location, v.date


--- Selecting the data needed
select d.location, d.date, d.total_cases, d.new_cases, d.total_deaths, d.population
from CovidDeaths d
where continent is not null
order by d.location, d.date



--- Total cases vs. Total Deaths 
--- Death Percentage shows the likelihood of dying if you contract covid in your country
select d.location, d.date, d.total_cases, d.total_deaths, 
--(d.total_deaths/d.total_cases) *100 as DeathPercentage
(CONVERT(float, d.total_deaths) / NULLIF(CONVERT(float, d.total_cases), 0)) * 100 AS Deathpercentage
from CovidDeaths d
where d.location = 'united states' and continent is not null
order by d.location, d.date




--- Total cases vs. Population
select d.location, d.date, d.total_cases, d.population, 
--(d.total_deaths/d.total_cases) *100 as DeathPercentage
(CONVERT(float, d.total_cases) / NULLIF(CONVERT(float, d.population), 0)) * 100 AS Deathpercentage
from CovidDeaths d
where d.location = 'united states' and continent is not null
order by d.location, d.date




--- Looking at countries with highest infection rates related to population
select d.location, d.population, max(d.total_cases) as HighestInfectionCount, 
--(d.total_deaths/d.total_cases) *100 as DeathPercentage
max((CONVERT(float, d.total_cases) / NULLIF(CONVERT(float, d.population), 0))) * 100 AS PercentageInfected
from CovidDeaths d
where continent is not null
--where d.location = 'united states'
group by d.location, d.population
order by PercentageInfected desc




--- Looking at data by continent
select d.location, MAX(d.total_deaths) as TotalDeaths
from CovidDeaths d
where continent is null
group by d.location
order by TotalDeaths desc




--- Looking at countries with the highest death rates per population
select d.location, MAX(d.total_deaths) as TotalDeaths
from CovidDeaths d
where continent is not null
group by d.location
order by TotalDeaths desc



--- Looking at the global numbers
select d.date, sum(d.new_cases) TotalCases, SUM(new_deaths) TotalDeaths,
(sum(convert(float, d.new_deaths) / NULLIF(CONVERT(float, d.new_cases), 0))) * 100 DeathPercentage
from CovidDeaths d
where continent is not null
group by d.date
order by 1,2



select sum(d.new_cases) TotalCases, SUM(new_deaths) TotalDeaths,
(sum(convert(float, d.new_deaths) / NULLIF(CONVERT(float, d.new_cases), 0))) * 100 DeathPercentage
from CovidDeaths d
where continent is not null
order by 1,2





select d.continent, d.location, d.date, d.population, v.new_vaccinations,
--SUM(convert(float, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)
SUM(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingCountVaccinations
 from CovidVaccinations v
join CovidDeaths d
on v.date = d.date and v.location=d.location
where d.continent is not null
order by 1,2,3




-- CTE


with PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingCountVaccinations)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingCountVaccinations
 from CovidVaccinations v
join CovidDeaths d
on v.date = d.date and v.location=d.location
where d.continent is not null
--order by 2,3
)
select *, (nullif(CONVERT(float, RollingCountVaccinations), 0)) / Population * 100 as PercentagePeopleVaccinated
from PopulationvsVaccination




--- TEMP TABLE

DROP TABLE #PercentPopulationVaccinated

CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountVaccinations numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingCountVaccinations
 from CovidVaccinations v
join CovidDeaths d
on v.date = d.date and v.location=d.location
where d.continent is not null
order by 2,3


select *, (nullif(CONVERT(float, RollingCountVaccinations), 0)) / Population * 100 as PercentagePeopleVaccinated
from #PercentPopulationVaccinated



--- Creating a data views for visualizations
Create View PercentagePeopleVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingCountVaccinations
 from CovidVaccinations v
join CovidDeaths d
on v.date = d.date and v.location=d.location
where d.continent is not null
--order by 2,3


select * from
PercentagePeopleVaccinated