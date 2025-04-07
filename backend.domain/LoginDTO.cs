using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.domain
{
    public class LoginDTO
    {
        public int nIdUsuario { get; set; }
        public string? sNombreCompleto { get; set; }
        public int? nIdTipoUsuario { get; set; }
        public string? sCodigoTipoUsuario { get; set; }
        public int? nIdPerDet { get; set; }
        public string? sMsj { get; set; }
    }

}
