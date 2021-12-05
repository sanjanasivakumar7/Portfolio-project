  select *
  from portfolioproject..['owid-covid-death']
  order by 3,4

   select *
  from portfolioproject..['owid-covid-vacc']
  order by 3,4

  --selecting data for use
  select location, date,total_cases,new_cases,total_deaths,population
  from portfolioproject..['owid-covid-death']
  order by 1,2

  --TOTAL CASE Vs TOTAL DEATH
  select location, date,total_cases,total_deaths,population, (cast (total_deaths as int)/total_cases)*100 as death_percentage
  from portfolioproject..['owid-covid-death']
  order by 1,2

  --TOTAL CASE Vs POPULATION
    select location, date,total_cases,total_deaths,population, (cast (total_cases as int)/population)*100 as death_percentage
  from portfolioproject..['owid-covid-death']
  order by 1,2

  --HIGHEST INFECTION RATE
  select location,population,max(total_cases) as highestinfectionrate, max((total_cases/population))*100 as ppl
  from portfolioproject..['owid-covid-death']
  group by location,population
  order by ppl desc

  --DEATH COUNT
  select location,max(cast(total_deaths as int)) as deathcount
  from portfolioproject..['owid-covid-death']
  where continent is not null
  group by location
  order by deathcount desc

  --BREAKDOWN BY CONTINENT
    select continent,max(cast(total_deaths as int)) as deathcount_c
  from portfolioproject..['owid-covid-death']
 -- where continent is not null
  group by continent
  order by deathcount_c desc

  --GLOBAL
  select date, sum(cast(new_cases as int)) as totcase,sum(cast(new_deaths as int)) as totdeath, sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as deathper
  from portfolioproject..['owid-covid-death']
  where continent is not null
  group by date
  order by 1,2

 select *
 from portfolioproject..['owid-covid-death'] dea
 join portfolioproject..['owid-covid-vacc'] vacc
 on dea.location=vacc.location and dea.date=vacc.date
 where dea.continent is not null

 select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations
 ,sum (cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingvacc
 from portfolioproject..['owid-covid-death'] dea
 join portfolioproject..['owid-covid-vacc'] vacc
 on dea.location = vacc.location and dea.date = vacc.date
 where dea.continent is not null 
 order by 2,3

 --USING CTE
 with popvsvac(continent,location,date,population,rollingvacc,new_vaccinations) as
 (
  select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations
 ,sum (cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingvacc
 from portfolioproject..['owid-covid-death'] dea
 join portfolioproject..['owid-covid-vacc'] vacc
 on dea.location = vacc.location and dea.date = vacc.date
 where dea.continent is not null 

 )
 select *, (rollingvacc/population)*100
 from popvsvac

 --CREATING VIEW
 --populationvaccinated
 create view ppv as
  select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations
 ,sum (cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingvacc
 from portfolioproject..['owid-covid-death'] dea
 join portfolioproject..['owid-covid-vacc'] vacc
 on dea.location = vacc.location and dea.date = vacc.date
 where dea.continent is not null 
 --order by 2,3