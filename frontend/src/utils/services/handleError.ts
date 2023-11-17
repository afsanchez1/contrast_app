import type { AxiosError } from 'axios'
import type { RequestError } from '../../types'
import { logger } from '../logs'

/**
 * Handles failed requests
 * @param {AxiosError} error - Error returned by axios lib when request fails
 * @returns {RequestError}
 */
export function handleError(error: AxiosError): RequestError {
    logger.error({ errorMessage: error.message })
    // The request was made and the server responded with an status code out of 2xx
    if (error.response != null) {
        const { status, data } = error.response
        return {
            status,
            data,
            message: `Request failed with status: ${status}`,
        }
        // Request was made but no response was received
    } else if (error.request != null) {
        return {
            message: 'No response received from the server',
        }
        // Timeout
    } else if (error.code === 'ECONNABORTED' && error.message.includes('timeout')) {
        return {
            message: 'Request timed out',
        }
    } else if (error.code === 'ECONNABORTED') {
        return {
            message: 'Request aborted',
        }
    }
    // Something failed setting up the request
    else {
        return {
            message: 'Error setting up the request',
        }
    }
}
