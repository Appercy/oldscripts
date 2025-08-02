<script setup>
import { ref, defineAsyncComponent, computed, onMounted, inject, provide, onUnmounted } from 'vue';
import Dialog from 'primevue/dialog';
import InputNumber from 'primevue/inputnumber';
import Dropdown from 'primevue/dropdown';
import 'primeicons/primeicons.css';
import { useI18n } from 'vue-i18n';
import { i18n } from '../main.js';


const { t } = useI18n();
const { toggleDisplay } = inject('displayState');

const handleKeyPress = (event) => {
  if (event.key === 'Escape') {
    exitBanking();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeyPress);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyPress);
});

const handleClickOutside = (event) => {
  // const tabletElement = document.querySelector('.tablet-element');
  // if (tabletElement && !tabletElement.contains(event.target)) {
  //   exitBanking();
  // }
};

onMounted(() => {
  window.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  window.removeEventListener('click', handleClickOutside);
});

// NUI Implementation
const fetchNui = async (eventName, data = {}) => {
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

// State Management
const bankData = ref(null);
const isLoading = ref(true);
const activeTab = ref('home');

// Data Processing
const processBankData = (rawData) => {
  if (!rawData) return null;
  
  // Check if rawData is an array
  if (!Array.isArray(rawData)) {
    console.error('Invalid bank data format: expected an array', rawData);
    return { accounts: [], primaryAccount: null };
  }
  
  try {
    return {
      accounts: rawData.map(account => {
        // Ensure each account object is valid
        if (!account) {
          console.warn('Found null or undefined account in data');
          return null;
        }
        
        return {
          id: account.IBAN || `account-${Math.random().toString(36).substring(2, 10)}`,
          name: account.Primary ? t('accounts.main') : t('accounts.savings'),
          balance: account.Balance || 0,
          iban: account.IBAN || 'N/A',
          role: account.Role || 'user',
          transactions: Array.isArray(account.Transactions) ? account.Transactions : [],
          cards: account.cards?.flatMap(cardGroup => 
            cardGroup ? Object.values(cardGroup) : []
          ) || [],
          group: Array.isArray(account.Group) ? account.Group : []
        };
      }).filter(Boolean), // Remove null entries
      primaryAccount: rawData.find(acc => acc?.Primary)
    };
  } catch (error) {
    console.error('Error processing bank data:', error);
    return { accounts: [], primaryAccount: null };
  }
};

// Data Fetching
const loadBankData = async () => {
    try {
        const response = await fetchNui('getBankData');
        
        // Debug log to see what's coming from the server
        console.log('Raw bank data received:', response);
        
        if (!response) {
            console.warn('No data received from NUI');
            bankData.value = { accounts: [], primaryAccount: null };
        } else {
            bankData.value = processBankData(response);
        }
    } catch (error) {
        console.error('Failed to load bank data:', error);
        bankData.value = { accounts: [], primaryAccount: null };
    } finally {
        isLoading.value = false;
    }
};

// Components
const Home = defineAsyncComponent(() => import('./BankingSites/Home.vue'));
const Banking = defineAsyncComponent(() => import('./BankingSites/BankingTab.vue'));
const Billing = defineAsyncComponent(() => import('./BankingSites/Billing.vue'));
const ATM = defineAsyncComponent(() => import('./BankingSites/Card.vue'));
const Settings = defineAsyncComponent(() => import('./BankingSites/Settings.vue'));

// UI Configuration
const items = ref([
  { label: 'Home', icon: 'pi pi-home', value: 'home', active: true },
  { label: 'Banking', icon: 'pi pi-wallet', value: 'banking', active: false },
  { label: 'Bills', icon: 'pi pi-credit-card', value: 'billing', active: false },
  { label: 'Cards', icon: 'pi pi-id-card', value: 'atm', active: false },
]);

const tabComponents = {
  home: Home,
  banking: Banking,
  billing: Billing,
  atm: ATM,
  settings: Settings
};

// Reactive Data
const accounts = computed(() => bankData.value?.accounts || []);
provide('bankData', bankData);

// Tab Navigation
const activeTabIndex = computed({
  get() {
    return items.value.findIndex(item => item.value === activeTab.value);
  },
  set(index) {
    activeTab.value = items.value[index].value;
  }
});

const onTabSelect = (event) => {
  activeTabIndex.value = event.index;
  items.value.forEach((item, index) => {
    item.active = index === event.index;
  });
};

// Initialization
onMounted(loadBankData);
const exitBanking = () => toggleDisplay('banking');
</script>

<template>
    <div class="tablet-element w-[90vw] h-[90vh] mx-auto my-auto relative flex rounded-2xl shadow-2xl bg-slate-900 border border-slate-800/60">
        <!-- Loading Overlay -->
        <div v-if="isLoading" class="absolute inset-0 bg-slate-900/80 backdrop-blur-sm z-50 flex items-center justify-center">
            <div class="text-center">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-sky-400 mx-auto"></div>
                <p class="mt-4 text-slate-300">Loading banking data...</p>
            </div>
        </div>

        <!-- Navigation Sidebar with disabled state -->
        <div class="w-20 hover:w-64 bg-slate-900/95 p-6 flex flex-col border-r border-sky-900/40 transition-all duration-300 ease-out-expo group/sidebar"
                 :class="{ 'opacity-50 pointer-events-none': isLoading }">
            <!-- Logo -->
            <div class="mb-8 px-4 flex flex-col items-center">
                <!-- <img src="@/assets/tc-logo.png" alt="Logo" class="h-10 w-10 filter brightness-125 transition-transform duration-300 hover:scale-110"> -->
                <span class="mt-2 text-zinc-400 font-medium text-sm opacity-0 group-hover/sidebar:opacity-100 transition-opacity">BankName</span>
            </div>

            <!-- Navigation -->
            <nav class="flex-1 space-y-2">
                <button
                  v-for="(item, index) in items"
                  :key="item.label"
                  @click="onTabSelect({ index })"
                  class="w-full flex items-center gap-4 px-4 py-3 rounded-xl transition-all duration-200 group/item overflow-hidden"
                  :class="{
                    'bg-sky-400/10 text-sky-400': activeTab === item.value,
                    'text-slate-400 hover:bg-slate-800/20': activeTab !== item.value
                  }"
                >
                  <i :class="item.icon" class="text-lg transition-transform duration-200 group-hover/item:scale-110" />
                  <span class="text-sm font-medium opacity-0 group-hover/sidebar:opacity-100 transition-opacity">{{ t("sidebar." + item.value) }}</span>
                </button>
            </nav>

            <!-- Settings Button -->
            <button
                @click="activeTab = 'settings'"
                class="mt-4 flex items-center gap-3 px-4 py-3 text-slate-400 hover:bg-slate-800/20 rounded-xl transition-colors overflow-hidden"
                :class="{ 'bg-sky-400/10 text-sky-400': activeTab === 'settings' }"
            >
                <i class="pi pi-cog text-lg" />
                <span class="text-sm opacity-0 group-hover/sidebar:opacity-100 transition-opacity">{{ t("sidebar.settings") }}</span>
            </button>

            <!-- Exit Button -->
            <button 
                @click="exitBanking"
                class="mt-auto flex items-center gap-3 px-4 py-3 text-slate-400 hover:bg-slate-800/20 rounded-xl transition-colors overflow-hidden"
            >
                <i class="pi pi-sign-out text-lg" />
                <span class="text-sm opacity-0 group-hover/sidebar:opacity-100 transition-opacity">{{ t("sidebar.exit") }}</span>
            </button>
        </div>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col bg-gradient-to-br from-slate-900/50 to-slate-900/20 backdrop-blur-lg">
            <div v-if="!isLoading" class="flex-1 overflow-y-auto p-6">
                <component 
                    :is="tabComponents[activeTab]"
                    class="bg-transparent rounded-xl transition-all"
                />
            </div>
        </div>
    </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

* {
    font-family: 'Inter', sans-serif;
    scrollbar-width: thin;
    scrollbar-color: rgba(148, 163, 184, 0.4) transparent;
}

::-webkit-scrollbar {
    width: 6px;
}

::-webkit-scrollbar-thumb {
    background: rgba(148, 163, 184, 0.4);
    border-radius: 3px;
}

.component-enter-active,
.component-leave-active {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.ease-out-expo {
    transition-timing-function: cubic-bezier(0.16, 1, 0.3, 1);
}

.p-dropdown-panel {
    background: #0f172a !important;
    border: 1px solid #1e293b !important;
}

.p-inputnumber-input {
    background: #1e293b !important;
    border-color: #334155 !important;
}
</style>