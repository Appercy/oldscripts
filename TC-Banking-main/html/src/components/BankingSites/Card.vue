<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import ContextMenu from 'primevue/contextmenu';
import { useI18n } from 'vue-i18n';
const { t } = useI18n();

// Local bank data state
const bankData = ref(null);
const isLoadingBankData = ref(false);

// Track saved card nicknames
const cardNicknames = ref(JSON.parse(localStorage.getItem('cardNicknames') || '{}'));
watch(cardNicknames, (newNicknames) => {
  localStorage.setItem('cardNicknames', JSON.stringify(newNicknames));
}, { deep: true });

// Local cache for optimistic UI updates
const localCardCache = ref([]);

// Fetch and process bank data
const loadBankData = async () => {
  isLoadingBankData.value = true;
  try {
    const response = await fetchNui('getBankData');
    if (response) {
      bankData.value = {
        accounts: response.map(account => ({
          iban: account.IBAN,
          balance: account.Balance || 0,
          role: account.owngroup,
          primary: !!account.Primary,
          cards: processAccountCards(account.cards),
          interestRate: account.Interest || 0,
          transactions: processTransactions(account.Transactions, account.Transfers)
        }))
      };
    }
  } catch (error) {
    console.error('Failed to load bank data:', error);
    showPopupMessage(`${t('errors.loadBankDataFailed')}: ${error.message}`, true);
  } finally {
    isLoadingBankData.value = false;
  }
};

const processTransactions = (transactions, transfers) => {
  if (!transactions) return [];
  return transactions.map(transaction => ({
    id: transaction.ID,
    amount: transaction.AMOUNT,
    date: transaction.DATE,
    description: transaction.DESCRIPTION,
    type: 'transaction'
  })).concat(
    transfers.map(transfer => ({
      id: transfer.ID,
      amount: transfer.AMOUNT,
      date: transfer.DATE,
      description: transfer.DESCRIPTION,
      type: 'transfer'
    }))
  ).sort((a, b) => b.date - a.date);
};

const processAccountCards = (cards) => {
  if (!cards) return [];
  return Object.values(cards).flat().map(card => ({
    ID: card.ID,
    CARD_NUMBER: card.CARD_NUMBER,
    EXPIRATION_DATE: card.EXPIRATION_DATE,
    LOCKED: card.LOCKED,
    MWPH: card.MWPH,
    PIN: card.PIN
  }));
};

// Owner accounts computed
const ownerAccounts = computed(() => {
  if (!bankData.value?.accounts) return [];
  return bankData.value.accounts.filter(account => 
    account.role === 'owner'
  ).map(account => ({
    id: account.iban,
    name: `${t('cardManagement.account')} ${account.iban.slice(-4)}`,
    balance: account.balance,
    currency: '€',
    iban: account.iban
  }));
});

// Cards computed (server cards + local cache)
const cards = computed(() => {
  const serverCards = [];
  if (bankData.value?.accounts) {
    bankData.value.accounts.forEach(account => {
      account.cards.forEach(card => {
        const existing = localCardCache.value.find(c => !c.isOptimistic && c.id === card.ID);
        if (existing) return;
        
        serverCards.push({
          id: card.ID,
          name: `${t('cardManagement.card')} ${card.CARD_NUMBER.toString().slice(-4)}`,
          nickname: cardNicknames.value[card.ID] || '',
          cardNumber: formatCardNumber(card.CARD_NUMBER),
          rawCardNumber: card.CARD_NUMBER,
          expirationDate: card.EXPIRATION_DATE,
          type: 'TCB',
          locked: card.LOCKED,
          accountId: account.iban,
          accountIban: account.iban,
          maxWithdrawalPerHour: card.MWPH,
          pin: card.PIN
        });
      });
    });
  }
  return [...serverCards, ...localCardCache.value];
});

// Rest of original functionality remains the same
// (formatCardNumber, generateCardNumber, fetchNui, 
//  card actions, modals, context menu, etc.)

onMounted(async () => {
  localCardCache.value = localCardCache.value.filter(card => !card.isOptimistic);
  await loadBankData();
});

// Format card number with spaces
const formatCardNumber = (number) => {
  const strNum = number.toString();
  return strNum.match(/.{1,4}/g)?.join(' ') || strNum;
};

// Generate mock card number for immediate UI feedback
const generateCardNumber = () => {
  // Generate a valid-looking credit card number (16 digits)
  return Array(16).fill(0).map(() => 
    Math.floor(Math.random() * 10).toString()
  ).join('');
};

