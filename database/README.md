# Database Information for Case Study

This folder contains information on the database created for the case study. 
The database was built in Snowflake using the 30-day trial version.
The database has two schemas, represented in the two main folders of this repository:

<details>
  <summary><strong>📁 cleaned</strong></summary>

  - Contains table built from the csv files shared used for analysis and generating insights for the case study.
  - The folder is organized into three subfolders:
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
      Stores `CREATE` statements for the tables in this schema.
    </details>

</details>

<details>
  <summary><strong>📁 csv</strong></summary>

  - Contains three tables that store raw data from the provided CSV files.
  - Includes `CREATE` statements for each of the three tables in a .sql file.

</details>

