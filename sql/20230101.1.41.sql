alter table "user" add column if not exists scraper_enabled bool not null default true;