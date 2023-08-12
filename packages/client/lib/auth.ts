import type { NextAuthOptions } from "next-auth";

export const authOptions: NextAuthOptions = {
    providers: [
      {
        id: "worldcoin",
        name: "Worldcoin",
        type: "oauth",
        wellKnown: "https://id.worldcoin.org/.well-known/openid-configuration",
        authorization: { params: { scope: "openid" } },
        clientId: process.env.WLD_CLIENT_ID,
        clientSecret: process.env.WLD_CLIENT_SECRET,
        idToken: true,
        profile(profile) {
          return {
            id: profile.sub,
            name: profile.sub,
            credentialType: profile["https://id.worldcoin.org/beta"].credential_type,
          }
        },
      },
    ],
    callbacks: {
      async jwt({ token }) {
        token.userRole = "admin"
        return token
      },
    },
  }