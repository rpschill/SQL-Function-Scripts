//sql

CREATE function fn_res_prorate_last_month(@phmy numeric, @amt numeric(18,2), @dtmoveout datetime)
RETURNS NUMERIC (18,2)
AS

	BEGIN
		DECLARE @b30day AS NUMERIC (4)
		DECLARE @bProraterent AS NUMERIC (4)
		DECLARE @bproyear AS NUMERIC (4)
		DECLARE @bmoveoutday AS NUMERIC (4)
		DECLARE @idue AS NUMERIC (4)
		DECLARE @idays AS NUMERIC (5,2)
		DECLARE @camt AS NUMERIC (18,2)
		
		SET @idue = 1
		SET @camt = ISNULL(@amt,0)
		
		SELECT @b30day = hvalue FROM propoptions WHERE hprop = @phmy AND stype = 'B30DAY'
		SELECT @bproraterent = hvalue FROM propoptions WHERE hprop = @phmy AND stype = 'BPRORATERENT'
		SELECT @bproyear = hvalue FROM propoptions WHERE hprop = @phmy AND stype = 'BPROYEAR'
		SELECT @bmoveoutday = hvalue FROM propoptions WHERE hprop = @phmy AND stype = 'BCHARGEMOVEOUT'
		
		IF @bproraterent = 0
		  RETURN @camt
		  
		IF @bproyear = 1
		  BEGIN
			  SELECT @idays = DAY(@dtmoveout) - 1
			  
			  IF @bmoveoutday = 1
			  	BEGIN
					  SET @idays = @idays + 1
				  END
			
			  SET @camt = (((@camt * 12.00) / CONVERT(NUMERIC(18,2), DATEDIFF(d, '01/01/' + CONVERT(VARCHAR, year(@dtmoveout)), '12/31/' + CONVERT(VARCHAR, year(@dtmoveout))) + 1)) * @idays)
		  END

		ELSE
		
			IF @b30day = 1
			
			  BEGIN
				  
				SET @idays = DAY(@dtmoveout) - 1
						  
				IF @bmoveoutday = 1
					BEGIN
						SET @idays = @idays + 1
					END
				  
				SET @camt = @camt * @idays / 30.00
				  
			  END
			 
			ELSE
			
				BEGIN
					
					SELECT @idays = DAY(@dtmoveout) - 1
					
					IF @bmoveoutday = 1
						BEGIN
							SET @idays = @idays + 1
						END
						
					SET @camt = @camt * @idays / (DAY(DATEADD(d, -DAY(DATEADD(m, 1, @dtmoveout)), DATEADD(m, 1, @dtmoveout))))
				END
				
			RETURN @camt
	END
//end sql
			  
		