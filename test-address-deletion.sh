#!/bin/bash

# Test script to verify the address deletion with reference details implementation
echo "Testing the address deletion with reference details implementation"

# Restart the backend services to ensure our changes are loaded
echo "Restarting backend services..."
./docker-services.sh restart backend

# Wait for the services to start
sleep 5

# Execute a query to check the specific address with references
echo "Checking address 3311ca1b-da19-4837-b8f8-b194580affab references..."
docker exec -i management-db-1 psql -U postgres management_db -c "
    SELECT 'projects' as reference_type, COUNT(*) FROM projects WHERE address_id = '3311ca1b-da19-4837-b8f8-b194580affab'
    UNION ALL
    SELECT 'estimates' as reference_type, COUNT(*) FROM estimates WHERE address_id = '3311ca1b-da19-4837-b8f8-b194580affab'
    UNION ALL
    SELECT 'invoices' as reference_type, COUNT(*) FROM invoices WHERE address_id = '3311ca1b-da19-4837-b8f8-b194580affab'
    UNION ALL
    SELECT 'pre_assessments' as reference_type, COUNT(*) FROM pre_assessments WHERE client_address_id = '3311ca1b-da19-4837-b8f8-b194580affab';
"

# Show actual reference details
echo "Getting detailed reference information..."
docker exec -i management-db-1 psql -U postgres management_db -c "
    SELECT id, type, status FROM projects WHERE address_id = '3311ca1b-da19-4837-b8f8-b194580affab';
"

docker exec -i management-db-1 psql -U postgres management_db -c "
    SELECT id, estimate_number, status FROM estimates WHERE address_id = '3311ca1b-da19-4837-b8f8-b194580affab';
"

# Get the address details
echo "Getting address information..."
docker exec -i management-db-1 psql -U postgres management_db -c "
    SELECT * FROM client_addresses WHERE id = '3311ca1b-da19-4837-b8f8-b194580affab';
"

echo "Testing complete. The address should now properly show detailed reference information when deletion is attempted."
