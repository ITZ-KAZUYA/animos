<script lang="ts">
  import { page } from "$app/stores";
  import Genres from "$lib/components/Genres.svelte";
  import IconBtn from "$lib/components/IconBtn.svelte";
  import FaDown from "svelte-icons/fa/FaArrowDown.svelte";
  import FaHeart from "svelte-icons/fa/FaHeart.svelte";
  import { convertRemToPixels, getTitle } from "$lib/utils";
  import { onMount } from "svelte";
  import type { Anime } from "@prisma/client";
  import FaCircleXMark from "$lib/components/FaCircleXMark.svelte";

  let descriptionExpand = false;
  let episodePage = 0;
  let anime: Anime;
  let maxDescription: number;
  let showExpand = false;
  let synopsisElem: HTMLElement;

  function generateRange(start: number, end: number, max: number) {
    if (end > max) end = max;
    let arr = [];
    for (let i = start; i <= end; i++) arr.push(i);
    return arr;
  }

  async function get(): Promise<Anime> {
    let idParam = $page.url.searchParams.get("animeId");
    if (!idParam) {
      location.href = "/";
    }
    let kitsuId = parseInt(idParam ?? "");
    let anime = await window.api.anime.info(kitsuId);
    console.log("anime fetched");
    console.log(anime.episodes);
    return anime;
  }

  onMount(async () => {
    anime = await get();
    maxDescription = convertRemToPixels(10);
    console.log(maxDescription);
    showExpand = anime.synopsis.length > maxDescription * 3; // 45 rem width * 2 characters * 3 lines
  });
</script>

{#if anime}
  {#if anime.available}
    <section>
      <div
        class="flex flex-col md:flex-row justify-center items-center my-5 gap-36"
      >
        <img
          src={anime.posterImg}
          alt={getTitle(anime)}
          class="w-80 rounded-lg"
          style="height: 30rem;"
        />
        <div class="flex flex-col gap-6">
          <h1 class="font-semibold text-3xl">{getTitle(anime)}</h1>
          <Genres {anime} size="large" />
          <div class="relative px-2">
            <p
              bind:this={synopsisElem}
              id="synopsis"
              class="mt-5 synopsis transition-all text-gray-200 ease-in-out duration-500"
              class:limit-lines={!descriptionExpand}
              style={descriptionExpand || !showExpand
                ? "height: max-content; line-height: 1.8rem;"
                : `height: ${maxDescription}px; line-height: 1.65rem`}
            >
              {anime.synopsis}
            </p>
            {#if showExpand && !descriptionExpand}
              <div
                class="absolute bottom-0 left-0 w-full h-full bg-black rounded-b-lg black-gradient"
              />
              <div
                class="absolute cursor-pointer"
                style="bottom: -1rem;left: calc(50% - 2rem)"
                on:click={(_) => (descriptionExpand = true)}
              >
                <IconBtn>
                  <FaDown />
                </IconBtn>
              </div>
            {/if}
          </div>
        </div>
      </div>
      <div class="w-full grid place-items-center">
        <div class="mt-14">
          <span class="font-semibold text-xl mt-16">Episodes</span>
          {#if anime.episodes > 100}
            <select
              class="bg-gray-200 h-fit w-fit text-sm ml-5 rounded-md"
              bind:value={episodePage}
            >
              {#each Array.from( { length: Math.ceil(anime.episodes / 100) } ) as _, index}
                <option value={index}
                  >{index * 100 + (anime.zeroEpisode ? 0 : 1)} - {(index + 1) *
                    100}</option
                >
              {/each}
            </select>
          {/if}
        </div>
        <div
          class="mt-10 flex gap-5 flex-wrap max-w-xl justify-center items-center"
        >
          {#each generateRange(episodePage * 100 + (anime.zeroEpisode ? 0 : 1), (episodePage + 1) * 100, anime.episodes) as epNo}
            <a
              style="width: {(anime.episodes.toString().length ?? 0) +
                1.25}rem;"
              class=" bg-gray-300 text-center rounded-sm"
              href="/episode?animeId={anime.kitsuId}&episodeId={epNo}&zeroEp={anime.zeroEpisode}&totalEpisode={anime.episodes}"
            >
              <span class="font-semibold text-black">{epNo}</span>
            </a>
          {/each}
        </div>
      </div>
    </section>
    <div
      on:click={(_) => {
        anime.liked = !anime.liked;
        window.api.anime.setLike(anime.kitsuId, anime.liked);
      }}
      class="fixed overflow-hidden active:scale-110 rounded-lg text-gray-800 {anime.liked
        ? 'bg-accent'
        : 'bg-gray-400'} bottom-8 right-8"
    >
      <IconBtn bgAccent={false}>
        <FaHeart />
      </IconBtn>
    </div>
  {:else}
    <div class="w-full h-full flex flex-col gap-12 justify-center items-center">
      <div class="w-32 text-white">
        <FaCircleXMark />
      </div>
      <h3 class="text-xl text-gray-300">Anime not available :(</h3>
    </div>
  {/if}
{:else}
  Loading anime
{/if}

<style>
  .black-gradient {
    background: linear-gradient(
      180deg,
      rgba(0, 0, 0, 0) 32.46%,
      rgba(0, 0, 0, 0.7) 100%
    );
  }
  p {
    max-width: 45rem;
  }

  .limit-lines {
    overflow: hidden;
    text-overflow: ellipsis;
  }
</style>
