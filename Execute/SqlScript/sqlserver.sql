
IF object_id('[dbo].[centit_base64_encode]') IS NOT NULL
DROP FUNCTION [dbo].[centit_base64_encode]
GO

CREATE FUNCTION [dbo].[centit_base64_encode](
	@plain_text varbinary(max)
)RETURNS varchar(max)
AS BEGIN
--local variables
DECLARE
	@output            varchar(max),
	@input_length      integer,
	@block_start       integer,
	@partial_block_start integer, -- position of last 0, 1 or 2 characters
	@partial_block_length integer,
	@block_val         integer,
	@encodes_len         integer,
	@map               char(64)

	SET @map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	--初始花变量
	SET @output   = ''
	SET @encodes_len = 0
	--获得数据长
	SET @input_length = datalength(@plain_text)
	SET @partial_block_length = @input_length % 3
	SET @partial_block_start = @input_length - @partial_block_length
	SET @block_start       = 1
	--每三个字节循环编码
	WHILE @block_start < @partial_block_start BEGIN
		SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, 3) AS BINARY(3))
		--每三个字节编码为4个字符
		SET @output = @output + SUBSTRING(@map, @block_val / 262144 + 1, 1)
								+ SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
								+ SUBSTRING(@map, (@block_val / 64 & 63 ) + 1, 1)
								+ SUBSTRING(@map, (@block_val & 63) + 1, 1)
		--设置中间变量
		SET @block_start = @block_start + 3
		SET @encodes_len = @encodes_len + 4
		--每64个字节一个换行
		if @encodes_len % 64 = 0
			SET @output = @output + char(10)
	END
	-- 处理最后几个字节
	IF @partial_block_length > 0
	BEGIN
		if @partial_block_length = 1 
			SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, @partial_block_length) AS BINARY(1)) * 65536;
		else if @partial_block_length = 2 
			SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, @partial_block_length) AS BINARY(2)) * 256;

		SET @output = @output
		+ SUBSTRING(@map, @block_val / 262144 + 1, 1)
		+ SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
		+ CASE WHEN @partial_block_length < 2
			THEN REPLACE(SUBSTRING(@map, (@block_val / 64 & 63 ) + 1, 1), 'A', '=')
			ELSE SUBSTRING(@map, (@block_val / 64 & 63 ) + 1, 1) END
		+ CASE WHEN @partial_block_length < 3
			THEN REPLACE(SUBSTRING(@map, (@block_val & 63) + 1, 1), 'A', '=')
			ELSE SUBSTRING(@map, (@block_val & 63) + 1, 1) END
	END
--return the result
	RETURN @output
END
GO

IF object_id('[dbo].[centit_base64_decode]') IS NOT NULL
DROP FUNCTION [dbo].[centit_base64_decode]
GO

