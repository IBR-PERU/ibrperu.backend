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

        public async Task<IList<UsuarioDTO>> getUsuarioById(int IdUsuario)
        {
            IEnumerable<UsuarioDTO> list = new List<UsuarioDTO>();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 2);
                parameters.Add("IdUsuario", IdUsuario);

                list = await connection.QueryAsync<UsuarioDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }
            return list.ToList();
        }


        public async Task<SqlRspDTO> InsUsuario(UsuarioDTO usuario)
        {
            SqlRspDTO resp = new SqlRspDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 3);
                // Parámetros de Usuario
                parameters.Add("NamesUser", usuario.NamesUser);
                parameters.Add("Username", usuario.Username);
                parameters.Add("Email", usuario.Email);
                parameters.Add("Phone", usuario.Phone);
                parameters.Add("Website", usuario.Website);

                // Parámetros de Address
                parameters.Add("Street", usuario.Street);
                parameters.Add("Suite", usuario.Suite);
                parameters.Add("City", usuario.City);
                parameters.Add("Zipcode", usuario.Zipcode);
                parameters.Add("Lat", usuario.Lat);
                parameters.Add("Lng", usuario.Lng);

                // Parámetros de Company
                parameters.Add("CompanyNames", usuario.NamesCompany);
                parameters.Add("CatchPhrase", usuario.CatchPhrase);
                parameters.Add("Bs", usuario.Bs, DbType.String);

                resp = await connection.QuerySingleAsync<SqlRspDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }

        public async Task<SqlRspDTO> patchUpdUsuario(UsuarioDTO usuario)
        {
            SqlRspDTO resp = new SqlRspDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 4);
                // Parámetros de Usuario
                parameters.Add("NamesUser", usuario.NamesUser);
                parameters.Add("Username", usuario.Username);
                parameters.Add("Email", usuario.Email);
                parameters.Add("Phone", usuario.Phone);
                parameters.Add("Website", usuario.Website);

                // Parámetros de Address
                parameters.Add("Street", usuario.Street);
                parameters.Add("Suite", usuario.Suite);
                parameters.Add("City", usuario.City);
                parameters.Add("Zipcode", usuario.Zipcode);
                parameters.Add("Lat", usuario.Lat);
                parameters.Add("Lng", usuario.Lng);

                // Parámetros de Company
                parameters.Add("CompanyNames", usuario.NamesCompany);
                parameters.Add("CatchPhrase", usuario.CatchPhrase);
                parameters.Add("Bs", usuario.Bs, DbType.String);

                resp = await connection.QuerySingleAsync<SqlRspDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }

        public async Task<SqlRspDTO> deleteUsuario(int IdUsuario)
        {
            SqlRspDTO resp = new SqlRspDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_usuario]", 5);
                // Parámetros de Usuario
                parameters.Add("IdUsuario", IdUsuario);

                resp = await connection.QuerySingleAsync<SqlRspDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }


    }
}
