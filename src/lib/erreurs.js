/**
 * Traduit les messages d'erreur de Supabase en français clair.
 * @param {unknown} erreur
 */
export function messageErreur(erreur) {
	const brut = erreur instanceof Error ? erreur.message : String(erreur ?? '');
	const texte = brut.toLowerCase();
	if (texte.includes('invalid login credentials')) return 'E-mail ou mot de passe incorrect.';
	if (texte.includes('email not confirmed'))
		return "Votre adresse n'est pas encore confirmée : cliquez sur le lien reçu par e-mail.";
	if (texte.includes('user already registered')) return 'Un compte existe déjà avec cette adresse.';
	if (texte.includes('password should be at least'))
		return 'Le mot de passe doit contenir au moins 8 caractères.';
	if (texte.includes('rate limit') || texte.includes('too many'))
		return 'Trop de tentatives. Patientez quelques minutes avant de réessayer.';
	if (texte.includes('failed to fetch') || texte.includes('network'))
		return 'Connexion impossible. Vérifiez votre accès à internet.';
	return 'Une erreur est survenue. Réessayez, et si le problème persiste, contactez-nous.';
}
