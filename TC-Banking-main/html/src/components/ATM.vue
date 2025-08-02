<script setup>
import { ref, computed, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';

// Toast setup
const toast = useToast();

// Debug data provided
const debugData = {
  MaxTransactionWithdrawal: 2000,
  MaxTransactionDeposit: 2000,
  "CARD-ID": "1234-5678-9101-1121",
  AccountBalance: 10000,
  AccountNumber: "1234567890",
  AccountHolder: "John Doe",
  AccountType: "Savings"
};

// Component state
const accountData = ref({
  balance: debugData.AccountBalance,
  cardId: debugData["CARD-ID"],
  accountNumber: debugData.AccountNumber,
  accountHolder: debugData.AccountHolder,
  accountType: debugData.AccountType
});

// Transaction limits tracking
const transactionLimits = ref({
  withdrawal: {
    remaining: debugData.MaxTransactionWithdrawal,
    lastReset: new Date().getTime(),
  },
  deposit: {
    remaining: debugData.MaxTransactionDeposit,
    lastReset: new Date().getTime(),
  }
});

// UI state
const activeTab = ref('account'); // 'account', 'withdraw', 'deposit', 'history'
const amount = ref('');
const isLoading = ref(false);
const transactions = ref([
  { type: 'deposit', amount: 1500, date: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), success: true },
  { type: 'withdrawal', amount: 300, date: new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString(), success: true }
]);

// Check if limits need to be reset (hourly)
const checkLimitReset = () => {
  const currentTime = new Date().getTime();
  
  // Check withdrawal limit
  if (currentTime - transactionLimits.value.withdrawal.lastReset >= 60 * 60 * 1000) {
    transactionLimits.value.withdrawal.remaining = debugData.MaxTransactionWithdrawal;
    transactionLimits.value.withdrawal.lastReset = currentTime;
  }
  
  // Check deposit limit
  if (currentTime - transactionLimits.value.deposit.lastReset >= 60 * 60 * 1000) {
    transactionLimits.value.deposit.remaining = debugData.MaxTransactionDeposit;
    transactionLimits.value.deposit.lastReset = currentTime;
  }
};

// Format currency
const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).format(value);
};

// Get time until limit reset
const getTimeUntilReset = (lastReset) => {
  const resetTime = lastReset + (60 * 60 * 1000);
  const currentTime = new Date().getTime();
  const difference = resetTime - currentTime;
  
  if (difference <= 0) return '0m 0s';
  
  const minutes = Math.floor((difference / (1000 * 60)) % 60);
  const seconds = Math.floor((difference / 1000) % 60);
  
  return `${minutes}m ${seconds}s`;
};

// Calculate time remaining for withdrawal reset
const withdrawalTimeRemaining = computed(() => {
  return getTimeUntilReset(transactionLimits.value.withdrawal.lastReset);
});

// Calculate time remaining for deposit reset
const depositTimeRemaining = computed(() => {
  return getTimeUntilReset(transactionLimits.value.deposit.lastReset);
});

// Handle withdrawal
const handleWithdraw = () => {
  checkLimitReset();
  
  const withdrawAmount = parseFloat(amount.value);
  
  if (!withdrawAmount || isNaN(withdrawAmount) || withdrawAmount <= 0) {
    toast.add({ severity: 'error', summary: 'Invalid Amount', detail: 'Please enter a valid amount to withdraw', life: 3000 });
    return;
  }
  
  if (withdrawAmount > accountData.value.balance) {
    toast.add({ severity: 'error', summary: 'Insufficient Funds', detail: 'You do not have enough funds for this withdrawal', life: 3000 });
    return;
  }
  
  if (withdrawAmount > transactionLimits.value.withdrawal.remaining) {
    toast.add({ 
      severity: 'error', 
      summary: 'Limit Exceeded', 
      detail: `Hourly withdrawal limit reached. You can withdraw up to ${formatCurrency(transactionLimits.value.withdrawal.remaining)} now. Limit resets in ${withdrawalTimeRemaining.value}`, 
      life: 5000 
    });
    return;
  }
  
  isLoading.value = true;
  
  // Simulate transaction processing
  setTimeout(() => {
    accountData.value.balance -= withdrawAmount;
    transactionLimits.value.withdrawal.remaining -= withdrawAmount;
    
    // Add transaction to history
    transactions.value.unshift({
      type: 'withdrawal',
      amount: withdrawAmount,
      date: new Date().toISOString(),
      success: true
    });
    
    toast.add({ 
      severity: 'success', 
      summary: 'Withdrawal Successful', 
      detail: `You have withdrawn ${formatCurrency(withdrawAmount)}`, 
      life: 3000 
    });
    
    amount.value = '';
    isLoading.value = false;
  }, 1500);
};

