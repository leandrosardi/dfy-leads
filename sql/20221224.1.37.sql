alter table scr_order add column if not exists dfyl_id_parent uuid null references scr_order("id");