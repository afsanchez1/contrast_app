import { VStack } from '@chakra-ui/react'
import { type FC } from 'react'
import { ArticleDisplayer } from '.'
// import { BackButton } from '..'

/**
 * CompareArticles is a custom React component for managing article comparison
 * @returns {JSX.Element}
 */
export const CompareArticles: FC = () => {
    return (
        <VStack spacing='1.75rem'>
            <ArticleDisplayer displayCount={2} />
        </VStack>
    )
}
