<script>
	import { supabase } from '#lib/supabase.js';
	import { auth, deconnexion } from '#lib/session.svelte.js';
	import { messageErreur } from '#lib/erreurs.js';

	/** @typedef {{ id: string, type: 'prestataire' | 'entreprise', nom: string, pack: string | null }} Espace */

	/** @type {Espace[]} */
	let espaces = $state([]);
	let chargement = $state(true);
	let erreur = $state('');
	/** @type {string | null} */
	let espaceActifId = $state(null);

	// Création d'un espace
	/** @type {'prestataire' | 'entreprise'} */
	let nouveauType = $state('prestataire');
	let nouveauNom = $state('');
	let packViticole = $state(true);
	let creation = $state(false);
	let afficherCreation = $state(false);

	let espaceActif = $derived(espaces.find((e) => e.id === espaceActifId) ?? null);
	let nomUtilisateur = $derived(auth.session?.user.user_metadata?.nom || auth.session?.user.email || '');

	const CLE_ESPACE = 'agrafe.espaceActif';

	async function charger() {
		chargement = true;
		erreur = '';
		const { data, error } = await supabase
			.from('espaces')
			.select('id, type, nom, pack')
			.is('deleted_at', null)
			.order('created_at');
		chargement = false;
		if (error) {
			erreur = messageErreur(error);
			return;
		}
		espaces = data ?? [];
		let memorise = null;
		try {
			memorise = localStorage.getItem(CLE_ESPACE);
		} catch {}
		espaceActifId = espaces.some((e) => e.id === memorise) ? memorise : (espaces[0]?.id ?? null);
	}

	/** @param {string} id */
	function choisirEspace(id) {
		espaceActifId = id;
		try {
			localStorage.setItem(CLE_ESPACE, id);
		} catch {}
	}

	/** @param {SubmitEvent} e */
	async function creerEspace(e) {
		e.preventDefault();
		creation = true;
		erreur = '';
		const { data, error } = await supabase.rpc('creer_espace', {
			p_type: nouveauType,
			p_nom: nouveauNom.trim(),
			p_pack: packViticole ? 'viticole' : null
		});
		creation = false;
		if (error) {
			erreur = messageErreur(error);
			return;
		}
		nouveauNom = '';
		afficherCreation = false;
		await charger();
		choisirEspace(data);
	}

	charger();
</script>

