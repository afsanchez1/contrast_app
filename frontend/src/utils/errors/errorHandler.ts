import { ErrorType } from '../../types'

export const getError = (error: ErrorType): string => {
    switch (error) {
        case ErrorType.EmptyTopicError:
            return 'Por favor, introduce un tema'

        case ErrorType.FetchError:
            return 'Ha ocurrido un error, inténtelo más tarde'

        default:
            return 'Error desconocido'
    }
}
