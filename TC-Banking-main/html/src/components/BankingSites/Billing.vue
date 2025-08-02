<script setup>
import { ref, computed, reactive } from 'vue';
import { useToast } from 'primevue/usetoast';
import Button from 'primevue/button';
import InputNumber from 'primevue/inputnumber';
import InputText from 'primevue/inputtext';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Dropdown from 'primevue/dropdown';
import Badge from 'primevue/badge';
import Checkbox from 'primevue/checkbox';

const toast = useToast();

// Debug data for received bills
const receivedBills = ref([
  {
    id: 1,
    amount: 200,
    issueDate: new Date('2023-08-05').toISOString(),
    dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
    description: 'Electricity Bill',
    issuer: 'Utility Co',
    paymentDate: null,
    isSocietyBill: false,
    society: null,
    iban: 'LS00BANK0000000001'
  },
  {
    id: 2,
    amount: 150,
    issueDate: new Date('2023-07-15').toISOString(),
    dueDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    description: 'Water Bill',
    issuer: 'Water Supplier',
    paymentDate: new Date('2023-07-20').toISOString(),
    isSocietyBill: false,
    society: null,
    iban: 'LS00BANK0000000002'
  }
]);

// Debug data for issued bills
const issuedBills = ref([
  {
    id: 3,
    amount: 450,
    issueDate: new Date('2023-08-01').toISOString(),
    dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString(),
    description: 'Web Development Services',
    recipient: 'Tech Corp',
    paid: false,
    iban: 'LS00BANK0000000003'
  }
]);

// Debug data for accounts (for paying bills)
const accounts = ref([
  { id: 1, name: 'Main Account', balance: 12500, IBAN: 'LS00BANK1234567890' },
  { id: 2, name: 'Savings', balance: 5000, IBAN: 'LS00BANK9876543210' }
]);

// UI State
const showCreateBillModal = ref(false);
const showPayBillModal = ref(false);
const selectedBill = ref(null);
const selectedPaymentAccount = ref(null);
const activeTab = ref('received'); // 'received' or 'issued'

// Form data for creating a new bill
const newBillData = reactive({
  amount: null,
  dueDate: null,
  description: '',
  issuer: '',
  isSocietyBill: false,
  society: 'Police', // Default society for now
  iban: ''
});

// Form data for creating a new card
const newCard = reactive({
  accountId: null,
  nickname: ''
});

// Loading states for async operations
const loading = ref({
  createBill: false,
  payBill: false
});

// Simulated async callback (2-second delay)
const simulateAsync = () => {
  return new Promise(resolve => setTimeout(() => resolve(true), 2000));
};

