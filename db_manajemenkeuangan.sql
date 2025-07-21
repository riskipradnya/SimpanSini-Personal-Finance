-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 18 Jul 2025 pada 18.18
-- Versi server: 10.4.24-MariaDB
-- Versi PHP: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_manajemenkeuangan`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('income','expense') NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `type`, `category`, `description`, `amount`, `date`, `created_at`) VALUES
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-09 16:21:28'),
(0, 1, 'income', 'Gaji', 'Gaji bulanan', '4000000.00', '2025-07-11', '2025-07-09 16:23:01'),
(0, 8, 'income', 'Bonus', '', '5000000.00', '2025-07-10', '2025-07-09 16:24:54'),
(0, 8, 'income', 'Investasi', '', '6000000.00', '2025-07-10', '2025-07-09 16:31:46'),
(0, 8, 'income', 'Bonus', '', '10000000.00', '2025-07-10', '2025-07-09 16:37:35'),
(0, 8, 'income', 'Gaji', '', '1000000.00', '2025-07-10', '2025-07-09 16:50:52'),
(0, 8, 'income', 'Gaji', '', '1000000.00', '2025-07-10', '2025-07-09 17:15:28'),
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-09 17:30:02'),
(0, 8, 'expense', 'Tagihan', 'Tagihan Listrik', '50000.00', '2025-07-10', '2025-07-09 17:31:48'),
(0, 8, 'income', 'Gaji', '', '13000000.00', '2025-07-10', '2025-07-09 18:06:11'),
(0, 8, 'income', 'Gaji', '', '5000000.00', '2025-07-10', '2025-07-09 18:08:43'),
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-09 18:09:29'),
(0, 8, 'income', 'Gaji', '', '2000000.00', '2025-07-10', '2025-07-09 18:15:34'),
(0, 8, 'income', 'Gaji', '', '1000000.00', '2025-07-10', '2025-07-09 18:26:01'),
(0, 8, 'income', 'Gaji', '', '3000000.00', '2025-07-10', '2025-07-09 18:30:18'),
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-09 18:33:23'),
(0, 8, 'income', 'Investasi', '', '1000000.00', '2025-07-10', '2025-07-10 00:09:26'),
(0, 8, 'income', 'Gaji', '', '3000000.00', '2025-07-10', '2025-07-10 00:20:24'),
(0, 8, 'income', 'Gaji', '', '1000000.00', '2025-07-10', '2025-07-10 00:25:11'),
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-10 00:30:37'),
(0, 8, 'income', 'Gaji', '', '4000000.00', '2025-07-10', '2025-07-10 00:32:18'),
(0, 8, 'expense', 'Makan Siang', '', '100000.00', '2025-07-10', '2025-07-10 00:39:03'),
(0, 8, 'income', 'Gaji', 'coba aja', '3000000.00', '2025-07-10', '2025-07-10 00:45:55'),
(0, 8, 'income', 'Gaji', 'masukan', '5000000.00', '2025-07-10', '2025-07-10 00:57:38'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-10', '2025-07-10 01:18:24'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-10', '2025-07-10 01:28:34'),
(0, 8, 'income', 'Gaji', 'lucu', '4000000.00', '2025-07-16', '2025-07-16 01:50:25'),
(0, 10, 'income', 'Gaji', 'anjay', '4000000.00', '2025-07-16', '2025-07-16 02:21:52'),
(0, 10, 'expense', 'Makan Siang', 'georek', '50000.00', '2025-07-16', '2025-07-16 02:29:15'),
(0, 3, 'income', 'Gaji', 'gajian lur', '4000000.00', '2025-07-16', '2025-07-16 02:47:59'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-16', '2025-07-16 05:04:13'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-16', '2025-07-16 05:04:54'),
(0, 8, 'income', 'Gaji', 'crash', '4000000.00', '2025-07-16', '2025-07-16 05:26:48'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-16', '2025-07-16 05:46:39'),
(0, 8, 'income', 'Gaji', 'haha', '4000000.00', '2025-07-16', '2025-07-16 06:00:01'),
(0, 8, 'income', 'Gaji', 'lucunya', '4000000.00', '2025-07-16', '2025-07-16 06:02:38'),
(0, 8, 'income', 'Gaji', 'cobasaha', '4000000.00', '2025-07-16', '2025-07-16 06:08:18'),
(0, 8, 'income', 'Gaji', 'hahah', '4000000.00', '2025-07-16', '2025-07-16 06:18:00'),
(0, 8, 'expense', 'Makan Siang', 'setelah crash', '50000.00', '2025-07-16', '2025-07-16 06:18:47'),
(0, 8, 'expense', 'Lainnya', 'kok ga muncul ya', '100000.00', '2025-07-16', '2025-07-16 06:19:19'),
(0, 8, 'expense', 'Makan Siang', 'coba', '100000.00', '2025-07-16', '2025-07-16 06:19:48'),
(0, 8, 'expense', 'Makan Siang', 'pengeluaran lebih gede dari pemasukan', '99999999.99', '2025-07-16', '2025-07-16 06:21:04'),
(0, 8, 'income', 'Gaji', 'setelah fix', '4000000.00', '2025-07-16', '2025-07-16 07:13:52'),
(0, 8, 'income', 'Gaji', 'setelah profile', '4000000.00', '2025-07-16', '2025-07-16 14:20:32'),
(0, 8, 'expense', 'Makan Siang', 'setelah profile', '50000.00', '2025-07-16', '2025-07-16 14:20:43'),
(0, 8, 'income', 'Gaji', 'coba', '4000000.00', '2025-07-17', '2025-07-17 03:33:06');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama_lengkap` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `nama_lengkap`, `email`, `password`, `profile_image`, `created_at`, `updated_at`) VALUES
(1, 'kiki', 'kiki@gmail.com', '$2y$10$iVyRTrFSHf6obbQsUbAQK.HyBjGk1EnPBwoQ7bLU7taOrkxTZNtjq', NULL, '2025-06-30 17:10:32', '2025-07-18 13:20:22'),
(2, 'admin', 'admin@gmail.com', '$2y$10$ZJ5/r8OwSxKjOE8OIBMCi.avGmUMhMjSKmPqUCWMs2FpABkwaoP3W', NULL, '2025-07-07 06:31:40', '2025-07-18 13:20:22'),
(3, 'admin', 'admin3@gmail.com', '$2y$10$V1o26h5TmQ43NPr5Zr37FewgEonsHR1bDu3X8hbY1N5Fs6zhvX2Ke', NULL, '2025-07-07 06:50:32', '2025-07-18 13:20:22'),
(4, 'admin', 'admin4@gmail.com', '$2y$10$VFjGbFLsTGiSlLndKTQeYOJO7UwmVsR9cpIdV1Pwby/idPSgngBwy', NULL, '2025-07-07 07:11:29', '2025-07-18 13:20:22'),
(5, 'admin', 'admin5@gmail.com', '$2y$10$PlY7cE9INOTHYkCWfrRBiOqlWMgkKJEseKdzFKdcYIOU00jINzWZG', NULL, '2025-07-07 07:15:34', '2025-07-18 13:20:22'),
(6, 'admin', 'admin7@gmail.com', '$2y$10$qEm3MsVEHlDSpWOjrKz1A.hl618JMArCYYOMlOizimsAOb7PMkk4G', NULL, '2025-07-08 01:55:57', '2025-07-18 13:20:22'),
(7, 'admin', 'admin8@gmail.com', '$2y$10$3U8XNvA6NnZKj4dzOIS.R.bqgvFyT6eaX6iceOTGI3m3dsuxjCbOS', NULL, '2025-07-09 05:42:47', '2025-07-18 13:20:22'),
(8, 'admin10', 'admin10@gmail.com', '$2y$10$gThktd9MaHVffdNa5kViLOU9zeqUn/87mkZckmMx7rQsZoBei7Kzy', 'uploads/68791c436b6c37.11781103.jpg', '2025-07-09 12:36:58', '2025-07-18 13:21:35'),
(9, 'admin11', 'admin11@gmail.com', '$2y$10$wGBagQxaO7Xy5AcLSvtXzOYamZZV08.ybHBONuh.A.Kncs6inzyyq', NULL, '2025-07-09 17:10:33', '2025-07-18 13:20:22'),
(10, 'agunggrss', 'admin2@gmail.com', '$2y$10$LY4PWKKB7VXJWSbDx4dnQej6fXkoMLkDWHKKZ2vRDVKudIBklu2TO', NULL, '2025-07-16 02:20:04', '2025-07-18 13:20:22');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
