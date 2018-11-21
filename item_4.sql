
/*******************************************************************/
/*Item 4:                                                          */
/*  Gera dinamicamente o script de criação das tabelas,            */
/*  usando cursores explícitos, com as seguintes informações:      */
/*  Nome da tabela, nomes das colunas, tipo da coluna,             */
/*  tamanho do dado (quando necessário), nulidade/obrigatoriedade  */
/*  , chaves primárias e estrangeiras.                             */
/*******************************************************************/        
create or replace procedure create_tables is

--Nome da tabela atual.
v_table_name user_tables.table_name%type;

--Nome da coluna, tipo do dado, tamanho do dado, nome da tabela a qual a coluna pertence e nulidade da tabela.
v_column_name user_tab_columns.column_name%type;
v_data_type user_tab_columns.data_type%type;
v_data_length user_tab_columns.data_length%type;
v_data_table_name user_tab_columns.table_name%type;
v_data_nullable user_tab_columns.nullable%type;

--Nome da PK, nome da tabela a qual a PK pertence, nome da coluna que a PK referencia.
v_pk user_constraints.constraint_name%type;
v_pk_table_name user_constraints.table_name%type;
v_index_name user_cons_columns.column_name%type;

--Contador para saber se a PK é simples ou composta.
v_counter NUMBER := 0;

--Nome da FK, tabela a qual ela pertence e coluna.
v_fk_name user_constraints.constraint_name%type;
v_fk_table user_constraints.table_name%type;
v_fk_column user_cons_columns.column_name%type;

--Coluna e tabela que a FK referencia.
v_fk_column_ref user_cons_columns.column_name%type;
v_index_table user_constraints.table_name%type;

--Seleciona o nome das tabelas.
cursor c_table_name is
    select table_name
    from user_tables;
    
--Pega os dados das tabelas.
cursor c_data is
    select a.column_name, a.data_type, a.data_length, a.table_name, a.nullable
    from user_tab_columns a, user_tables b
    where a.table_name = b.table_name
    order by table_name, a.column_id;

    
--Pega o nome das chaves primárias e a tabela às quais pertencem.
cursor c_pk is
        select distinct a.constraint_name, a.table_name from user_constraints a
        where a.constraint_type = 'P';

--Pega o nome da coluna referenciada pela PK, usando o nome de uma tabela como parâmetro.        
cursor c_pkname(v_table_name in user_tables.table_name%type) is
        select a.column_name
        from user_cons_columns a, user_constraints b
        where a.owner = b.owner
        and b.constraint_type='P'
        and a.constraint_name = b.constraint_name
        and a.table_name = v_table_name;

--Pega os dados da FK
cursor c_fk is
    select a.constraint_name as FK, a.table_name as FK_TABLE, b.column_name as FK_COLUMN,
        b_ref.column_name as REFS_COLUMN, a_ref.table_name as ON_TABLE
    from user_constraints a
        left join user_cons_columns b on b.constraint_name = a.constraint_name
        left join user_constraints a_ref on a_ref.constraint_name = a.r_constraint_name
        left join user_cons_columns b_ref on b_ref.constraint_name = a.r_constraint_name
    where a.constraint_type = 'R'
    order by a.table_name, b.column_name;
BEGIN
    --Passo 1: criar tabelas com colunas e primary keys
    open c_table_name; 
    
    --Colunas
    loop    --Table name - create table
        fetch c_table_name into v_table_name;
        exit when c_table_name%notfound;    --Terminou de varrer a tabela?
        DBMS_OUTPUT.PUT_LINE('CREATE TABLE '||v_table_name||'(');   
        
        --Passo 1.1: Pega os dados das tabelas e printa.
        open c_data;
        loop --Columns
            fetch c_data into v_column_name, v_data_type, v_data_length, v_data_table_name, v_data_nullable;
            exit when c_data%notfound;      --Terminou de varrer a tabela?
            
                --Achou uma row com os dados da tabela.
                if(v_data_table_name = v_table_name) then
                    DBMS_OUTPUT.PUT('   ' || v_column_name||' '||v_data_type);
                    if (v_data_type != 'NUMBER') then      --Tamanho do VARCHAR.
                        DBMS_OUTPUT.PUT(' ('||v_data_length||')');
                    end if;
                    if(v_data_nullable = 'N') then          --Dado obrigatório.
                        DBMS_OUTPUT.PUT(' NOT NULL');
                    end if;
                    DBMS_OUTPUT.PUT_LINE(',');              --Próximo dado
                end if;
                
        end loop;--end Columns
        
    --Terminou de gerar as colunas.
    close c_data;
    
    --Passo 1.2: Gerar as PK.
    open c_pk;
    loop --PK name
        fetch c_pk into v_pk, v_pk_table_name;
        exit when c_pk%notfound;        --Terminou de varrer a tabela das PK?    
        if(v_pk_table_name = v_table_name) then         --Achou a PK da tabela atual.
            DBMS_OUTPUT.PUT('   CONSTRAINT ' || v_pk || ' PRIMARY KEY (');
        end if;
        
        --Pegar a(s) coluna(s) referenciada(s) pela PK.
        open c_pkname(v_pk_table_name);
        loop --Table name, Column name - PK
            fetch c_pkname into v_index_name;
            exit when c_pkname%notfound;        --Terminou de buscar as colunas?        
                
            if(v_pk_table_name = v_table_name) then     --Achou a coluna da tabela.
                if(v_counter > 0) then                  --Se ainda não saiu no exit when,
                    DBMS_OUTPUT.PUT(', ');              --é porque ainda tem mais colunas na chave primária.
                end if;                                 --Então, precisa de vírgula.
                DBMS_OUTPUT.PUT(v_index_name);          --Printa o nome da coluna, ou seja, coloca ele na constraint.
                v_counter := v_counter + 1;             
            end if;
        end loop; -- end Table Name, Column Name - PK
        v_counter :=0;          --Reseta o contador para a próxima PK.
        
        --Terminou de gerar a PK dessa tabela.
        close c_pkname;        
        end loop; -- end PK name        
        DBMS_OUTPUT.PUT_LINE(')');
        
        --Terminou de gerar as PK.
        close c_pk;
        
        
    DBMS_OUTPUT.PUT_LINE(');');
    DBMS_OUTPUT.PUT_LINE('');

    end loop; --end Table Name - Create
    
    --Terminou de gerar os scripts de create table.
    close c_table_name;
    
        --Passo 1.3: Alterar as tabelas com as FKs.
        open c_fk;
        loop
            fetch c_fk into v_fk_name, v_fk_table, v_fk_column, v_fk_column_ref, v_index_table;
            exit when c_fk%notfound;
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || v_fk_table || ' ADD CONSTRAINT ' || v_fk_name);
            DBMS_OUTPUT.PUT_LINE('  FOREIGN KEY (' ||  v_fk_column || ') ' || 'REFERENCES '  
                                    || v_index_table || '(' || v_fk_column_ref || ') ;' );
            DBMS_OUTPUT.PUT_LINE('');
        end loop;
        close c_fk;
END;

--Seta o tamanho maximo da output. Descomente para executar
--set serveroutput on size 30000;
--execute create_tables;