// Handle deposit
const handleDeposit = () => {
  checkLimitReset();
  
  const depositAmount = parseFloat(amount.value);
  
  if (!depositAmount || isNaN(depositAmount) || depositAmount <= 0) {
    toast.add({ severity: 'error', summary: 'Invalid Amount', detail: 'Please enter a valid amount to deposit', life: 3000 });
    return;
  }
  
  if (depositAmount > transactionLimits.value.deposit.remaining) {
    toast.add({ 
      severity: 'error', 
      summary: 'Limit Exceeded', 
      detail: `Hourly deposit limit reached. You can deposit up to ${formatCurrency(transactionLimits.value.deposit.remaining)} now. Limit resets in ${depositTimeRemaining.value}`, 
      life: 5000 
    });
    return;
  }
  
  isLoading.value = true;
  
  // Simulate transaction processing
  setTimeout(() => {
    accountData.value.balance += depositAmount;
    transactionLimits.value.deposit.remaining -= depositAmount;
    
    // Add transaction to history
    transactions.value.unshift({
      type: 'deposit',
      amount: depositAmount,
      date: new Date().toISOString(),
      success: true
    });
    
    toast.add({ 
      severity: 'success', 
      summary: 'Deposit Successful', 
      detail: `You have deposited ${formatCurrency(depositAmount)}`, 
      life: 3000 
    });
    
    amount.value = '';
    isLoading.value = false;
  }, 1500);
};

// Set quick amount
const setQuickAmount = (value) => {
  amount.value = value.toString();
};

// Reset component
const resetComponent = () => {
  activeTab.value = 'account';
  amount.value = '';
};

// Check for limit resets periodically
onMounted(() => {
  const intervalId = setInterval(checkLimitReset, 10000); // Check every 10 seconds
  
  // Clean up interval on unmount
  return () => clearInterval(intervalId);
});

// Emit events
const emit = defineEmits(['close']);
</script>

