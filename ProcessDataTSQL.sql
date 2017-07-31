SET XACT_ABORT ON;
SET NOCOUNT ON;
SET IMPLICIT_TRANSACTIONS OFF;
go  
WHILE (@@TranCount > 0) COMMIT TRANSACTION;  
go  

DECLARE @debug bit
SET @debug = 0

DECLARE @mspeaktypepeptideid bigint
SET @mspeaktypepeptideid = (SELECT id FROM mspeaktype WHERE title = 'Peptides')

DECLARE @mspeaktypefragmentid bigint
SET @mspeaktypefragmentid = (SELECT id FROM mspeaktype WHERE title = 'Fragments')

DECLARE @sequencematchtypePLGS1id bigint
SET @sequencematchtypePLGS1id = (SELECT id FROM sequencematchtype WHERE title = 'PLGS1')

DECLARE @mspeakmatchtypePLGS1id bigint
SET @mspeakmatchtypePLGS1id = (SELECT id FROM mspeakmatchtype WHERE title = 'PLGS1')


-- Variable declaration
DECLARE @fragmentrows bigint
DECLARE @rate numeric(18,6) SET @rate = 0.0
DECLARE @index bigint SET @index = 0
DECLARE @previousPeptideSequence varchar(128) SET @previousPeptideSequence = ''
DECLARE @peptidemspeakid bigint SET @peptidemspeakid = 0
DECLARE @fragmentmspeakid bigint SET @fragmentmspeakid = 0
DECLARE @mspeakxid bigint SET @mspeakxid = 0
DECLARE @updateResult bigint SET @updateResult = 0
DECLARE @timestampstart datetime
DECLARE @timestampend datetime
DECLARE @batchsize int SET @batchsize = 100000
DECLARE @thisbatchsize int SET @thisbatchsize = 0
DECLARE @numberofbatches int SET @numberofbatches = 0
DECLARE @batchnumber int SET @batchnumber = 0
DECLARE @errormessage nvarchar(2048)

DECLARE @proteinid bigint SET @proteinid = 0
DECLARE @sequenceid bigint SET @sequenceid = 0
DECLARE @mspeaksequenceid bigint SET @mspeaksequenceid = 0

DECLARE @fragmentbatch TABLE (
	[identity] bigint identity	PRIMARY KEY NOT NULL,
	[id] bigint NOT NULL,
	[datasetid]			bigint			NOT NULL,
	[proteinaccession]	nvarchar(10)	NOT NULL,
	[proteinscore]		numeric(12, 6)	NOT NULL,
	[peptidesequence]	nvarchar(128)	NOT NULL,
	[peptidescore]		numeric(12, 6)	NOT NULL,
	[precursormz]		numeric(12, 6)	NOT NULL,
	[precursormhp]		numeric(12, 6)	NOT NULL,
	[precursorz]		tinyint			NOT NULL,
	[precursorintensity]bigint			NOT NULL,
	[precursorrettime]	numeric(12, 6)	NOT NULL,
	[precursormobility]	numeric(12, 6)	NOT NULL,
	[precursordeltappm] numeric(12, 6)	NOT NULL,
	[precursorfwhm]		numeric(12, 6)	NOT NULL,
	[fragmentsequence]	nvarchar(128)	NOT NULL,	
	[productmz]			numeric(12, 6)	NOT NULL,
	[productmhp]		numeric(12, 6)	NOT NULL,
	[productz]			tinyint			NOT NULL,
	[productintensity]	bigint			NOT NULL,
	[productrettime]	numeric(12, 6)	NOT NULL,
	[productmobility]	numeric(12, 6)	NOT NULL,
	[productdeltappm]   numeric(12, 6)	NOT NULL,
	[productfwhm]		numeric(12, 6)	NOT NULL
)

DECLARE @minfragmentbatchidentity bigint;
DECLARE @minfragmentbatchid bigint;
DECLARE @maxfragmentbatchid bigint; 

