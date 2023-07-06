<!-- you write scripts in <script> -->
<script lang="ts">
    let a = 1;
    let b = 2;
    let count: number = 20;
    // $: signifies a reactive line
    // when count is changed, then doubled also changes
    $: doubled = count * 2;

    function incCount() {
        count++
    }

    let doubled;
</script>

<!-- You compose predefined tailwind classes -->
<h1 class="text-3xl">Styled text</h1>
<button class="bg-blue-500 hover:bg-blue-800">Click me</button>

<!-- when values change, svelte does DOM updates efficiently-->
<button on:click={incCount}>inc count</button>

<div>count={count} doubled={ doubled }</div>

<!-- When we change the inputs, then the values a and b change also-->
<input type="number" bind:value={a}/>
<input type="number" bind:value={b}/>

<!-- change of a and b is automatically renders this div -->
<div>{a} + {b} = {a + b}</div>

