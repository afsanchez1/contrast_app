import type { Author } from './author'

/**
 * Represents a newspaper article
 * @interface Article
 */
export interface Article {
    /**
     * The newspaper name
     * @type {string}
     */
    newspaper: string
    /**
     * The article's headline
     * @type {string}
     */
    headline: string
    /**
     * The article's subheadline
     * @type {string}
     */
    subheadline: string
    /**
     * The article's authors
     * @type {Author[]}
     */
    authors: Author[]
    /**
     * The article's last known date and time in locale format
     * @type {string}
     */
    last_date_time: string
    /**
     * The article's body as an array of objects of the form { htmlTag: content }
     * @type {Array<Record<string, string>>}
     */
    body: Array<Record<string, string>>
}