DECLARE @id bigint
DECLARE @datasetid bigint
DECLARE @proteinaccession varchar(10)
DECLARE @proteinscore numeric (12,6)
DECLARE @peptidesequence varchar(128)
DECLARE @peptidescore numeric (12,6)
DECLARE @precursormz numeric (12,6)
DECLARE @precursormhp numeric (12,6)
DECLARE @precursorz tinyint
DECLARE @precursorintensity bigint
DECLARE @precursorrettime numeric (12,6)
DECLARE @precursormobility numeric (12,6)
DECLARE @precursordeltappm numeric (12,6)
DECLARE @precursorfwhm numeric (12,6)
DECLARE @fragmentsequence varchar(128)
DECLARE @productmz numeric (12,6)
DECLARE @productmhp numeric (12,6)
DECLARE @productz tinyint
DECLARE @productintensity bigint
DECLARE @productrettime numeric (12,6)
DECLARE @productmobility numeric (12,6)
DECLARE @productdeltappm numeric (12,6)
DECLARE @productfwhm numeric (12,6)

PRINT 'Retrieving count of fragmentfile table'
SET @fragmentrows = (
	SELECT count(*)
	FROM fragmentFile with (nolock)
	WHERE processeddate is null
)

SET @numberofbatches = @fragmentrows / @batchsize + 1
PRINT cast(@fragmentrows as varchar(10))  + ' rows to be processed in ' + cast(@numberofbatches as varchar(10)) + ' batches of size ' + cast(@batchsize as varchar(10))

SET @timestampstart = GETDATE()

