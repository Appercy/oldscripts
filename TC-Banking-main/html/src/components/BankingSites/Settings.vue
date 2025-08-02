<template>
  <div class="settings-page p-6 bg-slate-900 min-h-screen transition-all duration-300 overflow-hidden">
    <div class="max-w-2xl mx-auto space-y-8">
      <!-- Header -->
      <div class="text-center space-y-2">
        <h1 class="text-4xl font-bold bg-gradient-to-r from-sky-400 to-sky-600 bg-clip-text text-transparent">
          {{ t('settings.title') }}
        </h1>
        <p class="text-slate-400">{{ t('settings.subtitle') }}</p>
      </div>

      <!-- Language Selection Card -->
      <div class="bg-slate-800 rounded-xl p-6 shadow-xl transition-all hover:shadow-2xl">
        <h2 class="text-xl font-semibold mb-6 text-sky-400 flex items-center space-x-2">
          <i class="pi pi-globe"></i>
          <span>{{ t('settings.language') }}</span>
        </h2>
        
        <div class="grid grid-cols-2 gap-4">
          <button
            v-for="lang in languages"
            :key="lang.code"
            @click="setLanguage(lang.code)"
            class="p-4 rounded-lg flex items-center justify-center space-x-3 transition-all"
            :class="[
              selectedLanguage === lang.code 
                ? 'bg-sky-600/30 border-2 border-sky-500 scale-[1.02]' 
                : 'bg-slate-700/50 border-2 border-slate-600 hover:border-sky-400 hover:bg-sky-500/20',
              'hover:scale-[1.01] focus:scale-[1.02]'
            ]"
          >
            <span class="text-2xl">{{ lang.flag }}</span>
            <div class="text-left">
              <p class="font-medium">{{ lang.name }}</p>
              <p class="text-sm text-slate-400">{{ lang.nativeName }}</p>
            </div>
            <i 
              v-if="selectedLanguage === lang.code"
              class="pi pi-check text-sky-400 ml-2 animate-fade-in"
            ></i>
          </button>
        </div>
      </div>

      <!-- Disabled Color Picker -->
      <div class="bg-slate-800 rounded-xl p-6 opacity-50 cursor-not-allowed relative">
        <div class="absolute top-2 right-2 bg-slate-700 text-xs px-2 py-1 rounded-full">
         {{ t('settings.disabled') }}
        </div>
        <h2 class="text-xl font-semibold mb-4 text-slate-500">
          <i class="pi pi-palette mr-2"></i>
         {{ t('settings.color') }}
        </h2>
        <ColorPicker 
          disabled
          class="w-full"
          :style="{ pointerEvents: 'none' }"
        />
      </div>

      <!-- Toast Notification -->
      <Toast position="bottom-right" />
      
    </div>
    
    <div class="absolute bottom-1 right-8 text-xs text-slate-400">Manitär unterwegs</div>
    <div class="absolute top-1 right-1 text-xs text-slate-400">Made by Ludaro & Davis</div>
    <img src="@/assets/poggers.png" alt="Poggers" class="absolute bottom-1 right-1 w-6 opacity-50" />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'primevue/usetoast';
import ColorPicker from 'primevue/colorpicker';
import { i18n } from '../../main.js';

const { t, locale } = useI18n();
const toast = useToast();

const languages = [
  { code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸' },
  { code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪' },
];

// Initialize selectedLanguage with the current locale from i18n
const selectedLanguage = ref(i18n.global.locale);

const setLanguage = (code) => {
  selectedLanguage.value = code;
  locale.value = code;
  i18n.global.locale = code;
  localStorage.setItem('locale', code);
  showSuccess();
};

watch(locale, (newLocale) => {
  i18n.global.locale = newLocale;
});

const showSuccess = () => {
  toast.add({
    severity: 'success',
    summary: t('settings.settingsApplied'),
    detail: t('settings.languageChanged'),
    life: 3000,
  });
};
</script>

<style>
@keyframes fade-in {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}


.p-colorpicker-preview {
  height: 40px !important;
  width: 100% !important;
  border-radius: 8px !important;
}
</style>