// State management
const showCreateModal = ref(false);
const showWithdrawalModal = ref(false);
const showDeleteModal = ref(false);
const showRecreateModal = ref(false);
const showRenameModal = ref(false);
const showPopup = ref(false);
const popupMessage = ref('');
const popupColor = ref('bg-emerald-500/90');
const selectedCard = ref(null);
const newCardNumber = ref('');
const newCard = ref({ accountId: null, pin: '', nickname: '' });
const newNickname = ref('');
const maxWithdrawal = ref(1000);
const isProcessing = ref(false);

// Show popup messages
const showPopupMessage = (message, isError = false) => {
  popupMessage.value = message;
  popupColor.value = isError ? 'bg-red-500/90' : 'bg-emerald-500/90';
  showPopup.value = true;
  setTimeout(() => showPopup.value = false, 3000);
};

// Create NUI callback with timeout handling and improved error handling
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


// Card actions
const toggleCardLock = async (card) => {
  try {
    const newLockState = !card.locked;
    await fetchNui('toggleCardLock', { 
      cardId: card.rawCardNumber, 
      iban: card.accountIban,
      locked: newLockState
    });
    
    // Update local state only after successful server update
    card.locked = newLockState;

    // Update the card in the UI
    const cardInCache = localCardCache.value.find(c => c.id === card.id);
    if (cardInCache) {
      cardInCache.locked = newLockState;
    }

    bankData.value.accounts.forEach(account => {
      account.cards.forEach(c => {
      if (c.ID === card.id) {
        c.LOCKED = newLockState;
      }
      });
    });

    showPopupMessage(card.locked ? t('cardManagement.notifications.cardLocked') : t('cardManagement.notifications.cardUnlocked'));
  } catch (error) {
    showPopupMessage(`${t('errors.cardLockToggle')}: ${error.message}`, true);
  }
};

const openRenameModal = (card) => {
  selectedCard.value = card;
  newNickname.value = card.nickname || '';
  showRenameModal.value = true;
};

const saveCardNickname = () => {
  if (!selectedCard.value) return;
  
  // Save the new nickname
  cardNicknames.value[selectedCard.value.id] = newNickname.value;
  
  // Update the card in the UI
  selectedCard.value.nickname = newNickname.value;
  
  // If card is in local cache, update it there too
  const localCard = localCardCache.value.find(card => card.id === selectedCard.value.id);
  if (localCard) {
    localCard.nickname = newNickname.value;
  }
  
  showRenameModal.value = false;
  showPopupMessage(t('cardManagement.notifications.nicknameUpdated'));
};

const confirmDelete = (card) => {
  selectedCard.value = card;
  showDeleteModal.value = true;
};

const deleteCard = async () => {
  if (selectedCard.value) {
    try {
      await fetchNui('deleteCard', { 
        cardId: selectedCard.value.rawCardNumber,
        iban: selectedCard.value.accountIban
      });
      
      // Delete nickname from local storage
      delete cardNicknames.value[selectedCard.value.id];
      
      // Remove from local cache if it exists there
      localCardCache.value = localCardCache.value.filter(
        card => card.id !== selectedCard.value.id
      );

      // Remove from UI cards
      bankData.value.accounts.forEach(account => {
        account.cards = account.cards.filter(card => card.ID !== selectedCard.value.id);
      });
      
      showDeleteModal.value = false;
      showPopupMessage(t('cardManagement.notifications.cardDeleted'));
    } catch (error) {
      showPopupMessage(`${t('errors.deleteCard')}: ${error.message}`, true);
    }
  }
};

