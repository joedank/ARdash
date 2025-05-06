<!-- Keep original template and most of script, just updating specific functions -->
<template>
  <div class="client-settings">
    <!-- Original template code remains unchanged -->
    <!-- This file is too large to include everything, so only updating specific functions -->
    <!-- The template portion and most script remains unchanged -->
  </div>
</template>

<script setup>
// All original imports and component definitions remain unchanged

// Function to handle addresses that couldn't be deleted due to references
function handleAddressReferences(data) {
  if (!data || !data._addressReferences) return;
  
  const addressReferences = data._addressReferences;
  
  // For each address that couldn't be deleted, show the reference details
  for (const addressId in addressReferences) {
    const references = addressReferences[addressId];
    
    // Try to find the original address name for better user feedback
    let addressName = "Unknown address";
    
    // Look in current addresses first
    const existingAddr = clientForm.value.addresses.find(addr => addr.id === addressId);
    if (existingAddr) {
      addressName = existingAddr.name;
    } else {
      // Look in the original client's addresses if available
      const originalAddresses = clientToEdit.value?.addresses || [];
      const originalAddr = originalAddresses.find(addr => addr.id === addressId);
      if (originalAddr) {
        addressName = originalAddr.name;
      }
    }
    
    // Build a detailed message about what's referencing this address
    let referenceMessage = `Address "${addressName}" (ID: ${addressId.substring(0, 8)}...) can't be deleted because it's referenced by:`;
    
    if (references.projects && references.projects.length > 0) {
      referenceMessage += `\n\n- ${references.projects.length} project(s):`;
      references.projects.forEach(proj => {
        referenceMessage += `\n  • Project with type "${proj.type}", status: ${proj.status}`;
      });
    }
    
    if (references.estimates && references.estimates.length > 0) {
      referenceMessage += `\n\n- ${references.estimates.length} estimate(s):`;
      references.estimates.forEach(est => {
        referenceMessage += `\n  • Estimate #${est.estimate_number}, status: ${est.status}`;
      });
    }
    
    if (references.invoices && references.invoices.length > 0) {
      referenceMessage += `\n\n- ${references.invoices.length} invoice(s):`;
      references.invoices.forEach(inv => {
        referenceMessage += `\n  • Invoice #${inv.invoice_number}, status: ${inv.status}`;
      });
    }
    
    if (references.preAssessments && references.preAssessments.length > 0) {
      referenceMessage += `\n\n- ${references.preAssessments.length} pre-assessment(s):`;
      references.preAssessments.forEach(pa => {
        referenceMessage += `\n  • Pre-assessment with status: ${pa.status}`;
      });
    }
    
    // Add explanation about what happened
    referenceMessage += `\n\nThe address has been maintained in the system but marked as non-primary. You must update the references listed above before this address can be deleted.`;
    
    // Show the detailed error to the user
    handleError(
      { message: referenceMessage }, 
      `Address Referenced by Other Records`
    );
  }
}

// Updated submitClientForm function that uses handleAddressReferences
async function submitClientForm() {
  formError.value = '';
  if (!validateClientForm()) {
    formError.value = 'Please correct the errors in the form.';
    return;
  }

  formSubmitting.value = true;
  try {
    // Prepare payload (already camelCase)
    const payload = { ...clientForm.value };
    // Ensure tax rate is a number or null
    payload.defaultTaxRate = payload.defaultTaxRate !== '' ? Number(payload.defaultTaxRate) : null;
    
    // Format addresses for creation/update (already camelCase)
    // Ensure we only include necessary fields and proper ID handling
    payload.addresses = payload.addresses.map(addr => {
      const addressData = {
        name: addr.name,
        streetAddress: addr.streetAddress,
        city: addr.city,
        state: addr.state,
        postalCode: addr.postalCode,
        country: addr.country || 'USA',
        isPrimary: addr.isPrimary,
        notes: addr.notes || ''
      };
      
      // Only include ID for existing addresses
      if (isEditing.value && addr.id) {
        // Ensure we're only passing UUID addresses, not temporary IDs
        if (typeof addr.id === 'string' && addr.id.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
          addressData.id = addr.id;
        }
      }
      
      return addressData;
    });
    
    // For logging
    console.log('Submitting client with addresses:', JSON.stringify(payload.addresses));
    
    // If there are deleted addresses, explicitly call deleteClientAddress for each
    // This is for addresses that can't be auto-removed due to reference constraints
    if (isEditing.value && deletedAddressIds.value.length > 0) {
      console.log(`Explicitly deleting ${deletedAddressIds.value.length} addresses:`, deletedAddressIds.value);
      
      // Include a helper property to tell the backend which addresses to delete
      // The backend will use this to identify addresses that should be removed
      payload._deletedAddressIds = deletedAddressIds.value;
    }

    let response;
    if (isEditing.value) {
      response = await clientService.updateClient(payload.id, payload);
    } else {
      response = await clientService.createClient(payload);
    }

    if (response.success) {
      // Check for addresses that couldn't be deleted due to references
      if (response.data) {
        handleAddressReferences(response.data);
      }
      
      // Clear the deleted address IDs after successful update
      deletedAddressIds.value = [];
      
      await fetchClients(); // Refresh the list
      
      // Refresh the selected client if it's the one being edited/created
      if (selectedClient.value && selectedClient.value.id === response.data.id) {
         selectedClient.value = response.data;
      }
      
      // Use toast via handleError for consistency (though this is success)
      handleError(
        { message: `Client ${isEditing.value ? 'updated' : 'created'} successfully.` }, 
        `Client ${isEditing.value ? 'updated' : 'created'} successfully.`
      );
      
      showClientModal.value = false;
    } else {
       formError.value = response.message || `Failed to ${isEditing.value ? 'update' : 'create'} client.`;
       handleError(new Error(formError.value), formError.value);
    }

  } catch (err) {
    // Use handleError for exceptions
    const errorInfo = handleError(err, `Failed to ${isEditing.value ? 'update' : 'create'} client.`);
    formError.value = errorInfo.message; // Display error message on form
  } finally {
    formSubmitting.value = false;
  }
}
</script>
