import { Box, Heading, Text } from '@chakra-ui/react'
import { type FC } from 'react'
import { type ArticleBody } from '../../types'
/**
 * Props for ComponentBuilder
 */
export interface ArticleBuilderProps {
    /**
     * The article body
     */
    articleBody: ArticleBody
}
/**
 * ArticleBuilder is a custom React component for building articles
 * @returns {JSX.Element}
 */
export const ArticleBuilder: FC<ArticleBuilderProps> = ({ articleBody }) => {
    return (
        <Box>
            {articleBody.map((item, index) => {
                const tag = Object.keys(item)[0]
                const content = item[tag]

                switch (tag) {
                    case 'h2':
                        return (
                            <Heading as='h2' key={index}>
                                {content}
                            </Heading>
                        )
                    case 'h3':
                        return (
                            <Heading as='h3' key={index}>
                                {content}
                            </Heading>
                        )

                    case 'p':
                        return (
                            <Text as='p' key={index}>
                                {content}
                            </Text>
                        )

                    default:
                        return null
                }
            })}
        </Box>
    )
}