const createCard = async () => {
  try {
    // Fixed PIN validation - explicitly check for exactly 4 digits
    if (!newCard.value.accountId) {
      showPopupMessage(t('errors.selectAccount'), true);
      return;
    }
    
    if (!/^\d{4}$/.test(newCard.value.pin)) {
      showPopupMessage(t('errors.pinMustBe4Digits'), true);
      return;
    }

    // Generate card number that will be sent to server
    const generatedCardNumber = generateCardNumber();
    newCardNumber.value = generatedCardNumber;
    
    // Create optimistic card data
    const optimisticCard = {
      id: 'temp-' + Math.random().toString(36).substring(2),
      name: `${t('cardManagement.card')} ${generatedCardNumber.slice(-4)}`,
      nickname: newCard.value.nickname || '',
      cardNumber: formatCardNumber(generatedCardNumber),
      rawCardNumber: generatedCardNumber,
      expirationDate: new Date(Date.now() + 3 * 365 * 24 * 60 * 60 * 1000).getTime(), // 3 years from now
      type: 'TCB',
      locked: false,
      accountId: newCard.value.accountId,
      accountIban: newCard.value.accountId,
      maxWithdrawalPerHour: 1000,
      pin: newCard.value.pin,
      isOptimistic: true // Flag to identify this as an optimistic update
    };

    // Add to local cache immediately
    localCardCache.value.push(optimisticCard);
    
    // Close modal and reset form
    showCreateModal.value = false;
    showPopupMessage(t('cardManagement.notifications.cardCreating'));

    // Send the request to the server with the generated card number
    const result = await fetchNui('createCard', {
      iban: newCard.value.accountId,
      pin: Number(newCard.value.pin),
      cardNumber: generatedCardNumber // Send the generated card number to the server
    });
    
    console.log(t('debug.cardCreationResponse'), result);
    
    if (result) {
      // Update the temporary card with real data instead of removing it
      const tempCardIndex = localCardCache.value.findIndex(card => card.id === optimisticCard.id);
      
      if (tempCardIndex !== -1) {
        // Update the temporary card with real ID and remove optimistic flag
        localCardCache.value[tempCardIndex] = {
          ...localCardCache.value[tempCardIndex],
          id: result.cardId,
          isOptimistic: false,
        };
      }
      
      // Save nickname locally if we have a real card ID
      if (newCard.value.nickname) {
        cardNicknames.value[result.cardId] = newCard.value.nickname;
      }
      
      newCard.value = { accountId: null, pin: '', nickname: '' };
      showPopupMessage(t('cardManagement.notifications.cardCreated'));
    } else {
      throw new Error(t('errors.cardCreationFailed'));
    }
  } catch (error) {
    // Remove optimistic card on error
    localCardCache.value = localCardCache.value.filter(
      card => !card.isOptimistic || card.accountId !== newCard.value.accountId
    );
    
    console.error(t('errors.createCardError'), error);
    showPopupMessage(`${t('errors.createCard')}: ${error.message}`, true);
  }
};

const recreateCard = async () => {
  if (selectedCard.value) {
    try {
      await fetchNui('recreateCard', { 
        cardId: selectedCard.value.id,
        iban: selectedCard.value.accountIban,
        cardNumber: selectedCard.value.rawCardNumber
      });
      showRecreateModal.value = false;
      showPopupMessage(t('cardManagement.notifications.cardRecreated'));
    } catch (error) {
      showPopupMessage(`${t('errors.recreateCard')}: ${error.message}`, true);
    }
  }
};

const openWithdrawalModal = (card) => {
  selectedCard.value = card;
  maxWithdrawal.value = card.maxWithdrawalPerHour;
  showWithdrawalModal.value = true;
};

const openRecreateModal = (card) => {
  selectedCard.value = card;
  showRecreateModal.value = true;
};

const updateWithdrawalLimits = async () => {
  if (selectedCard.value) {
    try {
      await fetchNui('updateCardLimit', {
        cardId: selectedCard.value.rawCardNumber,
        iban: selectedCard.value.accountIban,
        limit: maxWithdrawal.value
      });
      
      // Update local state
      selectedCard.value.maxWithdrawalPerHour = maxWithdrawal.value;

      // Update the card in the UI
      bankData.value.accounts.forEach(account => {
        account.cards.forEach(card => {
          if (card.ID === selectedCard.value.id) {
        card.MWPH = maxWithdrawal.value;
          }
        });
      });
      
      // Find and update in local cache if it exists there
      const cardInCache = localCardCache.value.find(card => card.id === selectedCard.value.id);
      if (cardInCache) {
        cardInCache.maxWithdrawalPerHour = maxWithdrawal.value;
      }
      
      showWithdrawalModal.value = false;
      showPopupMessage(t('cardManagement.notifications.limitUpdated'));
    } catch (error) {
      showPopupMessage(`${t('errors.updateLimit')}: ${error.message}`, true);
    }
  }
};

