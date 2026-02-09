import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const CACHE_TTL_SECONDS = 5;
const cache = new Map<
  string,
  { words: Record<string, number>; expiresAt: number }
>();

const STOPWORDS = new Set([
  "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "he",
  "in", "is", "it", "its", "of", "on", "that", "the", "to", "was", "were", "will",
  "with", "i", "me", "my", "myself", "we", "our", "you", "your", "they", "them",
  "this", "these", "those", "am", "been", "being", "have", "had", "do", "does",
  "did", "would", "could", "should", "can", "may", "might", "must", "shall",
  "what", "which", "who", "when", "where", "why", "how", "all", "each", "every",
  "both", "few", "more", "most", "other", "some", "such", "no", "nor", "not",
  "only", "own", "same", "so", "than", "too", "very", "just", "but", "if", "or",
  "because", "until", "while", "about", "into", "through", "during", "before",
  "after", "above", "below", "up", "down", "out", "off", "over", "under", "again",
  "then", "once", "here", "there", "any", "she", "her", "hers", "him", "his",
]);

function tokenize(text: string): string[] {
  const lower = text.toLowerCase();
  const words = lower.replace(/[^a-z0-9\s']/g, " ").split(/\s+/);
  return words.filter(
    (w) => w.length >= 2 && !STOPWORDS.has(w) && !/^\d+$/.test(w)
  );
}

function countWords(contents: string[]): Record<string, number> {
  const freq: Record<string, number> = {};
  for (const text of contents) {
    for (const word of tokenize(text)) {
      freq[word] = (freq[word] ?? 0) + 1;
    }
  }
  return freq;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401 }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const jwt = authHeader.replace("Bearer ", "").trim();
    const parts = jwt.split(".");
    if (parts.length !== 3) {
      return new Response(
        JSON.stringify({ error: "Invalid token" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401 }
      );
    }
    let payload: { sub?: string };
    try {
      payload = JSON.parse(atob(parts[1]));
    } catch {
      return new Response(
        JSON.stringify({ error: "Invalid token" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401 }
      );
    }
    const cacheKey = payload.sub ?? "anon";
    const now = Date.now() / 1000;
    const cached = cache.get(cacheKey);
    if (cached && cached.expiresAt > now) {
      return new Response(JSON.stringify({ words: cached.words }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    const { data: rows, error } = await supabase
      .from("journal_entries")
      .select("content");

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    const contents = (rows ?? []).map((r: { content: string }) => r.content);
    const words = countWords(contents);
    cache.set(cacheKey, {
      words,
      expiresAt: now + CACHE_TTL_SECONDS,
    });

    return new Response(JSON.stringify({ words }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
