# Database Information for Case Study

This folder contains details about the database created for the case study.  
The database was built in Snowflake using the 30-day trial version.  
It has two schemas, represented by the two main folders in this repository:

<br>

<details>
  <summary><strong>📁 cleaned</strong></summary>

  - Contains tables built from the CSV files provided, used for analysis and generating insights.  
  - This folder is organized into three subfolders:

    <details>
      <summary>📁 bulk_upload</summary>
      Stores bulk upload queries for the tables in this schema.
    </details>

    <details>
      <summary>📁 refresh</summary>
      Stores refresh queries for the tables in this schema.
    </details>

    <details>
      <summary>📁 tables</summary>
      Stores CREATE statements for the tables in this schema.
    </details>

</details>

<br>

<details>
  <summary><strong>📁 csv</strong></summary>

  - Contains three tables storing raw data from the provided CSV files.  
  - Includes CREATE statements for each table in a `.sql` file.

</details>

<br>
