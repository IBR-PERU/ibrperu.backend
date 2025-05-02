using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.domain
{
    public class UsuarioDTO
    {
        public int? IdUsuario { get; set; }
        public string? NamesUser { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }

        public int? IdAddress { get; set; }
        public string? Street { get; set; }
        public string? Suite { get; set; }
        public string? City { get; set; }
        public string? Zipcode { get; set; }
        public decimal? Lat { get; set; }
        public decimal? Lng { get; set; }

        public int? IdCompany { get; set; }
        public string? NamesCompany { get; set; }
        public string? CatchPhrase { get; set; }
        public string? Bs { get; set; }
    }



}
