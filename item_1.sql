/**************************************************************************************/
/*Item 1:                                                                             */
/*  Consulta os indíces do usuário, junto das tabelas e colunas que eles referenciam. */
/**************************************************************************************/
select index_name, table_name, column_name
from user_ind_columns
order by table_name;
