import api from '@/lib/axios';

export async function uploadImage(file) {
  const payload = new FormData();
  payload.append('file', file);

  const { data } = await api.post('/uploads', payload, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });

  return data?.url || '';
}
