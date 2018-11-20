select a.index_name, a.table_name, b.column_name
from user_indexes a, user_cons_columns b
where a.index_name = b.constraint_name;
