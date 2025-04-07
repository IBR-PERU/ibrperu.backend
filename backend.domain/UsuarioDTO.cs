using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.domain
{
    public class UsuarioDTO
    {
        public int? nIdUsuario { get; set; }
        public string? sUsuario { get; set; }
        public string? sPassword { get; set; }
        public bool? bActivo { get; set; }
        public int nIdTipoUsuario { get; set; }
        public string? sTipoUsuario { get; set; }
        public int? nIdPerDet { get; set; }
        public string? sNombreCompleto { get; set; }
        public int? bChangePassword { get; set; }

    }

    public class authLoginDTO
    {
        public string sUsuario { get; set; }
        public string sPassword { get; set; }
    }

    public class recoverPasswordDTO
    {
        public int bChangePassword { get; set; }
        public string sCorreoUser { get; set; }
        public string? sMsj { get; set; }
        public int emailExist { get; set; }
    }
}
