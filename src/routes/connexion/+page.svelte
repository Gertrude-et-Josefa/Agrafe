<script>
	import { supabase } from '#lib/supabase.js';
	import { messageErreur } from '#lib/erreurs.js';
	import { VERSION } from '#lib/version.js';
	import ChampMotDePasse from '#lib/ChampMotDePasse.svelte';

	/** @type {'connexion' | 'inscription' | 'oubli'} */
	let mode = $state('connexion');
	let nom = $state('');
	let email = $state('');
	let motDePasse = $state('');
	let enCours = $state(false);
	let erreur = $state('');
	let info = $state('');

	/** @param {'connexion' | 'inscription' | 'oubli'} m */
	function changerMode(m) {
		mode = m;
		erreur = '';
		info = '';
	}

	/** @param {SubmitEvent} e */
	async function valider(e) {
		e.preventDefault();
		enCours = true;
		erreur = '';
		info = '';
		try {
			if (mode === 'connexion') {
				const { error } = await supabase.auth.signInWithPassword({ email, password: motDePasse });
				if (error) throw error;
			} else if (mode === 'inscription') {
				const { data, error } = await supabase.auth.signUp({
					email,
					password: motDePasse,
					options: { data: { nom }, emailRedirectTo: `${location.origin}/` }
				});
				if (error) throw error;
				if (!data.session) {
					info = 'Compte créé. Cliquez sur le lien reçu par e-mail pour confirmer votre adresse, puis connectez-vous.';
					mode = 'connexion';
				}
			} else {
				const { error } = await supabase.auth.resetPasswordForEmail(email, {
					redirectTo: `${location.origin}/nouveau-mot-de-passe`
				});
				if (error) throw error;
				info = 'Si un compte existe avec cette adresse, vous allez recevoir un lien pour choisir un nouveau mot de passe.';
			}
		} catch (err) {
			erreur = messageErreur(err);
		} finally {
			enCours = false;
		}
	}
</script>

<main>
	<div class="carte">
		<h1>Agrafe</h1>
		<p class="accroche">Le lien entre votre entreprise et vos prestataires</p>

		{#if mode !== 'oubli'}
			<div class="onglets" role="tablist" aria-label="Connexion ou création de compte">
				<button role="tab" aria-selected={mode === 'connexion'} class:actif={mode === 'connexion'} onclick={() => changerMode('connexion')}>Se connecter</button>
				<button role="tab" aria-selected={mode === 'inscription'} class:actif={mode === 'inscription'} onclick={() => changerMode('inscription')}>Créer un compte</button>
			</div>
		{:else}
			<h2>Mot de passe oublié</h2>
			<p class="aide">Saisissez votre adresse : nous vous envoyons un lien pour en choisir un nouveau.</p>
		{/if}

		<form onsubmit={valider}>
			{#if mode === 'inscription'}
				<label for="nom">Prénom et nom</label>
				<input id="nom" bind:value={nom} autocomplete="name" required />
			{/if}

			<label for="email">Adresse e-mail</label>
			<input id="email" type="email" bind:value={email} autocomplete="email" required />

			{#if mode !== 'oubli'}
				<ChampMotDePasse
					id="mdp"
					bind:valeur={motDePasse}
					autocomplete={mode === 'inscription' ? 'new-password' : 'current-password'}
				/>
				{#if mode === 'inscription'}
					<p class="aide">8 caractères minimum.</p>
				{/if}
			{/if}

			{#if erreur}<p class="message erreur" role="alert">{erreur}</p>{/if}
			{#if info}<p class="message succes" role="status">{info}</p>{/if}

			<button class="bouton plein" type="submit" disabled={enCours}>
				{#if enCours}Un instant…
				{:else if mode === 'connexion'}Se connecter
				{:else if mode === 'inscription'}Créer mon compte
				{:else}Envoyer le lien{/if}
			</button>
		</form>

		{#if mode === 'connexion'}
			<button class="lien centre" onclick={() => changerMode('oubli')}>Mot de passe oublié ?</button>
		{:else if mode === 'oubli'}
			<button class="lien centre" onclick={() => changerMode('connexion')}>Retour à la connexion</button>
		{/if}
	</div>

	<footer>Agrafe, par Gertrude & Josefa · version {VERSION}</footer>
</main>

<style>
	main {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
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
		margin: 0;
		color: var(--encre);
		font-size: 2rem;
		letter-spacing: -0.02em;
	}
	h2 {
		margin: 1.25rem 0 0;
		font-size: 1.15rem;
	}
	.accroche {
		margin: 0.25rem 0 1.5rem;
		color: var(--texte-doux);
	}
	.aide {
		margin: 0.35rem 0 0;
		font-size: 0.85rem;
		color: var(--texte-doux);
	}
	.onglets {
		display: grid;
		grid-template-columns: 1fr 1fr;
		background: var(--accent-clair);
		border-radius: 8px;
		padding: 4px;
	}
	.onglets button {
		font: inherit;
		border: 0;
		background: transparent;
		padding: 0.5rem;
		border-radius: 6px;
		cursor: pointer;
		color: var(--texte-doux);
	}
	.onglets button.actif {
		background: #fff;
		color: var(--encre);
		font-weight: 600;
	}
	.plein {
		width: 100%;
		margin-top: 1.5rem;
	}
	.centre {
		display: block;
		margin: 1rem auto 0;
		font-size: 0.9rem;
	}
	footer {
		margin-top: 1.5rem;
		font-size: 0.8rem;
		color: var(--texte-doux);
	}
</style>