// Calculate days left until due date (if unpaid)
const daysUntilDue = (dueDateStr) => {
  const now = new Date();
  const due = new Date(dueDateStr);
  const diffTime = due - now;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

// Computed: Sort bills so that unpaid come first
const sortedBills = computed(() => {
  return [...receivedBills.value].sort((a, b) => {
    if (a.paymentDate && !b.paymentDate) return 1;
    if (!a.paymentDate && b.paymentDate) return -1;
    return 0;
  });
});

// Action: Create a new bill
const createBill = async () => {
  if (!newBillData.amount || !newBillData.dueDate) return;
  loading.value.createBill = true;
  const result = await simulateAsync();
  loading.value.createBill = false;
  if (!result) return;
  const newBill = {
    id: issuedBills.value.length + 1,
    amount: newBillData.amount,
    issueDate: new Date().toISOString(),
    dueDate: newBillData.dueDate.toISOString(),
    description: newBillData.description,
    recipient: newBillData.issuer,
    paid: false,
    iban: newBillData.iban
  };
  issuedBills.value.push(newBill);
  showCreateBillModal.value = false;
  newBillData.amount = null;
  newBillData.dueDate = null;
  newBillData.description = '';
  newBillData.issuer = '';
  newBillData.isSocietyBill = false;
  newBillData.society = 'Police';
  newBillData.iban = '';
};

// Action: Pay a bill
const payBill = async () => {
  if (!selectedBill.value || !selectedPaymentAccount.value) return;
  loading.value.payBill = true;
  const result = await simulateAsync();
  loading.value.payBill = false;
  if (!result) return;

  // Deduct the bill amount from the selected account
  const account = accounts.value.find(a => a.id === selectedPaymentAccount.value);
  if (account && account.balance >= selectedBill.value.amount) {
    account.balance -= selectedBill.value.amount;
    // Mark the bill as paid
    selectedBill.value.paymentDate = new Date().toISOString();
  }
  showPayBillModal.value = false;
  selectedBill.value = null;
  selectedPaymentAccount.value = null;
};

// Action: Decline a bill
const declineBill = (billId) => {
  const billIndex = receivedBills.value.findIndex(bill => bill.id === billId);
  if (billIndex !== -1 && !receivedBills.value[billIndex].isSocietyBill) {
    receivedBills.value.splice(billIndex, 1);
    toast.add({ severity: 'success', summary: 'Bill Declined', detail: 'Bill has been successfully declined', life: 3000 });
  }
};

// Date picker constraints
const minDate = new Date().toISOString().split('T')[0];
const maxDate = new Date(new Date().setMonth(new Date().getMonth() + 1)).toISOString().split('T')[0];

// Check if user has a whitelisted job (e.g., police)
const hasWhitelistedJob = ref(true); // For now, assume the user has the whitelisted job

import { useI18n } from 'vue-i18n';
import { i18n } from '../../main.js';
const { t, locale } = useI18n();
</script>

<template>
  <div class="billing-container p-6 min-h-screen">
    <!-- Tabs -->
    <div class="flex gap-2 mb-8 p-2 bg-slate-800/30 rounded-xl backdrop-blur-sm">
      <button
        v-for="tab in ['received', 'issued']"
        :key="tab"
        @click="activeTab = tab"
        class="px-6 py-2.5 rounded-lg text-sm font-medium transition-all"
        :class="[
          activeTab === tab 
            ? 'bg-sky-500/20 text-sky-400 shadow-md' 
            : 'text-slate-400 hover:bg-slate-700/40'
        ]"
      >
        {{ t(`billing.tabs.${tab}`) }}
      </button>
    </div>

    <!-- Received Bills -->
    <div v-if="activeTab === 'received'">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h1 class="text-2xl font-bold text-slate-100 mb-1">{{ t('billing.received.title') }}</h1>
          <p class="text-slate-400 text-sm">{{ t('billing.received.subtitle') }}</p>
        </div>
        <button 
          @click="showCreateBillModal = true"
          class="flex items-center gap-2 px-4 py-2.5 rounded-lg bg-sky-500/20 hover:bg-sky-500/30 transition-all"
        >
          <i class="pi pi-plus text-sky-400"></i>
          <span class="text-sky-400 text-sm">{{ t('billing.received.createBill') }}</span>
        </button>
      </div>

      <!-- Bills Grid -->
      <div v-if="sortedBills.length" class="grid gap-4">
        <div 
          v-for="bill in sortedBills"
          :key="bill.id"
          class="group relative bg-slate-800/40 backdrop-blur-sm rounded-xl p-5 border border-slate-700/50 hover:border-sky-400/30 transition-all"
        >
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-slate-100 font-medium mb-1">{{ bill.description }}</h3>
              <p class="text-slate-400 text-sm">{{ bill.issuer }}</p>
            </div>
            <div class="text-sky-400 text-lg font-semibold">
              {{ new Intl.NumberFormat('en-US', { style: 'currency', currency: 'EUR' }).format(bill.amount) }}
            </div>
          </div>

          <div class="flex justify-between items-center text-sm">
            <div class="text-slate-400">
              {{ new Date(bill.dueDate).toLocaleDateString() }}
              <span class="ml-2" :class="{
                'text-green-400': bill.paymentDate,
                'text-amber-400': !bill.paymentDate && daysUntilDue(bill.dueDate) > 3,
                'text-red-400': !bill.paymentDate && daysUntilDue(bill.dueDate) <= 3
              }">
                {{
                  bill.paymentDate 
                    ? t('billing.received.paid') 
                    : daysUntilDue(bill.dueDate) > 0 
                      ? t('billing.received.daysLeft', { days: daysUntilDue(bill.dueDate) })
                      : t('billing.received.overdue', { days: Math.abs(daysUntilDue(bill.dueDate)) })
                }}
              </span>
            </div>
            <div class="flex gap-2">
              <button
                v-if="!bill.paymentDate"
                @click="selectedBill = bill; showPayBillModal = true"
                class="p-2 rounded-lg hover:bg-slate-700/40 transition-colors text-slate-300 hover:text-sky-400"
              >
                <i class="pi pi-check"></i>
              </button>
              <button
                v-if="!bill.isSocietyBill && !bill.paymentDate"
                @click="declineBill(bill.id)"
                class="p-2 rounded-lg hover:bg-slate-700/40 transition-colors text-slate-300 hover:text-red-400"
              >
                <i class="pi pi-times"></i>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-12 text-slate-400/60">
        <i class="pi pi-inbox text-4xl mb-4"></i>
        <p class="text-sm">{{ t('billing.received.empty') }}</p>
      </div>
    </div>

    <!-- Issued Bills -->
    <div v-if="activeTab === 'issued'">
      <div class="mb-6">
        <h1 class="text-2xl font-bold text-slate-100 mb-1">{{ t('billing.issued.title') }}</h1>
        <p class="text-slate-400 text-sm">{{ t('billing.issued.subtitle') }}</p>
      </div>

      <div v-if="issuedBills.length" class="grid gap-4">
        <div 
          v-for="bill in issuedBills"
          :key="bill.id"
          class="group relative bg-slate-800/40 backdrop-blur-sm rounded-xl p-5 border border-slate-700/50 hover:border-sky-400/30 transition-all"
        >
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-slate-100 font-medium mb-1">{{ bill.description }}</h3>
              <p class="text-slate-400 text-sm">{{ bill.recipient }}</p>
            </div>
            <div class="text-sky-400 text-lg font-semibold">
              {{ new Intl.NumberFormat('en-US', { style: 'currency', currency: 'EUR' }).format(bill.amount) }}
            </div>
          </div>

          <div class="flex justify-between items-center text-sm">
            <div class="text-slate-400">
              {{ new Date(bill.dueDate).toLocaleDateString() }}
              <span class="ml-2" :class="{
                'text-green-400': bill.paid,
                'text-amber-400': !bill.paid
              }">
                {{ bill.paid ? t('billing.issued.paid') : t('billing.issued.pending') }}
              </span>
            </div>
            <div class="text-slate-400 text-xs">
              {{ bill.iban }}
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-12 text-slate-400/60">
        <i class="pi pi-inbox text-4xl mb-4"></i>
        <p class="text-sm">{{ t('billing.issued.empty') }}</p>
      </div>
    </div>

 
  </div>
</template>


<style>
.billing-container {
  background: linear-gradient(215deg, rgba(15,23,42,0.6) 0%, rgba(15,23,42,0.8) 100%);
}

/* Smooth transitions */
.transition-all {
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(15,23,42,0.4);
}

::-webkit-scrollbar-thumb {
  background: rgba(148,163,184,0.4);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(148,163,184,0.6);
}

</style>