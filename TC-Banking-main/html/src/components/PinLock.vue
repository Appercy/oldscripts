<script setup>
import { ref, watch } from 'vue';
import InputOtp from 'primevue/inputotp';
import { defineProps, defineEmits } from 'vue';
import ATM from './ATM.vue'; // Import the ATM component

const props = defineProps({
  maxAttempts: {
    type: Number,
    default: 3
  }
});

const emit = defineEmits(['close']);

const enteredPin = ref('');
const attempts = ref(0);
const showError = ref(false);
const showDispatchMessage = ref(false);
const isChecking = ref(false);
const correctPin = '1234';
const shake = ref(false);
const success = ref(false);
const isVisible = ref(true);
const showATM = ref(false); // Control visibility of ATM component

watch(enteredPin, (newVal) => {
  if (newVal.length === 4) {
    validatePin();
  }
});

const startCloseSequence = () => {
  isVisible.value = false;
};

const validatePin = async () => {
  isChecking.value = true;
  
  if (enteredPin.value === correctPin) {
    success.value = true;
    isVisible.value = false; // Hide PinLock component
    showATM.value = true; // Show ATM component
  } else {
    attempts.value++;
    showError.value = true;
    shake.value = true;
    
    if (attempts.value >= props.maxAttempts) {
      showDispatchMessage.value = true;
      setTimeout(startCloseSequence, 5000);
    }
    
    setTimeout(() => {
      enteredPin.value = '';
      shake.value = false;
      isChecking.value = false;
    }, 1000);
  }
};

const resetComponent = () => {
  enteredPin.value = '';
  attempts.value = 0;
  showError.value = false;
  showDispatchMessage.value = false;
  isChecking.value = false;
  shake.value = false;
  success.value = false;
};
</script>

<template>
  <div>
    <transition
      name="slide-up"
      @after-leave="() => { emit('close'); resetComponent(); }"
      appear
    >
      <div
        v-if="isVisible"
        class="w-full max-w-md h-[400px] bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl shadow-2xl p-6 flex flex-col justify-center items-center transition-all duration-300 relative"
      >
        <div class="space-y-6">
          <div class="text-center">
            <h2 class="text-4xl font-bold text-slate-100 mb-2">ATM</h2>
            <h2 class="text-2xl font-bold text-blue-400">
              Enter Your PIN
            </h2>
            <p class="text-sm text-gray-400 mt-1">
              To access your account, enter your 4-digit security PIN
            </p>
          </div>

          <div class="flex items-center justify-center">
            <InputOtp
              v-model="enteredPin"
              :length="4"
              integerOnly
              :disabled="isChecking || showDispatchMessage"
              class="[&>div]:justify-center gap-2 mb-4"
              inputClass="!w-16 h-16 text-4xl bg-gray-800 border-2 border-gray-700 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500/50 transition-all"
            />
          </div>

          <div class="text-center space-y-2">
            <p
              v-if="showError"
              class="text-red-400 text-sm animate-fade-in"
            >
              Incorrect PIN. {{ props.maxAttempts - attempts }} attempts remaining
            </p>

            <div v-if="showDispatchMessage" class="animate-fade-in">
              <p class="text-red-400 text-sm font-semibold">
                Security Alert
              </p>
              <p class="text-gray-300">
                Maximum attempts exceeded. Authorities have been notified.
              </p>
              <p class="text-sm text-gray-400 animate-pulse mt-2">
                Closing automatically in 5 seconds...
              </p>
            </div>
          </div>
        </div>

        <!-- Exit Button -->
        <button 
          @click="startCloseSequence"
          class="absolute top-3 right-3 flex items-center gap-3 px-4 py-3 text-white bg-red-500 hover:bg-red-600 rounded-xl transition-colors overflow-hidden"
        >
          <i class="pi pi-sign-out text-lg" />
          <span class="text-sm">Exit</span>
        </button>
      </div>
    </transition>

    <!-- Show ATM component when PIN is correct -->
    
      <ATM v-if="showATM" />
    
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
  transition: opacity 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}


</style>