<script>
	import favicon from '#lib/assets/favicon.svg';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { auth } from '#lib/session.svelte.js';

	/** @type {{children: import('svelte').Snippet}} */
	let { children } = $props();

	// Pages accessibles sans être connecté
	const PAGES_PUBLIQUES = ['/connexion', '/nouveau-mot-de-passe'];

	$effect(() => {
		if (!auth.pret) return;
		const chemin = page.url.pathname;
		if (auth.recuperation && chemin !== '/nouveau-mot-de-passe') {
			goto('/nouveau-mot-de-passe');
		} else if (!auth.session && !PAGES_PUBLIQUES.includes(chemin)) {
			goto('/connexion');
		} else if (auth.session && !auth.recuperation && chemin === '/connexion') {
			goto('/');
		}
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

{#if auth.pret}
	{@render children()}
{:else}
	<p class="chargement" aria-live="polite">Chargement…</p>
{/if}

<style>
	:global(:root) {
		--encre: #0b1136;
		--texte: #1f2433;
		--texte-doux: #5b6275;
		--fond: #f6f5f2;
		--carte: #ffffff;
		--bord: #dcdad3;
		--accent: #0b1136;
		--accent-clair: #e7e8f0;
		--erreur: #b42318;
		--succes: #1e7a4c;
		--rayon: 10px;
		font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
		color: var(--texte);
		background: var(--fond);
		line-height: 1.5;
	}
	:global(*) {
		box-sizing: border-box;
	}
	:global(body) {
		margin: 0;
		min-height: 100vh;
	}
	:global(label) {
		display: block;
		font-weight: 600;
		font-size: 0.9rem;
		margin: 1rem 0 0.35rem;
	}
	:global(input, select, textarea) {
		width: 100%;
		font: inherit;
		padding: 0.65rem 0.8rem;
		border: 1px solid var(--bord);
		border-radius: 8px;
		background: #fff;
		color: var(--texte);
	}
	:global(input:focus-visible, select:focus-visible, textarea:focus-visible, button:focus-visible, a:focus-visible) {
		outline: 3px solid #8f96c8;
		outline-offset: 1px;
	}
	:global(.bouton) {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.4rem;
		font: inherit;
		font-weight: 600;
		padding: 0.7rem 1.1rem;
		border-radius: 8px;
		border: 1px solid var(--accent);
		background: var(--accent);
		color: #fff;
		cursor: pointer;
		text-decoration: none;
	}
	:global(.bouton.secondaire) {
		background: transparent;
		color: var(--accent);
	}
	:global(.bouton:disabled) {
		opacity: 0.6;
		cursor: wait;
	}
	:global(.lien) {
		background: none;
		border: 0;
		padding: 0;
		font: inherit;
		color: var(--accent);
		text-decoration: underline;
		cursor: pointer;
	}
	:global(.message) {
		margin: 1rem 0 0;
		padding: 0.7rem 0.9rem;
		border-radius: 8px;
		font-size: 0.95rem;
	}
	:global(.message.erreur) {
		background: #fdecea;
		color: var(--erreur);
	}
	:global(.message.succes) {
		background: #e7f5ee;
		color: var(--succes);
	}
	.chargement {
		text-align: center;
		margin-top: 30vh;
		color: var(--texte-doux);
	}
</style>
