<script lang="ts">
import { defineComponent, ref } from 'vue';
import { useRouter } from 'vue-router';

export default defineComponent({
  setup() {
    const router = useRouter();
    const project = ref(window.location.hostname);

    function goToDashboard() {
      if (project.value) router.push(`/dashboard/${project.value}`);
      else router.push('/dashboard');
    }

    return { project, goToDashboard };
  },
});
</script>

<template>
  <div class="my-4 px-4">
    <header class="flex flex-col items-center mt-20">
      <img src="../assets/banner.png" style="max-width: 300px;" />

      <p>Simpler analytics for your website.</p>
    </header>

    <main>
      <pre
        class="p-4 my-10 bg-gray-100 rounded text-gray-700 text-center"
        style="white-space: pre-wrap;"
      ><code>{{ `<script src="https://unpkg.com/thesemetrics"></script>` }}</code></pre>

      <div class="flex flex-row justify-center items-center mt-20">
        <hr class="border-gray-400 flex-1" />
        <div class="mx-4 text-gray-800 uppercase">See your data</div>
        <hr class="border-gray-400 flex-1" />
      </div>

      <form @submit.prevent="goToDashboard" class="mt-10 flex flex-row justify-center items-center">
        <input
          class="p-2 mr-4 border focus:border-black text-base leading-normal"
          type="text"
          v-model="project"
          placeholder="Website"
        />
        <button type="submit" class="text-white bg-primary py-2 px-4 text-base leading-normal rounded">See Data</button>
      </form>
    </main>
  </div>
</template>
