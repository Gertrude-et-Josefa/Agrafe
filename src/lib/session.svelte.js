import { supabase } from '#lib/supabase.js';

/**
 * État de connexion partagé par toute l'application.
 * `pret` passe à true une fois la session lue au démarrage.
 */
export const auth = $state({
	/** @type {import('@supabase/supabase-js').Session | null} */
	session: null,
	pret: false,
	/** Vrai quand l'utilisateur arrive par le lien « mot de passe oublié » */
	recuperation: false
});

supabase.auth.getSession().then(({ data }) => {
	auth.session = data.session;
	auth.pret = true;
});

supabase.auth.onAuthStateChange((evenement, session) => {
	auth.session = session;
	if (evenement === 'PASSWORD_RECOVERY') auth.recuperation = true;
});

export async function deconnexion() {
	await supabase.auth.signOut();
}
