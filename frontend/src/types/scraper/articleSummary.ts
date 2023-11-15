import type Author from './author'
import { parseAuthors, parseLastDateTime } from '../../utils/types/parsingUtils'

export default class ArticleSummary {
    private readonly _newspaper: string
    private readonly _authors: Author[]
    private readonly _title: string
    private readonly _excerpt: string
    private readonly _dateTime: Date
    private readonly _isPremium: boolean
    private readonly _url: string

    constructor(
        newspaper: string,
        authors: Array<{ name: string; url: string }>,
        title: string,
        excerpt: string,
        isoDateTime: string,
        url: string,
        isPremium: boolean
    ) {
        this._newspaper = newspaper
        this._authors = parseAuthors(authors)
        this._title = title
        this._excerpt = excerpt
        this._dateTime = parseLastDateTime(isoDateTime)
        this._url = url
        this._isPremium = isPremium
    }

    public get newspaper(): string {
        return this._newspaper
    }

    public get authors(): Author[] {
        return this._authors
    }

    public get title(): string {
        return this._title
    }

    public get excerpt(): string {
        return this._excerpt
    }

    public get dateTime(): Date {
        return this._dateTime
    }

    public get isPremium(): boolean {
        return this._isPremium
    }

    public get url(): string {
        return this._url
    }
}
