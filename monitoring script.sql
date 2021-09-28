--Dynamic Management Views

--
SELECT * FROM sys.dm_exec_connections
WHERE session_id > 50

SELECT * FROM sys.dm_exec_sessions
WHERE session_id > 51

SELECT host_name, program_name, connect_time, auth_scheme
FROM sys.dm_exec_sessions AS a 
	JOIN sys.dm_exec_connections AS b ON a.session_id = b.session_id 

SELECT session_id, status, command, sql_handle, database_id
FROM sys.dm_exec_requests WHERE session_id >= 51

--CROSS APPLY
SELECT session_id, status, command, sql_handle, database_id, st.text
FROM sys.dm_exec_requests 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
 WHERE session_id >= 51

SELECT session_id, status, command, st.text, b.name
FROM sys.dm_exec_requests AS a
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
	JOIN sys.databases AS b ON a.database_id = b.database_id 
 WHERE session_id >= 51

 ------------------------------------------------------------------------------------
 --index based DMVs
 --DMV query that lists unused indexes within a database
SELECT t.name AS table_name,
	   i.name AS index_name
FROM sys.indexes AS i --system table
	JOIN sys.dm_db_index_usage_stats AS s ON s.object_id = i.object_id AND
		s.index_id = i.index_id 
	JOIN sys.tables AS t on i.object_id = t.object_id 
WHERE ((user_seeks = 0 AND user_scans = 0 AND user_lookups = 0) OR s.object_id IS NULL)


--top 20 queries that would benefit from an index
SELECT TOP 20
	ROUND(s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans),0) AS [Total Cost]
	, s.avg_user_impact 
	, d.statement AS TableName
	, d.equality_columns 
	, d.inequality_columns 
	, d.included_columns 
FROM sys.dm_db_missing_index_groups g
	JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle 
	JOIN sys.dm_db_missing_index_details d ON d.index_handle = g.index_handle 
ORDER BY [Total Cost] DESC

--slowest queries
SELECT TOP 20
	CAST(qs.total_elapsed_time / 1000000 AS DECIMAL(28,2) ) AS [Total Elapsed Dur (s)]
	, qs.execution_count
	, qt.text
	, DB_NAME (qt.dbid) AS DatabaseName
	, qp.query_plan 
FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY total_elapsed_time DESC

---sql plan cache
SELECT * FROM person.Person


