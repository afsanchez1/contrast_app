import type Result from '../../types/result'

export function isErrorResult<T>(result: Result<T>): result is { error: string } {
    return (result as { error: string }).error !== undefined
}
