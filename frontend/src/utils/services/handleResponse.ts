import { logger } from '../logs'
import type { AxiosResponse } from 'axios'

/**
 * Handles successful requests
 * @param {AxiosResponse} response
 * @returns {any}
 */
export function handleResponse(response: AxiosResponse): any {
    const data = response.data
    logger.info({
        message: 'Response received from the server',
        data,
    })

    return data
}
