<script lang="ts">
import { defineComponent, ref, computed, watch, toRefs } from 'vue';
import PageViewGraph from '../components/PageViewGraph.vue';

export default defineComponent({
  components: { PageViewGraph },
  props: {
    domain: {
      type: String,
      default: () => window.location.hostname,
    },
  },
  setup(props) {
    const error = ref<string>(null);
    const { domain } = toRefs(props);
    const resource = ref('*');
    const pageviews = ref<{ date: string; count: number; uniqueCount: number }[]>([]);
    const devices = ref<{ os: string; browser: string; count: number }[]>([]);
    const total = computed(() => pageviews.value.reduce((sum, pageview) => sum + pageview.count, 0));
    const totalUnique = computed(() => pageviews.value.reduce((sum, pageview) => sum + pageview.uniqueCount, 0));
    const browsers = computed(() => {
      const browsers: Record<string, number> = {};

      devices.value.forEach((device) => {
        if (!(device.browser in browsers)) {
          browsers[device.browser] = 0;
        }

        browsers[device.browser] += device.count;
      });

      return browsers;
    });
    const resources = ref<{ path: string; count: number }[]>([]);
    const referrers = ref<{ [key: string]: number }>({});

    watch(
      () => [domain.value, resource.value],
      async ([domain, resource]) => {
        const base = 'https://api.thesemetrics.xyz';
        const url = `${base}/stats?domain=${encodeURIComponent(domain)}&path=${encodeURIComponent(resource||'*')}`;
        const response = await fetch(url);

        if (response.ok && response.status === 200) {
          const result = await response.json();

          console.log(result)

          devices.value = result.devices;
          pageviews.value = result.pageviews;
          resources.value = result.resources;

          const data: { [key: string]: number } = {};
          result.referrers.forEach((referrer: { referrer: string; count: number }) => {
            if (!referrer.referrer) return;
            if (!(referrer.referrer in data)) data[referrer.referrer] = 0;
            data[referrer.referrer] += referrer.count;
          });

          referrers.value = data;
          error.value = null;
        } else {
          try {
            const result = await response.json();
            error.value = result.message;
          } catch {
            error.value = response.statusText;
          }
        }
      },
      { immediate: true }
    );

    return { domain, resource, total, totalUnique, pageviews, browsers, resources, referrers, error };
  },
});
</script>

<template>
  <div v-if="error" :class="$style.dashboard">
    <div :class="$style.project">
      <label>
        {{ domain }}
      </label>
    </div>

    <div :class="$style.graph" role="alert" style="color: red; text-align: center;">
      {{ error }}
    </div>
  </div>
  <div v-else :class="$style.dashboard">
    <div :class="$style.project">
      <label>
        {{ domain }}
      </label>
    </div>

    <div :class="$style.unique">{{ totalUnique }} unique visitors</div>
    <div :class="$style.total">{{ total }} page views</div>

    <div :class="$style.graph">
      <PageViewGraph :data="pageviews" />
    </div>

    <div :class="$style.resources">
      <h2>Top Pages</h2>
      <ul>
        <li v-for="item of resources">
          <label>
            <input type="radio" :value="item.path" v-model="resource" />
            {{ item.path === '*' ? 'Total' : item.path }} — {{ item.count }}
          </label>
        </li>
      </ul>
    </div>

    <div :class="$style.browsers">
      <h2>Browsers</h2>
      <ul>
        <li v-for="(count, browser) of browsers">{{ browser }} — {{ count }}</li>
      </ul>
    </div>

    <div :class="$style.referrers">
      <h2>Traffic Sources</h2>
      <ul>
        <li v-for="(count, referrer) of referrers">{{ referrer }} — {{ count }}</li>
      </ul>
    </div>
  </div>
</template>

<style module>
.dashboard {
  margin: 2rem auto;
  display: grid;
  grid-template-areas: 'X X X X' 'A A B B' 'C C C C' 'D D E F';
}

.project {
  grid-area: X;
  font-size: 24px;
  padding: 1rem;
  display: flex;
  justify-content: center;
}

.total {
  grid-area: A;
  font-size: 24px;
  padding: 1rem;
  display: flex;
  justify-content: center;
}

.unique {
  grid-area: B;
  font-size: 24px;
  padding: 1rem;
  display: flex;
  justify-content: center;
}

.graph {
  grid-area: C;
}
.resources {
  grid-area: D;
}
.browsers {
  grid-area: E;
}
.referrers {
  grid-area: F;
}
</style>
