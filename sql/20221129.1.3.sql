-- Link page results with a lead. 
-- Note that the same lead may be found by more than 1 search.
create table if not exists dfyl_result (
    id uuid not null primary key,
    create_time timestamp not null,
    id_page uuid not null references scr_page(id),
    id_lead uuid not null references fl_lead(id)
);

-- people results have pagination, so we need to know the page number.
alter table scr_page add column if not exists "number" bigint not null default 0;
 
-- use a fl_search object to save its filters.
--alter table scr_order add column if not exists id_search uuid /*not*/ null references fl_search(id);
alter table scr_order drop column if exists id_export;

-- after processing, the same process add all the leads to an export list for automated CSV file generation.
alter table scr_order add column if not exists id_export uuid /*not*/ null references fl_export("id");

-- scr_order search to track stats about the scraping, appending, and verification
alter table scr_order add column if not exists dfyl_stat_search_leads bigint null; -- how many leads were found in the source (eg: sales nav)
alter table scr_order add column if not exists dfyl_stat_scraped_pages bigint null; 
alter table scr_order add column if not exists dfyl_stat_scraped_leads bigint null;
alter table scr_order add column if not exists dfyl_stat_leads_appended bigint null;
alter table scr_order add column if not exists dfyl_stat_leads_verified bigint null;

-- Leads extension allows to filter by order.
alter table fl_search add column if not exists id_order uuid references scr_order(id) null;

-- Leads extension allows to filter by name.
alter table fl_search add column if not exists lead_name varchar(500) null;