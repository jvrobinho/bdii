-- Regra semantica 1: Não pode criar um artista sem nome    
create or replace TRIGGER check_artist_name 
    BEFORE INSERT OR UPDATE OF name ON artist
    FOR EACH ROW
        BEGIN
            IF(:new.name is NULL)THEN
                RAISE_APPLICATION_ERROR (-20000, 'O nome do artista não pode estar em branco');
            END IF;
        END;
        
--Regra semantica 2: Um employee deve ter HIRE DATE
CREATE OR REPLACE TRIGGER EMPLOYEE_HIRE_DATE 
    BEFORE INSERT OR UPDATE OF HIREDATE ON EMPLOYEE
    FOR EACH ROW
        BEGIN
            IF(:new.hiredate is null) then
                RAISE_APPLICATION_ERROR (-20000, 'O hire date não pode estar em branco');
            END IF;
        END;
--Regra semantica 3: Genre deve ter um nome       
CREATE OR REPLACE TRIGGER GENRE_NAME 
    BEFORE INSERT OR UPDATE ON GENRE 
    FOR EACH ROW
            BEGIN
                IF(:new.name is null) then
                    RAISE_APPLICATION_ERROR (-20000, 'O nome do gênero não pode estar em branco');
                END IF;
            END;
           
--Questao 3:
--Procedure pra Regra semantica 1:
create or replace PROCEDURE insert_artist(artist_id in number, name_artist in varchar2) IS
BEGIN
    IF name_artist is null THEN
        RAISE_APPLICATION_ERROR (-20000, 'O nome do artista não pode estar em branco');
    END IF;
    INSERT INTO artist VALUES (artist_id, name_artist);
END;

create or replace PROCEDURE update_name_artist(artist_id in number, name_artist in varchar2) IS
BEGIN
    IF name_artist is null THEN
        RAISE_APPLICATION_ERROR (-20000, 'O nome do artista não pode estar em branco');
    END IF;
    UPDATE artist set name = name_artist WHERE artistid = artist_id;
END;    

--Procedure  pra Regra semantica 2:
create or replace PROCEDURE insert_hiredate(employee_id in number,first_name in varchar2, last_name in varchar2, hire_date in date) IS
BEGIN
    IF hire_date is null THEN
        RAISE_APPLICATION_ERROR (-20000, 'O HireDate do Employee nao pode estar em branco');
    END IF;
    INSERT INTO employee VALUES (employee_id, first_name,last_name, hire_date);
END;

create or replace  PROCEDURE update_hiredate(employee_id in number,first_name in varchar2, last_name in varchar2, hire_date in date) IS
BEGIN
    IF hire_date is null THEN
        RAISE_APPLICATION_ERROR (-20000, 'O HireDate do Employee nao pode estar em branco');
    END IF;
    UPDATE employee set hiredate = hire_date WHERE employeeid = employee_id;
END;

--Procedure pra Regra semantica 3:

create or replace  PROCEDURE insert_genre_name(genreid in number, name_genre in varchar2) IS
BEGIN
    IF name_genre is null THEN
        RAISE_APPLICATION_ERROR (-20000,'O nome do genero nao pode estar em branco');
    END IF;
    INSERT INTO genre VALUES (genreid, name_genre);
END;

create or replace PROCEDURE update_name_genre(genre_id in number, name_genre in string) IS
BEGIN
    IF name_genre is null THEN
        RAISE_APPLICATION_ERROR (-20000,'O nome do genero nao pode estar em branco'); 
    END IF;
    UPDATE genre set name = name_genre WHERE genreid = genre_id;
END;    

--Comandos para criar o usuário.
--CREATE USER rand_user
--IDENTIFIED BY user123;

--GRANT CONNECT to rand_user;

--Permissões para o usuário interagir com o banco de dados.
--GRANT EXECUTE ON insert_artist TO rand_user;
--GRANT EXECUTE ON update_name_artist TO rand_user;

--GRANT EXECUTE ON insert_hire_date TO rand_user;
--GRANT EXECUTE ON update_hire_date TO rand_user;

--GRANT EXECUTE ON insert_genre_name TO rand_user;
--GRANT EXECUTE ON update_name_genre TO rand_user;
