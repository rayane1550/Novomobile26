const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const restaurantes = [
  {
    id: 1,
    title: 'Bacalhau Vinho e Cia',
    body: 'Casa especializada em bacalhau, com receitas tradicionais e ambiente acolhedor.',
    price: 89.9,
    imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2c/df/46/0f/bacalhau-a-portuguesa.jpg?w=900&h=500&s=1',
    menu: 'Bacalhau à portuguesa, entradas quentes, sobremesas e pratos da casa.',
    location: 'Rua da Barra Funda, 120 - São Paulo/SP',
    schedule: 'Segunda a domingo, das 11:30 às 23:00',
    parking: 'Estacionamento com manobrista e vagas externas.'
  },
  {
    id: 2,
    title: 'Jam - Itaim',
    body: 'Culinária japonesa com ambiente elegante, pratos criativos e experiências musicais.',
    price: 99.9,
    imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1c/a7/19/2f/caption.jpg?w=900&h=500&s=1',
    menu: 'Sushis, sashimis, combinados, frutos do mar e pratos grelhados.',
    location: 'Avenida Faria Lima, 3100 - Itaim Bibi/SP',
    schedule: 'Terça a domingo, das 12:00 às 23:30',
    parking: 'Estacionamento próprio e conveniado.'
  },
  {
    id: 3,
    title: 'Aguzzo Cucina Italiana - Pinheiros',
    body: 'Clássica experiência italiana com cozinha refinada, ambiente charmoso e sobremesas marcantes.',
    price: 119.9,
    imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1d/37/3c/04/aguzzo-cucina-italiana.jpg?w=1000&h=-1&s=1',
    menu: 'Massas frescas, risotos, carnes, pizzas e entradas italianas.',
    location: 'Rua Fradique Coutinho, 170 - Pinheiros/SP',
    schedule: 'Segunda a domingo, das 12:00 às 23:00',
    parking: 'Estacionamento no local e ruas próximas.'
  }
];

app.get('/', (req, res) => {
  res.json({ message: 'API Onde Comer rodando', status: 'ok' });
});

app.get('/Restaurantes', (req, res) => {
  res.json(restaurantes);
});

app.get('/Restaurantes/:id', (req, res) => {
  const id = Number(req.params.id);
  const restaurante = restaurantes.find((item) => item.id === id);

  if (!restaurante) {
    return res.status(404).json({ message: 'Restaurante não encontrado' });
  }

  return res.json(restaurante);
});

app.post('/Restaurantes', (req, res) => {
  const novo = {
    id: Date.now(),
    ...req.body,
  };

  restaurantes.push(novo);
  res.status(201).json(novo);
});

app.put('/Restaurantes/:id', (req, res) => {
  const id = Number(req.params.id);
  const index = restaurantes.findIndex((item) => item.id === id);

  if (index === -1) {
    return res.status(404).json({ message: 'Restaurante não encontrado' });
  }

  restaurantes[index] = {
    ...restaurantes[index],
    ...req.body,
    id,
  };

  return res.json(restaurantes[index]);
});

app.delete('/Restaurantes/:id', (req, res) => {
  const id = Number(req.params.id);
  const index = restaurantes.findIndex((item) => item.id === id);

  if (index === -1) {
    return res.status(404).json({ message: 'Restaurante não encontrado' });
  }

  const [removido] = restaurantes.splice(index, 1);
  return res.json(removido);
});

app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});
