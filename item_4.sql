/* ************************************************************************** */

/*Consulta todas as tabelas no schema*/
select * from user_tables;

/*Consulta as colunas das tabelas do schema*/
select * from user_tab_columns;

/*Consulta as primary keys das tabelas*/
/*Vai precisar abrir um cursor com esse comando e iterar sobre o cursor*/
select cols.table_name, cols.column_name, cols.position, cons.status, cons.owner
from user_constraints cons, user_cons_columns cols
where cons.constraint_type = 'P'
and cons.constraint_name = cols.constraint_name
and cons.owner = cols.owner
order by cols.table_name, cols.position; --essa linha nao vai precisar


/*
Item 4:

Ideia:

Um cursor pra pegar o nome das tabelas
Um cursor pra pegar o nome das colunas e criar as colunas
Um cursor pra dar alter table com primary key
Um cursor pra dar alter table com foreign keys
*/
