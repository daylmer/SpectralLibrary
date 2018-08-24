USE [master]
RESTORE DATABASE [protein] FROM  DISK = N'D:\protein\backup\protein2.bak' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5

GO


