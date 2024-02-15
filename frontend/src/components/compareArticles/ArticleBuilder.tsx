import { Box, Heading, Text, VStack } from '@chakra-ui/react'
import { type FC } from 'react'
import { type Article } from '../../types'
/**
 * Props for ComponentBuilder
 */
export interface ArticleBuilderProps {
    /**
     * The article body
     */
    article: Article
}
/**
 * ArticleBuilder is a custom React component for building articles
 * @returns {JSX.Element}
 */
export const ArticleBuilder: FC<ArticleBuilderProps> = ({ article }) => {
    return (
        <VStack textAlign='left' overflowY='auto' maxH='53vh' padding='1rem'>
            <Heading
                as='h1'
                fontSize={{
                    base: '1.75rem',
                    md: '2rem',
                }}
                mb='1rem'
            >
                {article.headline}
            </Heading>
            <Heading
                as='h2'
                fontSize={{
                    base: '1.2rem',
                    md: '1.5rem',
                }}
                fontWeight='medium'
                mb='1rem'
            >
                {article.subheadline}
            </Heading>
            <Box>
                {article.body.map((item, index) => {
                    const tag = Object.keys(item)[0]
                    const content = item[tag]

                    switch (tag) {
                        case 'h2':
                            return (
                                <Heading
                                    as='h2'
                                    key={index}
                                    fontSize='1.4rem'
                                    mt='1rem'
                                    mb='1rem'
                                    fontWeight='semibold'
                                >
                                    {content}
                                </Heading>
                            )
                        case 'h3':
                            return (
                                <Heading
                                    as='h3'
                                    key={index}
                                    fontSize='1.4rem'
                                    mt='1rem'
                                    mb='1rem'
                                    fontWeight='medium'
                                >
                                    {content}
                                </Heading>
                            )

                        case 'p':
                            return (
                                <Text
                                    as='p'
                                    key={index}
                                    fontSize={{
                                        base: '1rem',
                                        md: '1.2rem',
                                    }}
                                    mb='1.5rem'
                                >
                                    {content}
                                </Text>
                            )

                        default:
                            return null
                    }
                })}
            </Box>
        </VStack>
    )
}
