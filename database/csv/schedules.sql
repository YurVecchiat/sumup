create or replace TABLE SUMUP.CSV.SCHEDULES (
	AGENT VARCHAR(16777216), -- The name of the customer support agent.
	CHANNEL VARCHAR(16777216), -- The communication channel used by the customer to contact us.
	SCHEDULE_DATE DATE, -- The date on which a task or event is scheduled to occur.
	SCHEDULED_HOURS NUMBER(38,0) -- The number of hours allocated for a particular task or event.
)
	comment = 'Table contains containing information about the productive hours worked by SumUps customer support agents.'
;
