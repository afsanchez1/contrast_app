import axios, { type AxiosInstance } from 'axios'
const scraperUrl = process.env.BASE_URL

/**
 * Custom axios Axios instance for making request
 * @type {AxiosInstance}
 */
const axiosInst: AxiosInstance = axios.create({
    baseURL: scraperUrl,
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json',
    },
})

export default axiosInst
