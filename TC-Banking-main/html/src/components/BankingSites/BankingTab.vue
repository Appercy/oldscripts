<script setup>
import { ref, computed, reactive, onMounted, inject } from 'vue';
import Button from 'primevue/button';
import Select from 'primevue/select';
import InputNumber from 'primevue/inputnumber';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import InputText from 'primevue/inputtext';
import Badge from 'primevue/badge';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const toast = inject('toast', { add: console.log });
const { toggleDisplay } = inject('displayState', { toggleDisplay: () => {} });

const roleLabels = reactive({});



// NUI Implementation
const fetchNui = async (eventName, data = {}) => {
  console.log(eventName)
  const resourceName = window.GetParentResourceName?.() || 'tc-banking';
  try {
    const resp = await fetch(`https://${resourceName}/${eventName}`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data),
    });

    return await resp.json();
  } catch (error) {
    console.error('NUI Error:', error);
    return null;
  }
};

// Get Identifier from NUICallback
const getIdentifier = async () => {
  const response = await fetchNui('getIdentifier');
  return response?.identifier || null;
};

// State Management
const accounts = ref([]);
const isLoading = ref(true);
const nicknames = ref(JSON.parse(localStorage.getItem('accountNicknames')) || {}); // Load nicknames from localStorage

// Load accounts data
const loadAccounts = async () => {
  isLoading.value = true;
  try {
    const response = await fetchNui('getBankData');
    if (response) {
      // Process and normalize the accounts data
      accounts.value = response.map(account => ({
        GROUP: account.owngroup,
        IBAN: account.IBAN,
        BALANCE: account.Balance || 0,
        PRIMARY: account.Primary ? 1 : 0,
        NICKNAME: nicknames.value[account.IBAN] || 
            (account.owngroup === 'owner' ? 
          (account.Primary ? `${t('banking.mainAccount')} ${account.IBAN.slice(-3)}` : `${t('banking.savingsAccount')} ${account.IBAN.slice(-3)}`) : 
          `${t('banking.sharedAccount')} ${account.IBAN.slice(-3)}`),
        INTEREST_RATE: account.Interest || 0,
        ACCESS: account.Group?.map(member => ({
          IDENTIFIER: member.IDENTIFIER,
          ROLE: member.ROLE || 'user',
          name: member.name || '?'
        })) || [],
        TRANSACTIONS: processTransactions(account.Transactions, account.Transfers),
        CARDS: account.cards?.flatMap(cardGroup => Object.values(cardGroup)) || []
      }));
    }
  } catch (error) {
    console.error('Failed to load accounts:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.loadFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    isLoading.value = false;
  }
};

// Process and merge transactions and transfers, removing duplicates
const processTransactions = (transactions = [], transfers = []) => {
  const allTransactions = [
    ...(Array.isArray(transactions) ? transactions : []),
    ...(Array.isArray(transfers) ? transfers : [])
  ].reduce((acc, tx) => {
    if (!acc.some(t => t.ID === tx.ID)) {
      acc.push({
        DATE: tx.DATE || Date.now(),
        AMOUNT: tx.AMOUNT || 0,
        DESCRIPTION: tx.DESCRIPTION || 
                    (tx.IBAN_FROM && tx.IBAN_TO ? `Transfer ${tx.IBAN_FROM} → ${tx.IBAN_TO}` : 
                     tx.AMOUNT > 0 ? 'Deposit' : 'Withdrawal'),
        STATUS: tx.STATUS || 'completed',
        ISSUER: tx.ISSUER || 'system',
        ID: tx.ID
      });
    }
    return acc;
  }, []);
  
  // Sort by date, newest first
  return allTransactions.sort((a, b) => b.DATE - a.DATE);
};

// UI state variables
const showTransactionModal = ref(false);
const showTransferModal = ref(false);
const showShareModal = ref(false);
const showEditRoleModal = ref(false);
const showDeleteConfirmModal = ref(false);
const showLeaveConfirmModal = ref(false);
// const showCreateAccountModal = ref(false);
const showAccountDetailsModal = ref(false);
const selectedAccount = ref(null);
const selectedAccess = ref(null);
const shareData = ref({ identifier: '', role: 'user' });
const transactionData = ref({ account: null, type: 'deposit', amount: null });
const transferData = ref({ from: null, transferType: 'internal', to: null, externalIban: '', amount: null, reason: '' });
const newAccountData = ref({ nickname: '' });
const showIban = ref({});

// New reactive properties for renaming accounts
const editNickname = ref(false);
const renameData = ref('');
const renameLoading = ref(false);

// Loading states for async operations
const loading = ref({
  transaction: false,
  transfer: false,
  delete: false,
  share: false,
  updateAccess: false,
  create: false,
  leave: false
});

// Computed properties
const primaryAccount = computed(() => accounts.value.find(a => a.PRIMARY === 1));
const sortedAccounts = computed(() => {
  const primary = primaryAccount.value;
  if (!primary) return accounts.value;
  return [primary, ...accounts.value.filter(a => a.IBAN !== primary.IBAN)];
});

// Map role values to display labels
const userRoleLabel = (role) => {

  switch (role) {
    case 'owner':
      console.log("Owner")
      return t('banking.roles.owner');
    case 'administrator':
      console.log("Admin")
      return t('banking.roles.administrator');
    default:
      console.log("default")
      return t('banking.roles.user');
  }
};
const currentUserRole = (iban) => {
  const account = accounts.value.find(a => a.IBAN === iban);
  console.log(`Account: ${JSON.stringify(account)}`);
  
  const role = account?.GROUP || 'user';
  console.log(`currentUserRole for IBAN ${iban}: ${role}`);
  
  return role;
};

const isOwner = (iban) => {
  const role = currentUserRole(iban);
  return role === 'owner';
};

const isAdministrator = (iban) => {
  const role = currentUserRole(iban);
  return role === 'administrator';
};

const isUser = (iban) => {
  const role = currentUserRole(iban);
  return role === 'user';
};


const isPrimary = (iban) => {
  console.log(`isPrimary for IBAN ${iban}`)
  const account = accounts.value.find(a => a.IBAN === iban);
  console.log(`Account: ${JSON.stringify(account)}`);

  return account.PRIMARY === 1;
}
// Formatter for balances
const formatBalance = (balance) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0
  }).format(balance);
};

