using backend.domain;
using Dapper;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;
using System.Data;
using backend.repository.Interfaces.Maestros;

namespace backend.repository.Maestros
{
    public class PersonaRepository : IPersonaRepository
    {
        private readonly IConfiguration _configuration;

        public PersonaRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<int> validDocumentoUsuario(int nIdUsuario, string? sDNI, string? sCE, string? sRUC)
        {
            int resp;

            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDatabase")))
            {
                DynamicParameters parameters = new();
                string storedProcedure = string.Format("{0};{1}", "[maestros].[pa_persona]", 1);
                parameters.Add("nIdUsuario", nIdUsuario);
                parameters.Add("sDNI", sDNI);
                parameters.Add("sCE", sCE);
                parameters.Add("sRUC", sRUC);

                resp = await connection.ExecuteScalarAsync<int>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            }

            return resp;
        }
    }
}
