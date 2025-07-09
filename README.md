# 🧹 Layoffs 2022 SQL Data Cleaning Project

## 📊 Dataset Source

This project uses the [Layoffs 2022 dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022) from Kaggle, which tracks major layoffs across companies and industries during the economic downturn of 2022.

---

## 📌 Objective

The goal of this project is to **clean and prepare the layoffs dataset** for deeper analysis by removing inconsistencies, handling missing data, and standardizing the dataset using SQL. This improves data reliability and ensures it is analysis-ready.

---

## 🛠️ Tools Used

* **SQL** (MySQL-compatible dialect)
* **ROW\_NUMBER() Window Function**
* **String Manipulation Functions** (e.g., `TRIM()`)
* **Date Formatting (`STR_TO_DATE()`)**
* **Data Validation & Conditional Logic**

---

## 🧾 Step-by-Step Process

### 🔁 Step 0: Create a Safe Working Copy

To prevent accidental data loss, a duplicate of the raw dataset (`layoffs`) is created:

```sql
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```

---

### 🔍 Step 1: Remove Duplicates

Duplicates are identified by creating a new column `row_num` using `ROW_NUMBER()` over all relevant columns. This allows us to:

* Assign a unique sequence number to each identical row
* Easily identify and delete all duplicates (rows with `row_num > 1`)

```sql
ROW_NUMBER() OVER(
  PARTITION BY company, location, industry, total_laid_off, 
  percentage_laid_off, date, stage, country, funds_raised_millions
) AS row_num
```

Duplicates are removed from the new `layoffs_staging2` table, and the cleaned data is preserved.

---

### 🧼 Step 2: Data Standardization

This step ensures consistency across the dataset:

1. **Trim Whitespace**
   Removes leading/trailing spaces from `company`, `country`, and similar string fields using `TRIM()`.

2. **Unify Categorical Values**

   * 'Crypto Currency' and 'CryptoCurrency' → standardized to `'Crypto'`
   * Empty strings in `industry` replaced with `NULL`
   * Missing industry values filled using existing company-level data via self-join

3. **Fix Country Names**
   Corrects inconsistencies like `'United States.'` → `'United States'`

4. **Convert Date Format**
   Converts string-formatted dates (MM/DD/YYYY) to SQL `DATE` type:

   ```sql
   STR_TO_DATE(date, '%m/%d/%Y')
   ```

---

### 🚫 Step 3: Handle Missing Data

* Missing values in `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions` are **kept** as `NULL` when appropriate.
* However, rows where both `total_laid_off` *and* `percentage_laid_off` are `NULL` are **dropped** as they provide no analytical value.

---

### 🧹 Step 4: Drop Helper Columns

The `row_num` column used for duplicate detection is removed once the cleaning is complete:

```sql
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
```

---

## ✅ Final Result

The final table `layoffs_staging2` is a **cleaned, standardized, and deduplicated** version of the original dataset, ready for:

* Exploratory Data Analysis (EDA) --> Project 2
* Visualization and Dashboarding
* Predictive Modeling
* Industry and company-level comparisons

---
