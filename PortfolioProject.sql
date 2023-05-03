Select * from CovidDeaths
Where continent is not Null  -- this gets rid on values with a continent name or world in the location column
order by 3,4 

--Select * from CovidVaccinations$
--order by 3,4 

Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths, it Shows the Likelihood of Dying if you contracted covid
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidDeaths
Where location like '%France%'
order by 1,2

--Total Cases vs Population, this shows what % of population has contracted covid
Select Location, Date, Population, total_cases, (total_cases/population)*100 as Population_Percentage
From CovidDeaths
--Where location like '%France%'
order by 1,2

--Looking at countries with highest infection rates as compared to population
Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Population_Infection_Percentage
From CovidDeaths
Group by Location, Population
order by Population_Infection_Percentage desc

--Looking at countries with highest death count as compared to population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount  --cast is used to change the data type of a column
From CovidDeaths
Where continent is not Null 
Group by Location
order by TotalDeathCount desc

--Looking at Continent with highest death count as compared to population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths
Where continent is not Null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS of TOTAL CASES AND TOTAL DEATHS PER DAY
Select date,SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- GLOBAL NUMBERS of TOTAL CASES AND TOTAL DEATHS Worldwide
Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From CovidDeaths
Where continent is not null
order by 1,2


Select *
From CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac. location
and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast (vac.new_vaccinations as int)) OVER(Partition by dea.location	Order by dea.location, dea.date) as rolling_people_vaccinated
From CovidDeaths as dea
join CovidVaccinations as vac
	ON dea.location = vac. location
	and dea.date = vac.date
Where dea.continent is not Null
order by 2,3 

--USE CTE

With Popvsvac (continent,location,date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast (vac.new_vaccinations as int)) OVER(Partition by dea.location	Order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
From CovidDeaths as dea
join CovidVaccinations as vac
	ON dea.location = vac. location
	and dea.date = vac.date
Where dea.continent is not Null
--order by 2,3 
)
Select *, (rolling_people_vaccinated/population)*100 as rolling_people_vaccinated_percent
From Popvsvac

--TEMP TABLE	

DROP TABLE IF EXISTS #PercentPoplationVaccinated
	Create Table #PercentPoplationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	rolling_people_vaccinated numeric,
	)

	Insert into #PercentPoplationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(cast (vac.new_vaccinations as int)) OVER(Partition by dea.location	Order by dea.location, dea.date) as rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
	From CovidDeaths as dea
	join CovidVaccinations as vac
		ON dea.location = vac. location
		and dea.date = vac.date
	Where dea.continent is not Null
	Select *, (rolling_people_vaccinated/population)*100 as rolling_people_vaccinated_percent
	From #PercentPoplationVaccinated

--Creating View to store data for later visualization
Create View PercentPoplationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast (vac.new_vaccinations as int)) OVER(Partition by dea.location	Order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
From CovidDeaths as dea
join CovidVaccinations as vac
	ON dea.location = vac. location
	and dea.date = vac.date
Where dea.continent is not Null
--order by 2,3

Select *
From PercentPoplationVaccinated