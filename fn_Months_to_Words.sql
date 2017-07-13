//sql
CREATE FUNCTION dbo.Months_to_Words (  
  @Number Numeric (38, 0) -- Input number with as many as 18 digits
 ,@nameForm VARCHAR(8000) -- 'Y' = full name of month; 'N' = abbreviated name of month
 ) RETURNS VARCHAR(8000)   
 /*  
 * Converts the month of a numeric date to the word  
 * 
 * Created by Ryan Schill
 *
 ****************************************************************/  
 AS BEGIN  
 DECLARE @inputNumber VARCHAR(38)
 DECLARE @outputString VARCHAR(8000)
 
 --Initialize the variables
 SELECT @inputNumber = CONVERT(varchar(38), @Number)
       ,@outputString = ''
 
 SET @outputString = CASE @nameForm 
  WHEN 'Y' THEN CASE @inputNumber
    WHEN '1'  THEN 'January'  WHEN '2'   THEN 'February'  WHEN '3'   THEN 'March'
    WHEN '4'  THEN 'April'    WHEN '5'   THEN 'May'       WHEN '6'   THEN 'June'
    WHEN '7'  THEN 'July'     WHEN '8'   THEN 'August'    WHEN '9'   THEN 'September'
    WHEN '10' THEN 'October'  WHEN '11'  THEN 'November'  WHEN '12'  THEN 'December' END
  WHEN 'N' THEN CASE @inputNumber
    WHEN '1'  THEN 'Jan.'     WHEN '2'   THEN 'Feb.'      WHEN '3'   THEN 'Mar.'
    WHEN '4'  THEN 'Apr.'     WHEN '5'   THEN 'May'       WHEN '6'   THEN 'June'
    WHEN '7'  THEN 'July'     WHEN '8'   THEN 'Aug.'      WHEN '9'   THEN 'Sept.'
    WHEN '10' THEN 'Oct.'     WHEN '11'  THEN 'Nov.'      WHEN '12'  THEN 'Dec.' END
  END
  
  RETURN @outputString
  END
//end sql