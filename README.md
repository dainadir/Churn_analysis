# Business case
This Python notebook provides basic client churn prediction analysis. Client is called innactive if he has uninstalled app from his device or if he did not import any new products into his store for more than 20 calendar days.

## Attributes:
Attributes used and their meanings:
- `id `: shop id
- `prepared`: idk
- `type`: idk
- `timezone`: timezone
- `plan_name`: plan type
- `country_code`: country of origin
- `initial_producs`: 
- `initial_orders`: 
- `created_at_date`: app installation date
- `cancelled_at_date`: date when app was uninstalled
- `failed_attempts`: failed attempts to install app
- `avg_number_of_orders_mnth`: average number of orders per month
- `churn`: churner or not?
- `days_to_import_first_prod`: how many days it took to import first product (counted from app installation date)
- `days_to_sell_first_prod`: how many days it took to sell first product (counted from app installation date). -1 - client did not sell anything

## Workflow:
1. Initial data modelling and preprocessing using SQL Server. Main queries to derive new columns are provided in `SQL queries` folder. 
2. Data cleaning, exploratory analysis and visualizations using Python.
3. Building a predictive model.
4. Evaluating model based on Confusion matrix metrics and AUC/ROC
5. Adjusting model based on results of step 4.
