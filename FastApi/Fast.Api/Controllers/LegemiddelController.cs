using Fast.Service;
using Microsoft.AspNetCore.Mvc;
using Fast.Data.Model.Fest;
using System.Collections.Generic;
using System.Linq;

namespace FastApi.Controllers
{
    [Route("api/legemiddel")]
    public class LegemiddelController : ControllerBase
    {
        private readonly FestService festService;

        public LegemiddelController(FestService festService)
        {
            this.festService = festService;
        }

        [HttpGet("")]
        public ActionResult<LegemiddelMerkevare[]> Get([FromQuery] string nameContains = "", [FromQuery] int take = 10, int skip = 0)
        {
            return festService.AllLegemiddelMerkevare(nameContains, take, skip);
        }

        [HttpGet("virkestoff")]
        public ActionResult<LegemiddelVirkestoff[]> GetVirkestoff([FromQuery] string search = "", [FromQuery] int take = 10, int skip = 0)
        {
            return festService.AllLegemiddelVirkestoff(search, take, skip);
        }
    }

}
