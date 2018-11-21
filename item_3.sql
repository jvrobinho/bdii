/******************************************/
/*Item 3:                                 */
/*  Lista as FK com as tabelas e colunas. */
/******************************************/

select a.constraint_name as FK, a.table_name as FK_TABLE, b.column_name as FK_COLUMN,
    b_ref.column_name as REFS_COLUMN, a_ref.table_name as ON_TABLE
from user_constraints a
    left join user_cons_columns b on b.constraint_name = a.constraint_name
    left join user_constraints a_ref on a_ref.constraint_name = a.r_constraint_name
    left join user_cons_columns b_ref on b_ref.constraint_name = a.r_constraint_name
where a.constraint_type = 'R'
order by a.table_name, b.column_name;