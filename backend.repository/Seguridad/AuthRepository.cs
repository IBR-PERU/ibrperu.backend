using backend.domain;
using Dapper;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;
using System.Data;
using backend.repository.Interfaces.Seguridad;

namespace backend.repository.Seguridad
{
    public class AuthRepository : IAuthRepository
    {
        private readonly IConfiguration _configuration;

        public AuthRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<LoginDTO> AuthUser(authLoginDTO authLogin)
        {
            LoginDTO resp = new LoginDTO();

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[seguridad].[pa_autentication]", 1);
                parameters.Add("sUsuario", authLogin.sUsuario);
                parameters.Add("sPassword", authLogin.sPassword);

                resp = await connection.QuerySingleAsync<LoginDTO>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }

     
    }
}
