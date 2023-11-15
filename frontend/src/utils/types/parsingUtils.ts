import type Author from '../../types/scraper/author'

export function parseAuthors(authors: Array<{ name: string; url: string }>): Author[] {
    return authors.map(authObj => ({
        name: authObj.name,
        url: authObj.url,
    }))
}

export function parseLastDateTime(lastDateTime: string): Date {
    return new Date(lastDateTime)
}
