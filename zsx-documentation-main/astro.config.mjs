import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightImageZoom from 'starlight-image-zoom'
// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			plugins: [starlightImageZoom()],
			title: 'ZSX Documentation',
			logo: {
				src: './src/assets/logo.png',
				replacesTitle: true,

			},
			editLink: {
				baseUrl: 'https://github.com/Ludaro1024/zsx-documentation/edit/main/',
			},
			favicon: './src/assets/favicon.ico',
			social: {
				github: 'https://github.com/it-zeusx',
				discord: 'https://discord.gg/kEWG9fVVgh',
				youtube: 'https://www.youtube.com/@ZSXDevelopment',
			},
			lastUpdated: false,
			pagination: false,
			titleDelimiter: "|",
			credits: false,
			customCss: [
				'./src/styles/custom.css',
			],
			components: {
				ThemeSelect: './src/components/EmptyThemeSelect.astro',
			},
			// localization disabled for now
			// defaultLocale: 'root', // Set the default locale to 'root'
			// locales: {
			// 	root: {
			// 		label: 'English',
			// 		lang: 'en',
			// 	},
			// 	de: {
			// 		label: 'Deutsch',
			// 	},
			// 	pl: {
			// 		label: 'Polski',
			// 	},
			// },

			sidebar: [

				{ label: 'Home', link: '/home' },

				{
					label: 'ZSX Multicharacter',
					autogenerate: { directory: 'multicharacter' },
					collapsed: true,
				},

				{
					label: 'User Interface (UI) V1',
					autogenerate: { directory: 'ui-v1' },
					collapsed: true,
				},
				{
					label: 'User Interface (UI) V2',
					autogenerate: { directory: 'ui-v2' },
					collapsed: true,
				},
				{
					label: 'Dealership',
					autogenerate: { directory: 'dealership' },
					collapsed: true,
				},
				{label:"Contributing", link:"/contributing"},
			],
		}),
	],
});