WHILE (@batchnumber < @numberofbatches) BEGIN

	DELETE FROM @fragmentbatch

	BEGIN TRANSACTION
	INSERT INTO @fragmentbatch
		SELECT TOP (@batchsize)
			id,
			datasetid,
			proteinaccession,
			proteinscore,
			peptidesequence,
			peptidescore,
			precursormz,
			precursormhp,
			precursorz,
			precursorintensity,
			precursorrettime,
			precursormobility,
			precursordeltappm,
			precursorfwhm,
			fragmentsequence,
			productmz,
			productmhp,
			productz,
			productintensity,
			productrettime,
			productmobility,
			productdeltappm,
			productfwhm
		FROM fragmentfile
		WHERE processeddate is null
		ORDER BY id

	SET @thisbatchsize = @@ROWCOUNT

	SET @minfragmentbatchidentity = (select min([identity]) from @fragmentbatch)

	SET @minfragmentbatchid = (select min(id) from @fragmentbatch)
	SET @maxfragmentbatchid = (select max(id) from @fragmentbatch)

	IF (@debug = 1) BEGIN
		SELECT @thisbatchsize, * FROM @fragmentbatch
	END

	IF (@debug = 1) BEGIN
		PRINT 'This batch size: ' + cast(@thisbatchsize as varchar(12))
	END	

	IF (@debug = 1) BEGIN
		PRINT @index
		PRINT @thisbatchsize
	END

	WHILE (@index < @thisbatchsize) BEGIN         
		
		BEGIN TRY

			SELECT
				@id = id,
				@datasetid = datasetid,
				@proteinaccession = proteinaccession,
				@proteinscore = proteinscore,
				@peptidesequence = peptidesequence,
				@peptidescore = peptidescore,
				@precursormz = precursormz,
				@precursormhp = precursormhp,
				@precursorz = precursorz,
				@precursorintensity = precursorintensity,
				@precursorrettime = precursorrettime,
				@precursormobility = precursormobility,
				@precursordeltappm = precursordeltappm,
				@precursorfwhm = precursorfwhm,
				@fragmentsequence = fragmentsequence,
				@productmz = productmz,
				@productmhp = productmhp,
				@productz = productz,
				@productintensity = productintensity,
				@productrettime = productrettime,
				@productmobility = productmobility,
				@productdeltappm = productdeltappm,
				@productfwhm = productfwhm
			FROM @fragmentbatch
			WHERE [identity] = @minfragmentbatchidentity + @index

			IF (@debug = 1) BEGIN
				SELECT * FROM @fragmentbatch WHERE [identity] = @minfragmentbatchidentity + @index
			END

			IF (@peptidesequence <> @previousPeptideSequence) BEGIN
				--PRINT 'Writing Peptide/precursor ' + @peptidesequence

				INSERT INTO mspeak (
					datasetid,
					mspeaktypeid,
					masscharge,
					mass,
					charge,
					intensity,
					retentiontime,
					drifttime,
					ppm,
					fwhm
				)
				VALUES (
					@datasetid,
					@mspeaktypepeptideid,
					@precursormz,
					@precursormhp,
					@precursorz,
					@precursorintensity,
					@precursorrettime,
					@precursormobility,
					@precursordeltappm,
					@precursorfwhm
				)
				SET @peptidemspeakid = SCOPE_IDENTITY()
					
				IF (@debug = 1) BEGIN
					SELECT @peptidemspeakid, * FROM mspeak WHERE id = @peptidemspeakid
				END

				SET @proteinid = ISNULL((SELECT id FROM [dbo].[protein] WHERE accession = @proteinaccession), 0)
				IF (@proteinid = 0) BEGIN
					INSERT INTO [dbo].[protein] (accession)
					VALUES (@proteinaccession)
					SET @proteinid = SCOPE_IDENTITY()
				END

				IF (@debug = 1) BEGIN
					SELECT @proteinid, * FROM [dbo].[protein] WHERE id = @proteinid
				END

				SET @sequenceid = ISNULL((SELECT id FROM sequence WHERE sequence = @peptidesequence), 0)
				IF (@sequenceid = 0) BEGIN
					INSERT INTO sequence (sequence)
					VALUES (@peptidesequence)
					SET @sequenceid = SCOPE_IDENTITY()
				END

				IF (@debug = 1) BEGIN
					SELECT @sequenceid, * FROM sequence WHERE id = @sequenceid
				END

				INSERT INTO mspeaksequence (
					mspeakid,
					proteinid,
					sequenceid,
					sequencematchtype,
					proteinscore,
					score
				)
				VALUES (
					@peptidemspeakid,
					@proteinid,
					@sequenceid,
					@sequencematchtypePLGS1id,
					@proteinscore,
					@peptidescore
				)

				SET @mspeaksequenceid = SCOPE_IDENTITY()

				IF (@debug = 1) BEGIN
					SELECT @mspeaksequenceid, * FROM mspeaksequence WHERE id = @mspeaksequenceid
				END

			END

			-- Don't add empty fragment sequences
			IF (@fragmentsequence <> '') BEGIN
				INSERT INTO mspeak (
					datasetid,
					mspeaktypeid,
					masscharge,
					mass,
					charge,
					intensity,
					retentiontime,
					drifttime,
					ppm,
					fwhm
				)
				VALUES (
					@datasetid,
					@mspeaktypefragmentid,
					@productmz,
					@productmhp,
					@productz,
					@productintensity,
					@productrettime,
					@productmobility,
					@productdeltappm,
					@productfwhm
				)

				SET @fragmentmspeakid = SCOPE_IDENTITY()
					
				IF (@debug = 1) BEGIN
					SELECT @fragmentmspeakid, * FROM mspeak WHERE id = @fragmentmspeakid
				END
					
				INSERT INTO mspeakx (
					mspeak1id,
					mspeak2id,
					mspeakmatchtype,
					score
				)
				VALUES (
					@peptidemspeakid,
					@fragmentmspeakid,
					@mspeakmatchtypePLGS1id,
					@peptidescore
				)

				SET @mspeakxid = SCOPE_IDENTITY()

				IF (@debug = 1) BEGIN
					SELECT @mspeakxid, * FROM mspeakx WHERE id = @mspeakxid
				END

			END

			IF (@debug = 1) BEGIN
				SELECT @id, * FROM fragmentfile WHERE id = @id
			END
			
		END TRY
		BEGIN CATCH
			-- Execute the error retrieval routine.			
			SET @errormessage = cast(ERROR_NUMBER() as nvarchar(64)) + CHAR(13) + CHAR(10)
			SET @errormessage = @errormessage + cast(ERROR_SEVERITY() as nvarchar(64)) + CHAR(13) + CHAR(10)
			SET @errormessage = @errormessage + cast(ERROR_STATE() as nvarchar(64)) + CHAR(13) + CHAR(10)
			SET @errormessage = @errormessage + cast(ERROR_PROCEDURE() as nvarchar(64)) + CHAR(13) + CHAR(10)
			SET @errormessage = @errormessage + cast(ERROR_LINE() as nvarchar(64)) + CHAR(13) + CHAR(10)
			SET @errormessage = @errormessage + cast(ERROR_MESSAGE() as nvarchar(1024))
			PRINT @errormessage
			RAISERROR (@errormessage, 20, 1) WITH LOG
		END CATCH
		
		SET @index = @index + 1
		SET @previousPeptideSequence = @peptidesequence

	END

	-- Update the current record of fragmentfile with the current datetime to mark as 'processed'
	UPDATE fragmentfile
	SET processeddate = getdate()
	WHERE id >= @minfragmentbatchid and id <= @maxfragmentbatchid

	SET @updateResult = @@ROWCOUNT
	IF (@updateResult <>  (select count(*) from @fragmentbatch)) BEGIN
		RAISERROR ('Was not able to update processed date for fragment file row', 20, 1) WITH LOG
	END

	-- SELECT * FROM fragmentfile where id = @id;

	SET @timestampend = GETDATE()
	DECLARE @timediff numeric(18,6)
	SET @timediff = (SELECT DATEDIFF(MICROSECOND, @timestampstart, @timestampend))
	IF (@timediff > 0) BEGIN
		SET @rate = @batchsize / @timediff * 1000000.0
	END ELSE BEGIN
		PRINT @timestampstart
		PRINT @timestampend
		PRINT @timediff
	END
	SET @timestampstart = GETDATE()

	DECLARE @statusmessage varchar(256)
	SET @statusmessage = 'Processing row ' + cast(@id as varchar(16)) + ' ' + cast((@batchnumber * @batchsize + @index) as varchar(64)) + ' of ' + cast(@fragmentrows as varchar(16)) + ' (' + @proteinaccession + ') ' +
		cast(cast(round(cast((@batchnumber * @batchsize + @index) as numeric(18,6)) / @fragmentrows * 100.0, 2) as numeric(18,2)) as varchar(64)) + '% '
	IF (@rate > 0) BEGIN
	SET @statusmessage = @statusmessage + cast(cast(round((@fragmentrows - (@batchnumber * @batchsize + @index)) / @rate, 2) as numeric(18,2)) as varchar(32)) + ' secs remain '
	END
	SET @statusmessage = @statusmessage + cast(cast(round(@rate, 2) as numeric(18,2)) as varchar(32)) + ' trans / sec'

	PRINT @statusmessage

	BEGIN TRY
		IF (@debug = 1) BEGIN
			ROLLBACK TRANSACTION
		END ELSE BEGIN
			COMMIT TRANSACTION
		END
	END TRY
	BEGIN CATCH
		-- Execute the error retrieval routine.
				
		SET @errormessage = cast(ERROR_NUMBER() as nvarchar(64)) + CHAR(13) + CHAR(10)
		SET @errormessage = @errormessage + cast(ERROR_SEVERITY() as nvarchar(64)) + CHAR(13) + CHAR(10)
		SET @errormessage = @errormessage + cast(ERROR_STATE() as nvarchar(64)) + CHAR(13) + CHAR(10)
		SET @errormessage = @errormessage + cast(ERROR_PROCEDURE() as nvarchar(64)) + CHAR(13) + CHAR(10)
		SET @errormessage = @errormessage + cast(ERROR_LINE() as nvarchar(64)) + CHAR(13) + CHAR(10)
		SET @errormessage = @errormessage + cast(ERROR_MESSAGE() as nvarchar(1024))
		PRINT @errormessage
		ROLLBACK TRANSACTION
		RAISERROR (@errormessage, 20, 1) WITH LOG
	END CATCH
	
	SET @batchnumber = @batchnumber + 1
	SET @index = 0
END

PRINT 'Finished processing!'
GO

SET IMPLICIT_TRANSACTIONS ON;
GO