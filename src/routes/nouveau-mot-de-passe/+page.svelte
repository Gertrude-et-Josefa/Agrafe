<script>
	import { goto } from '$app/navigation';
	import { supabase } from '#lib/supabase.js';
	import { auth } from '#lib/session.svelte.js';
	import { messageErreur } from '#lib/erreurs.js';
	import ChampMotDePasse from '#lib/ChampMotDePasse.svelte';

	let motDePasse = $state('');
	let enCours = $state(false);
	let erreur = $state('');

	/** @param {SubmitEvent} e */
	async function valider(e) {
		e.preventDefault();
		enCours = true;
		erreur = '';
		const { error } = await supabase.auth.updateUser({ password: motDePasse });
		enCours = false;
		if (error) {
			erreur = messageErreur(error);
			return;
		}
		auth.recuperation = false;
		goto('/');
	}
</script>

<main>
	<div class="carte">
		<h1>Nouveau mot de passe</h1>
		{#if auth.session}
			<form onsubmit={valider}>
				<ChampMotDePasse id="mdp" label="Choisissez un nouveau mot de passe" bind:valeur={motDePasse} autocomplete="new-password" />
				<p class="aide">8 caractères minimum.</p>
				{#if erreur}<p class="message erreur" role="alert">{erreur}</p>{/if}
				<button class="bouton plein" type="submit" disabled={enCours}>
					{enCours ? 'Un instant…' : 'Enregistrer'}
				</button>
			</form>
		{:else}
			<p>Ce lien n'est plus valable. Demandez-en un nouveau depuis la page de connexion.</p>
			<a class="bouton" href="/connexion">Page de connexion</a>
		{/if}
	</div>
</main>

<style>
	main {
		min-height: 100vh;
		display: grid;
		place-items: center;
		padding: 1.5rem 1rem;
	}
	.carte {
		width: 100%;
		max-width: 400px;
		background: var(--carte);
		border: 1px solid var(--bord);
		border-radius: var(--rayon);
		padding: 2rem 1.75rem;
	}
	h1 {
		margin: 0 0 0.5rem;
		font-size: 1.4rem;
		color: var(--encre);
	}
	.aide {
		margin: 0.35rem 0 0;
		font-size: 0.85rem;
		color: var(--texte-doux);
	}
	.plein {
		width: 100%;
		margin-top: 1.5rem;
	}
</style>