<header>
	<span class="marque">Agrafe</span>
	{#if espaces.length > 1}
		<label class="selecteur">
			<span class="visuellement-cache">Espace</span>
			<select value={espaceActifId} onchange={(e) => choisirEspace(e.currentTarget.value)}>
				{#each espaces as esp (esp.id)}
					<option value={esp.id}>{esp.nom} ({esp.type})</option>
				{/each}
			</select>
		</label>
	{/if}
	<span class="utilisateur">{nomUtilisateur}</span>
	<button class="lien" onclick={deconnexion}>Se déconnecter</button>
</header>

<main>
	{#if chargement}
		<p class="doux">Chargement de vos espaces…</p>
	{:else if espaces.length === 0 || afficherCreation}
		<section class="carte">
			<h1>{espaces.length === 0 ? 'Bienvenue sur Agrafe' : 'Nouvel espace'}</h1>
			<p class="doux">
				{espaces.length === 0
					? 'Pour commencer, créez votre espace.'
					: 'Un même compte peut accéder à plusieurs espaces.'}
			</p>
			<form onsubmit={creerEspace}>
				<fieldset>
					<legend>Vous êtes</legend>
					<label class="choix">
						<input type="radio" bind:group={nouveauType} value="prestataire" />
						<span><strong>Un prestataire</strong><br /><small>Vous réalisez des tâches pour vos clients</small></span>
					</label>
					<label class="choix">
						<input type="radio" bind:group={nouveauType} value="entreprise" />
						<span><strong>Une entreprise</strong><br /><small>Vous confiez des tâches à un prestataire</small></span>
					</label>
				</fieldset>

				<label for="nom-espace">Nom de l'espace</label>
				<input id="nom-espace" bind:value={nouveauNom} placeholder="ex. Vinalchimie" required />

				<label class="case">
					<input type="checkbox" bind:checked={packViticole} />
					Activer le pack viticole (cuvées, codes douaniers, DAE, tâches de la filière)
				</label>

				{#if erreur}<p class="message erreur" role="alert">{erreur}</p>{/if}

				<div class="actions">
					{#if espaces.length > 0}
						<button type="button" class="bouton secondaire" onclick={() => (afficherCreation = false)}>Annuler</button>
					{/if}
					<button class="bouton" type="submit" disabled={creation}>{creation ? 'Création…' : "Créer l'espace"}</button>
				</div>
			</form>
		</section>
	{:else if espaceActif}
		<section class="carte">
			<p class="etiquette">{espaceActif.type === 'prestataire' ? 'Espace prestataire' : 'Espace entreprise'}{espaceActif.pack === 'viticole' ? ' · pack viticole' : ''}</p>
			<h1>{espaceActif.nom}</h1>
			<p class="doux">
				Les fondations sont en place. Prochaine étape de construction : les contacts, les entreprises et leurs libellés.
			</p>
			<button class="lien" onclick={() => (afficherCreation = true)}>Créer un autre espace</button>
		</section>
	{/if}

	{#if erreur && !afficherCreation && espaces.length > 0}
		<p class="message erreur" role="alert">{erreur}</p>
	{/if}
</main>

<style>
	header {
		display: flex;
		align-items: center;
		gap: 1rem;
		padding: 0.75rem 1.25rem;
		background: var(--carte);
		border-bottom: 1px solid var(--bord);
		flex-wrap: wrap;
	}
	.marque {
		font-weight: 700;
		font-size: 1.2rem;
		color: var(--encre);
		margin-right: auto;
	}
	.selecteur {
		margin: 0;
	}
	.selecteur select {
		padding: 0.4rem 0.6rem;
	}
	.utilisateur {
		color: var(--texte-doux);
		font-size: 0.9rem;
	}
	main {
		max-width: 640px;
		margin: 2rem auto;
		padding: 0 1rem;
	}
	.carte {
		background: var(--carte);
		border: 1px solid var(--bord);
		border-radius: var(--rayon);
		padding: 1.75rem;
	}
	h1 {
		margin: 0 0 0.25rem;
		color: var(--encre);
	}
	.doux {
		color: var(--texte-doux);
	}
	.etiquette {
		margin: 0 0 0.25rem;
		font-size: 0.85rem;
		color: var(--texte-doux);
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}
	fieldset {
		border: 0;
		padding: 0;
		margin: 1rem 0 0;
		display: grid;
		gap: 0.5rem;
	}
	legend {
		font-weight: 600;
		font-size: 0.9rem;
		margin-bottom: 0.35rem;
	}
	.choix,
	.case {
		display: flex;
		gap: 0.6rem;
		align-items: flex-start;
		font-weight: 400;
		margin: 0;
	}
	.choix {
		border: 1px solid var(--bord);
		border-radius: 8px;
		padding: 0.75rem;
		cursor: pointer;
	}
	.choix:has(input:checked) {
		border-color: var(--accent);
		background: var(--accent-clair);
	}
	.case {
		margin-top: 1rem;
	}
	.choix input,
	.case input {
		width: auto;
		margin-top: 0.3rem;
	}
	small {
		color: var(--texte-doux);
	}
	.actions {
		display: flex;
		justify-content: flex-end;
		gap: 0.5rem;
		margin-top: 1.5rem;
	}
	.visuellement-cache {
		position: absolute;
		width: 1px;
		height: 1px;
		overflow: hidden;
		clip: rect(0 0 0 0);
	}
</style>