<template>
  <div>
    <Toast />
    <transition
      name="slide-up"
      @after-leave="() => { emit('close'); resetComponent(); }"
      appear
    >
      <div
        class="w-full h-[40rem] w-[60rem] bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl shadow-2xl p-6 flex flex-col transition-all duration-500 ease-in-out transform-gpu relative"
      >
        <!-- ATM Header -->
        <div class="flex justify-between items-center mb-6">
          <div class="flex items-center">
            <div class="text-emerald-400 text-3xl font-bold">FlexBank</div>
            <div class="ml-2 bg-emerald-400 text-slate-900 text-xs font-bold px-2 py-1 rounded">ATM</div>
          </div>
          <div class="text-slate-400 text-sm">{{ new Date().toLocaleString() }}</div>
        </div>
        
        <!-- ATM Content -->
        <div class="flex flex-1 gap-4">
          <!-- Left Navigation -->
          <div class="bg-slate-700/30 rounded-xl p-4 w-1/4 flex flex-col">
            <button 
              @click="activeTab = 'account'" 
              :class="[
                'p-3 mb-2 rounded-lg text-left transition-all duration-300 flex items-center',
                activeTab === 'account' 
                  ? 'bg-emerald-500/20 text-emerald-400' 
                  : 'hover:bg-slate-700/50 text-slate-300'
              ]"
            >
              <i class="pi pi-user mr-2"></i>
              Account
            </button>
            
            <button 
              @click="activeTab = 'withdraw'" 
              :class="[
                'p-3 mb-2 rounded-lg text-left transition-all duration-300 flex items-center',
                activeTab === 'withdraw' 
                  ? 'bg-emerald-500/20 text-emerald-400' 
                  : 'hover:bg-slate-700/50 text-slate-300'
              ]"
            >
              <i class="pi pi-arrow-up mr-2"></i>
              Withdraw
            </button>
            
            <button 
              @click="activeTab = 'deposit'" 
              :class="[
                'p-3 mb-2 rounded-lg text-left transition-all duration-300 flex items-center',
                activeTab === 'deposit' 
                  ? 'bg-emerald-500/20 text-emerald-400' 
                  : 'hover:bg-slate-700/50 text-slate-300'
              ]"
            >
              <i class="pi pi-arrow-down mr-2"></i>
              Deposit
            </button>
            
           
            
            <div class="flex-grow"></div>
            
            <button 
              @click="emit('close')" 
              class="p-3 rounded-lg text-left bg-red-500/20 text-red-400 hover:bg-red-500/30 transition-all duration-300 flex items-center mt-4"
            >
              <i class="pi pi-times mr-2"></i>
              Exit
            </button>
          </div>
          
          <!-- Right Content Area -->
          <div class="bg-slate-700/30 rounded-xl p-5 flex-1 overflow-hidden">
            <!-- Account Tab -->
            <transition name="fade" mode="out-in">
              <div v-if="activeTab === 'account'" class="h-full flex flex-col">
                <h2 class="text-xl font-bold text-white mb-6">Account Information</h2>
                
                <div class="bg-slate-800/50 rounded-xl p-5 mb-4">
                  <div class="flex items-center mb-4">
                    <div class="text-slate-400">Account Holder:</div>
                    <div class="text-white ml-2 font-medium">{{ accountData.accountHolder }}</div>
                  </div>
                  
                  <div class="flex items-center mb-4">
                    <div class="text-slate-400">Account Number:</div>
                    <div class="text-white ml-2 font-medium">{{ accountData.accountNumber }}</div>
                  </div>
                  
                  <div class="flex items-center mb-4">
                    <div class="text-slate-400">Account Type:</div>
                    <div class="text-white ml-2 font-medium">{{ accountData.accountType }}</div>
                  </div>
                  
                  <div class="flex items-center">
                    <div class="text-slate-400">Card ID:</div>
                    <div class="text-white ml-2 font-medium">{{ accountData.cardId }}</div>
                  </div>
                </div>
                
                <div class="bg-slate-800/50 rounded-xl p-5 flex flex-col items-center justify-center flex-grow">
                  <div class="text-slate-400 mb-2">Current Balance</div>
                  <div class="text-emerald-400 text-4xl font-bold">{{ formatCurrency(accountData.balance) }}</div>
                </div>
              </div>
              
              <!-- Withdraw Tab -->
              <div v-else-if="activeTab === 'withdraw'" class="h-full flex flex-col">
                <h2 class="text-xl font-bold text-white mb-2">Withdraw Funds</h2>
                
                <div class="text-sm text-slate-400 mb-6">
                  Hourly Limit: {{ formatCurrency(transactionLimits.withdrawal.remaining) }} 
                  <span  style="color: white !important" class="text-xs ml-1">(Resets in {{ withdrawalTimeRemaining }})</span>
                </div>
                
                <div class="bg-slate-800/50 rounded-xl p-5 mb-4">
                  <div class="mb-4">
                    <label class="block text-slate-400 mb-2">Amount to Withdraw</label>
                    <input 
                      type="number" 
                      v-model="amount" 
                      placeholder="Enter amount" 
                      class="w-full bg-slate-700 text-white p-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/50"
                    />
                  </div>
                  
                  <div class="grid grid-cols-2 gap-3">
                    <div 
                      v-for="quickAmount in [100, 200, 500, 1000]" 
                      :style="{ color: 'white' }"
                      :key="quickAmount"
                      @click="setQuickAmount(quickAmount)"
                      class="bg-slate-700/50 text-center p-3 rounded-lg cursor-pointer hover:bg-emerald-500/20 hover:text-emerald-400 transition-all duration-300"
                    >
                      {{ formatCurrency(quickAmount) }}
                    </div>
                  </div>
                </div>
                
                <div class="flex justify-between">
                  <button 
                    @click="activeTab = 'account'" 
                    class="px-5 py-3 rounded-lg bg-slate-700/50 text-slate-300 hover:bg-slate-700 transition-all duration-300"
                  >
                    Cancel
                  </button>
                  
                  <button 
                    @click="handleWithdraw" 
                    class="px-5 py-3 rounded-lg bg-emerald-600 text-white hover:bg-emerald-500 transition-all duration-300 flex items-center"
                    :disabled="isLoading"
                  >
                    <i v-if="isLoading" class="pi pi-spin pi-spinner mr-2"></i>
                    <span v-else class="pi pi-check mr-2"></span>
                    Confirm Withdrawal
                  </button>
                </div>
              </div>
              
              <!-- Deposit Tab -->
              <div v-else-if="activeTab === 'deposit'" class="h-full flex flex-col">
                <h2 class="text-xl font-bold text-white mb-2">Deposit Funds</h2>
                
                <div class="text-sm text-slate-400 mb-6">
                  Hourly Limit: {{ formatCurrency(transactionLimits.deposit.remaining) }} 
                  <span class="text-xs ml-1">(Resets in {{ depositTimeRemaining }})</span>
                </div>
                
                <div class="bg-slate-800/50 rounded-xl p-5 mb-4">
                  <div class="mb-4">
                    <label class="block text-slate-400 mb-2">Amount to Deposit</label>
                    <input 
                      type="number" 
                      v-model="amount" 
                      placeholder="Enter amount" 
                      class="w-full bg-slate-700 text-white p-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/50"
                    />
                  </div>
                  
                  <div class="grid grid-cols-2 gap-3">
                    <div 
                      v-for="quickAmount in [100, 200, 500, 1000]" 
                      :key="quickAmount"
                    :style="{ color: 'white' }"
                      @click="setQuickAmount(quickAmount)"
                      class="bg-slate-700/50 text-center p-3 rounded-lg cursor-pointer hover:bg-emerald-500/20 hover:text-emerald-400 transition-all duration-300"
                    >
                      {{ formatCurrency(quickAmount) }}
                    </div>
                  </div>
                </div>
                
                <div class="flex justify-between">
                  <button 
                    @click="activeTab = 'account'" 
                    class="px-5 py-3 rounded-lg bg-slate-700/50 text-slate-300 hover:bg-slate-700 transition-all duration-300"
                  >
                    Cancel
                  </button>
                  
                  <button 
                    @click="handleDeposit" 
                    class="px-5 py-3 rounded-lg bg-emerald-600 text-white hover:bg-emerald-500 transition-all duration-300 flex items-center"
                    :disabled="isLoading"
                  >
                    <i v-if="isLoading" class="pi pi-spin pi-spinner mr-2"></i>
                    <span v-else class="pi pi-check mr-2"></span>
                    Confirm Deposit
                  </button>
                </div>
              </div>
              
              <!-- History Tab -->
              <div v-else-if="activeTab === 'history'" class="h-full flex flex-col">
                <h2 class="text-xl font-bold text-white mb-6">Transaction History</h2>
                
                <div class="overflow-y-auto flex-grow">
                  <div v-if="transactions.length === 0" class="text-center text-slate-400 py-10">
                    No transaction history available
                  </div>
                  
                  <div v-else v-for="(transaction, index) in transactions" :key="index"
                    class="bg-slate-800/50 rounded-lg p-4 mb-3 flex items-center justify-between"
                  >
                    <div class="flex items-center">
                      <div 
                        :class="[
                          'rounded-full p-2 mr-4', 
                          transaction.type === 'withdrawal' ? 'bg-red-500/20 text-red-400' : 'bg-emerald-500/20 text-emerald-400'
                        ]"
                      >
                        <i :class="transaction.type === 'withdrawal' ? 'pi pi-arrow-up' : 'pi pi-arrow-down'"></i>
                      </div>
                      
                      <div>
                        <div class="font-medium text-white">{{ transaction.type === 'withdrawal' ? 'Withdrawal' : 'Deposit' }}</div>
                        <div class="text-sm text-slate-400">{{ new Date(transaction.date).toLocaleString() }}</div>
                      </div>
                    </div>
                    
                    <div 
                      :class="[
                        'font-bold', 
                        transaction.type === 'withdrawal' ? 'text-red-400' : 'text-emerald-400'
                      ]"
                    >
                      {{ transaction.type === 'withdrawal' ? '-' : '+' }}{{ formatCurrency(transaction.amount) }}
                    </div>
                  </div>
                </div>
              </div>
            </transition>
          </div>
        </div>
        
        <!-- ATM Footer -->
        <div class="flex justify-between items-center mt-4 text-sm text-slate-500 text-white">
          <div style="color: white !important">FlexBank ATM Services</div>
          <div style="color: white !important">Card: {{ accountData.cardId }}</div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style>
.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>