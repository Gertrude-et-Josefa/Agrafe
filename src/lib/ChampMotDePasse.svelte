<script>
	/** @type {{ valeur: string, label?: string, id: string, autocomplete?: import('svelte/elements').FullAutoFill }} */
	let { valeur = $bindable(), label = 'Mot de passe', id, autocomplete = 'current-password' } = $props();
	let visible = $state(false);
</script>

<label for={id}>{label}</label>
<div class="mdp">
	<input
		{id}
		type={visible ? 'text' : 'password'}
		bind:value={valeur}
		{autocomplete}
		required
		minlength="8"
	/>
	<button
		type="button"
		class="oeil"
		onclick={() => (visible = !visible)}
		aria-label={visible ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
		aria-pressed={visible}
	>
		{#if visible}
			<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 3l18 18M10.6 10.6a2 2 0 0 0 2.8 2.8M9.9 5.1A9.8 9.8 0 0 1 12 5c5 0 9 4.5 10 7-.4 1-1.3 2.4-2.6 3.7M6.6 6.6C4.4 8 2.8 10.1 2 12c1 2.5 5 7 10 7 1.7 0 3.3-.5 4.6-1.3" /></svg>
		{:else}
			<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12c1-2.5 5-7 10-7s9 4.5 10 7c-1 2.5-5 7-10 7S3 14.5 2 12z" /><circle cx="12" cy="12" r="3" /></svg>
		{/if}
	</button>
</div>

<style>
	.mdp {
		position: relative;
	}
	.mdp input {
		padding-right: 2.75rem;
	}
	.oeil {
		position: absolute;
		right: 0.25rem;
		top: 50%;
		transform: translateY(-50%);
		background: none;
		border: 0;
		padding: 0.4rem;
		cursor: pointer;
		color: var(--texte-doux);
	}
	.oeil svg {
		width: 1.25rem;
		height: 1.25rem;
		fill: none;
		stroke: currentColor;
		stroke-width: 1.8;
		stroke-linecap: round;
		stroke-linejoin: round;
	}
</style>
