import { useEffect, type FC, type ReactNode } from 'react'
import storage from 'redux-persist/lib/storage'

export interface StorageCleanerProps {
    children: ReactNode
}
/**
 * StorageCleaner is a custom React component for cleaning the localForage state (redux-persist)
 * @returns {JSX.Element}
 */
export const StorageCleaner: FC<StorageCleanerProps> = ({ children }) => {
    const handleBeforeUnload = (e: Event): void => {
        e.preventDefault()
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        storage.removeItem('persist:cart')
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        storage.removeItem('persist:compare')
    }

    useEffect(() => {
        window.addEventListener('beforeunload', handleBeforeUnload)

        return () => {
            window.removeEventListener('beforeunload', handleBeforeUnload)
        }
    }, [])

    return <>{children}</>
}
