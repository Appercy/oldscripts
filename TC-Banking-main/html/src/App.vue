<script setup>
import { ref, provide, onMounted } from 'vue';
import Banking from './components/Banking.vue';
import Billing from './components/Billing.vue';
import ATM from './components/PinLock.vue';
import { useToast } from 'primevue/usetoast';
import Toast from 'primevue/toast';

// Toast setup
const toast = useToast();

// Reactive state for visibility
const displayBanking = ref(false);
const displayBilling = ref(false);
const displayATM = ref(false);

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




// Function to toggle display
const toggleDisplay = async (type) => {

  
  if (type === 'banking') {
    displayBanking.value = !displayBanking.value;
    if (displayBanking.value === false) {
      fetchNui('closeNUI');
    }
    if (displayBanking.value) {
      displayBilling.value = false;
      displayATM.value = false;
    }
  } else if (type === 'billing') {
    displayBilling.value = !displayBilling.value;
    if (displayBilling.value === false) {
      fetchNui('closeNUI');
    }
    if (displayBilling.value) {
      displayBanking.value = false;
      displayATM.value = false;
    }
  } else if (type === 'atm') {
    displayATM.value = !displayATM.value;
    if (displayATM.value === false) {
      fetchNui('closeNUI');
    }
    if (displayATM.value) {
      displayBanking.value = false;
      displayBilling.value = false;
    }
  }
};
// Provide the state and a function to toggle it
provide('displayState', {
  displayBanking,
  displayBilling,
  displayATM,
  toggleDisplay,
});

onMounted(() => {
  window.addEventListener('message', (event) => {

    if (event.data.display) {
      toggleDisplay(event.data.display);
    }
  });
});
</script>

<template>
  <!-- Toast Notification -->
  <Toast />

  <!-- Banking Component -->
  <transition name="slide-top" appear>
    <div v-if="displayBanking" class="banking-container">
      <Banking />
    </div>
  </transition>

  <!-- Billing Component -->
  <div v-if="displayBilling" class="banking-container">
    <Billing />
  </div>

  <!-- ATM Component -->
  <div v-if="displayATM" class="banking-container">
    <ATM />
  </div>
</template>

<style>
* {
  background-color: transparent;
}

.banking-container {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

/* Adjust animation to start lower and fade into center */
.slide-top-enter-active {
  animation: myAnim 1s ease-out forwards;
}

/* Add it also when the component is disabled */
.slide-top-leave-active {
  animation: myAnimReverse 1s ease-out forwards;
}

@keyframes myAnimReverse {
  0% {
    opacity: 1;
    transform: translate(-50%, -50%);
  }
  100% {
    opacity: 0;
    transform: translate(-50%, 50px);
  }
}

@keyframes myAnim {
  0% {
    opacity: 0;
    transform: translate(-50%, 50px);
  }
  100% {
    opacity: 1;
    transform: translate(-50%, -50%);
  }
}
</style>