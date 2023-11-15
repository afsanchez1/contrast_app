import axios, { type AxiosInstance } from 'axios'
const scraperUrl = import.meta.env.BASE_URL

const axiosInst: AxiosInstance = axios.create({
    baseURL: scraperUrl,
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json',
    },
})

export default axiosInst
