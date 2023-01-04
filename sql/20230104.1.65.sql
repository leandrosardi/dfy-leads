ALTER TABLE public."user" ALTER COLUMN scraper_ppp SET DEFAULT 0.0179;
update "user" set scraper_ppp=0.0179 where scraper_ppp < 0.0179