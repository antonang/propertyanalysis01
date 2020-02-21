/** 1a. Display all property IDs and names for Owner Id: 1426 **/ 

SELECT t0.Id AS "Property Id", 
       t0.Name AS "Property Name"
FROM Keys.dbo.Property t0
     INNER JOIN Keys.dbo.OwnerProperty t1 ON t0.Id = t1.PropertyId
WHERE t1.OwnerId = 1426;


/** 1b. Display the current home value for each property **/ 

SELECT t0.Id AS "Property Id", 
       t0.Name AS "Property Name", 
       t2.Value AS "Current Home Value"
FROM Keys.dbo.Property t0
     INNER JOIN Keys.dbo.OwnerProperty t1 ON t0.Id = t1.PropertyId
     INNER JOIN Keys.dbo.PropertyHomeValue t2 ON t0.Id = t2.PropertyId
WHERE t1.OwnerId = 1426
      AND t2.IsActive = 1;


/** 1c.  For each property in question a), return the following:       
i.  Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query that returns 
    the sum of all payments from start date to end date. 
ii.  Display the yield.  
 **/ 

SELECT t0.Id AS "Property Id", 
       t0.Name AS "Property Name", 
       t2.PaymentAmount AS "Rental Payment Amount", 
       t3.Name AS "Rental Payment Frequency", 
       FORMAT(t2.StartDate,'dd/MM/yyyy ') AS "Tenant Start Date", 
       FORMAT(t2.EndDate,'dd/MM/yyyy ') AS "Tenant End Date",
       CASE t2.PaymentFrequencyId
           WHEN '1'
           THEN CAST(t2.PaymentAmount * DATEDIFF(DAY, t2.StartDate, COALESCE(t2.EndDate, GETDATE())) / 7 AS decimal(18, 2))
           WHEN '2'
           THEN CAST(t2.PaymentAmount * DATEDIFF(DAY, t2.StartDate, COALESCE(t2.EndDate, GETDATE())) / 14 AS decimal(18, 2))
           ELSE CAST(t2.PaymentAmount * DATEDIFF(DAY, t2.StartDate, COALESCE(t2.EndDate, GETDATE()) + 1) * 12 / 365 AS decimal(18, 2))
       END AS "Total Payment", 
       t4.Yield
FROM Keys.dbo.Property t0
     INNER JOIN Keys.dbo.OwnerProperty t1 ON t0.Id = t1.PropertyId
     INNER JOIN Keys.dbo.TenantProperty t2 ON t0.Id = t2.PropertyId
     INNER JOIN Keys.dbo.TenantPaymentFrequencies t3 ON t2.PaymentFrequencyId = t3.Id
     INNER JOIN Keys.dbo.PropertyFinance t4 ON t0.Id = t4.PropertyId
WHERE t1.OwnerId = 1426;


/** 1d. Display active (Open) job advertised in the marketplace with no job start and end dates **/

SELECT t0.Id AS "JobId",  
	   t1.Status,
	   t0.JobDescription,
	   t0.PropertyId, t0.OwnerId, t0.ProviderId,	   
       t0.PaymentAmount,	   
	   t0.JobStartDate, 
       t0.JobEndDate  
FROM Keys.dbo.Job t0
     INNER JOIN Keys.dbo.JobStatus t1 ON JobStatusId = t1.Id
WHERE t1.Id = 1 AND t0.JobEndDate is NULL AND t0.JobStartDate is NULL
ORDER BY t1.Status DESC;


/** 1e. Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for the properties in question 1a. **/

SELECT t0.Id AS "Property Id", 
       t0.Name AS "Property Name", 
       t4.FirstName AS "Tenant First Name", 
       t4.LastName AS "Tenant Last Name", 
       '$' + CAST(t2.PaymentAmount AS varchar) + 
	   CASE t2.PaymentFrequencyId
          WHEN '1'THEN ' per week'
          WHEN '2' THEN ' per fortnight'
          ELSE ' per month'
       END AS "Rental Payment"
FROM Keys.dbo.Property t0
     INNER JOIN Keys.dbo.OwnerProperty t1 ON t0.Id = t1.PropertyId
     INNER JOIN Keys.dbo.TenantProperty t2 ON t0.Id = t2.PropertyId
     INNER JOIN Keys.dbo.Tenant t3 ON t2.TenantId = t3.id
     INNER JOIN Keys.dbo.Person t4 ON t3.Id = t4.Id
WHERE t1.OwnerId = 1426
      AND t3.IsActive = 1;


