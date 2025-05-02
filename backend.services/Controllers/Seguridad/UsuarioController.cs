using backend.businesslogic.Interfaces.Seguridad;
using backend.domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.services.Controllers.Seguridad
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsuarioController : ControllerBase
    {
        public readonly IUsuarioBL service;

        public UsuarioController(IUsuarioBL _service)
        {
            service = _service;
        }

        [HttpGet("[action]")]
        public async Task<ActionResult<ApiResponse<List<UsuarioDTO>>>> getAllUsuario()
        {
            ApiResponse<List<UsuarioDTO>> response = new ApiResponse<List<UsuarioDTO>>();

            try
            {
                var result = await service.getAllUsuario();

                response.success = true;
                response.data = (List<UsuarioDTO>)result;
                return StatusCode(200, response);
            }
            catch (Exception ex)
            {
                response.success = false;
                response.errMsj = ex.Message;
                return StatusCode(500, response);
            }
        }

        [HttpGet("[action]")]
        public async Task<ActionResult<ApiResponse<List<UsuarioDTO>>>> getUsuarioById(int IdUsuario)
        {
            ApiResponse<List<UsuarioDTO>> response = new ApiResponse<List<UsuarioDTO>>();

            try
            {
                var result = await service.getUsuarioById(IdUsuario);

                response.success = true;
                response.data = (List<UsuarioDTO>)result;
                return StatusCode(200, response);
            }
            catch (Exception ex)
            {
                response.success = false;
                response.errMsj = ex.Message;
                return StatusCode(500, response);
            }
        }


        [HttpPost("[action]")]
        public async Task<ActionResult<ApiResponse<SqlRspDTO>>> postInsUsuario([FromBody] UsuarioDTO usuario)
        {
            ApiResponse<SqlRspDTO> response = new ApiResponse<SqlRspDTO>();

            try
            {
                var result = await service.InsUsuario(usuario);

                response.success = result.nCod == 0 ? false : true;
                response.data = result;
                return StatusCode(200, response);
            }
            catch (Exception ex)
            {
                response.success = false;
                response.errMsj = ex.Message;
                return StatusCode(500, response);
            }
        }

        [HttpPatch("[action]")]
        public async Task<ActionResult<ApiResponse<SqlRspDTO>>> patchUpdUsuario([FromBody] UsuarioDTO usuario)
        {
            ApiResponse<SqlRspDTO> response = new ApiResponse<SqlRspDTO>();

            try
            {
                var result = await service.patchUpdUsuario(usuario);

                response.success = result.nCod == 0 ? false : true;
                response.data = result;
                return StatusCode(200, response);
            }
            catch (Exception ex)
            {
                response.success = false;
                response.errMsj = ex.Message;
                return StatusCode(500, response);
            }
        }

        [HttpDelete("[action]")]
        public async Task<ActionResult<ApiResponse<SqlRspDTO>>> deleteUsuario(int IdUsuario)
        {
            ApiResponse<SqlRspDTO> response = new ApiResponse<SqlRspDTO>();

            try
            {
                var result = await service.deleteUsuario(IdUsuario);

                response.success = result.nCod == 0 ? false : true;
                response.data = result;
                return StatusCode(200, response);
            }
            catch (Exception ex)
            {
                response.success = false;
                response.errMsj = ex.Message;
                return StatusCode(500, response);
            }
        }


    }
}
