--Codes for Tableau Visualization (since I do not have a Paid Tableau subscription, 
--I'll be transferring the results to Excel and upload to Tableau Public

--Vizualization 1, this will have total_cases worldwide, total_deaths Worldwide and a Death Percentage Calculation

Select SUM(new_cases) Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 Death_Percentage
From CovidDeaths
Where continent is not null
order by 1,2

--Vizualization 2 Total Death Count per Continent, sorted from highest to lowest

SELECT Location, SUM(cast(new_deaths as int)) as Total_Death_Count
From CovidDeaths
Where continent is null
and Location not in ('European Union', 'World', 'International')
Group by location
Order by Total_Death_Count desc

--Visualization 3 selects total infection count, and percentage of population infected
Select Location, population, MAX(Total_Cases) as Highest_Infection_Count, MAX(Total_Cases)/Population*100 as Population_Infected_Percentage
From CovidDeaths
Group by Location, Population
order by Population_Infected_Percentage desc

--Visualization 4 same as 3 but includes dates

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as Population_Infected_Percentage
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by Population_Infected_Percentage desc

-- Link for Tableau Public project, https://public.tableau.com/app/profile/diego2348/viz/Covid2021PortfolioProject/Dashboard1
