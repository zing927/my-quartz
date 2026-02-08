import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

// 主题和布局参考 jackyzha0/quartz v4 官方 + jzhao.xyz（Recent Writing / Recent Notes）
const isWriting = (f: { slug?: string }) =>
  (f.slug ?? "").startsWith("posts/") || (f.slug ?? "").startsWith("blog/")
const isNote = (f: { slug?: string }) => {
  const s = f.slug ?? ""
  return !s.startsWith("posts/") && !s.startsWith("blog/") && s !== "index"
}

// components shared across all pages
export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [],
  afterBody: [],
  footer: Component.Footer({
    links: {
      GitHub: "https://github.com/jackyzha0/quartz",
      "Discord Community": "https://discord.gg/cRFFHYye7t",
    },
  }),
}

// components for pages that display a single page (e.g. a single note)
export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.ConditionalRender({
      component: Component.Breadcrumbs(),
      condition: (page) => page.fileData.slug !== "index",
    }),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TagList(),
  ],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        { Component: Component.Search(), grow: true },
        { Component: Component.Darkmode() },
      ],
    }),
    Component.RecentNotes({
      title: "最近的写作",
      limit: 4,
      showTags: false,
      linkToMore: "posts",
      filter: isWriting,
    }),
    Component.RecentNotes({
      title: "最近的笔记",
      limit: 4,
      showTags: false,
      linkToMore: false,
      filter: isNote,
    }),
  ],
  right: [
    Component.Graph(),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(),
  ],
}

// components for pages that display lists of pages  (e.g. tags or folders)
export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.Breadcrumbs(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        { Component: Component.Search(), grow: true },
        { Component: Component.Darkmode() },
      ],
    }),
    Component.RecentNotes({
      title: "最近的写作",
      limit: 4,
      showTags: false,
      linkToMore: "posts",
      filter: isWriting,
    }),
    Component.RecentNotes({
      title: "最近的笔记",
      limit: 4,
      showTags: false,
      linkToMore: false,
      filter: isNote,
    }),
  ],
  right: [],
}
