import type Author from './author'

export default interface ArticleSummary {
    newspaper: string
    authors: Author[]
    title: string
    excerpt: string
    date_time: string
    url: string
    is_premium: boolean
}
