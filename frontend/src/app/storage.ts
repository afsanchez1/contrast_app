import createWebStorage from 'redux-persist/lib/storage/createWebStorage'

// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
const createNoopStorage = () => {
    return {
        async getItem(_key: any) {
            return await Promise.resolve(null)
        },
        async setItem(_key: any, value: any) {
            return await Promise.resolve(value)
        },
        async removeItem(_key: any) {
            await Promise.resolve()
        },
    }
}

const storage = typeof window !== 'undefined' ? createWebStorage('local') : createNoopStorage()

export default storage
