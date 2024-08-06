DECLARE @ProcTable TABLE (Text NVARCHAR(MAX));
INSERT @ProcTable (Text)
EXEC sp_helptext [YourSchema].[ProcedureName];

WITH tmp
AS (
    SELECT * FROM @ProcTable
)
SELECT
     STRING_AGG (CONVERT(NVARCHAR(max),Text), '' '') sp_script
FROM tmp
