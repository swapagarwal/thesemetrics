import { createApp, defineAsyncComponent } from 'vue';
import { createRouter, createWebHistory } from 'vue-router';
import App from './App.vue';
import Home from './pages/home.vue';

const app = createApp(App);
const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: Home,
    },
    {
      path: '/dashboard',
      component: defineAsyncComponent(() => import('./pages/dashboard.vue')),
      props: true
    },
    {
      name: 'dashboard',
      path: '/dashboard/:domain',
      component: defineAsyncComponent(() => import('./pages/dashboard.vue')),
      props: true
    },
  ],
});

app.use(router);
app.mount('#app');
