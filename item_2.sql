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
