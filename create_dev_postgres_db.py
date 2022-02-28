'''
Created on Nov 23, 2019

@author: grose
'''

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
#import os
import io

#dir_path = os.path.dirname(os.path.realpath(__file__))
#print("Working directory is '%s'" % (dir_path,))

con = None
num_dbs = 0
sqlfile = None
try:
    
    # modify connection parameters below as needed
    con = psycopg2.connect(database="postgres", user="postgres", password="Password1!", host="127.0.0.1", port="5432")
    
    # in order to be able to issue CREATE DATABASE statements     
    con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = con.cursor()
    print("Connected to postgres db")
    
    # -- does user exists
    cur.execute("select * from pg_roles where rolname='%s'" % ('dev_user',))
    usr_exists = bool(cur.rowcount) 
 
    if usr_exists == False:
        sqlfile = open('dev_resources/Create dev_user.sql', 'r')
        cur.execute(sqlfile.read())
       
    db_name = "demo_dev"
    # db_name = "foo" 
    cur.execute("SELECT COUNT(*) AS num_dbs FROM pg_database WHERE datname = '" + db_name + "'")
    row = cur.fetchone()
    if row is not None:
        num_dbs = row[0]
        print(num_dbs)
    
    if num_dbs == 0:        
        cur.execute("CREATE DATABASE %s WITH OWNER = postgres ENCODING = 'UTF8'" % (db_name,))
        print("Created db '%s'" % (db_name,))

    cur.execute("GRANT TEMPORARY, CONNECT ON DATABASE demo_dev TO dev_user")
    cur.execute("GRANT ALL ON DATABASE demo_dev TO postgres")
        
    con.close()
    
    # connect to target db 
    con = psycopg2.connect(database="%s" % (db_name,), user="postgres", password="Password1!", host="127.0.0.1", port="5432")
    cur = con.cursor()
    print("Connected to db '%s'" % (db_name,))        
        
    # check for tables and create as needed     
    tables = ['entitlements', 'global_superstore', 'webapp_users']
    for table in tables:
        cur.execute("select * from information_schema.tables where table_name='%s'" % (table,))
        tbl_exists = bool(cur.rowcount) 
    
        if tbl_exists == True:
            print("Dropping table '%s'" % (table,))
            cur.execute("drop table %s" % (table,))
        else:
            print("Table '%s' not found. Creating it." % (table,))
            
    # create tables from file 
    sqlfile = open('dev_resources/Create Global_Superstore Tables Dev.sql', 'r')
    cur.execute(sqlfile.read())               
    con.commit();
    
    # finally insert data
    sqlfile = io.open('dev_resources/dev_inserts_utf_8.sql', mode='r', encoding='utf-8-sig')
    cur.execute(sqlfile.read())               
    con.commit();    
         
except (Exception, psycopg2.DatabaseError) as error:
    print(error)
    
finally:

    if cur is not None:
        cur.close()  
        
    if con is not None:
        con.close()       

print("Done.")