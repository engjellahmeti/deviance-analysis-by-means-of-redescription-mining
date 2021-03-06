USE [EventLog]
GO
/****** Object:  Table [dbo].[log_has_trace]    Script Date: 11/27/2021 10:50:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[log_has_trace](
	[log_id] [int] NULL,
	[trace_id] [int] NULL,
	[sequence] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[trace]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trace](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[value] [varchar](150) NOT NULL,
 CONSTRAINT [PK_trace] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[trace_has_event]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trace_has_event](
	[trace_id] [int] NULL,
	[event_id] [int] NULL,
	[sequence] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[log]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [text] NULL,
 CONSTRAINT [PK_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[event_collection]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[event_collection](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
 CONSTRAINT [PK_event_collection] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[event]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[event](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event_collection_id] [int] NULL,
	[timestamp] [datetime] NULL,
 CONSTRAINT [PK_event] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Log_View]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Log_View]
AS
SELECT        dbo.log_has_trace.log_id, dbo.[log].name AS log_name, dbo.trace.value AS trace_id, dbo.trace_has_event.event_id, dbo.event_collection.name AS Activity, dbo.event.timestamp
FROM            dbo.trace INNER JOIN
                         dbo.log_has_trace ON dbo.trace.id = dbo.log_has_trace.trace_id INNER JOIN
                         dbo.trace_has_event ON dbo.trace.id = dbo.trace_has_event.trace_id INNER JOIN
                         dbo.event_collection INNER JOIN
                         dbo.event ON dbo.event_collection.id = dbo.event.event_collection_id ON dbo.trace_has_event.event_id = dbo.event.id INNER JOIN
                         dbo.[log] ON dbo.log_has_trace.log_id = dbo.[log].id
GO
/****** Object:  UserDefinedFunction [dbo].[ActivityCombinations]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[ActivityCombinations] (@logID int)
RETURNS TABLE
AS
RETURN
   SELECT    distinct   e1.name AS A, e2.name AS B
FROM            (select distinct dbo.event_collection.name from dbo.event_collection INNER JOIN 
													   dbo.event ON dbo.event_collection.id = dbo.event.event_collection_id INNER JOIN
													   dbo.trace_has_event ON dbo.event.id = dbo.trace_has_event.event_id INNER JOIN
													   dbo.trace ON dbo.trace_has_event.trace_id = dbo.trace.id INNER JOIN
													   dbo.log_has_trace ON dbo.trace.id = dbo.log_has_trace.trace_id where dbo.log_has_trace.log_id = @logID) e1 cross join
				(select dbo.event_collection.name from dbo.event_collection INNER JOIN 
													   dbo.event ON dbo.event_collection.id = dbo.event.event_collection_id INNER JOIN
													   dbo.trace_has_event ON dbo.event.id = dbo.trace_has_event.event_id INNER JOIN
													   dbo.trace ON dbo.trace_has_event.trace_id = dbo.trace.id INNER JOIN
													   dbo.log_has_trace ON dbo.trace.id = dbo.log_has_trace.trace_id  where dbo.log_has_trace.log_id = @logID) e2
GO
/****** Object:  UserDefinedFunction [dbo].[LogData]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[LogData] (@logID int, @noOfRows int)
RETURNS TABLE
As
RETURN
   SELECT top (case when @noOfRows is null then (select count(*) FROM Log_View WHERE log_id = @logID) else @noOfRows end) * FROM Log_View WHERE log_id = @logID order by trace_id, timestamp;

GO
/****** Object:  Table [dbo].[attribute]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[attribute](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[attr_key] [varchar](max) NULL,
	[attr_type] [varchar](max) NULL,
	[parent_id] [int] NULL,
	[extension_id] [int] NULL,
 CONSTRAINT [PK_attribute] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[classifier]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[classifier](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[attr_keys] [text] NULL,
	[log_id] [int] NULL,
 CONSTRAINT [PK_classifier] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[event_has_attribute]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[event_has_attribute](
	[event_id] [int] NULL,
	[attribute_id] [int] NULL,
	[value] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[extension]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[extension](
	[id] [int] NOT NULL,
	[name] [varchar](50) NULL,
	[prefix] [varchar](50) NULL,
	[uri] [text] NULL,
 CONSTRAINT [PK_extension] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[log_has_attribute]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[log_has_attribute](
	[log_id] [int] NULL,
	[trace_global] [bit] NULL,
	[event_global] [bit] NULL,
	[attribute_id] [int] NULL,
	[value] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[trace_has_attribute]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trace_has_attribute](
	[trace_id] [int] NULL,
	[attribute_id] [int] NULL,
	[value] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[attribute]  WITH CHECK ADD  CONSTRAINT [FK_attribute_attribute] FOREIGN KEY([parent_id])
REFERENCES [dbo].[attribute] ([id])
GO
ALTER TABLE [dbo].[attribute] CHECK CONSTRAINT [FK_attribute_attribute]
GO
ALTER TABLE [dbo].[attribute]  WITH CHECK ADD  CONSTRAINT [FK_attribute_extension] FOREIGN KEY([extension_id])
REFERENCES [dbo].[extension] ([id])
GO
ALTER TABLE [dbo].[attribute] CHECK CONSTRAINT [FK_attribute_extension]
GO
ALTER TABLE [dbo].[classifier]  WITH CHECK ADD  CONSTRAINT [FK_classifier_log] FOREIGN KEY([log_id])
REFERENCES [dbo].[log] ([id])
GO
ALTER TABLE [dbo].[classifier] CHECK CONSTRAINT [FK_classifier_log]
GO
ALTER TABLE [dbo].[event]  WITH CHECK ADD  CONSTRAINT [FK_event_event_collection] FOREIGN KEY([event_collection_id])
REFERENCES [dbo].[event_collection] ([id])
GO
ALTER TABLE [dbo].[event] CHECK CONSTRAINT [FK_event_event_collection]
GO
ALTER TABLE [dbo].[event_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_event_has_attribute_attribute] FOREIGN KEY([attribute_id])
REFERENCES [dbo].[attribute] ([id])
GO
ALTER TABLE [dbo].[event_has_attribute] CHECK CONSTRAINT [FK_event_has_attribute_attribute]
GO
ALTER TABLE [dbo].[event_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_event_has_attribute_event] FOREIGN KEY([event_id])
REFERENCES [dbo].[event] ([id])
GO
ALTER TABLE [dbo].[event_has_attribute] CHECK CONSTRAINT [FK_event_has_attribute_event]
GO
ALTER TABLE [dbo].[log_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_log_has_attribute_attribute] FOREIGN KEY([attribute_id])
REFERENCES [dbo].[attribute] ([id])
GO
ALTER TABLE [dbo].[log_has_attribute] CHECK CONSTRAINT [FK_log_has_attribute_attribute]
GO
ALTER TABLE [dbo].[log_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_log_has_attribute_log] FOREIGN KEY([log_id])
REFERENCES [dbo].[log] ([id])
GO
ALTER TABLE [dbo].[log_has_attribute] CHECK CONSTRAINT [FK_log_has_attribute_log]
GO
ALTER TABLE [dbo].[log_has_trace]  WITH CHECK ADD  CONSTRAINT [FK_log_has_trace_log] FOREIGN KEY([log_id])
REFERENCES [dbo].[log] ([id])
GO
ALTER TABLE [dbo].[log_has_trace] CHECK CONSTRAINT [FK_log_has_trace_log]
GO
ALTER TABLE [dbo].[log_has_trace]  WITH CHECK ADD  CONSTRAINT [FK_log_has_trace_trace] FOREIGN KEY([trace_id])
REFERENCES [dbo].[trace] ([id])
GO
ALTER TABLE [dbo].[log_has_trace] CHECK CONSTRAINT [FK_log_has_trace_trace]
GO
ALTER TABLE [dbo].[trace_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_trace_has_attribute_attribute] FOREIGN KEY([attribute_id])
REFERENCES [dbo].[attribute] ([id])
GO
ALTER TABLE [dbo].[trace_has_attribute] CHECK CONSTRAINT [FK_trace_has_attribute_attribute]
GO
ALTER TABLE [dbo].[trace_has_attribute]  WITH CHECK ADD  CONSTRAINT [FK_trace_has_attribute_trace] FOREIGN KEY([trace_id])
REFERENCES [dbo].[trace] ([id])
GO
ALTER TABLE [dbo].[trace_has_attribute] CHECK CONSTRAINT [FK_trace_has_attribute_trace]
GO
ALTER TABLE [dbo].[trace_has_event]  WITH CHECK ADD  CONSTRAINT [FK_trace_has_event_event] FOREIGN KEY([event_id])
REFERENCES [dbo].[event] ([id])
GO
ALTER TABLE [dbo].[trace_has_event] CHECK CONSTRAINT [FK_trace_has_event_event]
GO
ALTER TABLE [dbo].[trace_has_event]  WITH CHECK ADD  CONSTRAINT [FK_trace_has_event_trace] FOREIGN KEY([trace_id])
REFERENCES [dbo].[trace] ([id])
GO
ALTER TABLE [dbo].[trace_has_event] CHECK CONSTRAINT [FK_trace_has_event_trace]
GO
/****** Object:  StoredProcedure [dbo].[AlternateLeadsandPrev]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[AlternateLeadsandPrev]
@logId int,
@noOfRows int,
@type varchar(10)
as
begin

	declare @totalActivities int;
	set @totalActivities = (select count(distinct Activity) from LogData(@logID, @noOfRows)) -1

	if @type = 'lead'
	begin

		declare @leadActivities table
			(
				activity varchar(100),
				activity_lead varchar(100),
				position int
			)

		while (@totalActivities > 0)
		begin
			insert into @leadActivities
			select Activity, lead(Activity, @totalActivities) over(partition by trace_id order by trace_id, timestamp) as activity_lead, @totalActivities
			from LogData(@logID, @noOfRows)


			set @totalActivities = @totalActivities -1
		end

		select activity, activity_lead, ROW_NUMBER() over (partition by activity order by activity, min(position))
		from @leadActivities
		where activity is not null and activity_lead is not null and activity != activity_lead
		group by activity, activity_lead
		order by activity, min(position)
	end
	else if @type = 'prev'
	begin
		declare @prevActivities table
		(
			activity_prev varchar(100),
			activity varchar(100),
			position int
		)
		
		while (@totalActivities > 0)
		begin
			insert into @prevActivities
			select lag(Activity, @totalActivities) over(partition by trace_id order by trace_id, timestamp) as activity_prev, Activity, @totalActivities
			from LogData(@logID, @noOfRows)


			set @totalActivities = @totalActivities -1
		end

		select activity_prev, activity,  ROW_NUMBER() over (partition by activity order by activity, min(position))
		from @prevActivities
		where activity is not null and activity_prev is not null and activity != activity_prev
		group by activity_prev, activity
		order by activity, min(position)
	end
end

GO
/****** Object:  StoredProcedure [dbo].[CreateAttribute]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CreateAttribute]
@eventId int,
@attributeKey varchar(max),
@attributeType varchar(max),
@attributeValue text
as
begin
	declare @attributeId int

	set @attributeId = (select top 1 id from attribute where attr_key = @attributeKey)

	if @attributeId is null
	begin
		insert into attribute(attr_key, attr_type) values (@attributeKey, @attributeType)
	
		set @attributeId = (select max(id) from attribute)
	end

	insert into event_has_attribute(event_id, attribute_id, [value]) values (@eventId, @attributeId, @attributeValue)
end
GO
/****** Object:  StoredProcedure [dbo].[CreateEvent]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CreateEvent]
@logId varchar(160),
@trace varchar(150),
@conecptName varchar(150),
@Timestamp datetime,
@eventId int output
as
begin
	declare @eventCollectionId int
	declare @traceId int
	set @eventCollectionId = (select top 1 id from event_collection where [name] = @conecptName)
	
	if @eventCollectionId is null
	begin
		insert into event_collection( [name]) values (@conecptName)
		set @eventCollectionId = (select max(id) from event_collection )
	end
	insert into event(event_collection_id, [timestamp]) values(@eventCollectionId, @Timestamp)

	set @eventId = (select max(id) from event)

	set @traceId = (select id from trace where value = @logId)

	if @traceId is not null
	begin
		insert into trace_has_event(trace_id, event_id) values (@traceId, @eventId)

		return @eventId
	end
	else
	begin
		return -1
	end
end
GO
/****** Object:  StoredProcedure [dbo].[GetAlternatePrecedenceDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [dbo].[GetAlternatePrecedenceDeclareConstraints]
@logID int, 
@noOfRows int
as
begin
	declare @discoveredAlternatePrecedenceConstraints table
	(
		TypeOfConstraint varchar(100),
		A varchar(500),
		B varchar(500),
		support varchar(25),
		confidence varchar(25)
	)

	insert into @discoveredAlternatePrecedenceConstraints
	select 'alternateprecedence' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.B
	inner join LogData(@logID, @noOfRows) lv2
	on c.A = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) a
							where a.Activity = c.A and  lv1.trace_id = a.trace_id and a.timestamp < lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc

	declare @prevActivities table
	(
		activity_prev varchar(100),
		activity varchar(100),
		id int
	)

	insert into @prevActivities
	exec AlternateLeadsandPrev @logID, @noOfRows, 'prev'


	select ar.TypeOfConstraint, l.activity_prev as A, ar.B
	from (	
			select d.TypeOfConstraint, d.B, min(pa.id) as id
			from @prevActivities pa inner join @discoveredAlternatePrecedenceConstraints d
			on pa.activity_prev = d.A and pa.activity = d.B
			group by d.TypeOfConstraint, d.B

		 ) ar inner join @prevActivities l
	    on ar.B = l.activity and ar.id = l.id 

end
GO
/****** Object:  StoredProcedure [dbo].[GetAlternateResponseDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [dbo].[GetAlternateResponseDeclareConstraints]
@logID int, 
@noOfRows int
as
begin
	declare @discoveredAlternateResponseConstraints table
	(
		TypeOfConstraint varchar(100),
		A varchar(500),
		B varchar(500),
		support varchar(25),
		confidence varchar(25)
	)

	insert into @discoveredAlternateResponseConstraints
	select 'alternateresponse' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.A
	inner join LogData(@logID, @noOfRows) lv2
	on c.B = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) b
							where b.Activity = c.B and  lv1.trace_id = b.trace_id and b.timestamp > lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc


	declare @leadActivities table
	(
		activity varchar(100),
		activity_lead varchar(100),
		id int
	)

	insert into @leadActivities
	exec AlternateLeadsandPrev @logID, @noOfRows, 'lead'


	select ar.TypeOfConstraint, ar.A, l.activity_lead as B
	from (	
			select d.TypeOfConstraint, d.A, min(la.id) as id
			from @leadActivities la inner join @discoveredAlternateResponseConstraints d
			on la.activity = d.A and la.activity_lead = d.B
			group by d.TypeOfConstraint, d.A
		 ) ar inner join @leadActivities l
	    on ar.A = l.activity and ar.id = l.id 

end
GO
/****** Object:  StoredProcedure [dbo].[GetChainPrecedenceDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [dbo].[GetChainPrecedenceDeclareConstraints]
@logID int, 
@noOfRows int null
as
begin

	declare @discoveredChainPrecedenceConstraints table
	(
		TypeOfConstraint varchar(100),
		A varchar(500),
		B varchar(500),
		support varchar(25),
		confidence varchar(25)
	)

	insert into @discoveredChainPrecedenceConstraints
	select 'chainprecedence' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.B
	inner join LogData(@logID, @noOfRows) lv2
	on c.A = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) a
							where a.Activity = c.A and  lv1.trace_id = a.trace_id and a.timestamp < lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc

	declare @prevActivities table
	(
		activity_prev varchar(100),
		activity varchar(100)
	)
	
	insert into @prevActivities
	select distinct lag(Activity, 1) over(order by trace_id, timestamp) as activity_prev, Activity
	from LogData(@logID, @noOfRows)


	select distinct d.*
	from @prevActivities pa inner join @discoveredChainPrecedenceConstraints d
	on pa.activity = d.A and pa.activity_prev =d.B
	where pa.activity is not null and pa.activity_prev is not null

end
GO
/****** Object:  StoredProcedure [dbo].[GetChainResponseDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [dbo].[GetChainResponseDeclareConstraints]
@logID int, 
@noOfRows int
as
begin
	declare @discoveredChainResponseConstraints table
	(
		TypeOfConstraint varchar(100),
		A varchar(500),
		B varchar(500),
		support varchar(25),
		confidence varchar(25)
	)

	insert into @discoveredChainResponseConstraints
	select 'chainresponse' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.A
	inner join LogData(@logID, @noOfRows) lv2
	on c.B = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) b
							where b.Activity = c.B and  lv1.trace_id = b.trace_id and b.timestamp > lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc


	declare @leadActivities table
	(
		activity varchar(100),
		activity_lead varchar(100)
	)

	insert into @leadActivities
	select distinct Activity, lead(Activity, 1) over(order by trace_id, timestamp) as activity_lead
	from LogData(@logID, @noOfRows)


	select distinct d.*
	from @leadActivities la inner join @discoveredChainResponseConstraints d
	on la.activity = d.A and la.activity_lead =d.B
	where la.activity is not null and la.activity_lead is not null

end

GO
/****** Object:  StoredProcedure [dbo].[GetPrecedenceDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetPrecedenceDeclareConstraints]
@logID int, 
@noOfRows int
as
begin

	select 'precedence' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.B
	inner join LogData(@logID, @noOfRows) lv2
	on c.A = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) a
							where a.Activity = c.A and  lv1.trace_id = a.trace_id and a.timestamp < lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc
end
GO
/****** Object:  StoredProcedure [dbo].[GetRespondedExistenceDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetRespondedExistenceDeclareConstraints]
@logID int, 
@noOfRows int
as
begin

	select 'RespondedExistence' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.A
	inner join LogData(@logID, @noOfRows) lv2
	on c.B = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) b
							where b.Activity = c.B and lv1.trace_id = b.trace_id and c.A != c.B order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc
end
GO
/****** Object:  StoredProcedure [dbo].[GetResponseDeclareConstraints]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetResponseDeclareConstraints]
@logID int, 
@noOfRows int
as
begin
	select 'response' as TypeOfConstraint, c.A as A, c.B as B, (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) as Support, (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) as Confidence
	from LogData(@logID, @noOfRows) lv1 inner join ActivityCombinations(@logID) c
	on lv1.Activity = c.A
	inner join LogData(@logID, @noOfRows) lv2
	on c.B = lv2.Activity
	where lv2.event_id in 
						(select top 1 event_id 
							from LogData(@logID, @noOfRows) b
							where b.Activity = c.B and  lv1.trace_id = b.trace_id and b.timestamp > lv1.timestamp order by Timestamp desc)
	group by c.A, c.B
	having (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0)) >0.7 and (( (count(distinct lv1.event_id)/((select count(distinct event_id) from LogData(@logID, @noOfRows) where Activity = c.A) + .0))*(select count(distinct trace_id) from LogData(@logID, @noOfRows) where Activity = c.A))/((select  count(distinct trace_id) from LogData(@logID, @noOfRows))+.0)) > 0.3
	order by Support desc
end
GO
/****** Object:  StoredProcedure [dbo].[InsertLog]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[InsertLog]
@LogName varchar(500),
@LogId int output
as
begin
	insert into log(name) values (@LogName)

	set @LogId = (select max(id) from log)

	return @LogId
end
GO
/****** Object:  StoredProcedure [dbo].[InsertTraces]    Script Date: 11/27/2021 10:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[InsertTraces]
@logId int,
@trace varchar(150)
as
begin
	
	insert into trace(value) values(@trace)

	declare @traceId int
	set @traceId = (select max(id) from trace)

	insert into log_has_trace(log_id, trace_id) values (@logId, @traceId)
end
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[66] 4[3] 2[12] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "trace"
            Begin Extent = 
               Top = 185
               Left = 1097
               Bottom = 264
               Right = 1267
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "log_has_trace"
            Begin Extent = 
               Top = 200
               Left = 803
               Bottom = 313
               Right = 973
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "trace_has_event"
            Begin Extent = 
               Top = 6
               Left = 1306
               Bottom = 119
               Right = 1476
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "event_collection"
            Begin Extent = 
               Top = 6
               Left = 474
               Bottom = 102
               Right = 644
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "event"
            Begin Extent = 
               Top = 199
               Left = 217
               Bottom = 324
               Right = 407
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "log"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 144' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Log_View'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
         Alias = 2175
         Table = 3405
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Log_View'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Log_View'
GO
