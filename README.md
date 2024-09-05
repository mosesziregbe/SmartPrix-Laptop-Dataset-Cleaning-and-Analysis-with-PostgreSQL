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


## Inferences

1. Diverse Pricing Across Brands: The laptop market offers a wide range of prices across 31 brands, with Razer, Apple, and Samsung leading the high-end segment and brands like Infinix and Chuwi catering to budget-conscious consumers.

2. Price vs. Spec Score: There is a strong positive correlation of 0.72 between price and spec score, indicating that higher-priced laptops tend to have better specifications.

3. NVIDIA Graphics Premium: Laptops with NVIDIA graphics cards are significantly more expensive, suggesting they are associated with higher-end models. Additionally, in high-rated laptops, NVIDIA graphics cards, especially the GeForce RTX 4060, are most common.

4. RAM and Price Relationship: Higher RAM capacities correspond to higher average prices, with top-tier RAM categories commanding prices over six times that of the lowest RAM category. The 16 GB DDR4 RAM is the most common memory configuration, followed by 8 GB DDR4.

Market Segment Leaders: Lenovo, HP, and Asus dominate both the budget and mid-range segments, while HP leads in the premium segment, followed by MSI.

Brand Diversity: The budget segment is the most diverse, with 18 different brands, while the premium segment is dominated by a few established names.

Utility Categories and User Ratings: Multi-purpose laptops generally receive higher user ratings compared to specialized laptops, like those focused solely on gaming or business.

Gaming Market Share: MSI leads the gaming laptop market with a 23.58% share, followed by HP and Asus.

Processor Generations: Laptops from newer processor generations tend to have higher prices, but not necessarily higher user ratings, indicating that high price does not always equate to higher user satisfaction. Intel processors dominate the market with 743 laptops compared to 225 with AMD processors. Also, Core i5 processors are the most popular across all utility categories.


Touch Screen Functionality: There is a positive correlation between price and the inclusion of touch screen functionality, with this feature becoming more common in higher-end models.

Laptop Screen Size and User Ratings: Laptops with 16-inch screens and larger are the heaviest, averaging 2.20 kg. Asus offers the widest range of screen sizes, from 11.6 to 17.3 inches. Laptops with larger screens (16" and above) have the highest average user rating of 4.38.


## Insights

Consumer Price Sensitivity: The wide range of prices across brands suggests that consumers have varied budget constraints, and brands cater to different segments of the market accordingly.

Specification Influence on Pricing: The strong correlation between spec scores and prices indicates that consumers are willing to pay more for better specifications, emphasizing the importance of high specs in the pricing strategy.

Graphics Cards as a Selling Point: The premium pricing of NVIDIA-equipped laptops shows that graphics capabilities are a major selling point, particularly for high-end users.

RAM as a Key Pricing Factor: The significant impact of RAM on pricing suggests that consumers view RAM as a critical component in performance, which brands could leverage in their marketing. Also, the trend in RAM and storage is moving towards higher capacities, especially in newer processor generations.

Brand Loyalty Across Segments: Lenovo, HP, and Asus's dominance across multiple segments indicates strong brand loyalty and a broad product range that meets diverse consumer needs.

Multi-Purpose Laptops Preferred: The higher user ratings for multi-purpose laptops indicate that versatility is valued by consumers, which could influence future product development.

MSI's Gaming Leadership: MSI's leadership in the gaming segment highlights its strong brand recognition and product focus in this niche market.

Discrepancy in Price and User Ratings: The gap between high prices and lower-than-average user ratings in newer processor generations suggests potential overpricing or unmet consumer expectations.

Touch Screens in High-End Laptops: The increased prevalence of touch screens in premium models indicates that this feature is becoming a standard expectation among high-end consumers.

Fingerprint Sensors in Mid-Range Laptops: The higher adoption of fingerprint sensors in mid-range laptops suggests that security features are becoming more mainstream, though still premium in lower segments.

### Other Market and Consumer Behavior Insights:

The slight negative correlation between user ratings and votes might suggest that popular models attract more critical reviews.

Multi-utility laptops often have lower battery capacities, suggesting a trade-off between versatility and battery life.

User satisfaction isn't solely determined by price, as some lower-priced laptops have high user ratings.

Larger, heavier laptops tend to be more powerful and expensive, often catering to the gaming market.

The dominance of Intel processors suggests brand loyalty or better marketing, despite AMD's competitive offerings.

The wide range of screen sizes offered by major brands shows an effort to cater to diverse user needs.


## Recommendations

1. Target Diverse Price Segments: Brands should continue to offer a wide range of prices to cater to different consumer budgets, ensuring a broad market reach.

2. Emphasize High Specs in Marketing: Given the strong correlation between price and spec score, marketing should highlight high specifications as a key selling point, especially in high-end models.

3. Leverage Graphics Capabilities: Brands should emphasize NVIDIA graphics in their high-end models to attract consumers who prioritize gaming or graphic-intensive tasks.

4. Increase RAM Options: Offering laptops with higher RAM capacities could cater to consumers who are willing to pay more for enhanced performance, especially in mid-range and premium models.

5. Strengthen Brand Positioning: Lenovo, HP, and Asus should continue to capitalize on their dominance in various segments by reinforcing brand loyalty through targeted marketing and product differentiation.

6. Expand Multi-Purpose Offerings: Brands should consider developing more versatile laptops, as these are preferred by consumers and receive higher ratings.

7. Focus on Gaming Laptops: For brands like MSI, maintaining a strong focus on gaming laptops will help retain leadership in this niche market.

Reassess Pricing Strategy: Brands with newer processor generations should reassess their pricing strategies to ensure they align with consumer expectations and satisfaction.

Enhance Touch Screen Availability: Expanding the availability of touch screens in lower segments could meet the growing demand for this feature and potentially increase market share.

Promote Security Features: Emphasizing fingerprint sensors in marketing could appeal to security-conscious consumers, especially in the mid-range and premium segments.


For consumers: Pay attention to RAM type and capacity when choosing a laptop, as it significantly impacts performance.

For gamers: Look for laptops with NVIDIA RTX series graphics cards for the best gaming experience.

For professionals: Consider "Performance, Business" category laptops for the best balance of performance and battery life.

For budget-conscious buyers: Don't overlook lower-priced models, as they can still offer high user satisfaction.

For retailers: Stock a diverse range of screen sizes to cater to different user preferences.

For product developers: Focus on optimizing battery life in multi-utility laptops to enhance their appeal.

For marketers: Highlight the number of USB ports in premium models as a selling point.

For reviewers: Encourage more user reviews to provide a broader perspective, especially for highly-rated laptops.

For eco-conscious consumers: Consider the trade-off between performance and weight/power consumption when choosing a laptop.

Remember, these findings and recommendations are based on the current dataset. The tech market moves fast, so it's always good to keep an eye on the latest trends and updates.
## 🔄 Future Work

- **Feature Engineering**: Create new features that could be used for predictive modeling.
- **Price Prediction**: Use the cleaned dataset to build models that predict laptop prices based on their features.
