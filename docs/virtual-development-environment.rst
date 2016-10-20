Virtual Development Environment
===============================

| It's recommended to use `Vagrant <http://www.vagrantup.com/>`__ and
  `VirtualBox <https://www.virtualbox.org/>`__ in order to achieve
| consistent development environment across all contributors.

Installation
------------

#. Download and install latest
   `VirtualBox <https://www.virtualbox.org/>`__.
#. Download and install latest `Vagrant <http://www.vagrantup.com/>`__.
#. Clone GitHub repo:

   .. code:: shell

       $ git clone https://github.com/apiaryio/dredd
       $ cd dredd

#. Import the Vagrant box:

   .. code:: shell

       $ vagrant box add precise64 http://files.vagrantup.com/precise64.box

#. Start virtual development environment:

   .. code:: shell

       $ vagrant up

       | **Note:** You may be prompted to enter your root password due
       | to exporting shared folder over NFS to the virtual machine.

#. SSH to the virtual development environment:

   .. code:: shell

       $ vagrant ssh

#. You will find your project shared in ``/vagrant`` inside the virtual
   environment:

   .. code:: shell

       $ cd /vagrant

#. | Use your favorite local editor in your local folder to edit the
     code and
   | run tests in the virtual environment:

   .. code:: shell

       $ npm install && npm test
