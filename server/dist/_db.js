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
export default { authors, books, users, games, reviews };
