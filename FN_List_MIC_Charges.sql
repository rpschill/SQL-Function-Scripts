//SQL

DROP FUNCTION fn_listMICCharges

//END SQL

//SQL

CREATE FUNCTION fn_listMICCharges (
    @htenant NUMERIC(18), 
    @chargeType VARCHAR(8000) = 'LA', -- 'LA' = lease amount; 'MI' = move-in amount; defaults to lease amount
    @listSeparator VARCHAR(10) = ', ',
    @andFunction VARCHAR(3) = 'NO'
  ) 
  
/* This function returns all selected charges on the move-in calculator associated with a tenant handle in a comma delimited string.
If there are no charges, 'None' is returned.
Parameters:
    @htenant        - t.hmyperson for the tenant whose move-in charges will be returned
    @chargeType     - flag ('LA'/'MI') that determines whether lease amount or move-in amount charges should be returned
    @listSeparator  - string that separates each item in the list
    @andFunction    - flag ('Yes'/'No') that determines whether 'AND' should be placed between second-to-last and last item in list
*/
    
RETURNS VARCHAR(8000)

AS 
BEGIN

    DECLARE @outputString VARCHAR(8000)
    DECLARE @chgCount INT
    DECLARE @chgDescription VARCHAR(8000)
    DECLARE @chgAmount INT
    
    /* Initialize variables */
    
    SELECT
        CASE @chargeType
            WHEN 'LA' OR '' THEN @chgAmount = ISNULL(mic.cLeaseAmt,0)
            WHEN 'MI' THEN @chgAmount = ISNULL(mic.cMoveInAmt, 0)
        END
        
        ,@chgCount = COUNT(mic.hmy)
        ,@chgDescription = ISNULL(mic.sChargeDesc,'')
        
        ,@outputString = COALESCE(@outputString + char(167), '') + 
            FORMAT(@chgAmount, 'C', 'en-US') + ' ' + 'as' + ' ' + LTRIM(RTRIM(@chgDescription))
    FROM moveincharges mic
    WHERE mic.htenant = @htenant
      AND mic.bselected = -1
      AND @chgAmount <> 0
    END
    
    
    IF @andFunction = 'YES' AND LEN(@outputString) <> 0
        BEGIN
            IF ISNULL(chgCount, 0) > 1
                SET @outputString = SUBSTRING(@outputString, 0, (LEN(@outputString) - CHARINDEX(char(167), REVERSE(@outputString), 0) + 1))
                    + ' and '
                    + SUBSTRING(@outputString, (LEN(@outputString) - CHARINDEX(char(167), REVERSE(@outputString), 0))
                    + 2, CHARINDEX(char(167), REVERSE(@outputString),0)
                    - (CASE WHEN CHARINDEX(char(167), REVERSE(@outputString), 0) = 0 THEN 0 ELSE -1 END))
        END
     ELSE IF (@andFunction = '' OR @andFunction = 'NO')
        BEGIN
            SET @outputString = @outputString
        END
        
    
     IF ISNULL(@chgCount,0) <> 0
        BEGIN
            IF ISNULL(@chgCount,0) > 2
                SET @outputString = REPLACE(@outputString, char(167), @listSeparator)
        END
        
     RETURN(@outputString)
     
END

//END SQL