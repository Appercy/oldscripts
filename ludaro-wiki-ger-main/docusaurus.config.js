// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/palenight');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Ludaro.de Wiki!',
  tagline: 'Lua Lernen für jeden!',
  url: 'https://ludaro.de',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'Ludaro1024', // Usually your GitHub org/user name.
  projectName: 'ludaro-wiki-ger', // Usually your repo name.

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'de',
    locales: ['de', 'en']
  },

 

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
     //     editUrl:
            //'https://github.com/Ludaro1024/ludaro-wiki-ger',
    // showReadingTime: true,
            editUrl: ({locale, docPath}) => {
              if (locale !== "de") {
                return `https://github.com/Ludaro1024/ludaro-wiki-ger/tree/main/i18n/${locale}/docusaurus-plugin-content-docs/current/${docPath}`;
              }
              
              return `https://github.com/Ludaro1024/ludaro-wiki-ger/blob/main/docs/${docPath}`;
            },
        },
        // blog: {
        //   showReadingTime: true,
        //   // Please change this to your repo.
        //   // Remove this to remove the "edit this page" links.
        //   editUrl:
        //     'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        // },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    
    ({
      colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: false,
    },
    markdown: {
      mermaid: true, // Aktiviere Mermaid für Markdown-Dateien
    },
    themes: ['@docusaurus/theme-mermaid'], // Füge das Mermaid-Thema hinzu
      navbar: {
        hideOnScroll: true,
        title: 'Ludaro.de Wiki!',
        logo: {
          alt: 'Ein Kleiner Poro <3',
          src: 'img/docusaurus.png',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Wiki',
          },
        //  {to: '/blog', label: 'Blog', position: 'left'},
          {
            type: 'localeDropdown',
            position: 'right',
            dropdownItemsAfter: [
              {
                type: 'html',
                value: '<hr style="margin: 0.3rem 0;">',
              },
              {
                href: 'https://github.com/Ludaro1024/ludaro-wiki-ger/i18n/',
                label: 'Help me Translate!',
              },
            ],
          },
          {
            href: 'https://github.com/Ludaro1024/ludaro-wiki-ger',
            position: 'right',
            className: 'header-github-link',
            'aria-label': 'GitHub repository',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          // {
          //   title: 'Docs',
          //   items: [
          //     {
          //       label: 'Tutorial',
          //       to: '/docs/intro',
          //     },
          //   ],
          // },
          // {
          //   title: 'More',
          //   items: [
          //     {
          //       label: 'Blog',
          //       to: '/blog',
          //     },
          //     {
          //       label: 'GitHub',
          //       href: 'https://github.com/facebook/docusaurus',
          //     },
          //   ],
          // },
          {
            title: 'Wichtige Links:',
            items: [
              {
                label: "Impressum",
                href: "https://ludaro.de/impressum",
              },
              {
                label: "Discord",
                href: "https://discord.ludaro.de",
              },
              {
                label: 'Github',
                href: 'https://github.com/Ludaro1024',
              },
             
            ],
          },
        ],
        logo: {
          alt: 'Poro Logo Ludaro.de',
          src: 'img/docusaurus.png',
          className: 'footer-logo',
          href: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          width: 100,
          height: 100,
        },
        copyright: `Copyright © ${new Date().getFullYear()} Poruvan, geschrieben mit vollem ❤️ für dich. mit Docusaurus`,
      },
      prism: {
        additionalLanguages: ['powershell', 'lua', 'php', 'csharp', 'css', 'javascript', 'sql', 'json', 'git', 'diff'],
        theme: darkCodeTheme
      },
    }),
};

module.exports = config;
