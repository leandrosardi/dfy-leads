-- scraping order is about replicating the fitlers of an `fl_search` on any site linke LinkedIn, and upload the HTML pages of its results.
-- user can request a reprocessing of the same search by duplicating the order.
create table if not exists scr_order (
    id uuid not null primary key,
    create_time timestamp not null,
    id_user uuid not null references "user"(id),
    "type" int not null, -- 0: sales navigator (use a fl_search object to save its filters).
    id_search uuid not null references fl_search(id),
    "url" text /*not*/ null -- the user don't have to provide it. It is added later by automation or manually.
);

alter table scr_order add column if not exists "name" int not null;
alter table scr_order add column if not exists delete_time timestamp null;
alter table scr_order add column if not exists "status" boolean not null;

-- after processing, the same process add all the leads to an export list for automated CSV file generation.
alter table scr_order add column if not exists id_export uuid /*not*/ null references fl_export("id");

-- HTML downloaded from the browser, and uploaded to CS, by the extension.
create table if not exists scr_page (
    id uuid not null primary key,
    create_time timestamp not null,
    id_order uuid not null references scr_order(id),
    "number" bigint not null, -- page number
    -- pampa fields for parsing
    parse_reservation_id varchar(500) null,
    parse_reservation_time timestamp null,
    parse_reservation_times int null,
    parse_start_time timestamp null,
    parse_end_time timestamp null,
    parse_success boolean null,
    parse_error_description text null
);

-- Link page results with a lead. 
-- Note that the same lead may be found by more than 1 search.
create table if not exists scr_result (
    id uuid not null primary key,
    create_time timestamp not null,
    id_page uuid not null references scr_page(id),
    id_lead uuid not null references fl_lead(id)
);

-- Trace when a user has its extension ACTIVE.
create table if not exists scr_activity (
    id uuid not null primary key,
    create_time timestamp not null,
    id_user uuid not null references "user"(id),
    "year" int not null,
    "month" int not null,
    "day" int not null,
    "hour" int not null,
    "minute" int not null,
    active boolean not null
);

-- adapt scr_order to manage scraping, and assign to a user.
alter table scr_order add column if not exists assign_reservation_id varchar(500) null;
alter table scr_order add column if not exists assign_reservation_time timestamp null;
alter table scr_order add column if not exists assign_reservation_times int null;
alter table scr_order add column if not exists assign_start_time timestamp null;
alter table scr_order add column if not exists assign_end_time timestamp null;
alter table scr_order add column if not exists assign_success boolean null;
alter table scr_order add column if not exists assign_error_description text null;

-- scr_order search to track stats about the scraping, appending, and verification
alter table scr_order add column if not exists stat_sns_search_leads bigint null;
alter table scr_order add column if not exists stat_sns_scraped_pages bigint null;
alter table scr_order add column if not exists stat_sns_scraped_leads bigint null;
alter table scr_order add column if not exists stat_sns_leads_appended bigint null;
alter table scr_order add column if not exists stat_sns_leads_verified bigint null;
