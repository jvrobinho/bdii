select b.constraint_name as FK, b.table_name FK_TABLE, a.column_name as REF_COLUMN, a.table_name as ON_TABLE
    from user_cons_columns a, user_constraints b
    where b.constraint_type='R'
    and b.r_constraint_name = a.constraint_name;