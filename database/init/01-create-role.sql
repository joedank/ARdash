-- Create the josephmcmyne role if it doesn't exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'josephmcmyne') THEN
      CREATE ROLE josephmcmyne WITH LOGIN SUPERUSER PASSWORD '';
   END IF;
END
$$;
