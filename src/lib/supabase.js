import { createClient } from '@supabase/supabase-js';

// Valeurs lues dans le fichier .env (voir .env.example)
const url = import.meta.env.VITE_SUPABASE_URL;
const clePublique = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!url || !clePublique) {
	throw new Error('Configuration Supabase manquante : copiez .env.example en .env et complétez-le.');
}

/** Client Supabase unique pour toute l'application. */
export const supabase = createClient(url, clePublique);
