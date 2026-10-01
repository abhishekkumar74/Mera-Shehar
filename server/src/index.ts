import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', app: 'Mera Shehar Server', timestamp: new Date() });
});

app.get('/api/config', (req, res) => {
  res.json({
    featured_template_id: 'diwali_gold_01',
    ads_enabled: false,
    min_app_version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`[Mera Shehar Server] Running on http://localhost:${PORT}`);
});
