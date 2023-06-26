<!-- you write scripts in <script> -->
<script>
    let count = 9;
    // $: signifies a reactive line
    // when count is changed, then doubled also changes
    $: doubled = count * 2;

    function incCount() {
        count++
    }

    let doubled;
</script>

<!-- when values change, svelte does DOM updates efficiently-->
<button on:click={incCount}>inc count</button>

<div>count={count} doubled={ doubled }</div>

