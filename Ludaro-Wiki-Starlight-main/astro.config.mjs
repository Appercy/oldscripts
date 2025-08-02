// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightImageZoom from 'starlight-image-zoom'
import catppuccin from "starlight-theme-catppuccin";
// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			plugins: [starlightImageZoom(), catppuccin()],
			title: 'Ludaro Wiki',
			social: {
				github: 'https://github.com/Ludaro1024',
				discord: 'https://discord.gg/dqCa97qcYU',
				youtube: 'https://www.youtube.com/Ludaro1024',
			},
			lastUpdated: true,
			logo: {
				src: './src/assets/logo.png',
			},
			editLink: {
				baseUrl: 'https://github.com/Ludaro1024/ludaro-wiki-starlight/edit/main/',
			},
			favicon: './src/assets/logo.png',
			components: {
				ThemeSelect: './src/components/EmptyThemeSelect.astro',
				// Footer: './src/components/customfooter.astro',
			},
			sidebar: [
			],
			credits: true,
			customCss: [
				'./src/styles/custom.css',
			],
			defaultLocale: 'root',
			locales: {
				root: {
					label: 'German',
					lang: 'de',
				},
				en: {
					label: 'English',
					lang: 'en',
				},
			},
			sidebar: [

				{ label: 'Home', link: '/home' },

				{ label: 'Impressum', link: '/impressum' },

				{
					label: 'Lua Basics',
					autogenerate: { directory: 'lua' },
					collapsed: true,
				},

				{
					label: 'FiveM Server Setup',
					autogenerate: { directory: 'fvm' },
					collapsed: true,
				},
				{
					label: 'Bekannte Probleme',
					autogenerate: { directory: 'issues' },
					collapsed: true,
				},
				{
					label: 'Useful Information',
					autogenerate: { directory: 'useful' },
					collapsed: true,
				},
				{label:"Mitwirken", link:"/contributing"},
			],
		}),
	],
});