// Actions
const handleTransaction = async () => {
  const account = accounts.value.find(a => a.IBAN === transactionData.value.account);
  if (!account) return;
  
  loading.value.transaction = true;
  try {
    const result = await fetchNui('transaction', {
      iban: account.IBAN,
      type: transactionData.value.type,
      amount: transactionData.value.amount,
      reason:  transactionData.value.reason || (transactionData.value.type === 'deposit' ? t('banking.transaction.deposit') : t('banking.transaction.withdrawal')),
    });
    
    if (result && result.success) {
      // Update local data
      account.BALANCE += transactionData.value.amount * (transactionData.value.type === 'deposit' ? 1 : -1);
      
      account.TRANSACTIONS.unshift({
        DATE: Date.now(),
        AMOUNT: transactionData.value.amount * (transactionData.value.type === 'deposit' ? 1 : -1),
        DESCRIPTION: transactionData.value.reason || (transactionData.value.type === 'deposit' ? t('banking.transaction.deposit') : t('banking.transaction.withdrawal')),
        STATUS: 'completed'
      });

      toast.add({
        severity: 'success',
        summary: t('banking.success.transaction'),
        life: 3000,
      });
      
      showTransactionModal.value = false;
      transactionData.value = { account: null, type: 'deposit', amount: null };
    } else {
      throw new Error(result?.error || t('banking.errors.transactionFailed'));
    }
  } catch (error) {
    console.error('Transaction error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.transactionFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.transaction = false;
  }
};

const handleTransfer = async () => {
  const fromAccount = accounts.value.find(a => a.IBAN === transferData.value.from);
  if (!fromAccount) return;
  
  loading.value.transfer = true;
  try {
    let result;
    if (transferData.value.transferType === 'internal') {
      const toAccount = accounts.value.find(a => a.IBAN === transferData.value.to);
      if (!toAccount) throw new Error(t('banking.errors.accountNotFound'));
      
      result = await fetchNui('transfer', {
        fromIban: fromAccount.IBAN,
        toIban: toAccount.IBAN,
        amount: transferData.value.amount,
        description: transferData.value.reason 
      });
      
      if (result && result.success) {
        // Update local data
        fromAccount.BALANCE -= transferData.value.amount;
        toAccount.BALANCE += transferData.value.amount;
        
        const transactionDetails = {
          DATE: Date.now(),
          DESCRIPTION: transferData.value.reason || `Internal transfer to ${transferData.value.to}`,
          STATUS: 'completed'
        };
        
        fromAccount.TRANSACTIONS.unshift({
          ...transactionDetails,
          AMOUNT: -transferData.value.amount
        });
        
        toAccount.TRANSACTIONS.unshift({
          ...transactionDetails,
          AMOUNT: transferData.value.amount
        });
      }
    } else {
      result = await fetchNui('externalTransfer', {
        fromIban: fromAccount.IBAN,
        toIban: transferData.value.externalIban,
        amount: transferData.value.amount,
        reason: transferData.value.reason
      });
      
      if (result && result.success) {
        // Update local data
        fromAccount.BALANCE -= transferData.value.amount;
        fromAccount.TRANSACTIONS.unshift({
          DATE: Date.now(),
          AMOUNT: -transferData.value.amount,
          DESCRIPTION: `External transfer to ${transferData.value.externalIban}: ${transferData.value.reason}`,
          STATUS: 'pending'
        });
      }
    }
    
    if (!result || !result.success) {
      throw new Error(result?.error || t('banking.errors.transferFailed'));
    }
    
    toast.add({
      severity: 'success',
      summary: t('banking.success.transfer'),
      life: 3000,
    });
    
    showTransferModal.value = false;
    transferData.value = { from: null, transferType: 'internal', to: null, externalIban: '', amount: null, reason: '' };
  } catch (error) {
    console.error('Transfer error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.transferFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.transfer = false;
  }
};

const deleteAccount = async () => {
  if (!selectedAccount.value || selectedAccount.value.PRIMARY || !(await isOwner(selectedAccount.value.IBAN))) return;
  
  loading.value.delete = true;
  try {
    const result = await fetchNui('deleteAccount', {
      iban: selectedAccount.value.IBAN
    });
    
    if (result && result.success) {
      const idx = accounts.value.findIndex(a => a.IBAN === selectedAccount.value.IBAN);
      if (idx !== -1) {
        accounts.value.splice(idx, 1);
      }
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.accountDeleted'),
        life: 3000,
      });
      
      showDeleteConfirmModal.value = false;
      selectedAccount.value = null;
    } else {
      throw new Error(result?.error || t('banking.errors.deleteFailed'));
    }
  } catch (error) {
    console.error('Delete account error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.deleteFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.delete = false;
  }
};

const leaveAccount = async () => {
  if (!selectedAccount.value || selectedAccount.value.PRIMARY) return;
  
  loading.value.leave = true;
  try {
    const result = await fetchNui('leaveAccount', {
      iban: selectedAccount.value.IBAN
    });
    
    if (result && result.success) {
      const identifier = await getIdentifier();
      
      // Update the local data structure
      selectedAccount.value.ACCESS = selectedAccount.value.ACCESS.filter(
        a => a.IDENTIFIER !== identifier
      );
      
      // Remove account from the list if we no longer have access
      const idx = accounts.value.findIndex(a => a.IBAN === selectedAccount.value.IBAN);
      if (idx !== -1 && 
          !accounts.value[idx].ACCESS.some(a => a.IDENTIFIER === identifier)) {
        accounts.value.splice(idx, 1);
      }
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.leftAccount'),
        life: 3000,
      });
      
      showLeaveConfirmModal.value = false;
      selectedAccount.value = null;
    } else {
      throw new Error(result?.error || t('banking.errors.leaveFailed'));
    }
  } catch (error) {
    console.error('Leave account error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.leaveFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.leave = false;
  }
};

