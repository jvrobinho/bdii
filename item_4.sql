create or replace procedure create_tables is
v_table_name user_tables.table_name%type;

v_column_name user_tab_columns.column_name%type;
v_data_type user_tab_columns.data_type%type;
v_data_length user_tab_columns.data_length%type;
v_data_table_name user_tab_columns.table_name%type;
v_data_nullable user_tab_columns.nullable%type;

v_pk user_constraints.constraint_name%type;
v_pk_table_name user_constraints.table_name%type;
v_index_name user_cons_columns.column_name%type;

v_counter NUMBER := 0;

cursor c_table_name is
    select table_name
    from user_tables;
cursor c_data is
    select a.column_name, a.data_type, a.data_length, a.table_name, a.nullable
    from user_tab_columns a, user_tables b
    where a.table_name = b.table_name;
cursor c_pk is
        select distinct a.constraint_name, a.table_name from user_constraints a
        where a.constraint_type = 'P';
cursor c_pkname(v_table_name in user_tables.table_name%type) is
        select a.column_name
        from user_cons_columns a, user_constraints b
        where a.owner = b.owner
        and b.constraint_type='P'
        and a.constraint_name = b.constraint_name
        and a.table_name = v_table_name;
    BEGIN
    open c_table_name; --step 1: criar tabelas com colunas e primary keys
    
    --Colunas
    loop--Table name - Create
        fetch c_table_name into v_table_name;
        exit when c_table_name%notfound;
        DBMS_OUTPUT.PUT_LINE('CREATE TABLE '||v_table_name||'(');   
        open c_data;
        loop --Colums
            fetch c_data into v_column_name, v_data_type, v_data_length, v_data_table_name, v_data_nullable;
            exit when c_data%notfound;
                if(v_data_table_name = v_table_name) then
--                    DBMS_OUTPUT.PUT_LINE(v_column_name||' '||v_data_type||'('||v_data_length||'),');
                    DBMS_OUTPUT.PUT(v_column_name||' '||v_data_type);
                    if (v_data_type = 'VARCHAR2') then
                        DBMS_OUTPUT.PUT(' ('||v_data_length||')');
                    end if;
                    if(v_data_nullable = 'N') then
                        DBMS_OUTPUT.PUT(' NOT NULL');
                    end if;
                    DBMS_OUTPUT.PUT_LINE(',');
                end if;
                
        end loop;--end Columns
    
    close c_data;
    
    open c_pk;
    loop --PK name // each PK
        fetch c_pk into v_pk, v_pk_table_name;
        exit when c_pk%notfound;   
        if(v_pk_table_name = v_table_name) then
            DBMS_OUTPUT.PUT('CONSTRAINT ' || v_pk || ' PRIMARY KEY (');
        end if;    
        open c_pkname(v_pk_table_name);
        loop --Table name, Column name - PK
            fetch c_pkname into v_index_name;
            exit when c_pkname%notfound;
                
            if(v_pk_table_name = v_table_name) then
                if(v_counter > 0) then
                    DBMS_OUTPUT.PUT(', ');
                end if;
                DBMS_OUTPUT.PUT(v_index_name);
                v_counter := v_counter + 1;    
            end if;
        end loop; -- end Table Name, Column Name - PK
        v_counter :=0;
        close c_pkname;        
        end loop; -- end PK name
        DBMS_OUTPUT.PUT_LINE(')');
        close c_pk;
    DBMS_OUTPUT.PUT_LINE(');');
    end loop; --end Table Name - Create
    close c_table_name; -- end of step 1
END;

set serveroutput on size 30000;
execute create_tables;

