<script lang="ts">
import { defineComponent, ref, onMounted, computed, watch } from 'vue';
import Chart from 'apexcharts';

export default defineComponent({
  props: {
    data: {
      type: Array as () => Array<{ date: string; count: number }>,
      required: true,
    },
  },

  setup(props) {
    const el = ref<HTMLDivElement | null>(null);
    let chart: Chart;
    const formatter = new Intl.DateTimeFormat(undefined, {
      month: 'short',
      day: 'numeric',
    });

    const labels = ref<string[]>([]);
    const pageviews = computed(() => {
      const data = props.data.map((item) => item.count);

      while (data.length < 30) data.unshift(0);

      return data;
    });

    const date = new Date();
    Array(30)
      .fill(0)
      .forEach(() => {
        labels.value.unshift(formatter.format(date));
        date.setDate(date.getDate() - 1);
      });

    labels.value.reverse();

    onMounted(() => {
      chart = new Chart(el.value!, {
        chart: {
          type: 'line',
        },
        stroke: {
          curve: 'smooth',
          width: 1,
        },
        series: [
          {
            name: 'pageviews',
            data: pageviews.value,
          },
        ],
        xaxis: {
          categories: labels.value,
        },
      });

      chart.render();
    });

    watch(
      () => pageviews.value,
      (pageviews) => {
        chart.updateSeries([{ name: 'pageviews', data: pageviews }], true);
      }
    );

    return { el };
  },
});
</script>

<template>
  <div ref="el" style="width: 100%; max-width: 790px; height: 320px;"></div>
</template>
