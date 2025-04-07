using backend.businesslogic.Interfaces.Seguridad;
using backend.domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace backend.services.Controllers.Seguridad
{
    [Route("api/[controller]")]
    [ApiController]

    public class AuthController : ControllerBase
    {
        private readonly string secretKey;
        private readonly IAuthBL service;
        private readonly int expirationMin;

        public AuthController(IConfiguration _configuration, IAuthBL _service)
        {
            secretKey = _configuration["JWTConfig:secretKey"];
            service = _service;
            expirationMin = 30;
        }

        [HttpPost("[action]")]
        public async Task<ActionResult<ApiResponse<string>>> AuthLogin([FromBody] authLoginDTO request)
        {

            LoginDTO rsp = await service.AuthUser(request);

            if (rsp.nIdUsuario > 0)
            {
                var keyBytes = Encoding.ASCII.GetBytes(secretKey);
                var claims = new ClaimsIdentity();

                claims.AddClaim(new Claim("nIdUsuario", rsp.nIdUsuario.ToString()));
                claims.AddClaim(new Claim("sNombreCompleto", rsp.sNombreCompleto));
                claims.AddClaim(new Claim("nIdTipoUsuario", rsp.nIdTipoUsuario.ToString()));
                claims.AddClaim(new Claim("sCodigoTipoUsuario", rsp.sCodigoTipoUsuario));
                claims.AddClaim(new Claim("nIdPerDet", rsp.nIdPerDet.ToString()));

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = claims,
                    Expires = DateTime.UtcNow.AddMinutes(expirationMin),
                    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256Signature)
                };

                var tokenHandler = new JwtSecurityTokenHandler();
                var tokenConfig = tokenHandler.CreateToken(tokenDescriptor);
                var token = tokenHandler.WriteToken(tokenConfig);

                return StatusCode(StatusCodes.Status200OK, new ApiResponse<string> { success = true, data = token, errMsj = "" });
            }
            else
            {
                return StatusCode(StatusCodes.Status200OK, new ApiResponse<string> { success = false, data = "", errMsj = rsp.sMsj });
            }
        }


    }
}
