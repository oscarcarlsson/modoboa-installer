# This file is opened as root, so it should be owned by root and mode 0600.
#
# http://wiki2.dovecot.org/AuthDatabase/SQL
#
# For the sql passdb module, you'll need a database with a table that
# contains fields for at least the username and password. If you want to
# use the user@domain syntax, you might want to have a separate domain
# field as well.
#
# If your users all have the same uig/gid, and have predictable home
# directories, you can use the static userdb module to generate the home
# dir based on the username and domain. In this case, you won't need fields
# for home, uid, or gid in the database.
#
# If you prefer to use the sql userdb module, you'll want to add fields
# for home, uid, and gid. Here is an example table:
#
# CREATE TABLE users (
#     username VARCHAR(128) NOT NULL,
#     domain VARCHAR(128) NOT NULL,
#     password VARCHAR(64) NOT NULL,
#     home VARCHAR(255) NOT NULL,
#     uid INTEGER NOT NULL,
#     gid INTEGER NOT NULL,
#     active CHAR(1) DEFAULT 'Y' NOT NULL
# );

# Database driver: mysql, pgsql, sqlite
driver = %db_driver

# Database connection string. This is driver-specific setting.
#
# HA / round-robin load-balancing is supported by giving multiple host
# settings, like: host=sql1.host.org host=sql2.host.org
#
# pgsql:
#   For available options, see the PostgreSQL documention for the
#   PQconnectdb function of libpq.
#   Use maxconns=n (default 5) to change how many connections Dovecot can
#   create to pgsql.
#
# mysql:
#   Basic options emulate PostgreSQL option names:
#     host, port, user, password, dbname
#
#   But also adds some new settings:
#     client_flags        - See MySQL manual
#     ssl_ca, ssl_ca_path - Set either one or both to enable SSL
#     ssl_cert, ssl_key   - For sending client-side certificates to server
#     ssl_cipher          - Set minimum allowed cipher security (default: HIGH)
#     option_file         - Read options from the given file instead of
#                           the default my.cnf location
#     option_group        - Read options from the given group (default: client)
# 
#   You can connect to UNIX sockets by using host: host=/var/run/mysql.sock
#   Note that currently you can't use spaces in parameters.
#
# sqlite:
#   The path to the database file.
#
# Examples:
#   connect = host=192.168.1.1 dbname=users
#   connect = host=sql.example.com dbname=virtual user=virtual password=blarg
#   connect = /etc/dovecot/authdb.sqlite
#
#connect =
connect = host=%dbhost dbname=%modoboa_dbname user=%modoboa_dbuser password=%modoboa_dbpassword

# Default password scheme.
#
# List of supported schemes is in
# http://wiki2.dovecot.org/Authentication/PasswordSchemes
#
#default_pass_scheme = MD5

# passdb query to retrieve the password. It can return fields:
#   password - The user's password. This field must be returned.
#   user - user@domain from the database. Needed with case-insensitive lookups.
#   username and domain - An alternative way to represent the "user" field.
#
# The "user" field is often necessary with case-insensitive lookups to avoid
# e.g. "name" and "nAme" logins creating two different mail directories. If
# your user and domain names are in separate fields, you can return "username"
# and "domain" fields instead of "user".
#
# The query can also return other fields which have a special meaning, see
# http://wiki2.dovecot.org/PasswordDatabase/ExtraFields
#
# Commonly used available substitutions (see http://wiki2.dovecot.org/Variables
# for full list):
#   %%u = entire user@domain
#   %%n = user part of user@domain
#   %%d = domain part of user@domain
# 
# Note that these can be used only as input to SQL query. If the query outputs
# any of these substitutions, they're not touched. Otherwise it would be
# difficult to have eg. usernames containing '%%' characters.
#
# Example:
#   password_query = SELECT userid AS user, pw AS password \
#     FROM users WHERE userid = '%%u' AND active = 'Y'
#
#password_query = \
#  SELECT username, domain, password \
#  FROM users WHERE username = '%%n' AND domain = '%%d'

# userdb query to retrieve the user information. It can return fields:
#   uid - System UID (overrides mail_uid setting)
#   gid - System GID (overrides mail_gid setting)
#   home - Home directory
#   mail - Mail location (overrides mail_location setting)
#
# None of these are strictly required. If you use a single UID and GID, and
# home or mail directory fits to a template string, you could use userdb static
# instead. For a list of all fields that can be returned, see
# http://wiki2.dovecot.org/UserDatabase/ExtraFields
#
# Examples:
#   user_query = SELECT home, uid, gid FROM users WHERE userid = '%%u'
#   user_query = SELECT dir AS home, user AS uid, group AS gid FROM users where userid = '%%u'
#   user_query = SELECT home, 501 AS uid, 501 AS gid FROM users WHERE userid = '%%u'
#
#user_query = \
#  SELECT home, uid, gid \
#  FROM users WHERE username = '%%n' AND domain = '%%d'

# If you wish to avoid two SQL lookups (passdb + userdb), you can use
# userdb prefetch instead of userdb sql in dovecot.conf. In that case you'll
# also have to return userdb fields in password_query prefixed with "userdb_"
# string. For example:
#password_query = \
#  SELECT userid AS user, password, \
#    home AS userdb_home, uid AS userdb_uid, gid AS userdb_gid \
#  FROM users WHERE userid = '%%u'
password_query = SELECT email AS user, password FROM core_user WHERE email='%%u' and is_active=1 and master_user=1

# Query to get a list of all usernames.
#iterate_query = SELECT username AS user FROM users