const shareAccount = async () => {
  loading.value.share = true;
  try {
    const result = await fetchNui('shareAccount', {
      iban: selectedAccount.value.IBAN,
      identifier: shareData.value.identifier,
      role: shareData.value.role
    });
    
    if (result && result.success) {
      // Update local data
      selectedAccount.value.ACCESS.push({
        IDENTIFIER: shareData.value.identifier,
        ROLE: shareData.value.role
      });
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.accountShared'),
        life: 3000,
      });
      
      showShareModal.value = false;
      shareData.value = { identifier: '', role: 'user' };
    } else {
      throw new Error(result?.error || t('banking.errors.shareFailed'));
    }
  } catch (error) {
    console.error('Share account error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.shareFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.share = false;
  }
};

const updateAccessRole = async () => {
  if (!selectedAccess.value) return;
  
  loading.value.updateAccess = true;
  try {
    const account = accounts.value.find(acc => 
      acc.ACCESS.some(a => a.IDENTIFIER === selectedAccess.value.IDENTIFIER)
    );
    
    if (!account) throw new Error(t('banking.errors.accessNotFound'));
    
    const result = await fetchNui('updateAccessRole', {
      iban: account.IBAN,
      identifier: selectedAccess.value.IDENTIFIER,
      role: selectedAccess.value.ROLE
    });
    
    if (result && result.success) {
      // Update local data
      const access = account.ACCESS.find(a => a.IDENTIFIER === selectedAccess.value.IDENTIFIER);
      if (access) access.ROLE = selectedAccess.value.ROLE;
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.roleUpdated'),
        life: 3000,
      });
      
      showEditRoleModal.value = false;
      selectedAccess.value = null;
    } else {
      throw new Error(result?.error || t('banking.errors.updateRoleFailed'));
    }
  } catch (error) {
    console.error('Update access role error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.updateRoleFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.updateAccess = false;
  }
};

