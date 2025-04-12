// Updated submitClientForm function for ClientSettings.vue
async function submitClientForm() {
  formError.value = '';
  if (!validateClientForm()) {
    formError.value = 'Please correct the errors in the form.';
    return;
  }

  formSubmitting.value = true;
  try {
    if (isEditing.value) {
      const clientId = clientForm.value.id;
      
      // 1. Extract client data without addresses for separate handling
      const { addresses, ...clientData } = { ...clientForm.value };
      
      // Ensure tax rate is a number or null
      clientData.default_tax_rate = clientData.default_tax_rate !== '' ? Number(clientData.default_tax_rate) : null;
      
      // 2. Update the main client data
      await clientService.updateClient(clientId, clientData);
      
      // 3. Handle address updates separately
      if (addresses && Array.isArray(addresses)) {
        // Get current addresses from server
        const currentClientResponse = await clientService.getClientById(clientId);
        const currentAddresses = currentClientResponse.data.addresses || [];
        
        // Identify addresses to add, update, or delete
        const addressesToUpdate = addresses.filter(a => typeof a.id === 'number');
        const addressesToAdd = addresses.filter(a => typeof a.id !== 'number');
        const addressesToDelete = currentAddresses.filter(
          currentAddr => !addresses.some(newAddr => newAddr.id === currentAddr.id)
        );
        
        // Delete addresses that aren't in the new list
        for (const addr of addressesToDelete) {
          await clientService.deleteClientAddress(clientId, addr.id);
        }
        
        // Update existing addresses
        for (const addr of addressesToUpdate) {
          const { id, ...addressData } = addr;
          await clientService.updateClientAddress(clientId, id, addressData);
        }
        
        // Add new addresses
        for (const addr of addressesToAdd) {
          const { id, ...addressData } = addr; // Remove temporary id
          await clientService.addClientAddress(clientId, addressData);
        }
      }
      
      // 4. Refresh the client list
      await fetchClients();
      
      // 5. Refresh the selected client if it's the one being edited
      if (selectedClient.value && selectedClient.value.id === clientId) {
        const updatedClientResponse = await clientService.getClientById(clientId);
        selectedClient.value = updatedClientResponse.data;
      }
      
      showToastNotification('Client updated successfully.', 'success');
    } else {
      // For new clients, we can use the existing method since it creates everything at once
      const payload = { ...clientForm.value };
      // Ensure tax rate is a number or null
      payload.default_tax_rate = payload.default_tax_rate !== '' ? Number(payload.default_tax_rate) : null;
      // Format addresses for creation (remove temporary IDs)
      payload.addresses = payload.addresses.map(addr => {
        const { id, ...rest } = addr;
        return rest; // New addresses don't need IDs
      });
      
      await clientService.createClient(payload);
      await fetchClients(); // Refresh the list
      showToastNotification('Client created successfully.', 'success');
    }
    
    showClientModal.value = false;
  } catch (err) {
    console.error('Error submitting client form:', err);
    formError.value = err.response?.data?.message || `Failed to ${isEditing.value ? 'update' : 'create'} client. Please try again.`;
    showToastNotification(formError.value, 'error');
  } finally {
    formSubmitting.value = false;
  }
}