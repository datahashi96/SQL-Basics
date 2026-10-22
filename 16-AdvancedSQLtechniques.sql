/* Database Notes

Data Warehouse: A special database that collects and integrates data from
different sources to enable analytics and support decision-making.

Database Engine
	The brain of the database
	Handles different operations such as
		Storing
		Retrieving
		Managing Data within Database


Database Storage
	Disk Storage: Long term memory
		Data stored permanently
		Can hold a large amount of data
		Slow to write and read

		User/Catalogue/Temp Data
			User Data: Main content of database. Actual data that we
			care about is stored here

			Catalog Data:  Internal storage for its own information
			A blueprint that keeps track of everytihng about the database
			Holds metadata (data about data)
				For example column names, datatype of values etc
			This information can be found in the information schema
				A system defined schema with built in views that provide info 
				about database like tables and columns


	Cache Storage: Slow term memory
		Data only stored temporarily. Once tasks done, storage is cleared
		FAST! - to read and write. 
		Can only hold small amount of data

		To access go to system database in object explorer
		Because we are currently using local files we have access
		Typically only the database administrator
			Find temporary tables in tempdb under system databases
			Temporary tables covered/created in next section


		*/

-- accessing information schema
select *
from information_schema.columns

select
	distinct table_name
	from information_schema.columns