const timeLeft = (expirationDate) => {
  const diff = new Date(expirationDate) - new Date();
  if (diff <= 0) return t('cardManagement.expired');
  const days = Math.floor(diff / (864e5));
  return days > 30 ? `${Math.floor(days/30)}${t('cardManagement.timeUnits.mo')}` : 
         days > 0 ? `${days}${t('cardManagement.timeUnits.d')}` : 
         t('cardManagement.timeUnits.lessThanDay');
};

// Context menu items
const contextMenuItems = computed(() => [
  { 
    label: selectedCard.value?.locked ? t("cardManagement.actions.unlock") : t("cardManagement.actions.lock"), 
    icon: selectedCard.value?.locked ? 'pi pi-unlock' : 'pi pi-lock', 
    command: () => toggleCardLock(selectedCard.value) 
  },
  { label: t("cardManagement.actions.rename"), icon: 'pi pi-pencil', command: () => openRenameModal(selectedCard.value) },
  { label: t("cardManagement.actions.limit"), icon: 'pi pi-wallet', command: () => openWithdrawalModal(selectedCard.value) },
  { label: t("cardManagement.actions.duplicate"), icon: 'pi pi-refresh', command: () => openRecreateModal(selectedCard.value) },
  { label: t("cardManagement.actions.delete"), icon: 'pi pi-trash', command: () => confirmDelete(selectedCard.value) },
]);

const contextMenu = ref(null);

const onCardRightClick = (event, card) => {
  selectedCard.value = card;
  contextMenu.value.show(event);
};


