using System;
using Fast.Data.Model.Fest;

namespace Fast.Service
{
    /// <summary>A bidirectional coupling of Substance A and B</summary>
    public class InteraksjonCouple : IEquatable<InteraksjonCouple>
    {
        public SubstansgruppeSubstans SubstansA { get; set; }
        public SubstansgruppeSubstans SubstansB { get; set; }
        public Interaksjon Interaksjon { get; set; }

        public bool Equals(InteraksjonCouple other)
        {
            if (other == null)
                return false;

            if (other is InteraksjonCouple o)
            {
                var interaksjonEquals = this.Interaksjon == o.Interaksjon;
                var substansEquals = (this.SubstansA == o.SubstansA && this.SubstansB == o.SubstansB) || (this.SubstansB == o.SubstansA && this.SubstansA == o.SubstansB);
                return interaksjonEquals && substansEquals;
            }

            return false;
        }

        public override bool Equals(object obj)
        {
            return Equals(other: obj as InteraksjonCouple);
        }

        public override int GetHashCode()
        {

            return SubstansA.GetHashCode() & SubstansB.GetHashCode() & Interaksjon.GetHashCode();
        }
    }
}
