create index if not exists IX_scr_page__id_order__upload_success on scr_page(id_order, upload_success);

create index if not exists IX_scr_page__id_order__upload_success__parse_success on scr_page(id_order, upload_success, parse_success);

create index if not exists IX_dfyl_result__create_time_desc on dfyl_result(create_time desc);
