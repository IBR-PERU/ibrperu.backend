using Dapper;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using backend.domain;
using backend.repository.Interfaces.Seguridad;

namespace backend.repository.Seguridad
{
    public class UsuarioRepository : IUsuarioRepository
    {
        private readonly IConfiguration _configuration;

        public UsuarioRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<IList<UsuarioDTO>> getAllUsuario()
        {
            IEnumerable<UsuarioDTO> list = new List<UsuarioDTO>();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 1);

                list = await connection.QueryAsync<UsuarioDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }
            return list.ToList();
        }


        public async Task<SqlRspDTO> InsUsuario(UsuarioDTO usuario)
        {
            SqlRspDTO resp = new SqlRspDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnInmobisoft")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 4);
                parameters.Add("sUsuario", usuario.sUsuario);
                parameters.Add("sPassword", usuario.sPassword);
                parameters.Add("bActivo", usuario.bActivo);
                parameters.Add("nIdTipoUsuario", usuario.nIdTipoUsuario);
                parameters.Add("nIdPerDet", usuario.nIdPerDet);

                resp = await connection.QuerySingleAsync<SqlRspDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }

        public async Task<SqlRspDTO> patchUpdUsuario(UsuarioDTO usuario)
        {
            SqlRspDTO resp = new SqlRspDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnInmobisoft")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 5);
                parameters.Add("nIdUsuario", usuario.nIdUsuario);
                parameters.Add("sPassword", usuario.sPassword);
                parameters.Add("bActivo", usuario.bActivo);

                resp = await connection.QuerySingleAsync<SqlRspDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }



 

    }
}