</script>
<template>
  <div class="p-6">
    <!-- Notification Popup - Fixed z-index issue -->
    <transition name="fade-slide">
      <div 
        v-if="showPopup"
        :class="[popupColor, 'fixed top-4 right-4 text-white px-4 py-2 rounded-lg shadow-xl backdrop-blur-sm border border-white/20 transition-all z-[100]']"
      >
        {{ popupMessage }}
      </div>
    </transition>

    <!-- Loading Overlay -->
    <div v-if="isProcessing" class="fixed inset-0 bg-black/70 flex items-center justify-center z-[60] backdrop-blur-sm">
      <div class="text-center">
        <div class="w-12 h-12 border-4 border-t-sky-400 border-sky-400/30 rounded-full animate-spin mx-auto mb-4"></div>
        <p class="text-sky-400">{{ t('common.processing') }}</p>
      </div>
    </div>

    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-2xl font-bold text-slate-100">{{ t('cardManagement.title') }}</h2>
      <button 
        @click="showCreateModal = true"
        class="flex items-center gap-2 px-4 py-2.5 rounded-lg bg-slate-800/30 hover:bg-slate-700/40 transition-all border border-slate-700/50"
      >
        <i class="pi pi-plus text-sky-400"></i>
        <span class="text-sky-400">{{ t('cardManagement.newCard') }}</span>
      </button>
    </div>

    <!-- Cards Grid -->
    <template v-if="cards.length">
      <transition-group 
      name="staggered-fade" 
      tag="div" 
      class="grid gap-6 md:grid-cols-2 lg:grid-cols-3"
      >
      <div 
        v-for="card in cards"
        :key="card.id"
        class="group relative bg-slate-800 rounded-xl p-6 border border-slate-700/50 transition-all hover:border-sky-400/30 hover:shadow-xl backdrop-blur-sm"
        :class="{ 'opacity-60': card.locked, 'border-red-500': card.locked }"
        @contextmenu.prevent="onCardRightClick($event, card)"
      >
        <!-- NFC Chip -->
        <div class="absolute top-1/2 right-6 transform -translate-y-1/2 w-10 h-8 bg-gradient-to-br from-yellow-600 to-yellow-400 rounded-sm">
        <div class="absolute inset-0.5 bg-black/20 rounded-sm">
          <div class="h-full w-full flex flex-col justify-between p-0.5">
          <div class="h-1 bg-yellow-300/50 rounded-full"></div>
          <div class="h-1 bg-yellow-300/50 rounded-full w-3/4"></div>
          <div class="h-1 bg-yellow-300/50 rounded-full w-1/2"></div>
          </div>
        </div>
        </div>

        <!-- Card Content -->
        <div class="h-full flex flex-col justify-between">
        <!-- Card Header -->
        <div class="flex justify-between items-start mb-8">
          <div>
          <p class="text-sm text-slate-400 mb-1">{{ card.nickname || t('cardManagement.defaultCardName') }}</p>
          <h3 class="text-xl font-bold text-slate-100">{{ card.name }}</h3>
          <p class="text-xs text-slate-500 mt-1">{{ card.accountIban }}</p>
          </div>
          <div class="text-sky-400 text-2xl italic font-bold">
          {{ card.type }}
          </div>
        </div>

        <!-- Card Number -->
        <div class="mb-6 font-mono text-lg tracking-widest text-slate-100">
          {{ card.cardNumber }}
        </div>

        <!-- Card Footer -->
        <div class="flex justify-between items-center">
          <div>
          <p class="text-xs text-slate-400">{{ t('cardManagement.validThru') }}</p>
          <p class="text-sm text-slate-200">
            {{ new Date(card.expirationDate).toLocaleDateString('de-DE') }}
            <span class="text-xs text-slate-400 ml-1">({{ timeLeft(card.expirationDate) }})</span>
          </p>
          </div>
          <div>
          <p class="text-xs text-slate-400">{{ t('cardManagement.limit') }}</p>
          <p class="text-sm text-slate-200">€{{ card.maxWithdrawalPerHour }}/h</p>
          </div>
        </div>
        </div>
      </div>
      </transition-group>
    </template>

    <!-- Empty State -->
    <div v-else class="text-center py-12 text-slate-400">
      {{ t('cardManagement.emptyState') }}
    </div>

    <!-- Create Card Modal -->
    <transition name="modal">
      <div v-if="showCreateModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-[50]">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('cardManagement.modals.createCard.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('cardManagement.modals.createCard.account') }}</label>
              <select 
                v-model="newCard.accountId"
                class="w-full bg-slate-700/30 rounded-lg px-4 py-2.5 text-slate-200 focus:ring-2 focus:ring-sky-400 border border-slate-700/50"
              >
                <option 
                  v-for="account in ownerAccounts" 
                  :key="account.id" 
                  :value="account.id"
                  class="bg-slate-800 text-slate-200"
                >
                  {{ account.name }} (€{{ account.balance.toFixed(2) }}) - {{ account.iban }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('cardManagement.modals.createCard.pin') }}</label>
              <input
                v-model="newCard.pin"
                type="password"
                maxlength="4"
                pattern="[0-9]*"
                inputmode="numeric"
                class="w-full bg-slate-700/30 rounded-lg px-4 py-2.5 text-slate-200 focus:ring-2 focus:ring-sky-400 border border-slate-700/50"
                :placeholder="t('cardManagement.modals.createCard.pinplaceholder')"
              />
              <p class="text-xs text-slate-400 mt-1">{{ t('cardManagement.modals.createCard.pinHint') }}</p>
            </div>

            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('cardManagement.modals.createCard.nickname') }} ({{ t('common.optional') }})</label>
              <input
                v-model="newCard.nickname"
                type="text"
                class="w-full bg-slate-700/30 rounded-lg px-4 py-2.5 text-slate-200 focus:ring-2 focus:ring-sky-400 border border-slate-700/50"
                :placeholder="t('cardManagement.modals.createCard.nicknamePlaceholder')"
              />
            </div>
          </div>

          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showCreateModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('cardManagement.actions.cancel') }}
            </button>
            <button
              @click="createCard"
              class="px-4 py-2 bg-sky-500/30 text-sky-400 rounded-lg hover:bg-sky-500/40 transition-all"
            >
              {{ t('cardManagement.actions.create') }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Withdrawal Limit Modal -->
    <transition name="modal">
      <div v-if="showWithdrawalModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-[50]">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('cardManagement.modals.withdrawalLimit.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('cardManagement.modals.withdrawalLimit.maxWithdrawal') }}</label>
                <div class="flex flex-col gap-1">
                <input 
                  v-model.number="maxWithdrawal" 
                  type="number" 
                  min="100" 
                  max="10000" 
                  class="w-full bg-slate-700/30 rounded-lg px-4 py-2.5 text-slate-200 focus:ring-2 focus:ring-sky-400 border border-slate-700/50"
                  @input="maxWithdrawal = Math.min(Math.max(maxWithdrawal, 100), 10000)"
                />
                <p v-if="maxWithdrawal < 100 || maxWithdrawal > 10000" class="text-red-500 text-sm">
                  {{ t('errors.invalidWithdrawalLimit') }}
                </p>
                </div>
            </div>
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showWithdrawalModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('cardManagement.actions.cancel') }}
            </button>
            <button
              @click="updateWithdrawalLimits"
              class="px-4 py-2 bg-sky-500/30 text-sky-400 rounded-lg hover:bg-sky-500/40 transition-all"
            >
              {{ t('cardManagement.actions.saveChanges') }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Rename Card Modal -->
    <transition name="modal">
      <div v-if="showRenameModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-[50]">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('cardManagement.modals.renameCard.title') }}</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-300 mb-2">{{ t('cardManagement.modals.renameCard.nickname') }}</label>
              <input
                v-model="newNickname"
                type="text"
                class="w-full bg-slate-700/30 rounded-lg px-4 py-2.5 text-slate-200 focus:ring-2 focus:ring-sky-400 border border-slate-700/50"
                :placeholder="t('cardManagement.modals.renameCard.nicknamePlaceholder')"
              />
            </div>
            <div class="text-xs text-slate-400">
              {{ t('cardManagement.modals.renameCard.description') }}
            </div>
          </div>
          <div class="mt-8 flex justify-end gap-3">
            <button
              @click="showRenameModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('cardManagement.actions.cancel') }}
            </button>
            <button
              @click="saveCardNickname"
              class="px-4 py-2 bg-sky-500/30 text-sky-400 rounded-lg hover:bg-sky-500/40 transition-all"
            >
              {{ t('cardManagement.actions.saveChanges') }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Recreate Card Modal -->
    <transition name="modal">
      <div v-if="showRecreateModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-[50]">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('cardManagement.modals.recreateCard.title') }}</h3>
          <p class="text-slate-300 mb-6">{{ t('cardManagement.modals.recreateCard.confirmMessage') }}</p>
          <div class="flex justify-end gap-3">
            <button
              @click="showRecreateModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('cardManagement.actions.cancel') }}
            </button>
            <button
              @click="recreateCard"
              class="px-4 py-2 bg-sky-500/30 text-sky-400 rounded-lg hover:bg-sky-500/40 transition-all"
            >
              {{ t('cardManagement.actions.recreate') }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Delete Confirmation Modal -->
    <transition name="modal">
      <div v-if="showDeleteModal" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm z-[50]">
        <div class="bg-slate-800/90 rounded-xl p-6 w-full max-w-md border border-slate-700/50 backdrop-blur-lg">
          <h3 class="text-xl font-bold mb-6 text-slate-100">{{ t('cardManagement.modals.deleteCard.title') }}</h3>
          <p class="text-slate-300 mb-6">{{ t('cardManagement.modals.deleteCard.confirmMessage') }}</p>
          <div class="flex justify-end gap-3">
            <button
              @click="showDeleteModal = false"
              class="px-4 py-2 text-slate-300 hover:text-slate-100 transition-all"
            >
              {{ t('cardManagement.actions.cancel') }}
            </button>
            <button
              @click="deleteCard"
              class="px-4 py-2 bg-red-500/30 text-red-400 rounded-lg hover:bg-red-500/40 transition-all"
            >
              {{ t('cardManagement.actions.deletePermanently') }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Context Menu -->
    <ContextMenu ref="contextMenu" :model="contextMenuItems" />
  </div>
</template>

<style>
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-slide-enter-from,
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.p-contextmenu {
  background-color: rgba(15, 23, 42, 0.95) !important;
  border: 1px solid rgba(51, 65, 85, 0.5) !important;
  border-radius: 0.5rem;
  padding: 0.5rem;
  z-index: 100 !important;
}

.p-menuitem-link {
  color: rgb(226, 232, 240) !important;
  padding: 0.5rem 1rem !important;
  border-radius: 0.25rem !important;
}

.p-menuitem-link:hover {
  background-color: rgba(51, 65, 85, 0.5) !important;
}

.p-menuitem-icon {
  color: rgb(56, 189, 248) !important;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.staggered-fade-move {
  transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}

.staggered-fade-enter-active {
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1) 0.1s;
}

.staggered-fade-enter-from,
.staggered-fade-leave-to {
  opacity: 0;
  transform: scale(0.95);
}

/* Hover effects for card */
.group:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
}

/* Locked card styles */
.group.opacity-60:before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.2)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect x='3' y='11' width='18' height='11' rx='2' ry='2'%3E%3C/rect%3E%3Cpath d='M7 11V7a5 5 0 0 1 10 0v4'%3E%3C/path%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: center;
  background-size: 40px;
  border-radius: 0.75rem;
  pointer-events: none;
}
</style>