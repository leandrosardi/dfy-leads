create index if not exists IX_scr_page__id_order__upload_success on scr_page(id_order, upload_success);

create index if not exists IX_scr_page__id_order__upload_success__parse_success on scr_page(id_order, upload_success, parse_success);
