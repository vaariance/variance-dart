'use client';
import { useState } from 'react';
import Modal from './Modal';
import Login from './Login';

const Connect = () => {
  const [openConnectModal, setOpenConnectModal] = useState(false);
  return (
    <>
      <Modal state={openConnectModal} setState={setOpenConnectModal}>
        <Login />
      </Modal>
      <button
        className="flex items-center justify-center gap-x-1 py-2 px-4 text-white font-medium bg-gray-800 hover:bg-gray-700 active:bg-gray-900 rounded-full md:inline-flex"
        onClick={() => setOpenConnectModal(true)}
      >
        connect
      </button>
    </>
  );
};

export default Connect;
