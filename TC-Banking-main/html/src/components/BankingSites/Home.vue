<script setup>
import { ref, computed, inject, watchEffect, onMounted } from 'vue';
import Chart from 'primevue/chart';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const bankData = inject('bankData');

const currentUser = ref("NOT FOUND");
const currentDateTime = ref(new Date().toLocaleString());

const fetchNui = async (eventName, data = {}) => {
  const resourceName = window.GetParentResourceName?.() || 'tc-banking';
  try {
    console.log(eventName)
    const resp = await fetch(`https://${resourceName}/${eventName}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    });
    const text = await resp.text();
    try {
      return JSON.parse(text);
    } catch (error) {
      console.error('NUI Error: Invalid JSON response', error);
      return null;
    }
  } catch (error) {
    console.error('NUI Error:', error);
    return null;
  }
};

onMounted(async () => {
  const user = await fetchNui('getUser');
  if (user) {
    currentUser.value = user.name;
  }
});

const transactionsModalVisible = ref(false);

const mainAccount = computed(() => {
  if (!bankData.value?.accounts) return {};
  console.log(JSON.stringify(bankData.value.accounts, null, 2));
  return bankData.value.accounts.find(acc => acc.group.some(g => g.ROLE === "owner")) || {};
});

const balance = computed(() => mainAccount.value?.balance ?? 0);

watchEffect(() => {
  console.log('Bank Data:', bankData.value);
  console.log('Main Account:', mainAccount.value);
  console.log('Balance:', balance.value);
});

// Transactions
const allTransactions = computed(() => {
  return (mainAccount.value.transactions || [])
    .sort((a, b) => b.DATE - a.DATE)
    .map(t => ({
      ...t,
      formattedDate: formatDate(t.DATE),
      formattedAmount: t.ADDITIVE === 1 ?
        `+${parseFloat(t.AMOUNT).toFixed(2)}€` :
        `-${parseFloat(t.AMOUNT).toFixed(2)}€`,
      isAdditive: t.ADDITIVE === 1
    }));
});

const recentTransactions = computed(() => allTransactions.value.slice(0, 4));

const openTransactionsModal = () => { transactionsModalVisible.value = true; };
const closeTransactionsModal = () => { transactionsModalVisible.value = false; };

const getTransactionIcon = (transaction) => {
  return transaction.isAdditive ? 'pi-arrow-down text-emerald-400' : 'pi-arrow-up text-rose-400';
};

// Chart data setup
const chartData = ref();
const spendingData = ref();
const incomeData = ref();

const groupTransactionsByDay = (transactions) => {
  const grouped = {};
  transactions.forEach(t => {
    const date = new Date(t.DATE).toLocaleDateString();
    if (!grouped[date]) grouped[date] = { date, total: 0 };
    grouped[date].total += Math.abs(t.AMOUNT);
  });
  return Object.values(grouped);
};

const balanceHistory = computed(() => {
  const transactions = (mainAccount.value.transactions || []).sort((a, b) => a.DATE - b.DATE);
  let balance = mainAccount.value.balance;
  const history = transactions.reverse().map(t => {
    if (t.ADDITIVE === 1) {
      balance -= parseFloat(t.AMOUNT);
    } else {
      balance += parseFloat(t.AMOUNT);
    }
    return balance;
  }).reverse();
  return history.length > 0 ? history : [mainAccount.value.balance];
});

// Spending and income categories
const spendingCategories = computed(() => {
  const categories = {};
  (mainAccount.value.transactions || []).forEach(t => {
    if (t.ADDITIVE !== 1) {
      const category = (typeof t.DESCRIPTION === 'string' ? t.DESCRIPTION.split(' ')[0] : 'Other') || 'Other';
      categories[category] = (categories[category] || 0) + Math.abs(t.AMOUNT);
    }
  });
  return categories;
});

const incomeCategories = computed(() => {
  const categories = {};
  (mainAccount.value.transactions || []).forEach(t => {
    if (t.ADDITIVE === 1) {
      const category = (typeof t.DESCRIPTION === 'string' ? t.DESCRIPTION.split(' ')[0] : 'Other') || 'Other';
      categories[category] = (categories[category] || 0) + Math.abs(t.AMOUNT);
    }
  });
  return categories;
});

const totalIncome = computed(() => Object.values(incomeCategories.value).reduce((sum, value) => sum + value, 0));
const totalSpending = computed(() => Object.values(spendingCategories.value).reduce((sum, value) => sum + value, 0));

const setChartData = () => {
  const transactionsByDay = groupTransactionsByDay(mainAccount.value.transactions || []);
  chartData.value = {
    labels: transactionsByDay.map(t => t.date),
    datasets: [{
      label: t('home.balancehistory'),
      data: transactionsByDay.map(t => t.total),
      borderColor: '#38bdf8',
      tension: 0.4,
      fill: true,
      backgroundColor: 'rgba(56, 189, 248, 0.1)',
    }]
  };

  const spendingEntries = Object.entries(spendingCategories.value);
  spendingData.value = {
    labels: spendingEntries.map(([name]) => name),
    datasets: [{
      data: spendingEntries.map(([, value]) => value),
      backgroundColor: [
        'rgba(239, 68, 68, 0.7)',
        'rgba(245, 158, 11, 0.7)',
        'rgba(249, 115, 22, 0.7)',
        'rgba(234, 88, 12, 0.7)',
        'rgba(217, 70, 239, 0.7)',
        'rgba(168, 85, 247, 0.7)'
      ],
      hoverBackgroundColor: [
        'rgba(239, 68, 68, 1)',
        'rgba(245, 158, 11, 1)',
        'rgba(249, 115, 22, 1)',
        'rgba(234, 88, 12, 1)',
        'rgba(217, 70, 239, 1)',
        'rgba(168, 85, 247, 1)'
      ]
    }]
  };

  const incomeEntries = Object.entries(incomeCategories.value);
  incomeData.value = {
    labels: incomeEntries.map(([name]) => name),
    datasets: [{
      data: incomeEntries.map(([, value]) => value),
      backgroundColor: [
        'rgba(16, 185, 129, 0.7)',
        'rgba(5, 150, 105, 0.7)',
        'rgba(6, 182, 212, 0.7)',
        'rgba(56, 189, 248, 0.7)',
        'rgba(59, 130, 246, 0.7)',
        'rgba(124, 58, 237, 0.7)'
      ],
      hoverBackgroundColor: [
        'rgba(16, 185, 129, 1)',
        'rgba(5, 150, 105, 1)',
        'rgba(6, 182, 212, 1)',
        'rgba(56, 189, 248, 1)',
        'rgba(59, 130, 246, 1)',
        'rgba(124, 58, 237, 1)'
      ]
    }]
  };
};

const formatDate = (date) => new Date(date).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
const formatTime = (date) => new Date(date).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });

const getStatusClass = (status) => {
  switch(status?.toLowerCase()) {
    case 'completed': return 'bg-emerald-500/20 text-emerald-400';
    case 'pending': return 'bg-amber-500/20 text-amber-400';
    case 'failed': return 'bg-rose-500/20 text-rose-400';
    default: return 'bg-slate-500/20 text-slate-400';
  }
};

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 }).format(amount);
};

const hasEnoughData = computed(() => (mainAccount.value.transactions || []).length > 1);
const hasIncomeData = computed(() => Object.keys(incomeCategories.value).length > 0);
const hasSpendingData = computed(() => Object.keys(spendingCategories.value).length > 0);

watchEffect(() => {
  if (mainAccount.value && mainAccount.value.transactions) {
    setChartData();
  }
});
</script>

<template>
  <div class="space-y-8 p-6 max-w-screen-xl mx-auto">
    <!-- Header -->
    <header class="flex flex-col md:flex-row md:justify-between md:items-center">
      <h1 class="text-3xl font-bold">{{ t("home.dashboard") || "Dashboard" }}</h1>
      <div class="text-sm text-slate-400 flex items-center space-x-2">
        <i class="pi pi-calendar"></i>
        <span>{{ currentDateTime }}</span>
        <span>|</span>
        <span>{{ currentUser }}</span>
      </div>
    </header>

    <!-- Balance Card -->
    <section class="bg-gradient-to-br from-slate-800/70 to-slate-800/30 backdrop-blur p-6 rounded-2xl shadow-lg">
      <div class="flex flex-col md:flex-row md:justify-between items-start md:items-center">
        <div>
          <p class="text-slate-400">{{ t("home.balance") }}</p>
          <h2 class="text-4xl font-bold text-sky-400 mt-1">€ {{ balance.toLocaleString() }}</h2>
          <p class="text-sm text-slate-400 mt-1">{{ mainAccount.iban }}</p>
        </div>
        <i class="pi pi-wallet text-5xl text-sky-400/60 mt-4 md:mt-0"></i>
      </div>
    </section>

    <!-- Charts Grid -->
    <section class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <!-- Balance History & Income/Spending Charts -->
      <div class="bg-slate-800/40 rounded-2xl shadow-md backdrop-blur p-6">
        <h3 class="text-xl font-semibold mb-4">{{ t("home.balancehistory") }}</h3>
        <div v-if="hasEnoughData" class="mb-6">
          <Chart 
            type="line" 
            :data="chartData" 
            class="h-64 w-full"
            :options="{
              plugins: { legend: { display: false } },
              scales: { 
                y: { beginAtZero: false, grid: { color: '#334155' }, ticks: { color: '#94a3b8' } },
                x: { grid: { color: '#334155' }, ticks: { color: '#94a3b8' } }
              }
            }"
          />
        </div>
        <div v-else class="h-64 flex items-center justify-center text-slate-400">
          {{ t("home.notEnoughData") }}
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <!-- Income Chart -->
          <div>
            <div class="flex justify-between items-center mb-4">
              <h4 class="text-lg font-semibold">{{ t("home.income") || "Income" }}</h4>
              <span class="px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-400 font-medium">
                {{ formatCurrency(totalIncome) }}
              </span>
            </div>
            <div v-if="hasIncomeData" class="flex justify-center">
              <Chart 
                type="pie" 
                :data="incomeData" 
                class="h-44 w-44"
                :options="{ 
                  plugins: { legend: { position: 'bottom', labels: { color: '#94a3b8', boxWidth: 8, font: { size: 9 } } } },
                  maintainAspectRatio: false
                }"
              />
            </div>
            <div v-else class="h-44 flex items-center justify-center text-slate-400">
              {{ t("home.noIncomeData") || "No income transactions yet" }}
            </div>
          </div>
          <!-- Spending Chart -->
          <div>
            <div class="flex justify-between items-center mb-4">
              <h4 class="text-lg font-semibold">{{ t("home.spending") || "Spending" }}</h4>
              <span class="px-3 py-1 rounded-full bg-rose-500/20 text-rose-400 font-medium">
                {{ formatCurrency(totalSpending) }}
              </span>
            </div>
            <div v-if="hasSpendingData" class="flex justify-center">
              <Chart 
                type="pie" 
                :data="spendingData" 
                class="h-44 w-44"
                :options="{ 
                  plugins: { legend: { position: 'bottom', labels: { color: '#94a3b8', boxWidth: 8, font: { size: 9 } } } },
                  maintainAspectRatio: false
                }"
              />
            </div>
            <div v-else class="h-44 flex items-center justify-center text-slate-400">
              {{ t("home.noSpendingData") || "No spending transactions yet" }}
            </div>
          </div>
        </div>
      </div>
      <!-- Cash Flow Summary -->
      <div class="bg-slate-800/40 rounded-2xl shadow-md backdrop-blur p-6 flex flex-col">
        <h3 class="text-xl font-semibold mb-4">{{ t("home.cashflow") || "Cash Flow" }}</h3>
        <div class="space-y-4">
          <div class="flex items-center justify-between p-4 bg-slate-800/50 rounded-lg">
            <div class="flex items-center space-x-3">
              <div class="h-10 w-10 rounded-full flex items-center justify-center bg-emerald-500/20">
                <i class="pi pi-arrow-down text-emerald-400"></i>
              </div>
              <span>{{ t("home.totalIncome") || "Total Income" }}</span>
            </div>
            <span class="text-emerald-400 font-medium">{{ formatCurrency(totalIncome) }}</span>
          </div>
          <div class="flex items-center justify-between p-4 bg-slate-800/50 rounded-lg">
            <div class="flex items-center space-x-3">
              <div class="h-10 w-10 rounded-full flex items-center justify-center bg-rose-500/20">
                <i class="pi pi-arrow-up text-rose-400"></i>
              </div>
              <span>{{ t("home.totalSpending") || "Total Spending" }}</span>
            </div>
            <span class="text-rose-400 font-medium">{{ formatCurrency(totalSpending) }}</span>
          </div>
          <div class="flex items-center justify-between p-4 bg-slate-800/30 rounded-lg border-t border-slate-700">
            <span class="font-medium">{{ t("home.netCashflow") || "Net Cash Flow" }}</span>
            <span class="font-medium" :class="totalIncome - totalSpending >= 0 ? 'text-emerald-400' : 'text-rose-400'">
              {{ formatCurrency(totalIncome - totalSpending) }}
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- Recent Transactions -->
    <section class="bg-slate-800/40 rounded-2xl shadow-md backdrop-blur p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-semibold">{{ t("home.recent") || "Recent Transactions" }}</h3>
        <button @click="openTransactionsModal" class="text-sky-400 hover:text-sky-300 text-sm flex items-center transition-transform hover:scale-105">
          <span>{{ t("home.viewAll") || "View All" }}</span>
          <i class="pi pi-external-link ml-1"></i>
        </button>
      </div>
      <div class="space-y-3">
        <div 
          v-for="transaction in recentTransactions"
          :key="transaction.ID"
          class="p-4 bg-slate-800/50 rounded-xl flex justify-between items-center border-l-4 transition-colors hover:bg-slate-700/50"
          :class="transaction.isAdditive ? 'border-emerald-500' : 'border-rose-500'"
        >
          <div class="flex items-center space-x-3 flex-grow">
            <div class="h-10 w-10 rounded-full flex items-center justify-center" 
                 :class="transaction.isAdditive ? 'bg-emerald-500/20' : 'bg-rose-500/20'">
              <i class="pi" :class="getTransactionIcon(transaction)"></i>
            </div>
            <div class="flex-grow max-w-[60%]">
              <p class="font-medium text-slate-300 truncate">{{ transaction.DESCRIPTION }}</p>
              <div class="flex items-center text-xs space-x-2">
                <span class="text-slate-500">{{ transaction.formattedDate }}</span>
                <div class="px-2 py-0.5 rounded-full text-xs" :class="getStatusClass(transaction.STATUS)">
                  {{ transaction.STATUS }}
                </div>
              </div>
            </div>
          </div>
          <div class="text-right">
            <p class="font-medium text-lg" :class="transaction.isAdditive ? 'text-emerald-400' : 'text-rose-400'">
              {{ transaction.formattedAmount }}
            </p>
            <p class="text-xs text-slate-500" v-if="transaction.ISSUER">
              {{ transaction.ISSUER }}
            </p>
          </div>
        </div>
        <div v-if="recentTransactions.length === 0" class="text-center py-8 text-slate-500">
          <i class="pi pi-inbox text-3xl mb-2"></i>
          <p>No recent transactions</p>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="text-xs text-slate-500 text-right">
      <p>{{ currentDateTime }} | {{ currentUser }}</p>
    </footer>

    <!-- Transactions Modal -->
    <div v-if="transactionsModalVisible" class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 animate-fade-in">
      <div class="bg-slate-800 rounded-2xl shadow-xl w-full max-w-4xl max-h-[80vh] overflow-hidden flex flex-col">
        <!-- Modal Header -->
        <div class="p-4 border-b border-slate-700 flex justify-between items-center bg-slate-900">
          <h3 class="text-xl font-semibold">{{ t("home.allTransactions") || "All Transactions" }}</h3>
          <button @click="closeTransactionsModal" class="p-2 rounded-full hover:bg-slate-700 transition-colors">
            <i class="pi pi-times text-slate-400 hover:text-white"></i>
          </button>
        </div>
        <!-- Modal Content -->
        <div class="p-6 overflow-y-auto flex-grow">
          <div class="space-y-3">
            <div 
              v-for="transaction in allTransactions"
              :key="transaction.ID"
              class="p-4 bg-slate-800/50 rounded-xl flex justify-between items-center border-l-4 transition-colors hover:bg-slate-700/50"
              :class="transaction.isAdditive ? 'border-emerald-500' : 'border-rose-500'"
            >
              <div class="flex items-center space-x-3 flex-grow">
                <div class="h-10 w-10 rounded-full flex items-center justify-center" 
                     :class="transaction.isAdditive ? 'bg-emerald-500/20' : 'bg-rose-500/20'">
                  <i class="pi" :class="getTransactionIcon(transaction)"></i>
                </div>
                <div class="flex-grow max-w-[60%]">
                  <p class="font-medium text-slate-300 truncate">{{ transaction.DESCRIPTION }}</p>
                  <div class="flex items-center text-xs space-x-2">
                    <span class="text-slate-500">{{ transaction.formattedDate }}</span>
                    <div class="px-2 py-0.5 rounded-full text-xs" :class="getStatusClass(transaction.STATUS)">
                      {{ transaction.STATUS }}
                    </div>
                  </div>
                </div>
              </div>
              <div class="text-right">
                <p class="font-medium text-lg" :class="transaction.isAdditive ? 'text-emerald-400' : 'text-rose-400'">
                  {{ transaction.formattedAmount }}
                </p>
                <p class="text-xs text-slate-500" v-if="transaction.ISSUER">
                  {{ transaction.ISSUER }}
                </p>
              </div>
            </div>
            <div v-if="allTransactions.length === 0" class="text-center py-8 text-slate-500">
              <i class="pi pi-inbox text-3xl mb-2"></i>
              <p>No transactions found</p>
            </div>
          </div>
        </div>
        <!-- Modal Footer -->
        <div class="p-4 border-t border-slate-700 bg-slate-900 flex justify-end">
          <button @click="closeTransactionsModal" class="px-4 py-2 bg-slate-700 rounded-lg hover:bg-slate-600 transition-colors">
            {{ t("common.close") || "Close" }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
/* Global text color override for consistency */
* {
  color: white;
}

/* Simple fade-in animation */
.animate-fade-in {
  animation: fadeIn 0.3s ease-in;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
