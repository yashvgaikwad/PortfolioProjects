# COVID-19 Global Impact Analysis 📊

A data-driven deep dive into the spread, mortality, and vaccination trends of COVID-19 across the world using **SQL** and **Tableau**.

This project is more than just numbers — it's a story told through data: from infections and deaths to how countries responded with vaccinations.

---

## 🔧 Tools Used
- **SQL Server** – For heavy data exploration, joins, aggregations, window functions, CTEs, and views  
- **Tableau** – For dynamic, interactive visualizations and storytelling dashboards

---

## 🔍 Project Goals
- Understand **global infection trends** and **death rates**  
- Compare COVID’s impact across **continents and countries**  
- Analyze **vaccination progress** over time  
- Use SQL to create clean, analysis-ready datasets for visualization  

---

## 📌 Key Insights Uncovered
- **Europe** recorded the highest death toll globally  
- The **United States, UK, and India** showed some of the highest infection rates  
- While global cases soared, **vaccination rollouts** varied widely by region  
- A persistent gap existed between infection rates and vaccine adoption in several developing countries

---

## 📁 SQL Work Highlights

The raw data came from two primary sources:
- `CovidDeaths`
- `CovidVaccinations`

### 🚀 Highlights of SQL Work:
- Created dynamic views and temporary tables to calculate:
  - Daily & total deaths/cases
  - Infection and death percentages
  - Vaccination rollouts (using window functions for rolling sums)
- Used **CTEs and subqueries** to simplify complex logic
- Engineered data to feed into Tableau without needing post-processing

