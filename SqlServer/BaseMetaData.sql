DECLARE @db_name VARCHAR(max)
DECLARE @db_id INT
BEGIN
    IF NOT EXISTS (SELECT *
               FROM sys.objects
               WHERE object_id = OBJECT_ID(N'[YourDB].[YourSchema].[YourTable]')
                 AND type in (N'U'))
    BEGIN
        CREATE TABLE [YourDB].[YourSchema].[YourTable]
        (
            db_name     varchar(max),
            db_id       int,
            schema_name varchar(max),
            schema_id   int,
            table_name  varchar(max),
            table_type  varchar(max),
            table_id    int,
            column_name varchar(max),
            column_is_computed bit,
            column_user_type_id int,
            column_precision int,
            column_scale int,
            column_is_nullable bit,
            column_max_length int,
            column_collation_name varchar(max),
            column_default_object_id int,
            column_id int
        )
    END
    ELSE
        TRUNCATE TABLE [YourDB].[YourSchema].[YourTable];
END
DECLARE C CURSOR FOR
    SELECT
               name,
               database_id
    FROM sys.databases
    WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');
OPEN C
FETCH NEXT FROM C INTO @db_name,@db_id
WHILE @@FETCH_STATUS = 0
    BEGIN
        EXECUTE ('USE ['+ @db_name + '] ' +
            ';WITH t1 AS ( ' +
            'SELECT TABLE_CATALOG db_name,
                    TABLE_SCHEMA schema_name, ' +
                    'TABLE_NAME table_name, ' +
                    'TABLE_TYPE table_type,'+
                    @db_id + 'db_id ' +
            'FROM INFORMATION_SCHEMA.TABLES' +
             '),'+
             't2 AS ( '+
             'SELECT ' +
             'name, schema_id
                FROM sys.schemas'+
             '), '+
             't3 AS (SELECT t1.db_name,' +
            '      t1.db_id,
                   t1.schema_name,
                   t2.schema_id,
                   t1.table_name,
                   t1.table_type
             FROM t1
                     INNER JOIN t2 ON t1.schema_name = t2.name),
             t4 AS (SELECT t3.db_name,' +
            '       t3.db_id,
                    t3.schema_name,
                    t3.schema_id,
                    t3.table_name,
                    t3.table_type,
                    o.object_id table_id
             FROM sys.objects o
                     INNER JOIN t3 ON o.name = t3.table_name AND o.schema_id = t3.schema_id),
             t5 AS (
                    SELECT
                        t4.db_name,' +
            '           t4.db_id,
                        t4.schema_name,
                        t4.schema_id,
                        t4.table_name,
                        t4.table_type,
                        t4.table_id,
                        c.name column_name,
                        c.is_computed column_is_computed,
                        c.user_type_id column_user_type_id,
                        c.precision column_precision,
                        c.scale column_scale,
                        c.is_nullable column_is_nullable,
                        c.max_length column_max_length,
                        c.collation_name column_collation_name,
                        c.default_object_id column_default_object_id,
                        c.column_id column_id
                    FROM sys.columns c
                     INNER JOIN t4 ON c.object_id = t4.table_id
              ) '+
             'INSERT INTO [YourDB].[YourSchema].[YourTable] (db_name, db_id, schema_name, schema_id, table_name, table_type, table_id, column_name,
                          column_is_computed, column_user_type_id, column_precision, column_scale, column_is_nullable,
                          column_max_length, column_collation_name, column_default_object_id, column_id) ' +
             'SELECT
                        *
              FROM t5'
            )
        FETCH NEXT FROM C INTO @db_name,@db_id
    END
CLOSE C
DEALLOCATE C;
