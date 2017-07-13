//SQL

Create Function [dbo].[fn_GetYrMnDay_betn_twodates](@firstdate datetime, @seconddate datetime, @ReturnFormat varchar(2) = Null)  
 Returns varchar(50)  
 As  
 /*
 Results		: Select dbo.fn_GetYrMnDay_betn_twodates	('01-Jan-2007','15-Mar-2008','YY')	: 1
		  				Select dbo.fn_GetYrMnDay_betn_twodates	('01-Jan-2007','15-Mar-2008','MM')	: 2
		  					Select dbo.fn_GetYrMnDay_betn_twodates	('01-Jan-2007','15-Mar-2008','DD')	: 15
 
 */
 
 Begin  
  declare @dtfrom datetime  
  declare @dtto datetime   
  declare @y1 int  
  declare @m1 int  
  declare @d  Int   
  declare @cnt int  
  declare @totdays int   
  Declare @DaysInYear Int   
  declare @CheckLeapYear Int  
  declare @TempDate Datetime  
  declare @res varchar(50)  
  /*  Initialize Variables */  
  Select @res = '', @dtfrom = @firstdate, @dtto = @seconddate, @y1 = 0     
  /* Find current year to calcualte for Leap */   
  if month( @dtfrom) > 2    
   Select @CheckLeapYear = Year(dateadd(yy, 1, @dtfrom))  
  Else  
   Select @CheckLeapYear  = Year(@dtfrom)  
  /* Find Days in year depending on leap year Conditon */   
  select @DaysInYear =  Case when @CheckLeapYear % 4 = 0   
      Then Case when @CheckLeapYear % 100 = 0 then   
       Case when @CheckLeapYear % 400 = 0 then 366 else 365 End   
      Else 366 End  
     Else 365 End    
    
  /* To Calculate accurate Years between dates */       
    while (datediff(dd, @dtfrom, @dtto) + 1) >= @DaysInYear  
  begin          
   /* Increase year Counter */  
   Select @y1 = @y1 + 1, @dtfrom = dateadd(dd, @DaysInYear, @dtfrom)    
   /* Find current year to calculate for Leap */  
   if month( @dtfrom) > 2    
    Select @CheckLeapYear = Year(dateadd(yy, 1, @dtfrom))  
   Else  
    Select @CheckLeapYear  = Year(@dtfrom)  
   /* Find Days in year depending on leap year condition */   
   select @DaysInYear =  Case when @CheckLeapYear % 4 = 0   
       Then Case when @CheckLeapYear % 100 = 0 then   
        Case when @CheckLeapYear % 400 = 0 then 366 else 365 End   
       Else 366 End  
      Else 365 End    
  end  
  /* Initialize variables to calculate months */   
  Select @m1 = 0, @totdays = datediff(dd, @dtfrom, dateadd(mm, 1, @dtfrom))   
  while @dtfrom <= @dtto and @totdays <= datediff(dd, @dtfrom, @dtto) + 1  
  begin    
   Select @dtfrom  = dateadd(mm, 1, @dtfrom)  
   Select @totdays = datediff(dd, @dtfrom, dateadd(mm, 1, @dtfrom)), @m1 = @m1 + 1    
  end  
    
  /* To Calculate Accurate Days after calculate years and months */  
  
  
  /*if datepart(d,@firstdate) <> 1 
  begin
    Select @d = datediff(dd, @firstdate, dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@firstdate  )+1, 0)) ) + 1  
  end
  else*/
  begin
     Select @d = datediff(dd, @dtfrom, @dtto ) + 1 
  end 
  
  Select @d = case when @d < 0 then 0 Else @d End  
  	
  	
  /* Format the return variable as per third paramater */     
  Select @ReturnFormat = isnull(@ReturnFormat, '')  
  if @ReturnFormat ='DD'   
   select @res= convert(varchar(10), @d)  
  else if @ReturnFormat ='MM'   
   select @res= convert(varchar(10),ISNULL(@m1,0) + ISNULL(@y1,0) * 12) 
  else if @ReturnFormat = 'YY'  
   select @res= convert(varchar(10),ISNULL(@y1,0))  
  else   
  begin  
   /* First put days into return variable therefore we can easily concat and */  
   Select @res = convert(varchar(10), isnull(@d, 0))    
   /* Concat months to the return variable if days are there then add and else only months */  
   if @res = ''   
    Select @res =  convert(varchar(10),isnull(@m1,0))+ ' month(s) '  + @res  
   else  
    Select @res =  convert(varchar(10),isnull(@m1,0))+ ' month(s) and '  + @res  
   /* Concat Years to the return variable depending on days or months */  
   if @res = ''   
    Select @res = ltrim(case when isnull(@y1, 0) = 0 then '' else convert(varchar(10),@y1) + ' Year(s) 'end + @res)    
   else  
   begin  
    if charindex('day(s)', @res) > 0   
     Select @res = ltrim(case when isnull(@y1,0) =0 then '' else convert(varchar(10),isnull(@y1,0))+' Year(s) ' end + @res)    
    else  
     Select @res = ltrim(case when isnull(@y1,0) =0 then '' else convert(varchar(10),isnull(@y1,0))+' Year(s) and 'end + @res)    
   end  
  end  
  Return @res    
 End
 // End Sql