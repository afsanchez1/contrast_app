import type { AxiosError } from 'axios'
import type RequestError from '../../types/services/requestError'
import logger from '../logs/logger'

function handleError(error: AxiosError): RequestError {
    logger.error(error.toJSON)
    // The request was made and the server responded with an status code out of 2xx
    if (error.response != null) {
        const { status, data } = error.response
        return {
            status,
            data,
            message: `Request failed with status: ${status}`,
        }
        // Request was made but server did not respond
    } else if (error.request != null) {
        return {
            message: 'No response received from the server',
        }
        // Something failed setting up the request
    } else {
        return {
            message: 'Error setting up the request',
        }
    }
}

export default handleError
