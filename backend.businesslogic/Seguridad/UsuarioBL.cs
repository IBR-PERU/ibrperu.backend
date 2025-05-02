using backend.businesslogic.Interfaces.Seguridad;
using backend.domain;
using backend.repository.Interfaces.Seguridad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.businesslogic.Seguridad
{
    public class UsuarioBL : IUsuarioBL
    {
        IUsuarioRepository repository;
        public UsuarioBL(IUsuarioRepository _repository)
        {
            repository = _repository;
        }

        public async Task<IList<UsuarioDTO>> getAllUsuario()
        {
            return await repository.getAllUsuario();
        }

        public async Task<IList<UsuarioDTO>> getUsuarioById(int IdUsuario)
        {
            return await repository.getUsuarioById(IdUsuario);
        }

        public async Task<SqlRspDTO> InsUsuario(UsuarioDTO usuario)
        {
            return await repository.InsUsuario(usuario);
        }

        public async Task<SqlRspDTO> patchUpdUsuario(UsuarioDTO usuario)
        {
            return await repository.patchUpdUsuario(usuario);
        }

        public async Task<SqlRspDTO> deleteUsuario(int IdUsuario)
        {
            return await repository.deleteUsuario(IdUsuario);
        }
    }
}
