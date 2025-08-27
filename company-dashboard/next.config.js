/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
  images: {
    domains: ['localhost', 'api.inventry.com'],
  },
  experimental: {
    appDir: true,
  },
}

module.exports = nextConfig