<template>
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm px-4 py-4">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Choose an Avatar</h3>
    <div class="grid grid-cols-4 gap-4">
      <div 
        v-for="(avatar, index) in avatars" 
        :key="index"
        class="flex flex-col items-center"
      >
        <button
          type="button"
          @click="selectAvatar(avatar)"
          class="h-16 w-16 rounded-full overflow-hidden border-2 transition-all"
          :class="{
            'border-indigo-500 dark:border-indigo-400': selectedAvatar === avatar,
            'border-transparent hover:border-gray-300 dark:hover:border-gray-600': selectedAvatar !== avatar
          }"
        >
          <img
            :src="avatar"
            alt="User avatar"
            class="h-full w-full object-cover"
          />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const props = defineProps({
  initialAvatar: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['select']);

const avatars = ref([
  '/avatars/avatar1.svg',
  '/avatars/avatar2.svg',
  '/avatars/avatar3.svg',
  '/avatars/avatar4.svg',
  '/avatars/avatar5.svg',
  '/avatars/avatar6.svg',
  '/avatars/avatar7.svg',
  '/avatars/avatar8.svg'
]);

const selectedAvatar = ref(props.initialAvatar);

function selectAvatar(avatar) {
  selectedAvatar.value = avatar;
  emit('select', avatar);
}
</script>
