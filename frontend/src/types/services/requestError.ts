/**
 * Represents a request error
 * @interface RequestError
 */
export interface RequestError {
    message: string
    status?: number
    data?: any
}
