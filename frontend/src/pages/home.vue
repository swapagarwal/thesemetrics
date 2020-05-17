<script lang="ts">
import { defineComponent, ref } from 'vue';

export default defineComponent({
  setup() {
    const project = ref(window.location.hostname);

    return { project };
  },
});
</script>

<template>
  <div>
    <header>
      <h1>TheseMetrics</h1>

      <p>Simpler analytics for your website.</p>
    </header>

    <main>
      <pre>
        <code>
          {{ `<script src="https://unpkg.com/thesemetrics"></script>` }}
        </code>
      </pre>

      <div>
        <input type="text" v-model="project" placeholder="Website" style="margin-right: 1rem" />
        <RouterLink :to="project ? `/dashboard/${project}` : '/dashboard'">See Data</RouterLink>
      </div>
    </main>
  </div>
</template>
