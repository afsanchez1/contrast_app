import type Article from '../../../types/scraper/article'
import type ArticleSummary from '../../../types/scraper/articleSummary'

function parseDateTime(dateTime: string): string {
    return new Date(dateTime).toLocaleString()
}

export function parseArticleSummaries(artSumms: ArticleSummary[]): ArticleSummary[] {
    return artSumms.map<ArticleSummary>(artSumm => ({
        ...artSumm,
        date_time: parseDateTime(artSumm.date_time),
    }))
}

export function parseArticle(art: Article): Article {
    return {
        ...art,
        last_date_time: parseDateTime(art.last_date_time),
    }
}
