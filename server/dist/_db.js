const dbFilePath = './db.ts';
const authors = [
    { id: '1', name: 'mario', varified: true },
    { id: '2', name: 'ypshi', varified: true },
    { id: '3', name: 'peach', varified: true },
];
const books = [
    {
        title: 'The Awakening',
        author: 'Kate Chopin',
    },
    {
        title: 'City of Glass',
        author: 'Paul Auster',
    },
];
const products = [
    { id: '1', productId: '1', price: '1', quality: '1' },
    { id: '2', productId: '2', price: '2', quality: '2' },
    { id: '3', productId: '3', price: '3', quality: '3' },
    { id: '4', productId: '4', price: '4', quality: '4' },
];
const users = [
    { id: '1', name: 'maria', passwoed: 'maria123' },
    { id: '2', name: 'joan', passwoed: 'joan123' },
    { id: '3', name: 'pere', passwoed: 'pere123' },
];
const games = [
    { id: '1', title: 'a', platform: ['s', 'b'] },
    { id: '2', title: 'b', platform: ['s', 'b'] },
];
const reviews = [
    { id: '1', rating: 9, content: 'aa', author_id: '1', game_id: '2' },
    { id: '2', rating: 9, content: 'BB', author_id: '1', game_id: '2' },
];
export default { authors, books, users, games, reviews, products };
