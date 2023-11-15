import { parseAuthors, parseLastDateTime } from '../../utils/types/parsingUtils'
import type Author from './author'

export default class Article {
    private readonly _newspaper: string
    private readonly _headline: string
    private readonly _subheadline: string
    private readonly _authors: Author[]
    private readonly _lastDateTime: Date
    private readonly _body: object[]
    private readonly _url: string

    constructor(
        newspaper: string,
        headline: string,
        subheadline: string,
        authors: Array<{ name: string; url: string }>,
        isoDateTime: string,
        body: object[],
        url: string
    ) {
        this._newspaper = newspaper
        this._headline = headline
        this._subheadline = subheadline
        this._authors = parseAuthors(authors)
        this._lastDateTime = parseLastDateTime(isoDateTime)
        this._body = body
        this._url = url
    }

    public get newspaper(): string {
        return this._newspaper
    }

    public get headine(): string {
        return this._headline
    }

    public get subheadine(): string {
        return this._subheadline
    }

    public get authors(): Author[] {
        return this._authors
    }

    public get lastDateTime(): Date {
        return this._lastDateTime
    }

    public get body(): object[] {
        return this._body
    }

    public get url(): string {
        return this._url
    }
}
