const axios = require('axios');

const API_URL = 'http://localhost:3000/auth';

async function testAuth() {
  const testUser = {
    email: 'admin@gmail.com',
    password: 'password123',
    fullName: 'Admin RuangPulih'
  };

  console.log('--- Memulai Test Auth ---');

  try {
    // 1. Test Register
    console.log('\n1. Mencoba Registrasi...');
    try {
      const regRes = await axios.post(`${API_URL}/register`, testUser);
      console.log('✅ Registrasi Berhasil:', regRes.data);
    } catch (err) {
      if (err.response && err.response.status === 409) {
        console.log('ℹ️ User sudah terdaftar (Conflict), lanjut ke login.');
      } else {
        throw err;
      }
    }

    // 2. Test Login Benar
    console.log('\n2. Mencoba Login dengan data yang benar...');
    const loginRes = await axios.post(`${API_URL}/login`, {
      email: testUser.email,
      password: testUser.password
    });
    console.log('✅ Login Berhasil! Token didapat.');
    // console.log('Token:', loginRes.data.access_token);

    // 3. Test Login Salah (Password Salah)
    console.log('\n3. Mencoba Login dengan password salah...');
    try {
      await axios.post(`${API_URL}/login`, {
        email: testUser.email,
        password: 'password_salah'
      });
    } catch (err) {
      if (err.response && err.response.status === 401) {
        console.log('✅ Berhasil menolak login (Password Salah - 401 Unauthorized)');
      } else {
        throw err;
      }
    }

    // 4. Test Login Akun Asal
    console.log('\n4. Mencoba Login dengan akun asal (tidak terdaftar)...');
    try {
      await axios.post(`${API_URL}/login`, {
        email: 'akun_asal@gmail.com',
        password: 'sembarang_saja'
      });
    } catch (err) {
      if (err.response && err.response.status === 401) {
        console.log('✅ Berhasil menolak login (Akun Tidak Terdaftar - 401 Unauthorized)');
      } else {
        throw err;
      }
    }

    console.log('\n--- Semua Test Selesai dengan Sukses ---');

  } catch (error) {
    console.error('\n❌ Terjadi kesalahan saat testing:', error.message);
    if (error.response) {
      console.error('Data Error:', error.response.data);
    }
  }
}

testAuth();
