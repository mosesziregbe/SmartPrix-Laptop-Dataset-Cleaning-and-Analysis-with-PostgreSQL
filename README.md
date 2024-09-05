# SmartPrix Laptop Dataset Cleaning and Analysis with PostgreSQL

## 📚 Project Overview

This project involves cleaning, transforming and analyzing the SmartPrix Laptop Dataset to uncover key insights related to pricing, performance, market trends, and user experiences using PostgreSQL. 

The dataset was scraped directly from the SmartPrix website in India in March 2024 and contains 1020 rows and 27 columns, detailing various features of laptops available in the Indian market.

Using PostgreSQL, the dataset was cleaned to remove duplicates, standardize data formats, and ensure consistency for meaningful analysis. SQL was utilized for both the data cleaning and analysis processes, with each step documented in separate SQL files for better organization and clarity. 

Additionally, two Jupyter notebooks provide a comprehensive walkthrough of the analysis and summaries of the results, with SQL queries executed using Python and connected directly to a PostgreSQL database for interactive exploration.


## 🛠️ Tools Used

- **PostgreSQL**: The primary database management system used for data cleaning, transformation, and analysis.

- **SQL**: For writing queries to clean and manipulate the data.

- **pgAdmin**: To manage and query the PostgreSQL database.

- **Jupyter Notebook**: For documenting SQL queries and running analyses.


## 📊 Dataset Description

The SmartPrix Laptop Dataset includes 1020 rows and 27 columns. The columns represent various features of laptops, such as:

- `name`: Name of the model
- `price`: Price of the laptop
- `spec_score`: Spec score based on features
- `votes`: Number of votes by buyers
- `user_rating`: Ratings by buyers
- `os`: Operating system
- `utility`: Intended use of the laptop
- `thickness`: Thickness of the laptop
- `weight`: Weight of the laptop
- `warranty`: Warranty period
- `screen_size`: Screen size
- `resolution`: Screen resolution
- `ppi`: Pixels per inch
- `battery`: Battery capacity in Watt-hours
- `processor_name`: Name of the processor
- `processor_speed`: Processor speed and configuration
- `no_cores`: Number of processor cores
- `caches`: Cache memory
- `graphics_card`: Graphics card information
- `rom_memory`: ROM memory type
- `internal_memory`: RAM capacity
- `port_connection`: Available ports
- `wireless_connection`: Wireless connectivity features
- `usb_ports`: Types of USB ports available
- `hardware_features`: Additional hardware features

### Raw Dataset Image
![Raw Dataset Image](
https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/dataset%20images/raw_smartprix_data.jpg)

The dataset is raw and unclean, requiring extensive data cleaning to address both structural and qualitative issues before it can be used for any meaningful analysis or predictions.


## 🧼 Data Cleaning

The data cleaning process involves:

1. **Handling Duplicates**: Identified and removed duplicate rows based on key columns like laptop names, specifications, and prices.

2. **Handling Structural Issues**: Removing or correcting any structural anomalies in the dataset, such as missing columns, incorrect data types, and misaligned data.

3. **Cleaning Text Data**: Standardizing text data to remove inconsistencies like extra spaces, invisible characters, and inconsistent casing.

4. **Extracting and Transforming Data**: Using SQL’s `REGEXP_REPLACE`, `SUBSTRING`, and other string functions to extract meaningful components from complex strings (e.g., extracting processor models, handling multiple core configurations).

5. **Normalizing Values**: Ensuring that numerical data is consistently formatted and converting string representations of numbers to numeric types where necessary.

6. **Validation**: Checking for and correcting any remaining anomalies to ensure the dataset is clean and ready for analysis.

### Cleaned Dataset Images
#### pgadmin
![pgadmin laptops dataset image](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/dataset%20images/pgadmin_laptops_cleaned.jpg)
#### Excel
![Excel laptops dataset image](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/dataset%20images/excel_laptops_cleaned.jpg)

## 📁 Project Structure

This project is organized into a series of SQL queries, each addressing specific aspects of our data analysis, from cleaning and transformation to market insights and technical specifications. 

Accompanying these queries are Jupyter Notebooks that establish connections to our PostgreSQL database, allowing us to execute the queries, visualize their outputs, and present comprehensive summaries, solutions and insights derived from our analysis.

### *[I - Data Cleaning and Transformation - (SQL Queries)](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/SQL%20Queries/data_cleaning.sql)*
- Handling duplicates
- Correcting structural issues
- Standardizing text data
- Extracting and transforming complex data
- Normalizing numerical values
- Validating data integrity
-----
### *[II - Market and Value Analysis - (SQL Queries)](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/SQL%20Queries/market_value_analysis.sql)*
- Brand pricing strategies
- Price-performance correlations
- Market trends across price segments
- User ratings and brand performance
- Value propositions in different categories

#### *[Market and Value Analysis (Jupyter Notebook)](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/Jupyter%20Notebooks/Market%20and%20Value%20Analysis.ipynb)*
-----
### *[III - Technical Specifications and User Experience - (SQL Queries)](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/SQL%20Queries/tech_specs_user_experience.sql)*
- Performance metrics across brands
- Hardware configurations and trends
- Physical characteristics analysis
- User ratings correlation with specifications
- Feature adoption rates and their impact

#### *[Technical Specifications and User Experience (Jupyter Notebook)](https://github.com/mosesziregbe/SmartPrix-Laptop-Dataset-Cleaning-and-Analysis-with-PostgreSQL/blob/main/Jupyter%20Notebooks/Technical%20Specifications%20and%20User%20Experience%20Analysis.ipynb)*

-----
&nbsp;&nbsp;SmartPrix-Laptop-Analysis/  
&nbsp;&nbsp;├─ 📁 SQL Queries/  
&nbsp;&nbsp;├── data_cleaning.sql  
&nbsp;&nbsp;├── market_value_analysis.sql  
&nbsp;&nbsp;└── tech_specs_user_experience.sql  
&nbsp;&nbsp;  
&nbsp;&nbsp;├─ 📁 Jupyter Notebooks/  
&nbsp;&nbsp;├── Market_and_Value_Analysis.ipynb  
&nbsp;&nbsp;└── Technical_Specifications_and_User_Experience_Analysis.ipynb  
&nbsp;&nbsp;└── README.md  



## 🔄 Future Work

- **Feature Engineering**: Create new features that could be used for predictive modeling.
- **Price Prediction**: Use the cleaned dataset to build models that predict laptop prices based on their features.
