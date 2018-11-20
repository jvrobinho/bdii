select a.owner, a.constraint_name, a.table_name, a.column_name
    from user_cons_columns a, user_constraints b
    where a.owner = b.owner
    and b.constraint_type='R'
    and a.constraint_name = b.constraint_name;
    