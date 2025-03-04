require('avante').setup({
        default_provider = "anthropic",

        providers = {
                anthropic = {
                        api_key = os.getenv("ANTHROPIC_API_KEY"), -- Using environment variable for security
                        default_model = "claude-3-7-sonnet-20250219", -- Latest Claude model
                        temperature = 0.2,          -- Lower temperature for more deterministic coding responses
                        max_tokens = 4000,          -- Adjust based on your needs
                        top_p = 0.95,
                },
                gemini = {
                        api_key = os.getenv("GOOGLEAI_API_KEY"),
                        endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
                        model = "gemini-2.0-flash",
                        timeout = 30000, -- Timeout in milliseconds
                        temperature = 0,
                        max_tokens = 4096,
                },
        },

})
