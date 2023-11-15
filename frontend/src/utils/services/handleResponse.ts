import logger from '../logs/logger'
import type { AxiosResponse } from 'axios'

function handleResponse(response: AxiosResponse): any {
    const data = response.data
    logger.info({
        message: 'Response received from the server',
        data,
    })

    return data
}

export default handleResponse
