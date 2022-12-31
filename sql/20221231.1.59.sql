alter table scr_order add column if not exists dfyl_pagination_reservation_id uuid null;
alter table scr_order add column if not exists dfyl_pagination_reservation_time timestamp null;
alter table scr_order add column if not exists dfyl_pagination_reservation_times int null;
alter table scr_order add column if not exists dfyl_pagination_start_time timestamp null;
alter table scr_order add column if not exists dfyl_pagination_end_time timestamp null;
alter table scr_order add column if not exists dfyl_pagination_success bool null;
alter table scr_order add column if not exists dfyl_pagination_error_description text null;

alter table scr_order add column if not exists dfyl_splitting_reservation_id uuid null;
alter table scr_order add column if not exists dfyl_splitting_reservation_time timestamp null;
alter table scr_order add column if not exists dfyl_splitting_reservation_times int null;
alter table scr_order add column if not exists dfyl_splitting_start_time timestamp null;
alter table scr_order add column if not exists dfyl_splitting_end_time timestamp null;
alter table scr_order add column if not exists dfyl_splitting_success bool null;
alter table scr_order add column if not exists dfyl_splitting_error_description text null;

alter table scr_order add column if not exists dfyl_calculation_reservation_id uuid null;
alter table scr_order add column if not exists dfyl_calculation_reservation_time timestamp null;
alter table scr_order add column if not exists dfyl_calculation_reservation_times int null;
alter table scr_order add column if not exists dfyl_calculation_start_time timestamp null;
alter table scr_order add column if not exists dfyl_calculation_end_time timestamp null;
alter table scr_order add column if not exists dfyl_calculation_success bool null;
alter table scr_order add column if not exists dfyl_calculation_error_description text null;
