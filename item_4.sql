/* ************************************************************************** */
/*  Item 1:
        Consulta os indíces e as tabelas e colunas que eles referenciam**/
select a.index_name, a.table_name, b.column_name
from user_indexes a, user_cons_columns b
where a.index_name = b.constraint_name;

/* ************************************************************************** */
/*Consulta as constraints do usuario. Usando para ver o metadata das FK e PK*/
select * from user_constraints;

/*Consulta todas as tabelas colunas referenciadas pelas constraints do usuário*/
select * from user_cons_columns;

/*  Item 2:
        Dropa todos os índices criados em uma tabela */
create or replace procedure drop_all_indexes(nome_tabela in string) is
begin 
    for ind in 
    (
        select index_name
        from user_indexes
        where table_name = nome_tabela
        and index_name not in
       (
            select unique index_name
            from user_constraints
            where table_name = nome_tabela
            and index_name is not null
       )
    )
    loop
        execute immediate 'drop index'||ind.index_name;
    end loop;
end;

--execute drop_all_indexes('ALBUM');

/* ************************************************************************** */
/*  Item 3:
        Lista as FK com as tabelas e colunas*/
        
select a.owner, a.constraint_name, a.table_name, a.column_name
    from user_cons_columns a, user_constraints b
    where a.owner = b.owner
    and b.constraint_type='R'
    and a.constraint_name = b.constraint_name;

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
order by cols.table_name, cols.position;
/*
Item 4:

Ideia:

Um cursor pra pegar o nome das tabelas
Um cursor pra pegar o nome das colunas e criar as colunas
Um cursor pra dar alter table com primary key
Um cursor pra dar alter table com foreign keys
*/
--Aqui pega o nome das tabelas
SELECT table_name FROM user_tables;

--Aqui pega o nome das colunas dado uma tabela
select table_name, column_name, data_type, data_length
            from user_tab_columns;


create or replace procedure create_tables is
    BEGIN
    for ind in(
        select table_name
        from user_tables
    )
    
    loop
    DBMS_OUTPUT.PUT_LINE('CREATE TABLE '||ind.table_name||'(');
    for r in(
        select column_name, data_type, data_length
        from user_tab_columns
        where table_name = ind.table_name
    )
    loop    
    DBMS_OUTPUT.PUT_LINE(r.column_name||' '||r.data_type||'('||r.data_length||')');
    end loop;
    DBMS_OUTPUT.PUT_LINE(');');
    end loop;
    END;
set serveroutput on size 30000;
execute create_tables;