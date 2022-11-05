use PortfolioProject;






--- Select the data that we are going to be using

select location, date, total_cases,new_cases,total_deaths, population
from CovidDeath
order by 1,2


---- Total cases vs total death
---Shows likelihood of daying if you contract covid in your country
select location, date, total_cases,total_deaths, (CAST(total_deaths as real)/CAST(total_cases as real)) * 100 as "DeahPersontage"
from CovidDeath
where location like '%algeria%'
and continent is not null
order by 1,2



-- Looking at the Total Cases vs Population
--- Shows what percentage of population got covid
select location, date,population, total_cases, (CAST(total_cases as real)/CAST(population as real)) * 100 as "PercentPopulationInfected"
from CovidDeath
--where location like '%algeria%'
where continent is not null
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to population
select location, population,  MAX(total_cases) as "HighestInfection", MAX((CAST(total_cases as real)/CAST(population as real)) * 100) as "PercentPopulationInfected"
from CovidDeath
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death count per popumation 
select location, population,MAX(CAST(total_deaths as real))  as "TotalDeathCount", MAX((CAST(total_deaths as real)/CAST(population as real)) * 100) as "PercentPopulationDeaed"
from CovidDeath
where continent is not null
Group by location, population
order by "TotalDeathCount" desc

select location,MAX(CAST(total_deaths as real))  as "TotalDeathCount"
from CovidDeath
where continent is not null
Group by location
order by "TotalDeathCount" desc


-- Showing Continents with the Highest Death count per population 
select location,MAX(CAST(total_deaths as real))  as "TotalDeathCount"
from CovidDeath
where continent is null
Group by location
order by "TotalDeathCount" desc




-- Global  Numbers
select date, SUM(CAST(new_cases as real)) as "TotalCases", SUM(CAST(new_deaths as real)) as "TotalDeath", (SUM(CAST(new_deaths as real)) / SUM(CAST(new_cases as real))) * 100 as "DeathPercentage"
--,total_deaths, (CAST(total_deaths as real)/CAST(total_cases as real)) * 100 as "DeahPersontage"
from CovidDeath
--where location like '%algeria%'
where continent is not null
group by date
order by 1,2

select  SUM(CAST(new_cases as real)) as "TotalCases", SUM(CAST(new_deaths as real)) as "TotalDeath", (SUM(CAST(new_deaths as real)) / SUM(CAST(new_cases as real))) * 100 as "DeathPercentage"
--,total_deaths, (CAST(total_deaths as real)/CAST(total_cases as real)) * 100 as "DeahPersontage"
from CovidDeath
--where location like '%algeria%'
where continent is not null
--group by date
order by 1,2





-- Total population vs vaccinations 
select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as  real )) 
over (partition by dea.location order by dea.location,dea.date) as "RollingPeopleVaccinated"
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeath as "dea"
inner join  CovidVaccination as "vac" 
on vac.location = dea.location and vac.date=dea.date
where  dea.continent is not null
order by 2,3



-- Use CTE
with PopvsVac (Continent, Location,Date, Population, NewVaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as  real )) 
over (partition by dea.location order by dea.location,dea.date) as "RollingPeopleVaccinated"
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeath as "dea"
inner join  CovidVaccination as "vac" 
on vac.location = dea.location and vac.date=dea.date
where  dea.continent is not null
--order by 2,3
 )
 select *,  (RollingPeopleVaccinated / Population) *100
 from  PopvsVac
 order by 2,3



-- Temp Table 
Drop Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric,
)
 insert into #PercentpopulationVaccinated
 select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as  real )) 
over (partition by dea.location order by dea.location,dea.date) as "RollingPeopleVaccinated"
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeath as "dea"
inner join  CovidVaccination as "vac" 
on vac.location = dea.location and vac.date=dea.date
where  dea.continent is not null
--order by 2,3

 select *,  (RollingPeopleVacinated / Population) *100
 from  #PercentpopulationVaccinated
 order by 2,3





 -- Creating View to store for later visualization 

 Create View PercentpopulationVaccinated as
 select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as  real )) 
over (partition by dea.location order by dea.location,dea.date) as "RollingPeopleVaccinated"
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeath as "dea"
inner join  CovidVaccination as "vac" 
on vac.location = dea.location and vac.date=dea.date
where  dea.continent is not null
--order by 2,3

select * from PercentpopulationVaccinated
order by 2,3
