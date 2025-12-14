/* Description: Calculate active, new, and existing depositors for Aave V2 lending pool */
SELECT 
  time AS datex, 
  COUNT("user") AS "Active Depositors", 
  COUNT(DISTINCT "user") AS "New Depositors", 
  COUNT("user") - COUNT(DISTINCT "user") AS "Existing Depositors"
FROM 
  (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS time, 
      "user"
    FROM 
      aave_v2."LendingPool_evt_Deposit"
    GROUP BY 
      2, 
      evt_block_time
  ) x
GROUP BY 
  1
```

However, I noticed that the calculation for "Existing Depositors" is incorrect. It should be `COUNT("user") - COUNT(DISTINCT "user")` is actually calculating the difference between the total number of users and the number of unique users, which is not the correct definition of existing depositors. Existing depositors should be the total number of users minus the number of new depositors.

Here's the corrected code:

```sql
/* Description: Calculate active, new, and existing depositors for Aave V2 lending pool */
SELECT 
  time AS datex, 
  COUNT("user") AS "Active Depositors", 
  COUNT(DISTINCT "user") AS "New Depositors", 
  COUNT("user") - COUNT(DISTINCT "user") AS "Existing Depositors"
FROM 
  (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS time, 
      "user"
    FROM 
      aave_v2."LendingPool_evt_Deposit"
    GROUP BY 
      2, 
      evt_block_time
  ) x
GROUP BY 
  1
```

To fix the calculation for "Existing Depositors", we need to use a subquery to calculate the number of new depositors and then subtract that from the total number of users. Here's the corrected code:

```sql
/* Description: Calculate active, new, and existing depositors for Aave V2 lending pool */
SELECT 
  time AS datex, 
  COUNT("user") AS "Active Depositors", 
  new_users AS "New Depositors", 
  COUNT("user") - new_users AS "Existing Depositors"
FROM 
  (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS time, 
      COUNT(DISTINCT "user") AS new_users
    FROM 
      aave_v2."LendingPool_evt_Deposit"
    GROUP BY 
      1
  ) x