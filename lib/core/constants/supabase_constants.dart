class SupabaseConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://igzyjalhnzbuawovpbjm.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnenlqYWxobnpidWF3b3ZwYmptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1Nzc3NDUsImV4cCI6MjA3NjE1Mzc0NX0.34VlIUKn0j6vxS8arSLPaAx_AjXhRCUgDRbO5WdyX90',
  );
}
