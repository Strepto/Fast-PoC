using Microsoft.AspNetCore.Mvc;
using Fast.Data.Model.Fest;
using Fast.Service;

namespace FastApi.Controllers
{
    [Route("api/interaksjon")]
    [ApiController]
    public class InteraksjonController : ControllerBase
    {
        private readonly FestService festService;

        public InteraksjonController(FestService festService)
        {
            this.festService = festService;
        }

        [HttpGet("{id}")]
        public ActionResult<Interaksjon> GetById(string id)
        {
            var interaksjon = festService.GetInteraksjon(id);
            if (interaksjon == null)
                return NotFound();

            return interaksjon;
        }

        [HttpGet("")]
        public ActionResult<Interaksjon[]> Find([FromQuery] string[] atcVs)
        {
            var interaksjons = festService.FindInteraksjon(atcVs);
            if (interaksjons == null)
                return NotFound();

            return interaksjons;
        }

        [HttpGet("couple")]
        public ActionResult<InteraksjonCouple[]> FindCouples([FromQuery] string[] atcVs)
        {
            var interaksjonCouples = festService.FindInteraksjonVirkestoff(atcVs);
            if (interaksjonCouples == null)
                return NotFound();

            return interaksjonCouples;
        }
    }
}