CREATE FUNCTION [dbo].[centit_base64_decode](
	@input varchar(max)
)RETURNS varbinary(max)
AS
BEGIN
	DECLARE
		@base64 char(64),
		@junk char(6),
		@pos int,
		@v1 int,
		@v2 int,
		@v3 int,
		@v4 int,
		@len int,
		@outlen int,
		@output varbinary(max);
	SELECT
		@base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
		@pos = 1,
		@len = datalength(@input),
		@output = 0x;

	IF @input = ''
		RETURN NULL;

	if @len>7 
	begin
		set @junk = SUBSTRING(@input,1,6)
		if @junk = 'CDATA[' 
        begin
			set @len = @len - 1; -- 去掉最后面的 ]
			set @pos = 7;        -- 去掉最前面面的 CDATA[
	    end;
	end else
		return null;

	WHILE @pos < @len-2
	BEGIN
		--每四个字节合并为3个字节 
		set	@v1 = CHARINDEX(SUBSTRING(@input, @pos + 0, 1) COLLATE Chinese_PRC_BIN, @base64) - 1
		set @v2 = CHARINDEX(SUBSTRING(@input, @pos + 1, 1) COLLATE Chinese_PRC_BIN, @base64) - 1
		set @v3 = CHARINDEX(SUBSTRING(@input, @pos + 2, 1) COLLATE Chinese_PRC_BIN, @base64) - 1
		set @v4 = CHARINDEX(SUBSTRING(@input, @pos + 3, 1) COLLATE Chinese_PRC_BIN, @base64) - 1 
		set	@output = @output
				+ CONVERT(binary(1), ((@v1 & 63) * 4 ) | ((@v2 & 48) / 16))
				+ CONVERT(binary(1), ((@v2 & 15) * 16) | ((@v3 & 60) / 4 ))
				+ CONVERT(binary(1), ((@v3 & 3 ) * 64) | ((@v4 & 63) / 1 ))
		set @pos = @pos + 4
			-- 编码文件可能有换行
		if ascii(SUBSTRING(@input, @pos , 1)) = 10 or ascii(SUBSTRING(@input, @pos , 1)) = 13 
			set	@pos = @pos + 1;
		if ascii(SUBSTRING(@input, @pos , 1)) = 10 or ascii(SUBSTRING(@input, @pos , 1)) = 13 
			set	@pos = @pos + 1;
	END;
	--去掉最后的补齐字符
	set @outlen = datalength(@output)
	RETURN(SUBSTRING(@output, 1,  @outlen - 3 + CHARINDEX('=', SUBSTRING(@input,@len-1, 2) + '=')));
END;
GO


if object_id('[dbo].[AnnexToXmlNode]') is not null
drop function [dbo].[AnnexToXmlNode]
GO

create function [dbo].[AnnexToXmlNode](	@docId varchar(200),
	@docName varchar(200),
	@pathName varchar(200),    
	@fileContent varbinary(max))
returns  varchar(max)
as
begin
  return '<DOCUMENT><DOCUMENT_ID>'+replace( replace( @docId,'<','&lt;'),'>','&gt') 
				   + '</DOCUMENT_ID><DOCUMENT_NAME>'+ replace( replace( @docName,'<','&lt;'),'>','&gt')  
				   +'</DOCUMENT_NAME><FILE_NAME>'+ replace( replace( @pathName,'<','&lt;'),'>','&gt')  
                   +'</FILE_NAME><FILE_CONTENT><![CDATA[' -- CDATA 子集一定要这样写
                       + dbo.centit_base64_encode(@fileContent) + ']]></FILE_CONTENT></DOCUMENT>'
end;
GO

if object_id('[dbo].[AnnexSqlToXml]') is not null
drop procedure [dbo].[AnnexSqlToXml]
GO

create procedure [dbo].[AnnexSqlToXml](@sSqlSen  varchar(2000),@xmlRet varchar(max) output) 
--returns varchar(max)
as
begin
  declare
    @sSqlCur varchar(2000),
    @docId varchar(200),
	@docName varchar(200),
	@pathName varchar(200),    
	@fileContent varbinary(max)

  set @sSqlCur ='declare selAnnex CURSOR for '+ @sSqlSen
		--'select top 7 item_id ,doc_no,doc_name,doc_file from inf_apply_doc' ;
  exec(@sSqlCur)
  --EXECUTE sp_executesql @sSqlCur
  --exec sp_executesql @stmt =@sSqlCur
  set @xmlRet='<?xml version="1.0" encoding="GBK"?><DOCUMENTDATA>';

  OPEN selAnnex
  FETCH NEXT FROM selAnnex INTO @docId ,@docName,@pathName,@fileContent 
  WHILE @@fetch_status=0
  BEGIN
    set @xmlRet= @xmlRet + dbo.AnnexToXmlNode( @docId ,@docName,@pathName,@fileContent); 
    FETCH NEXT FROM selAnnex INTO @docId ,@docName,@pathName,@fileContent
  END
  CLOSE selAnnex
  DEALLOCATE   selAnnex

  set @xmlRet= @xmlRet + '</DOCUMENTDATA>';
  --print @xmlRet 
  --return @xmlRet;
end;
GO

if object_id('[dbo].[AnnexXmlToTab]') is not null
drop function [dbo].[AnnexXmlToTab]
GO

create function  [dbo].[AnnexXmlToTab](@annexXmlValue  varchar(max)) --
returns @annexTab table (docID varchar(100), docName varchar(200), pathName varchaR(200), fileContent varbinary(max))
--with schemabinding
as
begin
	--DECLARE @annexTab table (docID varchar(100), docName varchar(200), pathName varchaR(200), fileContent varbinary(max))
	DECLARE @doc XML, @len int, @firstStr varchar(50), @headlen int
	set @firstStr = SUBSTRING(@annexXmlValue, 1 , 5)
	if  @firstStr = '<?XML' 
	begin
		set @len = datalength(@annexXmlValue)
		set @headlen = CharIndex('>',@annexXmlValue )
		set @doc = lower(SUBSTRING(@annexXmlValue, 1 , @headlen)) + SUBSTRING(  @annexXmlValue, @headlen+1, @len - @headlen)
	end else
		SET @doc = @annexXmlValue

	insert into @annexTab
	select nref.value('DOCUMENT_ID[1]', 'varchar(200)'),nref.value('DOCUMENT_NAME[1]', 'varchar(200)')
			,nref.value('FILE_NAME[1]', 'varchar(200)'), dbo.centit_base64_decode( nref.value('FILE_CONTENT[1]', 'varchar(max)'))
	from   @doc.nodes('/DOCUMENTDATA/DOCUMENT') R(nref)

	return
end;
GO