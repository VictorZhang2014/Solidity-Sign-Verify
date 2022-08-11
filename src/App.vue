<template>
  <img alt="Vue logo" src="./assets/ethereum-logo.png" />
  <HelloWorld msg="Ethereum (EVM) blockchains"/>
  <!-- <MailExample msg="Mail Example"/> -->
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'
// import MailExample from './components/MailExample.vue'

export default {
  name: 'App',
  components: {
    HelloWorld,
    // MailExample
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
