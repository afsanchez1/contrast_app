import type Author from './author'

export default interface Article {
    newspaper: string
    headline: string
    subheadline: string
    authors: Author[]
    last_date_time: string
    body: Array<Record<string, string>>
}
