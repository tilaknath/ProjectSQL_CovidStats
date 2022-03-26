select *
from project..CovidDeaths
order by  3,4
--select *
--from project..CovidVaccinations
--order by 3,4

select location, date,total_cases,new_cases,total_deaths, population
from project..CovidDeaths
order by 1,2

--Querying Total Cases VS Total Deaths
--Showing the likelyhood of dying if one contract covid in India

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from project..CovidDeaths
where location='India'
order by 1,2

--Querying Total Cases vs Population
--Depicts the percentage of population conracted with covid
--Till 23rd March, 2022, 4.3 crores of people (3.08%) of India is being infected with Covid

select location, date,population,total_cases,(total_cases/population)*100 as Infected_percentage
from project..CovidDeaths
where location='India'
order by 1,2

--Countries with Highest Infection rate
select location,population, max (total_cases) as Highest_Infection_Count, max((total_cases/population)
)*100 as Infected_percentage
from project..CovidDeaths
group by population,location
order by Infected_percentage desc

--Countries with Highest Death count per Population
select location,population, max (cast(total_deaths as int)) as Total_Death_Count
from project..CovidDeaths
where continent is not null
group by population,location
order by Total_Death_Count desc

--Continents with Highest Death count per Population
select location, max (cast(total_deaths as int)) as Total_Death_Count
from project..CovidDeaths
where continent is null
group by location
order by Total_Death_Count desc

--Continents with Highest Death count per Population #2
select continent, max (cast(total_deaths as int)) as Total_Death_Count
from project..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc

-- Global Numbers (Finding the Death Percentage per day) 
select date, sum(new_cases) as Totalcases,sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from Project..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Total Population vs Vaccination Table (Country Wise)
select D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM(cast(V.new_vaccinations as bigint))
over (partition by D.location order by D.location,D.date) as Cummilative_Vaccinations
from project..CovidDeaths D
join project..CovidVaccinations V
on D.location=V.location
and D.date=V.date
where D.continent is not null
order  by 2,3;

--USE CTE
with popvsvac (continent, location,date,population,new_vaccinations,Cummilative_Vaccinations)
as
(
select D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM(cast(V.new_vaccinations as bigint))
over (partition by D.location order by D.location,D.date) as Cummilative_Vaccinations
from project..CovidDeaths D
join project..CovidVaccinations V
on D.location=V.location
and D.date=V.date
where D.continent is not null)
--order  by 2,3)
Select *,(Cummilative_Vaccinations/population)*100 as Cummilative_Percentage
from popvsvac
--where location='India'


--Temp Table
drop table if exists populationVaccinated
Create table populationVaccinated
(continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Cummilative_Vaccinations numeric)

Insert into populationVaccinated
select D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM(cast(V.new_vaccinations as bigint))
over (partition by D.location order by D.location,D.date) as Cummilative_Vaccinations
from project..CovidDeaths D
join project..CovidVaccinations V
on D.location=V.location
and D.date=V.date
where D.continent is not null
--order  by 2,3

Select *,(Cummilative_Vaccinations/population)*100 as Cummilative_Percentage
from populationVaccinated
--where location='India'



-- creating view to store data for data visualization
drop view if exists Vaccinated_count;



GO
create view
Vaccinated_count as
select D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM(cast(V.new_vaccinations as bigint))
over (partition by D.location order by D.location,D.date) as Cummilative_Vaccinations
from project..CovidDeaths D
join project..CovidVaccinations V
on D.location=V.location
and D.date=V.date
where D.continent is not null
--order  by 2,3
Go

Select *
from Vaccinated_count
drop view if exists Death_numbers_byContinent;

Go
create view Death_numbers_byContinent as
select location, max (cast(total_deaths as int)) as Total_Death_Count
from project..CovidDeaths
where continent is null
group by location
--order by Total_Death_Count desc
Go
select * from Death_numbers_byContinent