const deleteAccess = async (identifier) => {
  if (!selectedAccount.value || !(await isOwner(selectedAccount.value.IBAN))) return;
  
  loading.value.delete = true;
  try {
    const result = await fetchNui('deleteAccess', {
      iban: selectedAccount.value.IBAN,
      identifier: identifier
    });
    
    if (result && result.success) {
      // Update local data
      selectedAccount.value.ACCESS = selectedAccount.value.ACCESS.filter(
        a => a.IDENTIFIER !== identifier
      );
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.accessDeleted'),
        life: 3000,
      });
    } else {
      throw new Error(result?.error || t('banking.errors.deleteFailed'));
    }
  } catch (error) {
    console.error('Delete access error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.deleteFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.delete = false;
  }
};

const createAccount = async () => {

  try {
    const result = await fetchNui('createAccount', {
      nickname: newAccountData.value.nickname
    });
    
    if (result && result.success) {
      // Get the newly created account from the response
      if (result.account) {
  
        const newAccount = {
          GROUP: result.account.owngroup,
          IBAN: result.account.IBAN,
          BALANCE: result.account.Balance || 0,
          PRIMARY: result.account.Primary ? 1 : 0,
          NICKNAME: newAccountData.value.nickname,
          INTEREST_RATE: result.account.Interest || 0,
          ACCESS: result.account.Group?.map(member => ({
            IDENTIFIER: member.IDENTIFIER,
            ROLE: member.ROLE || 'user' // Ensure role is never none
          })) || [],
          TRANSACTIONS: [],
        };
        
        accounts.value.push(newAccount);
      } else {
        // If no account data is returned, refresh the accounts list
        await loadAccounts();
      }
      
      toast.add({
        severity: 'success',
        summary: t('banking.success.accountCreated'),
        life: 3000,
      });
      
      // showCreateAccountModal.value = false;
      newAccountData.value = { nickname: '' };
    } else {
      throw new Error(result?.error || t('banking.errors.createAccountFailed'));
    }
  } catch (error) {
    console.error('Create account error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.createAccountFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    loading.value.create = false;
  }
};

// Rename functionality for accounts
const renameAccount = () => {
  if (!selectedAccount.value) return;

  renameLoading.value = true;
  try {
    // Update local data
    selectedAccount.value.NICKNAME = renameData.value;
    nicknames.value[selectedAccount.value.IBAN] = renameData.value;
    localStorage.setItem('accountNicknames', JSON.stringify(nicknames.value));

    toast.add({
      severity: 'success',
      summary: t('banking.success.accountRenamed'),
      life: 3000,
    });

    editNickname.value = false;
  } catch (error) {
    console.error('Rename account error:', error);
    toast.add({
      severity: 'error',
      summary: t('banking.errors.renameFailed'),
      detail: error.message,
      life: 5000
    });
  } finally {
    renameLoading.value = false;
  }
};



// Load accounts on component mount
onMounted(loadAccounts);
</script>

<template>
  <!-- Template remains mostly unchanged, but remove the card section from the account details modal -->
  <div class="banking-tablet h-full flex flex-col gap-6 p-6 bg-gradient-to-br from-slate-800 to-slate-900 backdrop-blur-lg rounded-2xl border border-slate-700 shadow-xl">
    <!-- Loading indicator -->
    <div v-if="isLoading" class="flex items-center justify-center h-full">
      <i class="pi pi-spin pi-spinner text-4xl text-sky-400"></i>
      <span class="ml-3 text-xl text-slate-300">{{ t('banking.loading') }}</span>
    </div>
    
    <template v-else>
      <!-- Header -->
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-white flex items-center gap-3 transition-transform hover:scale-105">
          <i class="pi pi-wallet text-sky-400"></i>
          {{ t("banking.title") }}
        </h1>
        <div class="flex gap-4">
          <Button 
            :label="t('banking.actions.deposit')"
            icon="pi pi-arrow-down"
            class="custom-btn"
            data-type="success"
            @click="transactionData.type = 'deposit'; showTransactionModal = true"
          />
          <Button 
            :label="t('banking.actions.withdraw')"
            icon="pi pi-arrow-up"
            class="custom-btn"
            data-type="danger"
            @click="transactionData.type = 'withdraw'; showTransactionModal = true"
          />
          <Button 
            :label="t('banking.actions.transfer')"
            icon="pi pi-send"
            class="custom-btn"
            data-type="info"
            @click="showTransferModal = true"
          />
            <Button 
            :label="t('banking.actions.addAccount')"
            icon="pi pi-plus"
            class="custom-btn"
            data-type="help"
            @click="createAccount"
            />
        </div>
      </div>
      
      <!-- No accounts message -->
      <div v-if="accounts.length === 0" class="flex flex-col items-center justify-center p-10 bg-slate-800/50 rounded-xl">
        <i class="pi pi-info-circle text-4xl text-slate-400 mb-4"></i>
        <p class="text-xl text-slate-300">{{ t('banking.noAccounts') }}</p>
        <Button 
          :label="t('banking.actions.createFirstAccount')"
          icon="pi pi-plus"
          class="mt-6 custom-btn"
          data-type="help"
          @click="createAccount()"
        />
      </div>
      
      <!-- Accounts Section -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div v-for="account in sortedAccounts" :key="account.IBAN" class="bg-slate-800 rounded-xl p-4 border border-slate-700 hover:shadow-2xl transition-shadow duration-300">
          <div class="flex justify-between items-center">
            <div>
              <h2 class="text-xl font-bold text-white">
                {{ account.NICKNAME || t('banking.unnamedAccount') }}
              </h2>
              <div class="flex items-center gap-2 text-slate-400 text-sm">
                <Button icon="pi pi-eye" class="p-button-text p-button-sm hover:text-sky-400 no-hover-effect" @click="showIban[account.IBAN] = !showIban[account.IBAN]" />
                <span>{{ showIban[account.IBAN] ? account.IBAN : t('banking.maskedIban') }}</span>
              </div>
              <div class="mt-2 text-2xl font-bold text-white">
                {{ formatBalance(account.BALANCE) }}
              </div>
              <div v-if="account.INTEREST_RATE > 0" class="text-sm text-emerald-400">
                {{ t('banking.interestRate') }}: {{ account.INTEREST_RATE }}%
              </div>
            </div>
            <div>
                <Badge :value="userRoleLabel(account.GROUP)" severity="info" />
                <Badge v-if="account.PRIMARY === 1" :value="t('banking.mainAccount')" severity="success" class="ml-2" />
                <Badge v-if="account.PRIMARY === 0" :value="t('banking.savingsAccount')" severity="success" class="ml-2"/>
            </div>
          </div>
          
          <!-- Quick Actions -->
          <div class="mt-4 pt-4 border-t border-slate-700 flex flex-wrap gap-2">
            <Button icon="pi pi-info" :label="t('banking.actions.details')" class="p-button-text p-button-sm text-xs transition-colors no-hover-effect" @click="selectedAccount = account; showAccountDetailsModal = true" />
            <Button icon="pi pi-share-alt" :label="t('banking.actions.share')" class="p-button-text p-button-sm text-xs transition-colors no-hover-effect"
              @click="selectedAccount = account; showShareModal = true" 
              :disabled="isPrimary(account.IBAN) || !isOwner(account.IBAN)"
              :icon="loading.share ? 'pi pi-spin pi-spinner' : 'pi pi-share-alt'" />
            <template v-if="account.PRIMARY !== 1">
              <Button v-if="isOwner(account.IBAN)" icon="pi pi-trash" :label="t('banking.actions.delete')" class="p-button-text p-button-sm text-xs transition-colors no-hover-effect" 
                    :disabled="loading.delete" :icon="loading.delete ? 'pi pi-spin pi-spinner' : 'pi pi-trash'" 
                    @click="selectedAccount = account; showDeleteConfirmModal = true" />
              <Button v-else icon="pi pi-sign-out" :label="t('banking.actions.leave')" class="p-button-text p-button-sm text-xs transition-colors no-hover-effect" 
                    :disabled="loading.leave" :icon="loading.leave ? 'pi pi-spin pi-spinner' : 'pi pi-sign-out'" 
                    @click="selectedAccount = account; showLeaveConfirmModal = true" />
            </template>
          </div>
        </div>
      </div>
    </template>
    
    <!-- Transaction Modal -->
    <transition name="modal">
      <div v-if="showTransactionModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.transaction.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transaction.account') }}</label>
              <Select 
                v-model="transactionData.account" 
                :options="accounts.map(a => ({ label: a.NICKNAME || 'Account', value: a.IBAN }))" 
                optionLabel="label" 
                optionValue="value" 
                :placeholder="t('banking.modals.transaction.selectAccount')" 
                class="w-full bg-slate-700/30 rounded-lg" 
              />
                <InputText 
                v-model="transactionData.reason" 
                :placeholder="t('banking.modals.transaction.enterReason')" 
                class="w-full bg-slate-700/30 rounded-lg p-2 text-slate-200 mt-4"
                />
            </div>
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transaction.amount') }}</label>
              <InputNumber v-model="transactionData.amount" class="w-full" :min="0" />
            </div>
            <Button 
              :label="t(`banking.actions.${transactionData.type}`)" 
              :class="{'bg-emerald-500 hover:bg-emerald-600': transactionData.type === 'deposit', 'bg-red-500 hover:bg-red-600': transactionData.type === 'withdraw'}"
              class="w-full text-white rounded-lg transition-all" 
              :disabled="!transactionData.account || !transactionData.amount || loading.transaction" 
              :icon="loading.transaction ? 'pi pi-spin pi-spinner' : ''" 
              @click="handleTransaction" 
            />
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showTransactionModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    
    <!-- Transfer Modal -->
    <transition name="modal">
      <div v-if="showTransferModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.transfer.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.fromAccount') }}</label>
              <Select 
                v-model="transferData.from" 
                :options="accounts.map(a => ({ label: a.NICKNAME || 'Account', value: a.IBAN }))" 
                optionLabel="label" 
                optionValue="value" 
                :placeholder="t('banking.modals.transfer.selectSource')" 
                class="w-full bg-slate-700/30 rounded-lg"
              />
            </div>
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.transferType') }}</label>
              <Select 
                v-model="transferData.transferType" 
                :options="[
                  { label: t('banking.modals.transfer.internal'), value: 'internal' }, 
                  { label: t('banking.modals.transfer.external'), value: 'external' }
                ]" 
                optionLabel="label" 
                optionValue="value" 
                class="w-full bg-slate-700/30 rounded-lg"
              />
            </div>
            <template v-if="transferData.transferType === 'internal'">
              <div>
                <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.toAccount') }}</label>
                <Select 
                  v-model="transferData.to" 
                  :options="accounts.filter(a => a.IBAN !== transferData.from).map(a => ({ label: a.NICKNAME || 'Account', value: a.IBAN }))" 
                  optionLabel="label" 
                  optionValue="value" 
                  :placeholder="t('banking.modals.transfer.selectDestination')" 
                  class="w-full bg-slate-700/30 rounded-lg"
                  :disabled="!transferData.from"
                />
              </div>
            </template>
            <template v-else>
              <div>
                <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.externalIban') }}</label>
                <InputText 
                  v-model="transferData.externalIban" 
                  :placeholder="t('banking.modals.transfer.enterExternalIban')" 
                  class="w-full bg-slate-700/30 rounded-lg p-2 text-slate-200"
                />
              </div>
            </template>
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.amount') }}</label>
              <InputNumber 
                v-model="transferData.amount" 
                class="w-full" 
                :min="0" 
                :max="transferData.from ? accounts.find(a => a.IBAN === transferData.from)?.BALANCE || 0 : 0"
              />
            </div>
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.transfer.reason') }}</label>
              <InputText 
                v-model="transferData.reason" 
                :placeholder="t('banking.modals.transfer.enterReason')" 
                class="w-full bg-slate-700/30 rounded-lg p-2 text-slate-200"
              />
            </div>
            <Button 
              :label="t('banking.modals.transfer.confirmTransfer')" 
              class="w-full bg-sky-500 text-white rounded-lg hover:bg-sky-600 transition-all" 
              :disabled="!transferData.from || 
                       (transferData.transferType === 'internal' && !transferData.to) ||
                       (transferData.transferType === 'external' && !transferData.externalIban) ||
                       !transferData.amount || 
                       loading.transfer" 
              :icon="loading.transfer ? 'pi pi-spin pi-spinner' : ''" 
              @click="handleTransfer" 
            />
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showTransferModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    
    <!-- Share Modal -->
    <transition name="modal">
      <div v-if="showShareModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.share.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.share.playerIdentifier') }}</label>
              <InputText 
                v-model="shareData.identifier" 
                :placeholder="t('banking.modals.share.enterPlayerIdentifier')" 
                class="w-full bg-slate-700/30 rounded-lg p-2 text-slate-200"
              />
            </div>
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.share.role') }}</label>
              <Select 
                v-model="shareData.role" 
                :options="[
                  { label: t('banking.roles.administrator'), value: 'co-owner' },
                  { label: t('banking.roles.user'), value: 'user' }
                ]"
                optionLabel="label"
                optionValue="value"
                class="w-full bg-slate-700/30 rounded-lg"
              />
            </div>
            <Button 
              :label="t('banking.modals.share.share')" 
              class="w-full bg-sky-500 text-white rounded-lg hover:bg-sky-600 transition-all" 
                :disabled="!shareData.identifier || isUser(selectedAccount?.IBAN) || loading.share" 
              :icon="loading.share ? 'pi pi-spin pi-spinner' : ''" 
              @click="shareAccount" 
            />
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showShareModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    <transition name="modal">
      <!-- <div v-if="showCreateAccountModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.createAccount.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.createAccount.nickname') }}</label>
              <InputText 
                v-model="newAccountData.nickname" 
                :placeholder="t('banking.modals.createAccount.enterNickname')" 
                class="w-full bg-slate-700/30 rounded-lg p-2 text-slate-200"
              />
            </div>
            <Button 
              :label="t('banking.modals.createAccount.createAccount')" 
              class="w-full bg-sky-500 text-white rounded-lg hover:bg-sky-600 transition-all" 
              :disabled="!newAccountData.nickname || loading.create" 
              :icon="loading.create ? 'pi pi-spin pi-spinner' : ''" 
              @click="createAccount" 
            />
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showCreateAccountModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
          </div>
        </div>
      </div> -->
    </transition>
    
    <!-- Edit Access Role Modal -->
 
    
    <!-- Delete Confirmation Modal -->
    <transition name="modal">
      <div v-if="showDeleteConfirmModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.deleteAccount.title') }}</h3>
          <p class="text-slate-300">{{ t('banking.modals.deleteAccount.confirmMessage') }}</p>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showDeleteConfirmModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
            <button
              @click="deleteAccount"
              class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-all"
            >
              {{ t('banking.modals.deleteAccount.deleteAccount') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    
    <!-- Leave Confirmation Modal -->
    <transition name="modal">
      <div v-if="showLeaveConfirmModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.leaveAccount.title') }}</h3>
          <p class="text-slate-300">{{ t('banking.modals.leaveAccount.confirmMessage') }}</p>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showLeaveConfirmModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
            <button
              @click="leaveAccount"
              class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-all"
            >
              {{ t('banking.modals.leaveAccount.leaveAccount') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    
    <!-- Account Details Modal -->
    <transition name="modal">
      <div v-if="showAccountDetailsModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-3xl overflow-y-auto max-h-[90vh] border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.accountDetails.title') }}</h3>
          
          <!-- Rename Section -->
          <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-white">
              {{ selectedAccount?.NICKNAME || t('banking.unnamedAccount') }}
            </h2>
            <div>
              <template v-if="!editNickname">
              <Button icon="pi pi-pencil" class="p-button-text text-slate-300 hover:text-sky-400 no-hover-effect" @click="() => { renameData = selectedAccount.NICKNAME; editNickname = true; }" />
              </template>
              <template v-else>
              <div class="flex items-center gap-2">
                <InputText 
                v-model="renameData" 
                class="bg-slate-700/30 rounded-lg p-2 text-slate-200" 
                :placeholder="t('banking.modals.accountDetails.enterNewName')"
                />
                <Button icon="pi pi-check" class="p-button-text text-green-400 no-hover-effect" @click="renameAccount" :disabled="renameLoading" />
                <Button icon="pi pi-times" class="p-button-text text-red-400 no-hover-effect" @click="editNickname = false" />
              </div>
              </template>
            </div>
          </div>
          
          <!-- Account Info -->
          <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="bg-slate-700/30 p-4 rounded-lg">
              <h4 class="text-slate-300 font-medium mb-2">{{ t('banking.modals.accountDetails.balance') }}</h4>
              <p class="text-xl font-bold text-white">{{ formatBalance(selectedAccount?.BALANCE) }}</p>
            </div>
            <div class="bg-slate-700/30 p-4 rounded-lg">
              <h4 class="text-slate-300 font-medium mb-2">{{ t('banking.modals.accountDetails.iban') }}</h4>
              <p class="text-sm font-mono text-white">{{ selectedAccount?.IBAN }}</p>
            </div>
          </div>
          
            <!-- Transaction History -->
            <h3 class="text-lg text-slate-300 mt-6 mb-3">{{ t('banking.modals.accountDetails.transactionHistory') }}</h3>
            <div class="overflow-auto max-h-96">
            <table class="min-w-full bg-slate-800/50 rounded-lg">
              <thead>
              <tr>
                <th class="px-4 py-2 text-left text-slate-300">{{ t('banking.modals.accountDetails.date') }}</th>
                <th class="px-4 py-2 text-left text-slate-300">{{ t('banking.modals.accountDetails.description') }}</th>
                <th class="px-4 py-2 text-left text-slate-300">{{ t('banking.modals.accountDetails.amount') }}</th>
                <th class="px-4 py-2 text-left text-slate-300">{{ t('banking.modals.accountDetails.status') }}</th>
                <th class="px-4 py-2 text-left text-slate-300">{{ t('banking.modals.accountDetails.issuer') }}</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="transaction in selectedAccount?.TRANSACTIONS || []" :key="transaction.ID" class="border-t border-slate-700">
                <td class="px-4 py-2 text-slate-200">{{ new Date(transaction.DATE).toLocaleDateString() }}</td>
                <td class="px-4 py-2 text-slate-200">{{ transaction.DESCRIPTION }}</td>
                <td class="px-4 py-2 text-slate-200">
                <span :class="transaction.AMOUNT > 0 ? 'text-emerald-400' : 'text-red-400'">
                  {{ formatBalance(transaction.AMOUNT) }}
                </span>
                </td>
                <td class="px-4 py-2 text-slate-200">
                <Badge :value="transaction.STATUS" :severity="transaction.STATUS === 'completed' ? 'success' : 'warning'" />
                </td>
                <td class="px-4 py-2 text-slate-200">{{ transaction.ISSUER }}</td>
              </tr>
              </tbody>
            </table>
            </div>
          
          <!-- Interest Rate Display -->
          <div class="mt-4">
            <p class="text-slate-300 text-sm">{{ t('banking.modals.accountDetails.interestRate') }}: <span class="font-semibold">{{ selectedAccount?.INTEREST_RATE || 0 }}%</span></p>
          </div>
          
          <!-- Access List Section -->
          <div>
            <h3 class="text-lg text-slate-300 mt-6 mb-3">{{ t('banking.modals.accountDetails.accessList') }}</h3>
            <ul class="divide-y divide-slate-700 bg-slate-800/50 rounded-lg overflow-hidden">
              <li v-for="access in selectedAccount?.ACCESS" :key="access.IDENTIFIER" class="py-3 px-4 flex justify-between items-center">
                <span class="text-slate-300 text-sm">{{ access.name }} - {{ t(`banking.roles.${access.ROLE}`) }}</span>
                <Button 
                  v-if="isOwner(selectedAccount.IBAN) && access.ROLE !== 'owner'" 
                  icon="pi pi-pencil" 
                  class="p-button-rounded p-button-text text-slate-200 hover:text-sky-400" 
                  @click="selectedAccess = {...access}; showEditRoleModal = true" 
                />
                <Button 
                  v-if="isOwner(selectedAccount.IBAN) && access.ROLE !== 'owner'" 
                  icon="pi pi-trash" 
                  class="p-button-rounded p-button-text text-slate-200 hover:text-red-400" 
                  @click="deleteAccess(access.IDENTIFIER)" 
                />
              </li>
            </ul>
          </div>
          
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showAccountDetailsModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.close') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
    <transition name="modal">
      <div v-if="showEditRoleModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-50 z-9999999">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('banking.modals.editRole.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('banking.modals.editRole.role') }}</label>
              <Select 
                v-model="selectedAccess.ROLE" 
                :options="[
                  { label: t('banking.roles.administrator'), value: 'co-owner' },
                  { label: t('banking.roles.user'), value: 'user' }
                ]"
                optionLabel="label"
                optionValue="value"
                class="w-full bg-slate-700/30 rounded-lg"
              />
            </div>
            <Button 
              :label="t('banking.modals.editRole.updateRole')" 
              class="w-full bg-sky-500 text-white rounded-lg hover:bg-sky-600 transition-all" 
              :disabled="loading.updateAccess" 
              :icon="loading.updateAccess ? 'pi pi-spin pi-spinner' : ''" 
              @click="updateAccessRole" 
            />
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showEditRoleModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('banking.actions.cancel') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style>
 .p-datatable {
  background-color: transparent !important;
 }
</style>